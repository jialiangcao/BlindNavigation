//
//  LocationService.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 5/29/25.
//

import CoreLocation
import UIKit

protocol LocationServiceDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocation, accuracy: CLLocationAccuracy)
}

// Abstracted CLLocationManager protocol for dependency injection
// Necessary to create a mock class for testing
protocol LocationManagerType: AnyObject {
    var delegate: CLLocationManagerDelegate? { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

extension CLLocationManager: LocationManagerType {}

final class LocationService: NSObject {
    weak var delegate: LocationServiceDelegate?
    private let clManager: LocationManagerType
    
    init(manager: LocationManagerType = CLLocationManager()) {
        self.clManager = manager
        super.init()
        self.clManager.delegate = self
        clManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startUpdating() {
        clManager.requestWhenInUseAuthorization()
        clManager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        clManager.stopUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        delegate?.didUpdateLocation(lastLocation, accuracy: lastLocation.horizontalAccuracy)
    }
}
