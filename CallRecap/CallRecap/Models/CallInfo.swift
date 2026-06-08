import Foundation

struct CallInfo {
    let callId: UUID
    let phoneNumber: String?
    let contactName: String?
    let callType: CallType
    let startDate: Date
    let endDate: Date?

    enum CallType: String {
        case incoming
        case outgoing
    }

    var duration: TimeInterval {
        guard let endDate else { return 0 }
        return endDate.timeIntervalSince(startDate)
    }
}
