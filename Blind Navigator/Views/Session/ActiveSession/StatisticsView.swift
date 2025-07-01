//
//  StatisticsView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/11/25.
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    var endSession: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("STATISTICS")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    
                    StatisticCard(
                        title: "Prediction",
                        value: sessionViewModel.prediction ?? "Disabled",
                        icon: "waveform.path.ecg"
                    )
                    
                    StatisticCard(
                        title: "Decibels",
                        // Syntax necessary to avoid type inference error
                        value: sessionViewModel.decibelLevel.map { "\($0)"} ?? "Disabled",
                        icon: "speaker.wave.2.fill"
                    )
                    
                    StatisticCard(
                        title: "GPS Accuracy",
                        value: "\(sessionViewModel.locationAccuracy ?? 0) meters",
                        icon: "location.fill"
                    )
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal, 20)
                .padding(.top, 145)
                
                // End Session Button
                Button(action: endSession) {
                    Text("End Session")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.red)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .buttonStyle(ScaleButtonStyle())
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    StatisticsView(sessionViewModel: SessionViewModel(metaWearViewModel: MetaWearViewModel()), endSession: {})
        .preferredColorScheme(.dark)
}
