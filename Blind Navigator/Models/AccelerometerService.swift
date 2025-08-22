//
//  AccelerometerService.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 7/17/25.
//

import CoreMotion

protocol AccelerometerServiceDelegate: AnyObject {
    func didUpdateAccelerometerData(_ data: CMAcceleration)
}

final class AccelerometerService {
    weak var delegate: AccelerometerServiceDelegate?
    private let manager: CMMotionManager
    private var timer: Timer?
    
    init() {
        self.manager = CMMotionManager()
    }
    
    func startUpdating() {
        guard self.manager.isAccelerometerAvailable else {
            print("Device accelerometer unavailible")
            return
        }
        
        guard let delegate = delegate else {
            print("Delegate not set")
            return
        }
        
        self.manager.deviceMotionUpdateInterval = 1.0 / 100.0 // 100 Hz
        self.manager.startDeviceMotionUpdates(to: .main) { data, _ in
            guard let acc = data?.userAcceleration else { return }
            delegate.didUpdateAccelerometerData(acc)
        }
    }
    
    func stopUpdating() {
        self.manager.stopDeviceMotionUpdates()
    }
}
