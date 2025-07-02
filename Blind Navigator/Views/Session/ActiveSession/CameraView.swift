//
//  CameraView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/11/25.
//

import SwiftUI

struct CameraView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    @State private var isRecording = false
    
    var body: some View {
        ZStack {
            // Camera Preview
            if let session = sessionViewModel.cameraSession {
                CameraPreview(session: session)
                    .ignoresSafeArea()
            } else {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "camera")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Camera Unavailable")
                        .font(.title3.weight(.semibold))
                    Text("Recording is off or camera permissions are disabled.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            VStack {
                Spacer()
                Button(action: {
                    Task {
                        if isRecording {
                            sessionViewModel.stopRecording()
                        } else {
                            if sessionViewModel.cameraSession == nil {
                                await sessionViewModel.startCameraService()
                            }
                            sessionViewModel.startRecording()
                        }
                        isRecording.toggle()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: isRecording ? "stop.circle.fill" : "record.circle.fill")
                            .font(.system(size: 32, weight: .bold))
                        Text(isRecording ? "Stop Recording" : "Start Recording")
                            .font(.headline)
                            .bold()
                    }
                    .padding(.vertical, 18)
                    .frame(maxWidth: .infinity)
                    .background(isRecording ? Color.red : Color("accent"))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 36)
            }
        }
        .animation(.easeInOut, value: isRecording)
    }
}

#Preview {
    CameraView(sessionViewModel: SessionViewModel(metaWearViewModel: MetaWearViewModel()))
}
