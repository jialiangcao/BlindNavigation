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
    
    override init() {
        super.init()
        startSession()
    }
    
    deinit {
        stopSession()
    }
    
    func startSession() {
    }
    
    func stopSession() {
    }
}
