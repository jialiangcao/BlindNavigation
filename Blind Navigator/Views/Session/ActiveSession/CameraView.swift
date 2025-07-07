//
//  CameraView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/11/25.
//

import SwiftUI

struct CameraView: View {
    @ObservedObject var sessionViewModel: SessionViewModel
    
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
        }
    }
}

#Preview {
    CameraView(sessionViewModel: SessionViewModel(metaWearViewModel: MetaWearViewModel()))
}
