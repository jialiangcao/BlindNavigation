//
//  DeviceList.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 7/1/25.
//

import SwiftUI
import MetaWear

struct DeviceListView: View {
    @ObservedObject var metaWearViewModel: MetaWearViewModel
    @StateObject private var deviceList = DeviceListUseCase()
    
    var body: some View {
        NavigationView {
            if (deviceList.discoveredDevices.isEmpty) {
                Text("No MetaWear devices found, please ensure you have enabled Bluetooth and the MetaWear device is powered on.")
            } else {
                List(Array(deviceList.discoveredDevices), id: \.localBluetoothID) { device in
                    Button {
                        deviceList.selectDevice(device)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(device.name)
                                    .font(.headline)
                                Text(device.localBluetoothID.uuidString)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if device.localBluetoothID == deviceList.selectedDevice?.localBluetoothID {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        Button("Confirm", action: {
                            print("Confirmed")
                            if let selected = deviceList.selectedDevice {
                                metaWearViewModel.setDevice(selected)
                                metaWearViewModel.setupDevice()
                                metaWearViewModel.connectDevice()
                            }
                        })
                        
                    }
                }
            }
        }
        .navigationTitle("MetaWear Devices")
        .onAppear {
            deviceList.onAppear()
        }
        .onDisappear {
            deviceList.onDisappear()
        }
    }
}

#Preview {
    DeviceListView(metaWearViewModel: MetaWearViewModel())
}
