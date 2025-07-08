//
//  BannerNotificationView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 7/8/25.
//

import SwiftUI

struct BannerNotificationView: View {
    let systemImageName: String
    let message: String
    let backgroundColor: Color

    var body: some View {
        VStack {
            Spacer().frame(height: 0)
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: systemImageName)
                    .foregroundColor(.white)
                    .imageScale(.large)

                Text(message)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 22)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(backgroundColor)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
            )
            .padding(.top, 100)
            .padding(.horizontal, 24)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(1)
    }
}

