import Foundation
import CoreData

@objc(Recording)
public class Recording: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var filePath: String
    @NSManaged public var date: Date
    @NSManaged public var duration: Double
    @NSManaged public var contactName: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var callType: String
    @NSManaged public var transcriptText: String?
    @NSManaged public var summaryJSON: Data?
    @NSManaged public var isTrashed: Bool
    @NSManaged public var deletedAt: Date?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var transcriptionProgress: Double
    @NSManaged public var isTranscribing: Bool
    @NSManaged public var isSummarizing: Bool
    @NSManaged public var transcriptSegments: Data?
}

extension Recording {
    var summary: CallSummary? {
        guard let data = summaryJSON else { return nil }
        return try? JSONDecoder().decode(CallSummary.self, from: data)
    }

    func setSummary(_ summary: CallSummary) {
        summaryJSON = try? JSONEncoder().encode(summary)
    }

    var segments: [TranscriptSegment]? {
        guard let data = transcriptSegments else { return nil }
        return try? JSONDecoder().decode([TranscriptSegment].self, from: data)
    }

    func setSegments(_ segments: [TranscriptSegment]) {
        transcriptSegments = try? JSONEncoder().encode(segments)
    }

    var audioFileURL: URL {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDir.appendingPathComponent(filePath)
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
            return "Today \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "h:mm a"
            return "Yesterday \(formatter.string(from: date))"
        } else {
            formatter.dateFormat = "MMM d, h:mm a"
            return formatter.string(from: date)
        }
    }

    var dateGroup: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        if date >= calendar.date(byAdding: .day, value: -7, to: Date())! { return "This Week" }
        return "Earlier"
    }
}
