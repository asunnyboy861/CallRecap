import SwiftUI

struct RecordingRow: View {
    let recording: Recording

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(recording.contactName ?? "Unknown Caller")
                    .font(.headline)
                    .lineLimit(1)

                Spacer()

                if recording.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }

                Text(recording.formattedDuration)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            HStack {
                Image(systemName: recording.callType == "incoming" ? "phone.down.fill" : "phone.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(recording.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if let summary = recording.summary {
                    SentimentBadge(sentiment: summary.sentiment)
                }
            }

            if let summary = recording.summary, !summary.overview.isEmpty {
                Text(summary.overview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            } else if recording.isTranscribing {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Transcribing...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct SentimentBadge: View {
    let sentiment: Sentiment

    var color: Color {
        switch sentiment {
        case .positive: return .sentimentPositive
        case .neutral: return .sentimentNeutral
        case .negative: return .sentimentNegative
        case .mixed: return .sentimentMixed
        }
    }

    var icon: String {
        switch sentiment {
        case .positive: return "hand.thumbsup.fill"
        case .neutral: return "minus.circle.fill"
        case .negative: return "hand.thumbsdown.fill"
        case .mixed: return "arrow.left.arrow.right.circle.fill"
        }
    }

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption2)
            Text(sentiment.rawValue.capitalized)
                .font(.caption2)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}
