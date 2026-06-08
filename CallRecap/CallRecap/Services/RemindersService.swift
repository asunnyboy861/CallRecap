import Foundation
import EventKit
import Combine

class RemindersService: ObservableObject {
    private let eventStore = EKEventStore()

    func requestAccess() async -> Bool {
        do {
            return try await eventStore.requestFullAccessToReminders()
        } catch {
            return false
        }
    }

    func addReminder(title: String, deadline: Date? = nil) async -> Bool {
        let granted = await requestAccess()
        guard granted else { return false }

        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.calendar = eventStore.defaultCalendarForNewReminders()

        if let deadline = deadline {
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: deadline)
        }

        do {
            try eventStore.save(reminder, commit: true)
            return true
        } catch {
            return false
        }
    }

    func addReminders(_ items: [ActionItem]) async -> Int {
        var added = 0
        for item in items {
            if await addReminder(title: item.text, deadline: item.deadline) {
                added += 1
            }
        }
        return added
    }
}
