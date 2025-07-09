//
//  NotificationPopup.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/4/25.
//

import SwiftUI

struct NotificationPopup: View {
    let title: String
    let systemIconName: String
    let backgroundColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemIconName)
                .font(.title2)
                .foregroundColor(.white)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(backgroundColor)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        .padding(.top, 16)
    }
}

#Preview {
    NotificationPopup(title: "Success", systemIconName: "checkmark.circle", backgroundColor: .green)
    NotificationPopup(title: "Failed", systemIconName: "checkmark.circle", backgroundColor: .red)
}

