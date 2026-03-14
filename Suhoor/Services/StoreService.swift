import Foundation
import StoreKit

// MARK: - Product Identifier

enum SuhoorProduct: String {
    case premium = "com.chadnewbry.suhoor.lifetime"
}

// MARK: - Store Service

@MainActor
final class StoreService: ObservableObject {
    static let shared = StoreService()

    // MARK: - Published State

    @Published private(set) var product: Product?
    @Published private(set) var isPurchased = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // Free tier tracking
    @Published private(set) var usedFreeDays: Int = 0

    static let maxFreeDays = 5
    private static let freeDaysKey = "suhoor_free_days_used"
    private static let lastRecordedDateKey = "suhoor_last_recorded_date"

    private var transactionListener: Task<Void, Error>?

    /// Whether the user has premium access (purchased or within free tier)
    var isPremium: Bool {
        isPurchased || isInFreeTier
    }

    /// Whether user is still in the free trial period
    var isInFreeTier: Bool {
        !isPurchased && usedFreeDays < Self.maxFreeDays
    }

    /// Days remaining in free tier
    var freeDaysRemaining: Int {
        max(0, Self.maxFreeDays - usedFreeDays)
    }

    /// Whether the paywall should be shown for premium features
    var shouldShowPaywall: Bool {
        !isPurchased && !isInFreeTier
    }

    // Legacy compatibility
    var isPro: Bool { isPremium }

    private init() {
        loadFreeDays()
        transactionListener = listenForTransactions()
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        guard product == nil else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let storeProducts = try await Product.products(
                for: [SuhoorProduct.premium.rawValue]
            )
            product = storeProducts.first
            #if DEBUG
            if product == nil {
                print("[StoreService] No product found for ID: \(SuhoorProduct.premium.rawValue)")
                print("[StoreService] Returned products: \(storeProducts)")
            } else {
                print("[StoreService] Loaded product: \(product!.displayName) — \(product!.displayPrice)")
            }
            #endif
        } catch {
            errorMessage = "Failed to load products."
            #if DEBUG
            print("[StoreService] Error loading products: \(error)")
            #endif
        }
    }

    // MARK: - Purchase

    func purchase() async throws -> Bool {
        guard let product else { return false }

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
        var found = false

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == SuhoorProduct.premium.rawValue {
                found = true
            }
        }

        isPurchased = found
    }

    // MARK: - Free Day Tracking

    /// Record that the user used the app today. Call on app launch / when logging a fast.
    func recordAppUsageDay() {
        guard !isPurchased else { return }

        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = UserDefaults.standard.object(forKey: Self.lastRecordedDateKey) as? Date

        if let lastDate, Calendar.current.isDate(lastDate, inSameDayAs: today) {
            return // Already recorded today
        }

        UserDefaults.standard.set(today, forKey: Self.lastRecordedDateKey)
        usedFreeDays = min(usedFreeDays + 1, Self.maxFreeDays)
        UserDefaults.standard.set(usedFreeDays, forKey: Self.freeDaysKey)
    }

    private func loadFreeDays() {
        usedFreeDays = UserDefaults.standard.integer(forKey: Self.freeDaysKey)
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
