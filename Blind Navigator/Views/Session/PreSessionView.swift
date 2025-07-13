//
//  PreSessionView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 7/13/25.
//

import SwiftUI

struct PreSessionView: View {
    @EnvironmentObject private var navigationViewModel: NavigationViewModel

    @AppStorage("preferPredictions") private var preferPredictions = false
    @AppStorage("caneType") private var caneType = "Unset"
    @AppStorage("weather") private var weather = "Unset"
    @AppStorage("testBed") private var testBed = "Unset"
    @AppStorage("areaCode") private var areaCode = 0
    
    private var settingsSections: [SettingsSection] {
        [
            SettingsSection(title: "Session", items: [
                SettingItem(
                    title: "Cane Type",
                    iconName: "pencil.tip",
                    iconColor: .green,
                    type: .picker($caneType, options: ["Roller_Marshmallow", "Marshmallow", "Roller_Ball", "Pencil", "Metal", "Ceramic"])
                ),
                SettingItem(
                    title: "Weather Conditions",
                    iconName: "cloud.sun.fill",
                    iconColor: .yellow,
                    type: .picker($weather, options: ["Clear", "Rainy", "Windy"])
                ),
                SettingItem(
                    title: "Test Bed",
                    iconName: "map",
                    iconColor: .orange,
                    type: .picker($testBed, options: ["BMCC", "VISIONS"])
                ),
                SettingItem(
                    title: "Area Code",
                    iconName: "number",
                    iconColor: .cyan,
                    type: .intPicker($areaCode, entries: 50)
                ),
                SettingItem(
                    title: "Predictions (Requires unlimited LTE)",
                    iconName: "waveform.and.mic",
                    iconColor: .blue,
                    type: .toggle($preferPredictions)
                )
            ])
        ]
    }
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut) {
                            navigationViewModel.setStartSessionView()
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

            SettingsView(sections: settingsSections)
            
            Button("Confirm") {
                navigationViewModel.setDeviceListView()
            }
            .disabled(areaCode == 0 || testBed == "Unset")
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                (areaCode == 0 || testBed == "Unset") ? Color.gray : Color.accentColor
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
            .buttonStyle(ScaleButtonStyle())
        }
    }
}

#Preview {
    PreSessionView()
        .environmentObject(NavigationViewModel())
}
