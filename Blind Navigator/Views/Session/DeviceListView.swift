//
//  DeviceListView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 7/1/25.
//

import SwiftUI
import MetaWear

struct DeviceListView: View {
    @EnvironmentObject private var navigationViewModel: NavigationViewModel
    @ObservedObject var metaWearViewModel: MetaWearViewModel
    @StateObject private var deviceList = DeviceListUseCase()
    @State private var savePhase: SaveOverlayPhase = .hidden
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            SaveStatusOverlay(phase: $savePhase)
            VStack(spacing: 0) {
                // Title
                HStack {
                    Button {
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut) {
                                navigationViewModel.setPreSessionView()
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.accentColor)
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                }
                
                Text("Select a MetaWear Device")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .padding()
                
                if deviceList.discoveredDevices.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No Devices Found")
                            .font(.title3.weight(.semibold))
                        Text("Please ensure Bluetooth is enabled and your MetaWear device is powered on.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.top, 60)
                    .transition(.opacity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(Array(deviceList.discoveredDevices), id: \.localBluetoothID) { device in
                                DeviceRow(
                                    device: device,
                                    isSelected: device.localBluetoothID == deviceList.selectedDevice?.localBluetoothID
                                )
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        deviceList.selectDevice(device)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .transition(.opacity)
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                Button("Confirm") {
                    Task {
                        await MainActor.run {
                            withAnimation(.easeInOut) {
                                savePhase = .loading
                            }
                        }
                        
                        if let device = deviceList.selectedDevice {
                            metaWearViewModel.setDevice(device)
                            metaWearViewModel.setupDevice()
                        } else {
                            metaWearViewModel.metaWear = nil
                        }
                        
                        await MainActor.run {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                savePhase = .success
                            }
                        }
                        
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        
                        await MainActor.run {
                            withAnimation(.easeInOut) {
                                navigationViewModel.setActiveSessionView()
                            }
                        }
                    }
                }
                .disabled(deviceList.selectedDevice == nil)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(deviceList.selectedDevice == nil ? Color.gray : Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal)
        }
        .onAppear { deviceList.onAppear() }
        .onDisappear { deviceList.onDisappear() }
        .animation(.easeInOut, value: deviceList.discoveredDevices)
    }
}

struct DeviceRow: View {
    let device: MetaWear
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(device.localBluetoothID.uuidString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
                    .imageScale(.large)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: isSelected ? Color.accentColor.opacity(0.15) : Color.clear, radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .animation(.spring(), value: isSelected)
    }
}

#Preview {
    DeviceListView(metaWearViewModel: MetaWearViewModel())
        .environmentObject(NavigationViewModel())
}
