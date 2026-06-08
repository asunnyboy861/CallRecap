import SwiftUI
import AVFoundation

struct OnboardingView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @State private var currentPage = 0

    var body: some View {
        if onboardingComplete {
            ContentView()
        } else {
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                featuresPage.tag(1)
                permissionsPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }

    private func completeOnboarding() {
        onboardingComplete = true
    }

    private var welcomePage: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.appPrimary)

            Text("CallRecap")
                .font(.largeTitle.bold())

            Text("Record calls, get AI summaries,\nnever miss an action item.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button("Get Started") { withAnimation { currentPage = 1 } }
                .primaryButtonStyle()
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
        }
    }

    private var featuresPage: some View {
        VStack(spacing: 28) {
            Spacer()

            FeatureRow(icon: "mic.fill", title: "One-Tap Recording", description: "Record calls automatically or manually")
            FeatureRow(icon: "text.bubble.fill", title: "AI Transcription", description: "On-device Whisper — 100% private")
            FeatureRow(icon: "sparkles", title: "Smart Summaries", description: "Key points, action items, sentiment")
            FeatureRow(icon: "bell.badge.fill", title: "Add to Reminders", description: "Action items sync to Apple Reminders")
            FeatureRow(icon: "trash.circle.fill", title: "Recycle Bin", description: "30-day recovery for deleted recordings")

            Spacer()

            Button("Continue") { withAnimation { currentPage = 2 } }
                .primaryButtonStyle()
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
    }

    private var permissionsPage: some View {
        VStack(spacing: 28) {
            Spacer()

            Text("Permissions")
                .font(.title.bold())

            Text("CallRecap needs a few permissions to work properly.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            PermissionRow(icon: "mic.fill", title: "Microphone", description: "Required for call recording") {
                requestMicrophonePermission()
            }

            PermissionRow(icon: "phone.fill", title: "Call Detection", description: "Auto-detect incoming/outgoing calls") {
                requestCallKitPermission()
            }

            PermissionRow(icon: "bell.fill", title: "Notifications", description: "Recording completion alerts") {
                requestNotificationPermission()
            }

            Spacer()

            Button("Start Using CallRecap") { completeOnboarding() }
                .primaryButtonStyle()
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
    }

    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
    }

    private func requestCallKitPermission() {}

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(description).font(.subheadline).foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

private struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void

    @State private var granted = false

    var body: some View {
        Button(action: {
            action()
            granted = true
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(granted ? .green : Color.appPrimary)
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(description).font(.subheadline).foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: granted ? "checkmark.circle.fill" : "chevron.right")
                    .foregroundStyle(granted ? .green : .secondary)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
