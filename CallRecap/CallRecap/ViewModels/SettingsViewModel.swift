import Foundation
import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var autoRecordEnabled: Bool = UserDefaults.standard.autoRecordEnabled {
        didSet { UserDefaults.standard.autoRecordEnabled = autoRecordEnabled }
    }
    @Published var selectedModelSize: ModelSize = ModelSize(rawValue: UserDefaults.standard.selectedModelSize) ?? .base {
        didSet { UserDefaults.standard.selectedModelSize = selectedModelSize.rawValue }
    }
    @Published var audioQuality: AudioQuality = AudioQuality(rawValue: UserDefaults.standard.audioQuality) ?? .high {
        didSet { UserDefaults.standard.audioQuality = audioQuality.rawValue }
    }
    @Published var biometricLockEnabled: Bool = UserDefaults.standard.biometricLockEnabled {
        didSet { UserDefaults.standard.biometricLockEnabled = biometricLockEnabled }
    }
    @Published var defaultExportFormat: ExportFormat = ExportFormat(rawValue: UserDefaults.standard.defaultExportFormat) ?? .pdf {
        didSet { UserDefaults.standard.defaultExportFormat = defaultExportFormat.rawValue }
    }
    @Published var isPremium: Bool = UserDefaults.standard.isPremium
    @Published var remainingTranscriptions: Int = UserDefaults.standard.remainingFreeTranscriptions

    let subscriptionManager = SubscriptionManager()

    func refreshPremiumStatus() {
        isPremium = UserDefaults.standard.isPremium
        remainingTranscriptions = UserDefaults.standard.remainingFreeTranscriptions
    }

    var githubUser: String {
        "asunnyboy861"
    }

    var appName: String {
        "CallRecap"
    }

    var supportURL: URL {
        URL(string: "https://\(githubUser).github.io/\(appName)/support.html")!
    }

    var privacyURL: URL {
        URL(string: "https://\(githubUser).github.io/\(appName)/privacy.html")!
    }

    var termsURL: URL {
        URL(string: "https://\(githubUser).github.io/\(appName)/terms.html")!
    }
}
