//
//  MetaWearViewModel.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 7/1/25.
//

import Foundation
import MetaWear
import Combine

protocol MetaWearDelegate: AnyObject {
    func didUpdateAccelerometerData(_ values: SIMD3<Float>)
}

final class MetaWearViewModel: ObservableObject {
    weak var delegate: MetaWearDelegate?
    var metaWear: MetaWear?
    private var cancellables = Set<AnyCancellable>()

    init() {
        
    }
    
    func setDevice(_ device: MetaWear) {
        metaWear = device
        print("Set device")
    }
    
    func setupDevice() {
        guard let metaWear = metaWear else {
            print("No MetaWear device")
            return
        }

        metaWear
            .publishWhenConnected()
            .first()
            .stream(.accelerometer(rate: .hz100, gravity: .g2))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { [weak self] data in
                self?.delegate?.didUpdateAccelerometerData(data.value)
            })
            .store(in: &cancellables)
    }

    func connectDevice() {
        guard let metaWear = metaWear else {
            print("No MetaWear device")
            return
        }

        metaWear.connect()
    }
    
    func disconnectDevice() {
        if (metaWear == nil) {
            print("No MetaWear device connected")
            return
        }
        metaWear!.disconnect()
    }
}
