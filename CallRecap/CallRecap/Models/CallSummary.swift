import Foundation

struct ActionItem: Codable, Identifiable {
    let id: UUID
    let text: String
    let deadline: Date?
    let isCompleted: Bool

    init(id: UUID = UUID(), text: String, deadline: Date? = nil, isCompleted: Bool = false) {
        self.id = id
        self.text = text
        self.deadline = deadline
        self.isCompleted = isCompleted
    }
}

enum Sentiment: String, Codable {
    case positive
    case neutral
    case negative
    case mixed
}

struct CallSummary: Codable {
    let overview: String
    let keyPoints: [String]
    let actionItems: [ActionItem]
    let sentiment: Sentiment
    let topics: [String]

    static let empty = CallSummary(overview: "", keyPoints: [], actionItems: [], sentiment: .neutral, topics: [])
}
