import Foundation

extension Date {
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    var formattedShort: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today \(formattedTime)"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday \(formattedTime)"
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: self)
        }
    }
}
