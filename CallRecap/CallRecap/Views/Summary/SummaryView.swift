import SwiftUI

struct SummaryView: View {
    let recording: Recording
    @ObservedObject var viewModel: RecordingDetailViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let summary = recording.summary {
                    overviewCard(summary)
                    keyPointsCard(summary)
                    actionItemsCard(summary)
                    topicsCard(summary)
                } else if recording.isSummarizing {
                    ProgressView("Generating summary...")
                        .padding()
                } else {
                    noSummaryView
                }
            }
            .padding()
        }
    }

    private func overviewCard(_ summary: CallSummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Overview")
                    .font(.headline)
                Spacer()
                SentimentBadge(sentiment: summary.sentiment)
            }

            Text(summary.overview)
                .font(.body)
        }
        .cardStyle()
    }

    private func keyPointsCard(_ summary: CallSummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Key Points")
                .font(.headline)

            ForEach(summary.keyPoints, id: \.self) { point in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text(point)
                }
                .font(.subheadline)
            }
        }
        .cardStyle()
    }

    private func actionItemsCard(_ summary: CallSummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Action Items")
                    .font(.headline)
                Spacer()
                if !summary.actionItems.isEmpty {
                    Button {
                        viewModel.addActionItemsToReminders()
                    } label: {
                        if viewModel.addingToReminders {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Label("Add to Reminders", systemImage: "bell.badge.fill")
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }

            if summary.actionItems.isEmpty {
                Text("No action items detected")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(summary.actionItems) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: item.isCompleted ? "checkmark.square.fill" : "square")
                            .foregroundStyle(item.isCompleted ? .green : .secondary)
                        VStack(alignment: .leading) {
                            Text(item.text)
                                .font(.subheadline)
                            if let deadline = item.deadline {
                                Text(deadline.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .cardStyle()
    }

    private func topicsCard(_ summary: CallSummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Topics")
                .font(.headline)

            if summary.topics.isEmpty {
                Text("No topics detected")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(summary.topics, id: \.self) { topic in
                        Text(topic)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.appPrimary.opacity(0.15))
                            .foregroundStyle(Color.appPrimary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .cardStyle()
    }

    private var noSummaryView: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No Summary Yet")
                .font(.headline)
            Text("Summary will appear after transcription completes.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
