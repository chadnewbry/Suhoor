import Foundation
import StoreKit

// MARK: - Product Identifiers

enum SuhoorProduct: String, CaseIterable {
    case proMonthly = "com.chadnewbry.suhoor.pro.monthly"
    case proAnnual = "com.chadnewbry.suhoor.pro.annual"
    case proLifetime = "com.chadnewbry.suhoor.pro.lifetime"

    var isSubscription: Bool {
        switch self {
        case .proMonthly, .proAnnual: return true
        case .proLifetime: return false
        }
    }
}

// MARK: - Store Service

@MainActor
final class StoreService: ObservableObject {
    static let shared = StoreService()

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private var transactionListener: Task<Void, Error>?

    var isPro: Bool {
        !purchasedProductIDs.intersection(SuhoorProduct.allCases.map(\.rawValue)).isEmpty
    }

    var monthlyProduct: Product? {
        products.first { $0.id == SuhoorProduct.proMonthly.rawValue }
    }

    var annualProduct: Product? {
        products.first { $0.id == SuhoorProduct.proAnnual.rawValue }
    }

    var lifetimeProduct: Product? {
        products.first { $0.id == SuhoorProduct.proLifetime.rawValue }
    }

    private init() {
        transactionListener = listenForTransactions()
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        guard products.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let storeProducts = try await Product.products(
                for: SuhoorProduct.allCases.map(\.rawValue)
            )
            products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            errorMessage = "Failed to load products."
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await refreshEntitlements()
            return true

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    // MARK: - Entitlements

    func refreshEntitlements() async {
        var ids: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                ids.insert(transaction.productID)
            }
        }

        purchasedProductIDs = ids
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if let transaction = try? self?.checkVerified(result) {
                    await transaction.finish()
                    await self?.refreshEntitlements()
                }
            }
        }
    }

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Errors

enum StoreError: LocalizedError {
    case verificationFailed

    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "Transaction verification failed."
        }
    }
}
