import Foundation
import StoreKit

@MainActor
final class ReviewService: ObservableObject {
    static let shared = ReviewService()

    private static let suiteName = "group.com.chadnewbry.suhoor"
    private let streakKey = "fasting_streak"
    private let lastReviewPromptKey = "last_review_prompt_date"
    private let paywallShownAfterStreakKey = "paywall_shown_after_5day_streak"

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: Self.suiteName)
    }

    var consecutiveFastingDays: Int {
        defaults?.integer(forKey: streakKey) ?? 0
    }

    private var lastReviewPromptDate: Date? {
        get { UserDefaults.standard.object(forKey: lastReviewPromptKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: lastReviewPromptKey) }
    }

    var hasShownPaywallAfterStreak: Bool {
        get { UserDefaults.standard.bool(forKey: paywallShownAfterStreakKey) }
        set { UserDefaults.standard.set(newValue, forKey: paywallShownAfterStreakKey) }
    }

    private init() {}

    /// Call when user logs a fast for today. Increments the shared streak counter.
    func logFastingDay() {
        let current = consecutiveFastingDays
        defaults?.set(current + 1, forKey: streakKey)
    }

    /// Call when user breaks streak (skips a day)
    func resetStreak() {
        defaults?.set(0, forKey: streakKey)
    }

    /// Whether we should show the paywall (after 5th consecutive day)
    var shouldShowPaywallForStreak: Bool {
        consecutiveFastingDays >= 5 && !hasShownPaywallAfterStreak && !StoreService.shared.isPro
    }

    /// Whether we should prompt for App Store review (after 7th consecutive day)
    var shouldPromptReview: Bool {
        guard consecutiveFastingDays >= 7 else { return false }

        // Don't prompt more than once per 90 days
        if let last = lastReviewPromptDate,
           Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0 < 90 {
            return false
        }

        return true
    }

    /// Request an App Store review
    func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return
        }
        lastReviewPromptDate = Date()
        AppStore.requestReview(in: scene)
    }

    /// Call after logging a fast to check all triggers (paywall + review).
    /// Returns true if a paywall should be shown.
    func checkPostFastingTriggers() -> Bool {
        if shouldPromptReview {
            requestReview()
        }
        return shouldShowPaywallForStreak
    }
}
