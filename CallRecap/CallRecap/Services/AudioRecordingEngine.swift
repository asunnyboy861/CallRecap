import Foundation
import AVFoundation
import Combine

class AudioRecordingEngine: ObservableObject {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var audioLevel: Float = 0

    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var recordingStartTime: Date?
    private var timer: Timer?
    private var currentFilePath: String?

    var currentRecordingURL: URL? {
        guard let path = currentFilePath else { return nil }
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDir.appendingPathComponent(path)
    }

    func startRecording(quality: AudioQuality = .high) -> String? {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM/dd-HH-mm-ss"
        let fileName = dateFormatter.string(from: Date())
        let filePath = "Recordings/\(fileName).m4a"

        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let recordingsDir = documentsDir.appendingPathComponent("Recordings")
        let yearMonthDir = recordingsDir.appendingPathComponent(String(fileName.prefix(7)))

        do {
            try FileManager.default.createDirectory(at: yearMonthDir, withIntermediateDirectories: true)
        } catch {
            return nil
        }

        let fileURL = documentsDir.appendingPathComponent(filePath)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: quality.sampleRate,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: quality.bitRate
        ]

        do {
            audioFile = try AVAudioFile(forWriting: fileURL, settings: settings)
        } catch {
            return nil
        }

        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine,
              let inputNode = audioEngine.inputNode as? AVAudioInputNode else { return nil }

        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
            try? self?.audioFile?.write(from: buffer)
            if let channelData = buffer.floatChannelData?[0] {
                let frameLength = Int(buffer.frameLength)
                var sum: Float = 0
                for i in 0..<frameLength {
                    sum += abs(channelData[i])
                }
                let avg = sum / Float(frameLength)
                DispatchQueue.main.async {
                    self?.audioLevel = avg
                }
            }
        }

        do {
            try audioEngine.start()
        } catch {
            return nil
        }

        currentFilePath = filePath
        isRecording = true
        recordingStartTime = Date()
        startTimer()

        return filePath
    }

    func stopRecording() -> (filePath: String, duration: TimeInterval)? {
        guard isRecording else { return nil }

        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioFile = nil

        let duration = recordingDuration
        let filePath = currentFilePath

        isRecording = false
        audioLevel = 0
        recordingDuration = 0
        timer?.invalidate()
        timer = nil
        currentFilePath = nil
        recordingStartTime = nil

        guard let path = filePath else { return nil }
        return (path, duration)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let start = self?.recordingStartTime else { return }
            self?.recordingDuration = Date().timeIntervalSince(start)
        }
    }
}
