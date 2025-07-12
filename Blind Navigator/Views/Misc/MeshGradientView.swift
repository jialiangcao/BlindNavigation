//
//  MeshGradientView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 7/12/25.
//

import SwiftUI

enum MeshGradientState {
    case base
    case shiftUp
}

struct MeshGradientView: View {
    @Binding var animationState: MeshGradientState

    @State private var colors: [Color] = [
        Color(UIColor.systemBackground), Color(UIColor.systemBackground), Color(UIColor.systemBackground),
        
        Color.blue, Color.blue, Color.blue,
        
        Color.green, Color.green, Color.green,
    ]

    let points: [SIMD2<Float>] = [
        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
        [0.0, 0.8], [0.8, 0.4], [1.0, 0.6],
        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
    ]

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: points,
            colors: colors
        )
        .ignoresSafeArea()
        .onChange(of: animationState) {
            if animationState == .shiftUp {
                withAnimation(.easeInOut(duration: 0.5)) {
                    shiftColorsUp()
                }
            }
        }
    }

    func shiftColorsUp() {
        colors.removeFirst(3)
        colors.append(.mint)
        colors.append(.mint)
        colors.append(.mint)
    }
}

#Preview {
    @Previewable @State var meshState: MeshGradientState = .base
    MeshGradientView(animationState: $meshState)
    Button("Animate", action: {
        meshState = .shiftUp
    })
}
