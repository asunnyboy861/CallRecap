import SwiftUI

struct TranscriptView: View {
    let recording: Recording
    @ObservedObject var viewModel: RecordingDetailViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let segments = recording.segments, !segments.isEmpty {
                        ForEach(segments) { segment in
                            segmentRow(segment, index: segments.firstIndex(where: { $0.id == segment.id }) ?? 0)
                                .id(segment.id)
                        }
                    } else if let transcript = recording.transcriptText {
                        Text(transcript)
                            .font(.body)
                            .padding()
                    } else if recording.isTranscribing {
                        VStack(spacing: 12) {
                            ProgressView(value: recording.transcriptionProgress)
                            Text("Transcribing... \(Int(recording.transcriptionProgress * 100))%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(32)
                    } else {
                        noTranscriptView
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.currentSegmentIndex) { _, newIndex in
                if let index = newIndex, let segments = recording.segments, index < segments.count {
                    withAnimation {
                        proxy.scrollTo(segments[index].id, anchor: .center)
                    }
                }
            }
        }
    }

    private func segmentRow(_ segment: TranscriptSegment, index: Int) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(timeString(segment.startTime))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                if segment.speaker > 0 {
                    Text("Speaker \(segment.speaker)")
                        .font(.caption2.bold())
                        .foregroundStyle(speakerColor(segment.speaker))
                }
                Text(segment.text)
                    .font(.subheadline)
                    .highlighted(viewModel.currentSegmentIndex == index)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.seek(to: segment.startTime)
        }
    }

    private func speakerColor(_ speaker: Int) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
        return colors[speaker % colors.count]
    }

    private func timeString(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }

    private var noTranscriptView: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.bubble")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No Transcript Yet")
                .font(.headline)
            Text("Transcript will appear after processing.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(32)
    }
}

extension Text {
    func highlighted(_ isHighlighted: Bool) -> some View {
        self
            .padding(6)
            .background(isHighlighted ? Color.appPrimary.opacity(0.15) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
