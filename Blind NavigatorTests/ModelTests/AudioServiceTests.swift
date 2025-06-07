//
//  AudioServiceTests.swift
//  Blind NavigatorTests
//
//  Created by Jialiang Cao on 6/7/25.
//

@testable import Blind_Navigator

import XCTest

import AVFoundation

class MockEngine: AudioEngineType {
    var engineStartCalled = false
    var engineStopCalled = false
    var engineInputNode: AudioInputNodeType = MockInputNode()
    
    func engineStart() throws { engineStartCalled = true }
    func engineStop() { engineStopCalled = true }
}

class MockInputNode: AudioInputNodeType {
    var tapInstalled = false
    var block: ((AVAudioPCMBuffer, AVAudioTime) -> Void)?
    
    func inputFormat(forBus bus: Int) -> AVAudioFormat {
        return AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
    }
    
    func installTap(onBus bus: Int, bufferSize: AVAudioFrameCount, format: AVAudioFormat?, block: @escaping (AVAudioPCMBuffer, AVAudioTime) -> Void) {
        tapInstalled = true
        self.block = block
    }
}

class MockRecorder: AudioRecorderType {
    var url = URL(fileURLWithPath: "/tmp/audio.m4a")
    var delegate: AVAudioRecorderDelegate?
    
    var prepareCalled = false
    var recordCalled = false
    var stopCalled = false
    var prepareReturn = true
    var recordReturn = true
    
    func prepareToRecord() -> Bool {
        prepareCalled = true
        return prepareReturn
    }
    
    func record() -> Bool {
        recordCalled = true
        return recordReturn
    }
    
    func stop() {
        stopCalled = true
    }
}

class MockSession: URLSessionType {
    var request: URLRequest?
    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    -> URLSessionDataTaskType {
        self.request = request
        self.completionHandler = completionHandler
        return DummyTask()
    }
    
    class DummyTask: URLSessionDataTaskType {
        func resume() {}
    }
}

class MockDefaults: UserDefaultsType {
    var store: [String: Bool] = [:]
    func bool(forKey defaultName: String) -> Bool {
        return store[defaultName] ?? false
    }
}

class MockAuth: AuthViewModelType {
    var idToken: String? = "mock-token"
}

class MockDelegate: AudioServiceDelegate {
    var decibelLevelUpdated: Int?
    var audioProcessed: [[[Double]]]?
    
    func didProcessAudio(_ spectrogram: [[[Double]]]) {
        audioProcessed = spectrogram
    }
    
    func didUpdateDecibelLevel(_ decibels: Int) {
        decibelLevelUpdated = decibels
    }
}

class MockStorageService: StorageServiceType {
    var savedURL: URL?
    
    // Empty functions for conformance
    func createCSVFile(sessionId: String, headers: String) throws -> URL {
        let url = URL(filePath: "mockPath")
        return url
    }
    
    func append(row: String, to fileURL: URL) throws {
    }
    
    func closeFile() {
    }
    
    func uploadFile(localFileURL: URL, remotePath: String, completion: @escaping (Result<URL, any Error>) -> Void) {
    }
    
    func fetchLocalHistory() -> [URL] {
        let url = URL(filePath: "mockPath")
        return [url]
    }
    
    func deleteFile(localFileURL: URL) {
    }
    
    func saveFileOnDevice(originalURL: URL) {
        savedURL = originalURL
    }
}

class AudioServiceTests: XCTestCase, AudioServiceDelegate {
    var audioService: AudioService!
    var mockRecorder: MockRecorder!
    var mockEngine: MockEngine!
    var mockSession: MockSession!
    var mockDefaults: MockDefaults!
    var mockAuth: MockAuth!
    var mockStorage: MockStorageService!
    var mockDelegate: MockDelegate!
    
    override func setUp() {
        mockRecorder = MockRecorder()
        mockEngine = MockEngine()
        mockSession = MockSession()
        mockDefaults = MockDefaults()
        mockAuth = MockAuth()
        mockStorage = MockStorageService()
        mockDelegate = MockDelegate()
        
        audioService = AudioService(authViewModel: mockAuth,
                                    storageService: mockStorage,
                                    engine: mockEngine,
                                    recorder: mockRecorder,
                                    urlSession: mockSession,
                                    userDefaults: mockDefaults)
        audioService.delegate = mockDelegate
    }
    
    func testStartRecordingSuccess() {
        mockDefaults.store["preferPredictions"] = true
        audioService.startRecording()
        
        XCTAssertTrue(mockRecorder.prepareCalled)
        XCTAssertTrue(mockRecorder.recordCalled)
        XCTAssertTrue(mockEngine.engineStartCalled)
    }
    
    func testStopRecordingMovesFileAndSaves() {
        let fileURL = mockRecorder.url
        FileManager.default.createFile(atPath: fileURL.path, contents: Data(), attributes: nil)
        
        audioService.stopRecording()
        
        XCTAssertTrue(mockRecorder.stopCalled)
        XCTAssertNotNil(mockStorage.savedURL)
        
        _ = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first!
        XCTAssertEqual(
            mockStorage.savedURL?.deletingPathExtension().lastPathComponent,
            audioService.audioURL
        )
        XCTAssertEqual(mockStorage.savedURL?.pathExtension, fileURL.pathExtension)
    }
    
    func testUpdateDecibelLevel() {
        let data: [Float] = Array(repeating: 0.1, count: 1000)
        audioService.updateDecibelLevel(data: data)
        
        let level = mockDelegate.decibelLevelUpdated
        XCTAssertNotNil(level)
        XCTAssertGreaterThan(level!, 0)
    }
    
    func testPostAudioSetsCorrectHeaders() {
        audioService.postAudio(Data())
        let request = mockSession.request
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Authorization"), "Bearer mock-token")
    }
    
    func testProcessBufferAppendsAndTriggerDecibel() {
        audioService.startRecording()
        let floatBuffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!, frameCapacity: 1024)!
        floatBuffer.frameLength = 1024
        floatBuffer.floatChannelData!.pointee.initialize(repeating: 0.2, count: 1024)
        
        guard let block = (mockEngine.engineInputNode as? MockInputNode)?.block else {
            XCTFail("Tap was never installed")
            return
        }
        block(floatBuffer, AVAudioTime(sampleTime: 0, atRate: 44100))
        
        XCTAssertNotNil(mockDelegate.decibelLevelUpdated)
        XCTAssertGreaterThan(mockDelegate.decibelLevelUpdated!, 0)
    }
    
    func testUpdateDecibelLevelWithNaN() {
        audioService.delegate = mockDelegate
        let data = Array(repeating: Float.nan, count: 100)
        audioService.updateDecibelLevel(data: data)
        XCTAssertEqual(mockDelegate.decibelLevelUpdated, 0)
    }
    
    // Empty functions for conformance
    func didProcessAudio(_ spectrogram: [[[Double]]]) {
    }
    
    func didUpdateDecibelLevel(_ decibels: Int) {
    }
}
