import Foundation

extension UserDefaults {
    private enum Keys {
        static let onboardingComplete = "onboardingComplete"
        static let autoRecordEnabled = "autoRecordEnabled"
        static let selectedModelSize = "selectedModelSize"
        static let audioQuality = "audioQuality"
        static let biometricLockEnabled = "biometricLockEnabled"
        static let defaultExportFormat = "defaultExportFormat"
        static let freeTranscriptionsUsed = "freeTranscriptionsUsed"
        static let freeTranscriptionsResetDate = "freeTranscriptionsResetDate"
        static let isPremium = "isPremium"
        static let whisperModelDownloaded = "whisperModelDownloaded"
    }

    var onboardingComplete: Bool {
        get { bool(forKey: Keys.onboardingComplete) }
        set { set(newValue, forKey: Keys.onboardingComplete) }
    }

    var autoRecordEnabled: Bool {
        get { bool(forKey: Keys.autoRecordEnabled) }
        set { set(newValue, forKey: Keys.autoRecordEnabled) }
    }

    var selectedModelSize: String {
        get { string(forKey: Keys.selectedModelSize) ?? ModelSize.base.rawValue }
        set { set(newValue, forKey: Keys.selectedModelSize) }
    }

    var audioQuality: String {
        get { string(forKey: Keys.audioQuality) ?? AudioQuality.high.rawValue }
        set { set(newValue, forKey: Keys.audioQuality) }
    }

    var biometricLockEnabled: Bool {
        get { bool(forKey: Keys.biometricLockEnabled) }
        set { set(newValue, forKey: Keys.biometricLockEnabled) }
    }

    var defaultExportFormat: String {
        get { string(forKey: Keys.defaultExportFormat) ?? ExportFormat.pdf.rawValue }
        set { set(newValue, forKey: Keys.defaultExportFormat) }
    }

    var freeTranscriptionsUsed: Int {
        get { integer(forKey: Keys.freeTranscriptionsUsed) }
        set { set(newValue, forKey: Keys.freeTranscriptionsUsed) }
    }

    var freeTranscriptionsResetDate: Date? {
        get { object(forKey: Keys.freeTranscriptionsResetDate) as? Date }
        set { set(newValue, forKey: Keys.freeTranscriptionsResetDate) }
    }

    var isPremium: Bool {
        get { bool(forKey: Keys.isPremium) }
        set { set(newValue, forKey: Keys.isPremium) }
    }

    var whisperModelDownloaded: Bool {
        get { bool(forKey: Keys.whisperModelDownloaded) }
        set { set(newValue, forKey: Keys.whisperModelDownloaded) }
    }

    var canTranscribe: Bool {
        if isPremium { return true }
        resetIfNeeded()
        return freeTranscriptionsUsed < 5
    }

    var remainingFreeTranscriptions: Int {
        if isPremium { return -1 }
        resetIfNeeded()
        return max(0, 5 - freeTranscriptionsUsed)
    }

    private func resetIfNeeded() {
        let now = Date()
        let calendar = Calendar.current
        if let resetDate = freeTranscriptionsResetDate {
            if !calendar.isDate(resetDate, equalTo: now, toGranularity: .month) {
                freeTranscriptionsUsed = 0
                freeTranscriptionsResetDate = now
            }
        } else {
            freeTranscriptionsResetDate = now
        }
    }

    func incrementTranscriptionUse() {
        if !isPremium {
            resetIfNeeded()
            freeTranscriptionsUsed += 1
        }
    }
}
