import Foundation

enum ModelSize: String, CaseIterable {
    case base = "base.en"
    case small = "small.en"

    var displayName: String {
        switch self {
        case .base: return "Base (74MB)"
        case .small: return "Small (244MB)"
        }
    }

    var fileSize: Int64 {
        switch self {
        case .base: return 74 * 1024 * 1024
        case .small: return 244 * 1024 * 1024
        }
    }
}

enum AudioQuality: String, CaseIterable {
    case standard = "Standard"
    case high = "High"

    var sampleRate: Double {
        switch self {
        case .standard: return 22050.0
        case .high: return 44100.0
        }
    }

    var bitRate: Int {
        switch self {
        case .standard: return 64000
        case .high: return 128000
        }
    }
}

enum ExportFormat: String, CaseIterable {
    case pdf = "PDF"
    case srt = "SRT"
    case txt = "TXT"
    case audio = "Audio"
}
