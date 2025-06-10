//
//  AudioService.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 5/29/25.
//

import AVFoundation

// Audio Engine abstraction
protocol AudioEngineType {
    var engineInputNode: AudioInputNodeType { get }
    // Renamed start() and stop() to avoid name conflicts
    func engineStart() throws
    func engineStop()
}

protocol AudioInputNodeType {
    func inputFormat(forBus bus: Int) -> AVAudioFormat
    func installTap(onBus bus: Int,
                    bufferSize: AVAudioFrameCount,
                    format: AVAudioFormat?,
                    block: @escaping (AVAudioPCMBuffer, AVAudioTime) -> Void)
}

// Recorder abstraction
protocol AudioRecorderType {
    var url: URL { get }
    var delegate: AVAudioRecorderDelegate? { get set }
    func prepareToRecord() -> Bool
    func record() -> Bool
    func stop()
}

// Networking abstraction
protocol URLSessionDataTaskType {
    func resume()
}

protocol URLSessionType {
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTaskType
}

// UserDefaults abstraction
protocol UserDefaultsType {
    func bool(forKey defaultName: String) -> Bool
}

// Other Services

protocol AudioServiceDelegate: AnyObject {
    func didProcessAudio(_ spectrogram: [[[Double]]])
    func didUpdateDecibelLevel(_ decibels: Int)
}

final class AudioService: NSObject, AVAudioRecorderDelegate {
    weak var delegate: AudioServiceDelegate?
    
    private var engine: AudioEngineType
    private var recorder: AudioRecorderType
    private let urlSession: URLSessionType
    private let userDefaults: UserDefaultsType
    private let authViewModel: AuthViewModelType
    private let storageService: StorageServiceType
    
    private var formatter: DateFormatter
    private let preferPredictions: Bool
    private var buffer: [Float] = []
    private var lastUpdateTime: TimeInterval = 0.0
    private let requiredSize = Int(Constants.audioConfig.duration * Double(Constants.audioConfig.sampleRate))
    var audioURL: String
    
    init(authViewModel: AuthViewModelType,
         storageService: StorageServiceType,
         engine: AudioEngineType = AVAudioEngine(),
         recorder: AudioRecorderType = {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: Constants.audioConfig.sampleRate,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        return try! AVAudioRecorder(url: url, settings: settings)
    }(),
         urlSession: URLSessionType = URLSession.shared,
         userDefaults: UserDefaultsType = UserDefaults.standard,
    ) {
        self.authViewModel = authViewModel
        self.storageService = storageService
        self.engine = engine
        self.recorder = recorder
        self.urlSession = urlSession
        self.userDefaults = userDefaults
        
        self.formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        self.audioURL = "audio-"+formatter.string(from: Date())
        
        self.preferPredictions = userDefaults.bool(forKey: "preferPredictions")
        
        super.init()
        self.recorder.delegate = self
    }
    
    func startRecording() {
        setupAudioSession()
        setupRecorder()
        setupEngine()
    }
    
    func stopRecording() {
        engine.engineStop()
        recorder.stop()
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileExtension = recorder.url.pathExtension
        let fullURL = audioURL + ".\(fileExtension)"
        let renamedURL = documentsDirectory.appendingPathComponent(fullURL)
        
        do {
            try FileManager.default.moveItem(at: recorder.url, to: renamedURL)
            storageService.saveFileOnDevice(originalURL: renamedURL)
        } catch {
            print("Failed to rename recording file: \(error.localizedDescription)")
        }
    }
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default)
        try? session.setActive(true)
        
        // Sets exteneral microphone as input device
        guard let availableInputs = session.availableInputs else {
            print("No available inputs found")
            return
        }
        for input in availableInputs {
            if input.portType == .usbAudio || input.portType == .headsetMic {
                do {
                    try session.setPreferredInput(input)
                    break
                } catch {
                    print("Error setting preferred input: \(error)")
                }
            }
        }
        
        // Sets built-in speakers as output device, NOT TESTED
        for out in session.currentRoute.outputs {
            if out.portType == .builtInSpeaker || out.portType == .bluetoothA2DP {
                do {
                    try session.overrideOutputAudioPort(.speaker)
                } catch {
                    print("Error setting preferred output: \(error)")
                }
            }
        }
    }
    
    private func setupRecorder() {
        guard recorder.prepareToRecord() == true else {
            print("Error preparing audio recording")
            return
        }
        
        guard recorder.record() == true else {
            print("Error starting audio recording")
            return
        }
    }
    
    private func setupEngine() {
        let inputNode = engine.engineInputNode
        let format = inputNode.inputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak self] buffer, _ in
            self?.processBuffer(buffer)
        }
        
        try? engine.engineStart()
    }
    
    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let newData = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        self.buffer += newData
        checkBuffer()
        
        // Timer because CPU intensive
        let currentTime = Date().timeIntervalSince1970
        if currentTime - lastUpdateTime >= 2.0 {
            updateDecibelLevel(data: newData)
            lastUpdateTime = currentTime
            self.buffer.removeAll() // Prevents unbounded growth
        }
    }
    
    // Checks and calls processing for API, which returns a prediction string
    private func checkBuffer() {
        guard buffer.count >= requiredSize && preferPredictions else { return }
        
        let dataToSend = Array(buffer.suffix(requiredSize))
        buffer.removeAll()
        // Coverting to Float16 to save data. Float 64 sends about ~0.673 mb, Float 16 sends ~0.15 mb.
        // Result is send back and processed as Float64
        let dataToDouble = dataToSend.map { Float16($0) }
        let bufferMemory = dataToDouble.withUnsafeBytes { Data($0) }
        postAudio(bufferMemory)
    }
    
    func postAudio (_ bufferData: Data) {
        guard let idToken = authViewModel.idToken else {
            print("No token available")
            return
        }
        
        var request = URLRequest(url: Constants.localURL!)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = bufferData
        
        // Notice using protocol, not URLSession
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                print("Self object does not exist, may have been deallocated")
                return
            }
            if let error = error {
                print("Error receiving mel spectrogram: ", error)
            } else if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let melSpectrogram = json["mel_spectrogram"] as? [[[Double]]] {
                        self.delegate?.didProcessAudio(melSpectrogram)
                    }
                } catch {
                    print("Error parsing JSON", error)
                }
            }
        }
        task.resume()
    }
    
    func updateDecibelLevel(data: [Float]) {
        guard !data.isEmpty else {
            delegate?.didUpdateDecibelLevel(0)
            print("Data is empty")
            return
        }
        
        let rms = sqrt(data.reduce(0) { $0 + pow($1, 2)} / Float(data.count))
        
        guard rms > 0 else {
            delegate?.didUpdateDecibelLevel(0)
            return
        }
        
        let decibels = 20 * log10(rms / 0.00002)
        
        if decibels.isFinite {
            delegate?.didUpdateDecibelLevel(Int(decibels))
        } else {
            delegate?.didUpdateDecibelLevel(0)
        }
    }
}

extension AVAudioEngine: AudioEngineType {
    var engineInputNode: AudioInputNodeType { return self.inputNode }
    func engineStart() throws { try self.start() }
    func engineStop() { self.stop() }
}

extension AVAudioInputNode: AudioInputNodeType {}

extension AVAudioRecorder: AudioRecorderType {}

extension URLSessionDataTask: URLSessionDataTaskType {}

extension URLSession: URLSessionType {
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) -> any URLSessionDataTaskType {
        return (self.dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask)
    }
}

extension UserDefaults: UserDefaultsType {}
