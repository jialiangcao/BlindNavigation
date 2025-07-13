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
    case failed
}

struct SaveStatusOverlay: View {
    @Binding var phase: SaveOverlayPhase
    @State private var showConfetti = false
    @State private var showIcon = false

    private var iconName: String {
        switch phase {
        case .success, .successConfetti:
            return "checkmark.circle.fill"
        case .failed:
            return "xmark.circle.fill"
        default:
            return ""
        }
    }
    
    private var iconGradient: LinearGradient {
        switch phase {
        case .success, .successConfetti:
            return LinearGradient(
                colors: [Color.blue, Color.green],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .failed:
            return LinearGradient(
                colors: [Color.red, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [Color.clear, Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

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
                        Text("Saving...")
                            .foregroundColor(.white)
                            .font(.headline)
                    } else {
                        if !iconName.isEmpty {
                            Image(systemName: iconName)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .overlay(iconGradient)
                                .mask(
                                    Image(systemName: iconName)
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                )
                                .scaleEffect(showIcon ? 1 : 0.5)
                                .onAppear {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                        showIcon = true
                                    }
                                }
                                .onDisappear {
                                    showIcon = false
                                }
                        }

                        Text(phase == .failed ? "Something went wrong." : "Saved successfully!")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
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
    @State private var phase: SaveOverlayPhase = .successConfetti

    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            SaveStatusOverlay(phase: $phase)
        }
    }
}
