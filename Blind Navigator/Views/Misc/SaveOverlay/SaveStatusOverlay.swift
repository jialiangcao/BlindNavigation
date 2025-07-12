//
//  SaveStatusOverlay.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 7/10/25.
//

import SwiftUI

enum SaveOverlayPhase {
    case hidden
    case loading
    case success
    case successConfetti
}

struct SaveStatusOverlay: View {
    @Binding var phase: SaveOverlayPhase
    @State private var showConfetti = false
    @State private var showCheckmark = false

    var body: some View {
        if phase != .hidden {
            ZStack {
                Color.black.opacity(0.4).ignoresSafeArea()

                if showConfetti {
                    ConfettiView()
                        .transition(.opacity)
                }

                VStack(spacing: 16) {
                    if phase == .loading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                    } else if phase == .success || phase == .successConfetti {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .foregroundColor(.green)
                            .frame(width: 60, height: 60)
                            .scaleEffect(showCheckmark ? 1 : 0.5)
                            .opacity(showCheckmark ? 1 : 0)
                            .onAppear {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                    showCheckmark = true
                                }
                            }
                            .onDisappear {
                                showCheckmark = false
                            }
                    }

                    Text(phase == .loading ? "Saving..." : "Saved successfully!")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .padding(24)
                .background(Color(.systemGray6).opacity(0.9))
                .cornerRadius(16)
                .shadow(radius: 10)
            }
            .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            .zIndex(2)
            .onChange(of: phase) {
                if phase == .successConfetti {
                    triggerCelebration()
                }
            }
        }
    }

    private func triggerCelebration() {
        withAnimation(.easeOut(duration: 0.5)) {
            showConfetti = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showConfetti = false
            }
        }
    }
}

#Preview {
    SaveStatusOverlayPreviewWrapper()
}

private struct SaveStatusOverlayPreviewWrapper: View {
    @State private var phase: SaveOverlayPhase = .loading

    var body: some View {
        ZStack {
            SaveStatusOverlay(phase: $phase)
        }
        .padding()
    }
}
