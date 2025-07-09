//
//  SessionViewModel.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 5/28/25.
//

import SwiftUI
import CoreLocation
import AVFoundation

final class SessionViewModel: NSObject, ObservableObject {
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var userPath: [CLLocationCoordinate2D] = []
    @Published var locationAccuracy: Int?
    
    @Published var decibelLevel: Int?
    @Published var prediction: String?
    
    @Published var cameraSession: AVCaptureSession?
    @Published var recordingError: String? = nil
    @Published var isPreviewAttached = false
    
    @Published var accelerometerValues: SIMD3<Float>?
    @Published var isMetaWearConnected: Bool = false
    
    private var audioService: AudioService
    private let authViewModel: AuthViewModelType
    private var cameraService: CameraService
    private let locationService: LocationService
    private var metaWearViewModel: MetaWearViewModel
    private let predictionService: PredictionService
    private let storageService: StorageServiceType
    private let fileDate: String
    
    private var fileURL: URL?
    private var sessionStartTime: TimeInterval = 0
    
    init(
        authViewModel: AuthViewModelType = AuthViewModel(),
        locationService: LocationService = LocationService(),
        metaWearViewModel: MetaWearViewModel,
        predictionService: PredictionService = PredictionService(),
        storageService: StorageServiceType = StorageService()
    ) {
        self.fileDate = Constants.globalFormatter.string(from: Date())
        self.audioService = AudioService(authViewModel: authViewModel)
        self.authViewModel = authViewModel
        self.cameraService = CameraService(storageService: storageService, fileDate: fileDate)
        self.locationService = locationService
        self.metaWearViewModel = metaWearViewModel
        self.predictionService = predictionService
        self.storageService = storageService
        
        super.init()
        
        self.cameraService.onRecordingError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.recordingError = errorMessage
            }
        }
        self.audioService.delegate = self
        self.locationService.delegate = self
        self.metaWearViewModel.delegate = self
        self.predictionService.delegate = self
        startSession()
    }
    
    func startSession() {
        sessionStartTime = Date().timeIntervalSince1970
        do {
            let headers = "Timestamp,Elapsed Time,x-coordinate,y-coordinate,z-coordinate,latitude,longitude,prediction\n"
            fileURL = try storageService.createCSVFile(sessionId: "\(fileDate)", headers: headers)
        } catch {
            print("Failed to create CSV file: \(error)")
        }
        
        isMetaWearConnected = metaWearViewModel.metaWear != nil
        
        audioService.startRecording()
        locationService.startUpdating()
        metaWearViewModel.connectDevice()
    }
    
    func stopSession() async {
        audioService.stopRecording()
        locationService.stopUpdating()
        metaWearViewModel.disconnectDevice()
        storageService.closeFile()
        storageService.saveFileOnDevice(originalURL: fileURL!)
        await cameraService.stopRecording()
    }
    
    func startCameraService() async {
        await cameraService.createCaptureSession()
        // Needs to run on the main thread because cameraSession is @Published
        await MainActor.run {
            cameraSession = cameraService.getCaptureSession()
        }
    }
    
    func startRecording() {
        cameraService.startRecording()
    }
    
    private func logCurrentData() {
        guard let fileURL = fileURL, let userLocation = userLocation else {
            print("Cannot log data, no file URL")
            return
        }
        
        guard let accelerometerValues = accelerometerValues else {
            print("Accelerometer data is empty")
            return
        }
        
        let now = Constants.globalFormatter.string(from: Date())
        let elapsed = Date().timeIntervalSince1970 - sessionStartTime
        
        let latitude = userLocation.latitude
        let longitude = userLocation.longitude
        
        let predictionStr = prediction ?? "Disabled"
        
        let row = "\(now),\(elapsed),\(accelerometerValues.x),\(accelerometerValues.y),\(accelerometerValues.z),\(latitude),\(longitude),\(predictionStr)\n"
        
        do {
            try storageService.append(row: row, to: fileURL)
        } catch {
            print("Failed to append row to CSV: \(error)")
        }
    }
}

extension SessionViewModel: LocationServiceDelegate {
    func didUpdateLocation(_ location: CLLocation, accuracy: Int) {
        userLocation = location.coordinate
        userPath.append(location.coordinate)
        locationAccuracy = accuracy
    }
}

extension SessionViewModel: AudioServiceDelegate {
    func didProcessAudio(_ spectrogram: [[[Double]]]) {
        self.predictionService.processSpectrogram(spectrogram)
    }
    
    func didUpdateDecibelLevel(_ decibels: Int) {
        DispatchQueue.main.async {
            self.decibelLevel = decibels
        }
    }
}

extension SessionViewModel: PredictionServiceDelegate {
    func didReceivePrediction(_ prediction: String) {
        DispatchQueue.main.async {
            self.prediction = prediction
        }
    }
}

extension SessionViewModel: MetaWearDelegate {
    func didUpdateAccelerometerData(_ values: SIMD3<Float>) {
        self.accelerometerValues = values
        self.logCurrentData()
    }
    
    func didDisconnect() {
        self.isMetaWearConnected = false
    }
}
