//
//  ConfettiView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 7/10/25.
//

import SwiftUI

struct ConfettiView: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .pink]
    
    var body: some View {
        ZStack {
            ForEach(0..<40, id: \.self) { i in
                ConfettiPiece(color: colors.randomElement()!)
            }
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                let horizontalOffset = Double.random(in: -100...100)
                let upwardOffset = Double.random(in: -250 ... -150)
                let finalDrop = Double.random(in: 500...600)
                
                withAnimation(.interpolatingSpring(stiffness: 100, damping: 500)) {
                    offset = CGSize(width: horizontalOffset, height: upwardOffset)
                    rotation = Double.random(in: -25...25)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeIn(duration: 1.2)) {
                        offset = CGSize(width: horizontalOffset, height: finalDrop)
                    }
                }
            }
    }
}

#Preview {
    ConfettiView()
}
