import SwiftUI

struct RecordingDetailView: View {
    let recording: Recording
    @StateObject private var viewModel: RecordingDetailViewModel

    init(recording: Recording) {
        self.recording = recording
        _viewModel = StateObject(wrappedValue: RecordingDetailViewModel(recording: recording))
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Tab", selection: $viewModel.selectedTab) {
                ForEach(RecordingDetailViewModel.DetailTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            switch viewModel.selectedTab {
            case .summary:
                SummaryView(recording: recording, viewModel: viewModel)
            case .transcript:
                TranscriptView(recording: recording, viewModel: viewModel)
            case .play:
                AudioPlayerView(viewModel: viewModel)
            }
        }
        .navigationTitle(recording.contactName ?? "Recording")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Button {
                            viewModel.exportAs(format: format)
                        } label: {
                            Label(format.rawValue, systemImage: format.icon)
                        }
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .onAppear { viewModel.setupAudioPlayer() }
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let url = viewModel.exportURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension ExportFormat {
    var icon: String {
        switch self {
        case .pdf: return "doc.fill"
        case .srt: return "captions.bubble.fill"
        case .txt: return "doc.text.fill"
        case .audio: return "waveform"
        }
    }
}
