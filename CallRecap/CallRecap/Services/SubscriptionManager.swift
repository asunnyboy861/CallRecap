import Foundation
import StoreKit
import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    @Published var productItems: [Product] = []
    @Published var isPremium = UserDefaults.standard.isPremium
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var transactionListener: Task<Void, Never>?
    private let productIDs = [
        "com.zzoutuo.CallRecap.monthly",
        "com.zzoutuo.CallRecap.yearly",
        "com.zzoutuo.CallRecap.lifetime"
    ]

    init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        do {
            productItems = try await Product.products(for: productIDs)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isPremium = true
                UserDefaults.standard.isPremium = true
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    isPremium = true
                    UserDefaults.standard.isPremium = true
                    await transaction.finish()
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var monthlyProduct: Product? {
        productItems.first { $0.id == "com.zzoutuo.CallRecap.monthly" }
    }

    var yearlyProduct: Product? {
        productItems.first { $0.id == "com.zzoutuo.CallRecap.yearly" }
    }

    var lifetimeProduct: Product? {
        productItems.first { $0.id == "com.zzoutuo.CallRecap.lifetime" }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    await transaction.finish()
                    self?.isPremium = true
                    UserDefaults.standard.isPremium = true
                } catch {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
