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
        if let service = sessionViewModel.cameraService {
                    CameraPreview(session: service.captureSession)
                        .ignoresSafeArea()
                }
                Button(isRecording ? "Stop Recording" : "Start Recording") {
                    Task {
                        if (isRecording) {
                            sessionViewModel.stopCameraService()
                        } else {
                            await sessionViewModel.startCameraService()
                        }
                        isRecording.toggle()
                    }
                }
                .padding()
                .background(isRecording ? Color.red : Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

    }
}

#Preview {
    CameraView(sessionViewModel: SessionViewModel())
}
