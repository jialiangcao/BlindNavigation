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

class LocationService: NSObject {
    weak var delegate: LocationServiceDelegate?
    private let clManager = CLLocationManager()
    
    override init() {
        super.init()
        clManager.delegate = self
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
