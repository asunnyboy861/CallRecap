import Foundation
import Combine

class SummaryEngine: ObservableObject {
    @Published var isSummarizing = false

    func generateSummary(transcriptText: String) async -> CallSummary {
        isSummarizing = true
        defer { isSummarizing = false }

        if #available(iOS 18.0, *) {
            return await generateWithAppleIntelligence(transcriptText: transcriptText)
        } else {
            return generateWithLocalRules(transcriptText: transcriptText)
        }
    }

    @available(iOS 18.0, *)
    private func generateWithAppleIntelligence(transcriptText: String) async -> CallSummary {
        return generateWithLocalRules(transcriptText: transcriptText)
    }

    private func generateWithLocalRules(transcriptText: String) -> CallSummary {
        let sentences = transcriptText
            .components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let overview = sentences.first ?? "No summary available"

        let keyPoints = Array(sentences.prefix(5)).map { $0 }

        let actionKeywords = ["need to", "should", "must", "will", "let's", "make sure", "don't forget", "deadline", "follow up", "schedule"]
        let actionItems = sentences.filter { sentence in
            actionKeywords.contains(where: { sentence.lowercased().contains($0) })
        }.map { ActionItem(text: $0) }

        let positiveWords = ["great", "good", "excellent", "thanks", "happy", "love", "perfect", "wonderful", "agree"]
        let negativeWords = ["bad", "terrible", "hate", "angry", "frustrated", "disappointed", "problem", "issue", "wrong"]
        let lowerText = transcriptText.lowercased()
        let positiveCount = positiveWords.reduce(0) { $0 + (lowerText.contains($1) ? 1 : 0) }
        let negativeCount = negativeWords.reduce(0) { $0 + (lowerText.contains($1) ? 1 : 0) }

        let sentiment: Sentiment
        if positiveCount > negativeCount + 2 { sentiment = .positive }
        else if negativeCount > positiveCount + 2 { sentiment = .negative }
        else if positiveCount > 0 && negativeCount > 0 { sentiment = .mixed }
        else { sentiment = .neutral }

        let topicKeywords: [String: [String]] = [
            "Budget": ["budget", "cost", "price", "money", "expense", "revenue"],
            "Project": ["project", "deadline", "milestone", "sprint", "deliverable"],
            "Meeting": ["meeting", "schedule", "calendar", "appointment", "call"],
            "Technical": ["code", "bug", "feature", "deploy", "server", "api"],
            "Legal": ["contract", "agreement", "compliance", "regulation", "policy"]
        ]

        let topics = topicKeywords.filter { _, keywords in
            keywords.contains(where: { lowerText.contains($0) })
        }.map { $0.key }

        return CallSummary(
            overview: overview,
            keyPoints: keyPoints,
            actionItems: actionItems,
            sentiment: sentiment,
            topics: topics
        )
    }
}
