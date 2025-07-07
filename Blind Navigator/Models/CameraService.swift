//
//  CameraService.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/11/25.
//

import AVFoundation

final class CameraService: NSObject, AVCaptureFileOutputRecordingDelegate {
    private let storageService: StorageServiceType
    private let outputURL: URL
    private var videoOutput = AVCaptureMovieFileOutput()
    private var recordingFinishedContinuation: CheckedContinuation<Void, Never>?
    var captureSession: AVCaptureSession

    func checkAuthorization() async -> Bool {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let audioStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        
        var videoGranted = videoStatus == .authorized
        var audioGranted = audioStatus == .authorized
        
        if videoStatus == .notDetermined || videoStatus == .denied || videoStatus == .restricted {
            videoGranted = await AVCaptureDevice.requestAccess(for: .video)
        }
        
        if audioStatus == .notDetermined || audioStatus == .denied || audioStatus == .restricted {
            audioGranted = await AVCaptureDevice.requestAccess(for: .audio)
        }
        
        return videoGranted && audioGranted
    }
    
    init(storageService: StorageServiceType, fileDate: String) {
        self.storageService = storageService
        self.captureSession = AVCaptureSession()
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.outputURL = documents.appendingPathComponent("video-" + fileDate + ".mov")
    }
    
    func createCaptureSession() async {
        guard await checkAuthorization() else { return }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .medium // For battery and file size, low is too blurry
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
              captureSession.canAddInput(audioInput) else {
            fatalError("Can't add audio input")
        }
        captureSession.addInput(audioInput)
        
        // TODO: Show errors on screen
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
        
        guard captureSession.canAddOutput(videoOutput) else {
            print("Error setting camera video output")
            return
        }
        captureSession.addOutput(videoOutput)
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    func getCaptureSession() -> AVCaptureSession {
        return captureSession
    }
    
    func startRecording() {
        guard !videoOutput.isRecording else {
            print("VideoOutput is already recording")
            return
        }
        
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    func stopRecording() async {
        guard videoOutput.isRecording else {
            print("No recording session to stop")
            return
        }
        
        await withCheckedContinuation { continuation in
            self.recordingFinishedContinuation = continuation
            videoOutput.stopRecording()
        }
    }
}

extension CameraService {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording error: \(error.localizedDescription)")
        } else {
            storageService.saveFileOnDevice(originalURL: outputFileURL)
        }
        
        recordingFinishedContinuation?.resume()
        recordingFinishedContinuation = nil
    }
}
