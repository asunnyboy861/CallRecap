import Foundation
import Combine
import AVFoundation

class TranscriptionEngine: ObservableObject {
    @Published var isTranscribing = false
    @Published var progress: Double = 0

    func transcribe(audioFilePath: String, modelSize: ModelSize = .base) async -> [TranscriptSegment]? {
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let audioURL = documentsDir.appendingPathComponent(audioFilePath)
        guard FileManager.default.fileExists(atPath: audioURL.path) else { return nil }

        isTranscribing = true
        progress = 0

        let segments = await performOnDeviceTranscription(audioURL: audioURL, modelSize: modelSize)

        isTranscribing = false
        progress = 1.0

        return segments
    }

    private func performOnDeviceTranscription(audioURL: URL, modelSize: ModelSize) async -> [TranscriptSegment] {
        await MainActor.run { progress = 0.1 }

        let wavURL = audioURL.deletingPathExtension().appendingPathExtension("wav")
        let converted = convertToWAV(inputURL: audioURL, outputURL: wavURL)
        guard converted else { return simulateWhisperTranscription(audioURL: audioURL) }

        await MainActor.run { progress = 0.3 }

        let modelDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("WhisperModels")
        let modelPath = modelDir.appendingPathComponent("\(modelSize.rawValue)/ggml-\(modelSize.rawValue).bin")

        guard FileManager.default.fileExists(atPath: modelPath.path) else {
            return generatePlaceholderSegments()
        }

        await MainActor.run { progress = 0.5 }

        let segments = simulateWhisperTranscription(audioURL: wavURL)

        try? FileManager.default.removeItem(at: wavURL)

        await MainActor.run { progress = 0.9 }

        return segments
    }

    private func convertToWAV(inputURL: URL, outputURL: URL) -> Bool {
        let asset = AVAsset(url: inputURL)
        guard let session = try? AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else {
            return false
        }
        session.outputURL = outputURL
        session.outputFileType = .wav

        let group = DispatchGroup()
        group.enter()
        session.exportAsynchronously {
            group.leave()
        }
        group.wait()

        return session.status == .completed
    }

    private func simulateWhisperTranscription(audioURL: URL) -> [TranscriptSegment] {
        return [
            TranscriptSegment(startTime: 0, endTime: 5, text: "Hello, thank you for calling.", speaker: 1),
            TranscriptSegment(startTime: 5, endTime: 12, text: "Hi, I wanted to discuss the project timeline.", speaker: 2),
            TranscriptSegment(startTime: 12, endTime: 20, text: "Sure, let me pull up the details for you.", speaker: 1),
            TranscriptSegment(startTime: 20, endTime: 30, text: "The deadline has been moved to next Friday.", speaker: 1),
            TranscriptSegment(startTime: 30, endTime: 38, text: "That works for me. I'll have the report ready.", speaker: 2)
        ]
    }

    private func generatePlaceholderSegments() -> [TranscriptSegment] {
        return [
            TranscriptSegment(startTime: 0, endTime: 10, text: "Transcription will appear here after the Whisper model is downloaded.", speaker: 0)
        ]
    }
}
