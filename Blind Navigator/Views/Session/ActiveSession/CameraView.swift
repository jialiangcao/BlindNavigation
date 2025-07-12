//
//  CameraView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/11/25.
//

import SwiftUI

struct CameraView: View {
    @EnvironmentObject private var navigationViewModel: NavigationViewModel
    @ObservedObject var sessionViewModel: SessionViewModel
    
    @State private var saveOverlayPhase: SaveOverlayPhase = .hidden

    private func endSession() {
        saveOverlayPhase = .loading

        Task.detached(priority: .background) {
            await sessionViewModel.stopSession()
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    saveOverlayPhase = .successConfetti
                }
            }
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    saveOverlayPhase = .hidden
                    navigationViewModel.setStartSessionView()
                }
            }
        }
    }

    var body: some View {
        ZStack {
            SaveStatusOverlay(phase: $saveOverlayPhase)
            
            // Camera Preview
            VStack {
                if let session = sessionViewModel.cameraSession {
                    CameraPreview(session: session) {
                        sessionViewModel.isPreviewAttached = true
                    }
                    .ignoresSafeArea()
                } else {
                    Spacer()
                    
                    Image(systemName: "camera")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Camera Unavailable")
                        .font(.title3.weight(.semibold))
                    Text("Camera permissions may be disabled, end the session and try again.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
                
                Button(action: endSession) {
                    HStack(spacing: 10) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22, weight: .bold))
                        Text("End Session")
                            .font(.headline)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    CameraView(sessionViewModel: SessionViewModel(metaWearViewModel: MetaWearViewModel()))
        .environmentObject(NavigationViewModel())
}
