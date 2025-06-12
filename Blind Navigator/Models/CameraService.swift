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
    var setupSuccess: Bool = false // Prevents crashing when running start/stopRecording() without a properly configured session

    init () async {
        self.captureSession = AVCaptureSession()
        setupSuccess = await setUpCaptureSession()
        guard setupSuccess == true else {
            print("Error creating capture session")
            return
        }
        startSession()
    }
    
    deinit {
        stopSession()
    }

    func setUpCaptureSession() async -> Bool {
        guard await isAuthorized else { return false }
        
        captureSession.beginConfiguration()
        
        // TODO: Show errors on screen
        // Will not work on a simulator or preview
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Error creating videoDevice")
            return false
        }
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice), captureSession.canAddInput(videoDeviceInput) != false else {
            print("Error setting videoDeviceInput")
            return false
        }
        
        captureSession.addInput(videoDeviceInput)
        captureSession.commitConfiguration()
        return true
    }
    
    func getCaptureSession() -> AVCaptureSession {
        return captureSession
    }
    
    func startSession() {
        captureSession.startRunning()
    }
    
    func stopSession() {
        guard setupSuccess == true else {
            print("No recording session")
            return
        }
        captureSession.stopRunning()
    }
}
