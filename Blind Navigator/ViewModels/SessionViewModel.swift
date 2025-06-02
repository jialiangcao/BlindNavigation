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
    @Published var decibelLevel: Float?
    @Published var prediction: String?
    
    private let authVM: AuthViewModel
    private let locationService: LocationService
    private let audioService: AudioService
    private let predictionService: PredictionService
    
    override init() {
        self.authVM = AuthViewModel()
        self.locationService = LocationService()
        self.audioService = AudioService(authViewModel: authVM)
        self.predictionService = PredictionService()
        
        super.init()
        locationService.delegate = self
        audioService.delegate = self
        predictionService.delegate = self
        startSession()
    }
    
    deinit {
        stopSession()
    }
    
    func startSession() {
        locationService.startUpdating()
        audioService.startRecording()
    }
    
    func stopSession() {
        locationService.stopUpdating()
        audioService.stopRecording()
    }
}

extension SessionViewModel: LocationServiceDelegate {
    func didUpdateLocation(_ location: CLLocation, accuracy: CLLocationAccuracy) {
        userLocation = location.coordinate
        locationAccuracy = accuracy
    }
}

extension SessionViewModel: AudioServiceDelegate {
    func didProcessAudio(_ spectrogram: [[[Double]]]) {
        self.predictionService.processSpectrogram(spectrogram)
    }
        
    func didUpdateDecibelLevel(_ decibels: Float) {
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
