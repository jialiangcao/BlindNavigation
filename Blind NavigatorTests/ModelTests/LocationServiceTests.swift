//
//  LocationServiceTests.swift
//  Blind NavigatorTests
//
//  Created by Jialiang Cao on 6/7/25.
//

@testable import Blind_Navigator

import CoreLocation
import XCTest

class MockLocationManager: LocationManagerType {
    var delegate: CLLocationManagerDelegate?
    var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
    
    var didRequestAuth = false
    var didStartUpdating = false
    var didStopUpdating = false
    
    func requestWhenInUseAuthorization() {
        didRequestAuth = true
    }
    
    func startUpdatingLocation() {
        didStartUpdating = true
    }
    
    func stopUpdatingLocation() {
        didStopUpdating = true
    }
    
    func simulateLocationUpdate(location: CLLocation) {
        delegate?.locationManager?(CLLocationManager(), didUpdateLocations: [location])
    }
}

class LocationServiceTests: XCTestCase, LocationServiceDelegate {
    var locationService: LocationService!
    var mockManager: MockLocationManager!
    var didReceiveLocation = false
    var receivedLocation: CLLocation?
    var receivedAccuracy: CLLocationAccuracy?
    
    override func setUp() {
        super.setUp()
        mockManager = MockLocationManager()
        locationService = LocationService(manager: mockManager)
        locationService.delegate = self
    }
    
    func testStartUpdatingCalls() {
        locationService.startUpdating()
        XCTAssertTrue(mockManager.didRequestAuth)
        XCTAssertTrue(mockManager.didStartUpdating)
    }
    
    func testStopUpdatingCalls() {
        locationService.stopUpdating()
        XCTAssertTrue(mockManager.didStopUpdating)
    }
    
    func testDelegateReceivesLocation() {
        let testLocation = CLLocation(latitude: 37.0, longitude: -122.0)
        mockManager.simulateLocationUpdate(location: testLocation)
        XCTAssertTrue(didReceiveLocation)
        XCTAssertEqual(receivedLocation?.coordinate.latitude, 37.0)
        XCTAssertEqual(receivedAccuracy, testLocation.horizontalAccuracy)
    }
    
    func testEmptyLocationsDoesNotCallDelegate() {
        mockManager.delegate?.locationManager?(CLLocationManager(), didUpdateLocations: [])
        XCTAssertFalse(didReceiveLocation)
    }
    
    func didUpdateLocation(_ location: CLLocation, accuracy: CLLocationAccuracy) {
        didReceiveLocation = true
        receivedLocation = location
        receivedAccuracy = accuracy
    }
}
