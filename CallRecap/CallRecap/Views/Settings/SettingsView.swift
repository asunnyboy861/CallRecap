import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showPaywall = false
    @State private var showContactSupport = false
    @State private var biometricSupported = false

    var body: some View {
        NavigationStack {
            Form {
                subscriptionSection
                recordingSection
                transcriptionSection
                securitySection
                exportSection
                legalSection
                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showContactSupport) {
                ContactSupportView()
            }
            .onAppear {
                checkBiometricSupport()
            }
        }
    }

    private var subscriptionSection: some View {
        Section {
            if viewModel.isPremium {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                    Text("Pro Member")
                        .font(.headline)
                    Spacer()
                    Text("Active")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "crown")
                            .foregroundStyle(.yellow)
                        Text("Upgrade to Pro")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Text("Free Transcriptions Left")
                    Spacer()
                    Text("\(viewModel.remainingTranscriptions)/5")
                        .foregroundStyle(viewModel.remainingTranscriptions <= 1 ? .red : .secondary)
                }
            }
        } header: {
            Text("Subscription")
        }
    }

    private var recordingSection: some View {
        Section {
            Toggle("Auto-Record Calls", isOn: $viewModel.autoRecordEnabled)

            Picker("Audio Quality", selection: $viewModel.audioQuality) {
                ForEach(AudioQuality.allCases, id: \.self) { quality in
                    Text(quality.rawValue).tag(quality)
                }
            }
        } header: {
            Text("Recording")
        }
    }

    private var transcriptionSection: some View {
        Section {
            Picker("Whisper Model", selection: $viewModel.selectedModelSize) {
                ForEach(ModelSize.allCases, id: \.self) { size in
                    Text(size.displayName).tag(size)
                }
            }

            if !UserDefaults.standard.whisperModelDownloaded {
                HStack {
                    Text("Model Status")
                    Spacer()
                    Text("Not Downloaded")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
            }
        } header: {
            Text("Transcription")
        }
    }

    private var securitySection: some View {
        Section {
            if biometricSupported {
                Toggle("Biometric Lock", isOn: $viewModel.biometricLockEnabled)
            }
        } header: {
            Text("Security")
        }
    }

    private var exportSection: some View {
        Section {
            Picker("Default Export Format", selection: $viewModel.defaultExportFormat) {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    Text(format.rawValue).tag(format)
                }
            }
        } header: {
            Text("Export")
        }
    }

    private var legalSection: some View {
        Section {
            Link("Support", destination: viewModel.supportURL)
            Link("Privacy Policy", destination: viewModel.privacyURL)
            Link("Terms of Use", destination: viewModel.termsURL)
            Button("Contact Support") { showContactSupport = true }
            Button("Restore Purchases") {
                Task { await viewModel.subscriptionManager.restorePurchases() }
            }
        } header: {
            Text("Legal & Support")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("About")
        }
    }

    private func checkBiometricSupport() {
        let context = LAContext()
        var error: NSError?
        biometricSupported = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
}
