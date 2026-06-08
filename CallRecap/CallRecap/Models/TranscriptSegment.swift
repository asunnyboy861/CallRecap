import Foundation

struct TranscriptSegment: Codable, Identifiable {
    let id: UUID
    let startTime: Double
    let endTime: Double
    let text: String
    let speaker: Int

    init(id: UUID = UUID(), startTime: Double, endTime: Double, text: String, speaker: Int = 0) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.text = text
        self.speaker = speaker
    }
}
