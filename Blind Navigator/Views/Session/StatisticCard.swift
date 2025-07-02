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
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.accentColor)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        .padding(.vertical, 2)
    }
}

#Preview {
    StatisticCard(
        title: "Sample",
        value: "42",
        icon: "heart.fill"
    )
}
