//
//  CameraPreview.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/11/25.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    let onPreviewAttached: (() -> Void)?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.main.async {
            onPreviewAttached?()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Empty for conformance
    }
}
