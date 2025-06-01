//
//  AudioService.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 5/29/25.
//

import AVFoundation

protocol AudioServiceDelegate: AnyObject {
    func didProcessAudio(_ spectrogram: [[[Double]]])
    func didUpdateDecibelLevel(_ decibels: Float)
}

class AudioService: NSObject, AVAudioRecorderDelegate {
    weak var delegate: AudioServiceDelegate?
    private var engine: AVAudioEngine?
    private var recorder: AVAudioRecorder?
    private var buffer: [Float] = []
    private let requiredSize = Int(Constants.audioConfig.duration * Double(Constants.audioConfig.sampleRate))

    func startRecording() {
        setupAudioSession()
        setupRecorder()
        setupEngine()
    }
    
    func stopRecording() {
        engine?.stop()
        recorder?.stop()
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
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        recorder = try? AVAudioRecorder(url: url, settings: settings)
        recorder?.delegate = self
        recorder?.prepareToRecord()
        recorder?.record()
    }
    
    private func setupEngine() {
        engine = AVAudioEngine()
        let inputNode = engine?.inputNode
        let format = inputNode?.inputFormat(forBus: 0)
        
        // Testing higher buffer size, was on 1024 before
        inputNode?.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak self] buffer, _ in
            self?.processBuffer(buffer)
        }
        
        try? engine?.start()
    }
    
    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let newData = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        self.buffer += newData
        checkBuffer()
        updateDecibelLevel(data: newData)
    }
    
    private func checkBuffer() {
        guard buffer.count >= requiredSize else { return }
        
        let dataToSend = Array(buffer.suffix(requiredSize))
        buffer.removeAll()
        let dataToDouble = dataToSend.map { Double($0) }
        let bufferMemory = dataToDouble.withUnsafeBytes { Data($0) }
        postAudio(bufferMemory)
    }
    
    private func postAudio (_ bufferData: Data) {
        var request = URLRequest(url: Constants.localURL!)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.httpBody = bufferData
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
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
    
    private func updateDecibelLevel(data: [Float]) {
        let rms = sqrt(data.reduce(0) { $0 + pow($1, 2)} / Float(data.count))
        let decibels = 20 * log10(rms / 0.00002)
        delegate?.didUpdateDecibelLevel(decibels.rounded())
    }
}
