//
//  StatisticsView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/11/25.
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    
    func signalStrengthDescription(for rssi: Int) -> String {
        switch rssi {
        case -60...1:
            return "Excellent"
        case -70...(-61):
            return "Good"
        case -80...(-71):
            return "Fair"
        case -90...(-81):
            return "Poor"
        default:
            return "Unknown"
        }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Title
                Text("Session Statistics")
                    .font(.largeTitle.bold())
                    .padding(.top, 82)
                    .padding(.bottom, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        StatisticCard(
                            title: "Prediction",
                            value: sessionViewModel.prediction ?? "Disabled",
                            icon: "waveform.path.ecg"
                        )
                        StatisticCard(
                            title: "Decibels",
                            value: sessionViewModel.decibelLevel.map { "\($0)" } ?? "Disabled",
                            icon: "speaker.wave.2.fill"
                        )
                        StatisticCard(
                            title: "GPS Accuracy",
                            value: sessionViewModel.locationAccuracy != nil ? "\(sessionViewModel.locationAccuracy!) meters" : "Disabled",
                            icon: "location.fill"
                        )
                        StatisticCard(
                            title: "MetaWear Signal Strength",
                            value: signalStrengthDescription(for: sessionViewModel.rssi ?? -100),
                            icon: "wifi"
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 34)
                }
                .animation(.easeInOut, value: sessionViewModel.prediction)
                
                Spacer()
                
            }
        }
    }
}

#Preview {
    StatisticsView(sessionViewModel: SessionViewModel(metaWearViewModel: MetaWearViewModel()))
}
