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
    @Published var decibelLevel: Float? = 0
    
    private let locationService = LocationService()
    private let audioService = AudioService()
    
    override init() {
        super.init()
        locationService.delegate = self
        audioService.delegate = self
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
        //self.mlPredictor.processSpectrogram(spectrogram)
    }
        
    func didUpdateDecibelLevel(_ decibels: Float) {
        DispatchQueue.main.async {
            self.decibelLevel = decibels
        }
    }
}
