import SwiftUI
import LocalAuthentication

@main
struct CallRecapApp: App {
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false
    @State private var isUnlocked = false

    var body: some Scene {
        WindowGroup {
            Group {
                if !onboardingComplete {
                    OnboardingView()
                } else if biometricLockEnabled && !isUnlocked {
                    biometricLockView
                } else {
                    ContentView()
                }
            }
        }
    }

    private var biometricLockView: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.appPrimary)

            Text("CallRecap is Locked")
                .font(.title2.bold())

            Text("Authenticate to access your recordings")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Unlock") {
                authenticate()
            }
            .primaryButtonStyle()
            .padding(.horizontal, 48)
        }
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            isUnlocked = true
            return
        }

        Task {
            do {
                let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock CallRecap")
                isUnlocked = success
            } catch {
                isUnlocked = false
            }
        }
    }
}
