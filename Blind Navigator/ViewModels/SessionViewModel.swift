//
//  SessionViewModel.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 5/28/25.
//

import SwiftUI
import CoreLocation

final class SessionViewModel: NSObject, ObservableObject {
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var locationAccuracy: CLLocationAccuracy?
    @Published var decibelLevel: Int?
    @Published var prediction: String?
    
    private let authVM: AuthViewModel
    private let locationService: LocationService
    private let audioService: AudioService
    private let predictionService: PredictionService
    private let storageService: StorageService
    
    private var fileURL: URL?
    private var sessionStartTime: TimeInterval = 0
    let formatter: DateFormatter
    
    override init() {
        self.authVM = AuthViewModel()
        self.locationService = LocationService()
        self.audioService = AudioService(authViewModel: authVM)
        self.predictionService = PredictionService()
        self.storageService = StorageService()
        
        self.formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        
        super.init()
        locationService.delegate = self
        audioService.delegate = self
        predictionService.delegate = self
    }
    
    func startSession() {
        sessionStartTime = Date().timeIntervalSince1970
        do {
            // CSV headers: timestamp, elapsed, latitude, longitude, prediction
            let headers = "timestamp,elapsed,latitude,longitude,prediction\n"
            fileURL = try storageService.createCSVFile(sessionId: "session_\(Int(sessionStartTime))", headers: headers)
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
        uploadSession { _ in }
    }
    
    private func logCurrentData() {
            guard let fileURL = fileURL, let userLocation = userLocation else {
                return
            }
        
            let date = Date()
            let now = formatter.string(from: date)
            let elapsed = Date().timeIntervalSince1970 - sessionStartTime
        
            let latitude = userLocation.latitude
            let longitude = userLocation.longitude
            
            let predictionStr = prediction ?? "Disabled"
            
            let row = "\(now),\(elapsed),\(latitude),\(longitude),\(predictionStr)\n"
            
            do {
                try storageService.append(row: row, to: fileURL)
            } catch {
                print("Failed to append row to CSV: \(error)")
            }
    }
    
    private func uploadSession(completion: @escaping (Result<URL, Error>) -> Void) {
        guard let fileURL = fileURL else {
            completion(.failure(NSError(domain: "No file to upload", code: 0)))
            return
        }
        let remotePath = "sessions/\(fileURL.lastPathComponent)"
        storageService.uploadFile(localFileURL: fileURL, remotePath: remotePath) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}

extension SessionViewModel: LocationServiceDelegate {
    func didUpdateLocation(_ location: CLLocation, accuracy: CLLocationAccuracy) {
        userLocation = location.coordinate
        locationAccuracy = accuracy
        self.logCurrentData()
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
