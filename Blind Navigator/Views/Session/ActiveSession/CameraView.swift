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
        VStack {
            if (sessionViewModel.cameraSession != nil) {
                CameraPreview(session: sessionViewModel.cameraSession!)
                    .ignoresSafeArea()
            }
            
            Spacer()
            
            Button(isRecording ? "Stop Recording" : "Start Recording") {
                Task {
                    if (isRecording) {
                        sessionViewModel.stopRecording()
                    } else {
                        if (sessionViewModel.cameraSession == nil) {
                            await sessionViewModel.startCameraService()
                        }
                        sessionViewModel.startRecording()
                    }
                    isRecording.toggle()
                }
            }
            .padding()
            .background(isRecording ? Color.red : Color("accent"))
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(.bottom, 50)
    }
}

#Preview {
    CameraView(sessionViewModel: SessionViewModel())
}
