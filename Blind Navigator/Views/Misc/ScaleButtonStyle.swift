//
//  ScaleButtonStyle.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/2/25.
//

import SwiftUI

public struct ScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.3), value: configuration.isPressed)
    }
}

