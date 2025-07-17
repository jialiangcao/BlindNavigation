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
        
        self.manager.accelerometerUpdateInterval = 1.0 / 100.0 // 100 Hz
        self.manager.startAccelerometerUpdates()
        
        self.timer = Timer(fire: Date(), interval: (1.0/50.0),
                           repeats: true, block: { (timer) in
            if let data = self.manager.accelerometerData?.acceleration {
                delegate.didUpdateAccelerometerData(data)
            }
        })
        
        RunLoop.current.add(self.timer!, forMode: .default)
    }
    
    func stopUpdating() {
        self.manager.stopAccelerometerUpdates()
        self.timer?.invalidate()
        self.timer = nil
    }
}
