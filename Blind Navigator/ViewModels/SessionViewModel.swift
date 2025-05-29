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
    
    private let locationService = LocationService()
    
    override init() {
        super.init()
        locationService.delegate = self
        startSession()
    }
    
    deinit {
        stopSession()
    }
    
    func startSession() {
        locationService.startUpdating()
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
