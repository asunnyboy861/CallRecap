import Foundation
import AVFoundation
import SwiftUI
import Combine

@MainActor
class RecordingDetailViewModel: ObservableObject {
    @Published var selectedTab: DetailTab = .summary
    @Published var isPlaying = false
    @Published var playbackProgress: Double = 0
    @Published var currentTime: TimeInterval = 0
    @Published var totalDuration: TimeInterval = 0
    @Published var showExportSheet = false
    @Published var exportURL: URL?
    @Published var showShareSheet = false
    @Published var addingToReminders = false

    enum DetailTab: String, CaseIterable {
        case summary = "Summary"
        case transcript = "Transcript"
        case play = "Play"
    }

    private var audioPlayer: AVAudioPlayer?
    private let remindersService = RemindersService()
    private let dataManager = DataManager.shared

    let recording: Recording

    init(recording: Recording) {
        self.recording = recording
        self.totalDuration = recording.duration
    }

    func setupAudioPlayer() {
        let url = recording.audioFileURL
        guard FileManager.default.fileExists(atPath: url.path) else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            totalDuration = audioPlayer?.duration ?? recording.duration
        } catch {
            print("Audio player error: \(error)")
        }
    }

    func togglePlayback() {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            audioPlayer?.play()
            isPlaying = true
            startProgressTimer()
        }
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
        playbackProgress = totalDuration > 0 ? time / totalDuration : 0
    }

    func exportAs(format: ExportFormat) {
        guard let url = ExportService.exportRecording(recording, format: format) else { return }
        exportURL = url
        showShareSheet = true
    }

    func addActionItemsToReminders() {
        guard let summary = recording.summary, !summary.actionItems.isEmpty else { return }
        addingToReminders = true

        Task {
            let count = await remindersService.addReminders(summary.actionItems)
            addingToReminders = false
        }
    }

    private func startProgressTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            Task { @MainActor [weak self] in
                guard let self, self.isPlaying else { timer.invalidate(); return }
                self.currentTime = self.audioPlayer?.currentTime ?? 0
                self.playbackProgress = self.totalDuration > 0 ? self.currentTime / self.totalDuration : 0

                if let player = self.audioPlayer, !player.isPlaying {
                    self.isPlaying = false
                    self.playbackProgress = 0
                    self.currentTime = 0
                    timer.invalidate()
                }
            }
        }
    }

    var formattedCurrentTime: String {
        let minutes = Int(currentTime) / 60
        let seconds = Int(currentTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedTotalDuration: String {
        let minutes = Int(totalDuration) / 60
        let seconds = Int(totalDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var currentSegmentIndex: Int? {
        guard let segments = recording.segments else { return nil }
        for (index, segment) in segments.enumerated() {
            if currentTime >= segment.startTime && currentTime < segment.endTime {
                return index
            }
        }
        return nil
    }
}
