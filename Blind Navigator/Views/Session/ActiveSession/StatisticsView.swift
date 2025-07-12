//
//  StatisticsView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/11/25.
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    
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
