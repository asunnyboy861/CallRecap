import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: Plan = .yearly

    enum Plan: String, CaseIterable {
        case monthly
        case yearly
        case lifetime

        var displayName: String {
            switch self {
            case .monthly: return "Monthly"
            case .yearly: return "Yearly"
            case .lifetime: return "Lifetime"
            }
        }

        var price: String {
            switch self {
            case .monthly: return "$3.99/mo"
            case .yearly: return "$29.99/yr"
            case .lifetime: return "$79.99"
            }
        }

        var savings: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "Save 37%"
            case .lifetime: return "Best Value"
            }
        }

        var productID: String {
            switch self {
            case .monthly: return "com.zzoutuo.CallRecap.monthly"
            case .yearly: return "com.zzoutuo.CallRecap.yearly"
            case .lifetime: return "com.zzoutuo.CallRecap.lifetime"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featuresSection
                    planSelector
                    subscribeButton
                    legalLinks
                    restoreButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Upgrade to Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)

            Text("Unlock CallRecap Pro")
                .font(.title2.bold())

            Text("Unlimited transcription, AI summaries, and more")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var featuresSection: some View {
        VStack(spacing: 12) {
            FeatureCheckRow(text: "Unlimited AI transcription")
            FeatureCheckRow(text: "AI smart summaries with action items")
            FeatureCheckRow(text: "Speaker diarization")
            FeatureCheckRow(text: "Export as PDF, SRT, TXT")
            FeatureCheckRow(text: "Face ID / Touch ID lock")
            FeatureCheckRow(text: "Priority support")
        }
        .cardStyle()
    }

    private var planSelector: some View {
        VStack(spacing: 12) {
            ForEach(Plan.allCases, id: \.self) { plan in
                planCard(plan)
            }
        }
    }

    private func planCard(_ plan: Plan) -> some View {
        Button {
            selectedPlan = plan
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.displayName)
                            .font(.headline)
                        if let savings = plan.savings {
                            Text(savings)
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(plan == .yearly ? Color.appPrimary : Color.orange)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    Text(plan.price)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: selectedPlan == plan ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedPlan == plan ? Color.appPrimary : .secondary)
                    .font(.title3)
            }
            .padding()
            .background(selectedPlan == plan ? Color.appPrimary.opacity(0.1) : Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedPlan == plan ? Color.appPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var subscribeButton: some View {
        Button {
            purchaseSelectedPlan()
        } label: {
            if subscriptionManager.isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(selectedPlan == .yearly ? "Start 7-Day Free Trial" : "Subscribe")
                    .font(.headline)
            }
        }
        .primaryButtonStyle()
    }

    private var legalLinks: some View {
        VStack(spacing: 4) {
            Text("Subscription automatically renews unless canceled at least 24 hours before the end of the current period.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/CallRecap/privacy.html")!)
                    .font(.caption2)
                    .foregroundStyle(Color.appPrimary)
                Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/CallRecap/terms.html")!)
                    .font(.caption2)
                    .foregroundStyle(Color.appPrimary)
            }
            .padding(.top, 4)
        }
    }

    private var restoreButton: some View {
        Button("Restore Purchases") {
            Task { await subscriptionManager.restorePurchases() }
        }
        .font(.subheadline)
        .foregroundStyle(Color.appPrimary)
    }

    private func purchaseSelectedPlan() {
        guard let product = subscriptionManager.productItems.first(where: { $0.id == selectedPlan.productID }) else { return }
        Task {
            let success = await subscriptionManager.purchase(product)
            if success { dismiss() }
        }
    }
}

private struct FeatureCheckRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}
