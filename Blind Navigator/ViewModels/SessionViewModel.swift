//
//  SessionViewModel.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 5/28/25.
//

import SwiftUI
import CoreLocation
import CoreMotion
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
    
    // Note IMUValues contains accelerometer data from a MetaWear device's internal IMU while accelerometerValues contains accelerometer data from an IPhone's internal sensors
    @Published var IMUValues: SIMD3<Float>?
    @Published var isMetaWearConnected: Bool = false
    @Published var rssi: Int?

    @Published var accelerometerValues: CMAcceleration?
    
    @Published var isEnding: Bool = false
    
    private let accelerometerService: AccelerometerService
    private var audioService: AudioService
    private let authViewModel: AuthViewModelType
    private var cameraService: CameraService
    private let locationService: LocationService
    private var metaWearViewModel: MetaWearViewModel
    private let predictionService: PredictionService
    private let storageService: StorageServiceType
    
    private var IMUMonitorTimer: Timer?
    private var lastIMUValues: SIMD3<Float>?

    private var fileURL: URL? // Stores location and IMU data
    private var iphoneFileURL: URL? // Stores iPhone accelerometer data
    private var sessionStartTime: TimeInterval = 0
    private let fileDate: String

    init(
        authViewModel: AuthViewModelType = AuthViewModel(),
        locationService: LocationService = LocationService(),
        metaWearViewModel: MetaWearViewModel,
        predictionService: PredictionService = PredictionService(),
        storageService: StorageServiceType = StorageService(),
        accelerometerService: AccelerometerService = AccelerometerService()
    ) {
        self.fileDate = Constants.globalFormatter.string(from: Date())
        self.audioService = AudioService(authViewModel: authViewModel)
        self.authViewModel = authViewModel
        self.cameraService = CameraService(storageService: storageService, fileDate: fileDate)
        self.locationService = locationService
        self.metaWearViewModel = metaWearViewModel
        self.predictionService = predictionService
        self.storageService = storageService
        self.accelerometerService = accelerometerService
        
        super.init()
        
        self.cameraService.onRecordingError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.recordingError = errorMessage
            }
        }
        self.accelerometerService.delegate = self
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
            fileURL = try storageService.createCSVFile(sessionId: "metawear_\(fileDate)", headers: headers)
            iphoneFileURL = try storageService.createCSVFile(sessionId: "iphone_\(fileDate)", headers: "Timestamp,Elapsed Time,x-coordinate,y-coordinate,z-coordinate\n")
        } catch {
            print("Failed to create CSV file: \(error)")
        }
        
        isMetaWearConnected = metaWearViewModel.metaWear != nil
        
        accelerometerService.startUpdating()
        audioService.startRecording()
        locationService.startUpdating()
        metaWearViewModel.connectDevice()
        startIMUMonitor()
    }
    
    func stopSession() async {
        await MainActor.run {
            self.isEnding = true
        }

        accelerometerService.stopUpdating()
        audioService.stopRecording()
        locationService.stopUpdating()
        metaWearViewModel.disconnectDevice()
        storageService.closeAllFiles()
        storageService.saveFileOnDevice(originalURL: fileURL!)
        storageService.saveFileOnDevice(originalURL: iphoneFileURL!)
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
        guard let fileURL = fileURL, let iphoneFileURL = iphoneFileURL else {
            print("Cannot log data, no file URL")
            return
        }
        
        guard let userLocation = userLocation else {
            print("No location data")
            return
        }
        
        let now = Constants.globalFormatter.string(from: Date())
        let elapsed = Date().timeIntervalSince1970 - sessionStartTime

        let latitude = userLocation.latitude
        let longitude = userLocation.longitude
        
        let predictionStr = prediction ?? "Disabled"

        var IMURow = ""
        if let IMUValues = IMUValues {
            IMURow = "\(now),\(elapsed),\(IMUValues.x),\(IMUValues.y),\(IMUValues.z),\(latitude),\(longitude),\(predictionStr)\n"
        }
        
        var iphoneRow = ""
        if let accelerometerValues = accelerometerValues {
            iphoneRow = "\(now),\(elapsed),\(accelerometerValues.x),\(accelerometerValues.y),\(accelerometerValues.z)\n"
        }
                
        do {
            try storageService.append(row: IMURow, to: fileURL)
            try storageService.append(row: iphoneRow, to: iphoneFileURL)
        } catch {
            print("Failed to append row to CSV: \(error)")
        }
    }
    
    private func startIMUMonitor() {
        IMUMonitorTimer?.invalidate()

        IMUMonitorTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if let current = self.IMUValues, let last = self.lastIMUValues {
                if current == last {
                    DispatchQueue.main.async {
                        self.isMetaWearConnected = false
                    }
                    metaWearViewModel.connectDevice()
                } else {
                    DispatchQueue.main.async {
                        self.isMetaWearConnected = true
                    }
                }
            }

            self.lastIMUValues = self.IMUValues
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

extension SessionViewModel: AccelerometerServiceDelegate {
    func didUpdateAccelerometerData(_ data: CMAcceleration) {
        self.accelerometerValues = data
        if (self.isMetaWearConnected == false) {
            self.logCurrentData()
        }
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
        self.IMUValues = values
        self.logCurrentData()
    }
    
    func didUpdateRSSI(_ rssi: Int) {
        self.rssi = rssi
    }
    
    func didDisconnect() {
        self.isMetaWearConnected = false
    }
}
