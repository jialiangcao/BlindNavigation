//
//  SessionManager.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 5/28/25.
//

import CoreLocation

final class SessionManager: NSObject, ObservableObject {
    @Published var userLocation: CLLocationCoordinate2D?
    
    private let locationManager = CLLocationManager()
    
    // Lifecycle starts upon entering a session and ends upon leaving
    override init() {
        super.init()
        startSession()
    }
    
    deinit {
        stopSession()
    }
    
    func startSession() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopSession() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
}

extension SessionManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last?.coordinate
    }
}
