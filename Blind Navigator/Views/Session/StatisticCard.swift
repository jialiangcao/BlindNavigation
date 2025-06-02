//
//  StatisticsCardView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/2/25.
//

import SwiftUI

public struct StatisticCard: View {
        let title: String
        let value: String
        let icon: String
        
        public var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.cyan)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.cyan.opacity(0.12))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(value)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }

#Preview {
        StatisticCard(
            title: "Sample",
            value: "42",
            icon: "heart.fill"
        )
}
