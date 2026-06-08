import SwiftUI

struct RecordingListView: View {
    @StateObject private var viewModel = RecordingListViewModel()
    @State private var showingTrash = false

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.recordings.isEmpty {
                    emptyStateView
                } else {
                    recordingList
                }

                if viewModel.isRecording {
                    recordingBanner
                }
            }
            .navigationTitle("CallRecap")
            .searchable(text: $viewModel.searchText, prompt: "Search recordings")
            .onChange(of: viewModel.searchText) { _, _ in viewModel.loadRecordings() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingTrash = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .sheet(isPresented: $showingTrash) {
                TrashView()
            }
            .overlay(alignment: .bottom) {
                recordButton
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "waveform")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("No Recordings Yet")
                .font(.title2.bold())
            Text("Tap the record button to start")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var recordingList: some View {
        List {
            ForEach(viewModel.groupedRecordings, id: \.0) { group, recordings in
                Section(group) {
                    ForEach(recordings) { recording in
                        NavigationLink {
                            RecordingDetailView(recording: recording)
                        } label: {
                            RecordingRow(recording: recording)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteRecording(recording)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                viewModel.toggleFavorite(recording)
                            } label: {
                                Label(recording.isFavorite ? "Unfavorite" : "Favorite",
                                      systemImage: recording.isFavorite ? "star.slash" : "star")
                            }
                            .tint(.yellow)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var recordButton: some View {
        Button {
            if viewModel.isRecording {
                viewModel.stopManualRecording()
            } else {
                viewModel.startManualRecording()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(viewModel.isRecording ? Color.recordingRed : Color.appPrimary)
                    .frame(width: 64, height: 64)
                    .shadow(radius: 4)

                if viewModel.isRecording {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white)
                        .frame(width: 20, height: 20)
                } else {
                    Circle()
                        .fill(.white)
                        .frame(width: 24, height: 24)
                }
            }
        }
        .padding(.bottom, 24)
    }

    private var recordingBanner: some View {
        VStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.recordingRed)
                    .frame(width: 8, height: 8)
                    .blink()

                Text("Recording")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)

                Text(viewModel.recordingDuration.formattedDuration)
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.recordingRed)
            .clipShape(Capsule())
            .padding(.top, 8)

            Spacer()
        }
    }
}

extension TimeInterval {
    var formattedDuration: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct Blink: ViewModifier {
    @State private var isVisible = true

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0.3)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isVisible)
            .onAppear { isVisible.toggle() }
    }
}

extension View {
    func blink() -> some View { modifier(Blink()) }
}
