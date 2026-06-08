import Foundation
import CoreData
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()

    let container: NSPersistentContainer
    let viewContext: NSManagedObjectContext

    private init() {
        container = NSPersistentContainer(name: "CallRecap")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed: \(error)")
            }
        }
        viewContext = container.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
    }

    func createRecording(filePath: String, duration: Double, contactName: String? = nil, phoneNumber: String? = nil, callType: String = "manual") -> Recording {
        let recording = Recording(context: viewContext)
        recording.id = UUID()
        recording.filePath = filePath
        recording.date = Date()
        recording.duration = duration
        recording.contactName = contactName
        recording.phoneNumber = phoneNumber
        recording.callType = callType
        recording.isTrashed = false
        recording.isFavorite = false
        recording.transcriptionProgress = 0
        recording.isTranscribing = false
        recording.isSummarizing = false
        try? viewContext.save()
        return recording
    }

    func fetchRecordings(searchText: String = "") -> [Recording] {
        let request: NSFetchRequest<Recording> = Recording.fetchRequest() as! NSFetchRequest<Recording>
        var predicates = [NSPredicate(format: "isTrashed == %@", NSNumber(value: false))]

        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "contactName CONTAINS[cd] %@ OR transcriptText CONTAINS[cd] %@ OR phoneNumber CONTAINS[cd] %@", searchText, searchText, searchText))
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        return (try? viewContext.fetch(request)) ?? []
    }

    func fetchDeletedRecordings() -> [Recording] {
        let request: NSFetchRequest<Recording> = Recording.fetchRequest() as! NSFetchRequest<Recording>
        request.predicate = NSPredicate(format: "isTrashed == %@", NSNumber(value: true))
        request.sortDescriptors = [NSSortDescriptor(key: "deletedAt", ascending: false)]
        return (try? viewContext.fetch(request)) ?? []
    }

    func softDelete(_ recording: Recording) {
        recording.isTrashed = true
        recording.deletedAt = Date()
        try? viewContext.save()
    }

    func restore(_ recording: Recording) {
        recording.isTrashed = false
        recording.deletedAt = nil
        try? viewContext.save()
    }

    func permanentDelete(_ recording: Recording) {
        let fileURL = recording.audioFileURL
        try? FileManager.default.removeItem(at: fileURL)
        viewContext.delete(recording)
        try? viewContext.save()
    }

    func cleanupExpiredTrash() {
        let calendar = Calendar.current
        let threshold = calendar.date(byAdding: .day, value: -30, to: Date())!
        let request: NSFetchRequest<Recording> = Recording.fetchRequest() as! NSFetchRequest<Recording>
        request.predicate = NSPredicate(format: "isTrashed == %@ AND deletedAt < %@", NSNumber(value: true), threshold as NSDate)

        let expired = (try? viewContext.fetch(request)) ?? []
        for recording in expired {
            permanentDelete(recording)
        }
    }

    func toggleFavorite(_ recording: Recording) {
        recording.isFavorite.toggle()
        try? viewContext.save()
    }

    func save() {
        try? viewContext.save()
    }
}
