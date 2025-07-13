//
//  DeviceListUseCase.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 7/1/25.
//

import Foundation
import MetaWear
import MetaWearSync
import Combine

class DeviceListUseCase: ObservableObject {
    @Published private(set) var discoveredDevices: Set<MetaWear> = []
    @Published var selectedDevice: MetaWear? = nil

    private var cancellables = Set<AnyCancellable>()
    private weak var scanner: MetaWearScanner?
    private var discoverySub: AnyCancellable? = nil

    init(scanner: MetaWearScanner = MetaWearScanner()) {
        self.scanner = scanner
    }
}

extension DeviceListUseCase {
    func onAppear() {
        scanner?.retrieveConnectedMetaWears()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] devices in
                for device in devices {
                    self?.discoveredDevices.insert(device)

                    if (self?.selectedDevice == nil) {
                        self?.selectedDevice = device
                    }
                }
            }
            .store(in: &cancellables)

        scanner?.startScan(higherPerformanceMode: true)
        
        discoverySub = scanner?.didDiscover
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                self?.discoveredDevices.insert(device)
                
                if (self?.selectedDevice == nil) {
                    self?.selectedDevice = device
                }
        }
    }

    func onDisappear() {
        scanner?.stopScan()
    }
    
    func selectDevice(_ device: MetaWear) {
        selectedDevice = device
    }
}
