import SwiftUI

struct AudioPlayerView: View {
    @ObservedObject var viewModel: RecordingDetailViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            waveformVisualization

            VStack(spacing: 16) {
                Slider(
                    value: $viewModel.playbackProgress,
                    in: 0...1,
                    onEditingChanged: { _ in
                        viewModel.seek(to: viewModel.playbackProgress * viewModel.totalDuration)
                    }
                )
                .tint(Color.appPrimary)

                HStack {
                    Text(viewModel.formattedCurrentTime)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(viewModel.formattedTotalDuration)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)

            HStack(spacing: 40) {
                Button {
                    viewModel.seek(to: max(0, viewModel.currentTime - 15))
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }

                Button {
                    viewModel.togglePlayback()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.appPrimary)
                }

                Button {
                    viewModel.seek(to: min(viewModel.totalDuration, viewModel.currentTime + 15))
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
            }

            Spacer()
        }
    }

    private var waveformVisualization: some View {
        HStack(spacing: 2) {
            ForEach(0..<40, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.appPrimary.opacity(viewModel.isPlaying ? 0.3 + Double.random(in: 0...0.7) : 0.3))
                    .frame(width: 4, height: CGFloat.random(in: 20...60))
                    .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: viewModel.isPlaying)
            }
        }
        .frame(height: 60)
    }
}
