//
//  CameraService.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/11/25.
//

import AVFoundation

final class CameraService {
    var captureSession: AVCaptureSession
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            var isAuthorized = status == .authorized
            
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }

    init () async {
        self.captureSession = AVCaptureSession()
        await setUpCaptureSession()
        startSession()
    }
    
    deinit {
        stopSession()
    }

    func setUpCaptureSession() async {
        guard await isAuthorized else { return }
        
        captureSession.beginConfiguration()
        
        let videoDevice: AVCaptureDevice?
        
        // Will not work on a simulator or preview
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Error creating videoDevice")
            return
        }
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice), captureSession.canAddInput(videoDeviceInput) != false else {
            print("Error setting videoDeviceInput")
            return
        }
        
        captureSession.addInput(videoDeviceInput)
        captureSession.commitConfiguration()
    }
    
    func startSession() {
        captureSession.startRunning()
    }
    
    func stopSession() {
        captureSession.stopRunning()
    }
}
