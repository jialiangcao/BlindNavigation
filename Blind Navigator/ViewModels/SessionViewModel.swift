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
    @Published var locationAccuracy: CLLocationAccuracy?
    @Published var decibelLevel: Int?
    @Published var prediction: String?
    @Published var cameraSession: AVCaptureSession?
    @Published var accelerometerValues: SIMD3<Float>?
    
    private let authViewModel: AuthViewModelType
    private let storageService: StorageServiceType
    private let locationService: LocationService
    private var audioService: AudioService
    private let predictionService: PredictionService
    private var cameraService: CameraService?
    private var metaWearViewModel: MetaWearViewModel
    
    private var fileURL: URL?
    private var sessionStartTime: TimeInterval = 0
    
    init(
        metaWearViewModel: MetaWearViewModel,
        authViewModel: AuthViewModelType = AuthViewModel(),
        storageService: StorageServiceType = StorageService(),
        locationService: LocationService = LocationService(),
        predictionService: PredictionService = PredictionService(),
    ) {
        self.metaWearViewModel = metaWearViewModel
        self.authViewModel = authViewModel
        self.storageService = storageService
        self.locationService = locationService
        self.predictionService = predictionService
        self.audioService = AudioService(authViewModel: authViewModel, storageService: storageService)

        super.init()

        self.metaWearViewModel.delegate = self
        self.locationService.delegate = self
        self.audioService.delegate = self
        self.predictionService.delegate = self
        startSession()
    }
    
    deinit {
        stopSession()
    }
    
    func startSession() {
        sessionStartTime = Date().timeIntervalSince1970
        do {
            let headers = "Timestamp,Elapsed Time,x-coordinate,y-coordinate,z-coordinate,latitude,longitude,prediction\n"
            let date = Date()
            let now = Constants.globalFormatter.string(from: date)
            fileURL = try storageService.createCSVFile(sessionId: "\(now)", headers: headers)
        } catch {
            print("Failed to create CSV file: \(error)")
        }
        
        locationService.startUpdating()
        audioService.startRecording()
    }
    
    func stopSession() {
        locationService.stopUpdating()
        audioService.stopRecording()
        storageService.closeFile()
        storageService.saveFileOnDevice(originalURL: fileURL!)
    }
    
    func startCameraService() async {
        self.cameraService = CameraService(storageService: storageService)
        guard cameraService != nil else {
            print("SessionViewModel: Error creating cameraService")
            return
        }
        
        await cameraService!.createCaptureSession()
        // Needs to run on the main thread because cameraSession is @Published
        await MainActor.run {
            cameraSession = cameraService!.getCaptureSession()
        }
    }
    
    func startRecording() {
        cameraService?.startRecording()
    }
    
    func stopRecording() {
        cameraService?.stopRecording()
    }
    
    private func logCurrentData() {
        guard let fileURL = fileURL, let userLocation = userLocation else {
            return
        }
        
        let date = Date()
        let now = Constants.globalFormatter.string(from: date)
        let elapsed = Date().timeIntervalSince1970 - sessionStartTime
        
        let latitude = userLocation.latitude
        let longitude = userLocation.longitude
        
        let predictionStr = prediction ?? "Disabled"
        
        let row = "\(now),\(elapsed),\(accelerometerValues!.x),\(accelerometerValues!.y),\(accelerometerValues!.z),\(latitude),\(longitude),\(predictionStr)\n"
        
        do {
            try storageService.append(row: row, to: fileURL)
        } catch {
            print("Failed to append row to CSV: \(error)")
        }
    }
    
}

extension SessionViewModel: LocationServiceDelegate {
    func didUpdateLocation(_ location: CLLocation, accuracy: CLLocationAccuracy) {
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
}
