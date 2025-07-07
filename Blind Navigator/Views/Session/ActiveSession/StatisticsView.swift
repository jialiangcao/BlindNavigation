//
//  StatisticsView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/11/25.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var navigationViewModel: NavigationViewModel
    @ObservedObject var sessionViewModel: SessionViewModel

    private func endSession() {
        Task {
            await sessionViewModel.stopSession()
            await MainActor.run {
                navigationViewModel.setStartSessionView()
            }
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
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 34)
                }
                .animation(.easeInOut, value: sessionViewModel.prediction)
                
                Spacer()
                
                // Floating End Session Button
                Button(action: endSession) {
                    HStack(spacing: 10) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22, weight: .bold))
                        Text("End Session")
                            .font(.headline)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    StatisticsView(sessionViewModel: SessionViewModel(metaWearViewModel: MetaWearViewModel()))
}
