import Foundation
import SwiftUI
import Combine

@MainActor
class RecordingListViewModel: ObservableObject {
    @Published var recordings: [Recording] = []
    @Published var searchText = ""
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0

    private let dataManager = DataManager.shared
    private let audioEngine = AudioRecordingEngine()
    private let callDetection = CallDetectionService()
    private let transcriptionEngine = TranscriptionEngine()
    private let summaryEngine = SummaryEngine()

    var groupedRecordings: [(String, [Recording])] {
        let groups = Dictionary(grouping: recordings) { $0.dateGroup }
        let order = ["Today", "Yesterday", "This Week", "Earlier"]
        return groups.sorted { a, b in
            let ai = order.firstIndex(of: a.key) ?? 99
            let bi = order.firstIndex(of: b.key) ?? 99
            return ai < bi
        }
    }

    init() {
        loadRecordings()
        setupCallDetection()
    }

    func loadRecordings() {
        recordings = dataManager.fetchRecordings(searchText: searchText)
    }

    func startManualRecording() {
        guard let filePath = audioEngine.startRecording() else { return }
        isRecording = true

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self else { timer.invalidate(); return }
                self.recordingDuration = self.audioEngine.recordingDuration
                if !self.audioEngine.isRecording {
                    timer.invalidate()
                    self.isRecording = false
                    if let result = self.audioEngine.stopRecording() {
                        self.saveRecording(filePath: result.filePath, duration: result.duration, callType: "manual")
                    }
                }
            }
        }
    }

    func stopManualRecording() {
        if let result = audioEngine.stopRecording() {
            isRecording = false
            saveRecording(filePath: result.filePath, duration: result.duration, callType: "manual")
        }
    }

    private func saveRecording(filePath: String, duration: Double, callType: String, contactName: String? = nil) {
        let recording = dataManager.createRecording(
            filePath: filePath,
            duration: duration,
            contactName: contactName,
            callType: callType
        )
        loadRecordings()
        processRecording(recording)
    }

    private func processRecording(_ recording: Recording) {
        Task {
            if UserDefaults.standard.canTranscribe {
                let segments = await transcriptionEngine.transcribe(
                    audioFilePath: recording.filePath,
                    modelSize: ModelSize(rawValue: UserDefaults.standard.selectedModelSize) ?? .base
                )

                if let segments = segments {
                    let fullText = segments.map { $0.text }.joined(separator: " ")
                    recording.transcriptText = fullText
                    recording.setSegments(segments)
                    UserDefaults.standard.incrementTranscriptionUse()

                    let summary = await summaryEngine.generateSummary(transcriptText: fullText)
                    recording.setSummary(summary)
                    dataManager.save()
                    loadRecordings()
                }
            }
        }
    }

    private func setupCallDetection() {
        callDetection.setCallbacks(
            onStarted: { [weak self] info in
                Task { @MainActor in
                    self?.isRecording = true
                    if let filePath = self?.audioEngine.startRecording() {
                        self?.currentCallFilePath = filePath
                        self?.currentCallInfo = info
                    }
                }
            },
            onEnded: { [weak self] info in
                Task { @MainActor in
                    self?.isRecording = false
                    if let result = self?.audioEngine.stopRecording() {
                        self?.saveRecording(
                            filePath: result.filePath,
                            duration: result.duration,
                            callType: info.callType.rawValue,
                            contactName: info.contactName
                        )
                    }
                }
            }
        )
    }

    private var currentCallFilePath: String?
    private var currentCallInfo: CallInfo?

    func deleteRecording(_ recording: Recording) {
        dataManager.softDelete(recording)
        loadRecordings()
    }

    func toggleFavorite(_ recording: Recording) {
        dataManager.toggleFavorite(recording)
        loadRecordings()
    }
}
