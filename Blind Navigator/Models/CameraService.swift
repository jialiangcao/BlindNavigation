//
//  CameraService.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/11/25.
//

import AVFoundation

final class CameraService/*: NSObject, AVCaptureFileOutputRecordingDelegate */{
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
    private var videoOutput = AVCaptureMovieFileOutput()
    private var outputURL: URL?
    private let formatter = DateFormatter()

    init () async {
        self.captureSession = AVCaptureSession()
        setupSuccess = await setUpCaptureSession()
        guard setupSuccess == true else {
            print("Error creating capture session")
            return
        }
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
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
        
        guard captureSession.canAddOutput(videoOutput) else {
            print("Error setting camera video output")
            return false
        }
        captureSession.addOutput(videoOutput)

        captureSession.commitConfiguration()
        return true
    }
    
    func getCaptureSession() -> AVCaptureSession {
        return captureSession
    }
    
    func startSession() {
        guard setupSuccess == true, !videoOutput.isRecording else {
            print("CameraService failed setup or videoOutput is not recording")
            return
        }
                
        let date = Date()
        let now = formatter.string(from: date)
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documents.appendingPathComponent("video-"+"\(now)")
        
        // videoOutput.startRecording(to: outputURL, recordingDelegate: self)
        captureSession.startRunning()
    }
    
    func stopSession() {
        guard setupSuccess == true, videoOutput.isRecording else {
            print("No recording session to stop")
            return
        }
        videoOutput.stopRecording()
        captureSession.stopRunning()
    }
}

/*extension CameraService: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording error: \(error.localizedDescription)")
        } else {
            print("Video saved to: \(outputFileURL)")
        }
    }
}*/
