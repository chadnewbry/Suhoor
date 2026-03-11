import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = StoreService.shared
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorText = ""
    @State private var starPositions: [(x: CGFloat, y: CGFloat, opacity: Double, size: CGFloat)] = []

    var body: some View {
        ZStack {
            backgroundGradient

            ScrollView {
                VStack(spacing: 28) {
                    // Close button
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .accessibilityIdentifier("paywall_close")
                    }
                    .padding(.horizontal)

                    headerSection

                    featureComparisonSection

                    purchaseButton

                    footerLinks
                }
                .padding()
            }
        }
        .task {
            await store.loadProducts()
        }
        .onAppear {
            generateStarPositions()
        }
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorText)
        }
    }

    // MARK: - Background

    private func generateStarPositions() {
        starPositions = (0..<40).map { _ in
            (
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...0.5),
                opacity: Double.random(in: 0.1...0.5),
                size: CGFloat.random(in: 1...3)
            )
        }
    }

    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.03, blue: 0.15),
                    Color(red: 0.08, green: 0.05, blue: 0.25),
                    Color(red: 0.05, green: 0.04, blue: 0.16)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Stars
            GeometryReader { geo in
                ForEach(Array(starPositions.enumerated()), id: \.offset) { _, star in
                    Circle()
                        .fill(.white.opacity(star.opacity))
                        .frame(width: star.size)
                        .position(
                            x: star.x * geo.size.width,
                            y: star.y * geo.size.height
                        )
                }
            }

            // Crescent moon
            VStack {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.suhoorGold, Color.suhoorAmber],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.suhoorGold.opacity(0.5), radius: 25)
                    .padding(.top, 50)
                Spacer()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 70)

            Text("Make This Ramadan\nYour Best")
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)

            Text("One purchase. No subscriptions. No ads. Ever.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Feature Comparison

    private var featureComparisonSection: some View {
        VStack(spacing: 0) {
            // Header row
            HStack {
                Text("Features")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
                Text("Free")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 55)
                Text("Premium")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.suhoorGold)
                    .frame(width: 65)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider().background(Color.white.opacity(0.1))

            ForEach(featureRows, id: \.name) { row in
                HStack {
                    Text(row.name)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                    Spacer()
                    featureIcon(row.free)
                        .frame(width: 55)
                    featureIcon(row.pro)
                        .frame(width: 65)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func featureIcon(_ value: FeatureValue) -> some View {
        Group {
            switch value {
            case .yes:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.suhoorSuccess)
                    .font(.caption)
            case .no:
                Image(systemName: "minus.circle")
                    .foregroundStyle(.white.opacity(0.2))
                    .font(.caption)
            case .limited(let text):
                Text(text)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        VStack(spacing: 16) {
            // Price badge
            if let product = store.product {
                Text("One-time purchase")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))

                Button {
                    isPurchasing = true
                    Task {
                        do {
                            let success = try await store.purchase()
                            if success { dismiss() }
                        } catch {
                            errorText = error.localizedDescription
                            showError = true
                        }
                        isPurchasing = false
                    }
                } label: {
                    Group {
                        if isPurchasing {
                            ProgressView()
                                .tint(.black)
                        } else {
                            VStack(spacing: 4) {
                                Text("Unlock Suhoor Premium — \(product.displayPrice)")
                                    .font(.body.weight(.bold))
                                Text("Yours forever. No subscription.")
                                    .font(.caption2)
                                    .opacity(0.7)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.suhoorGold, Color.suhoorAmber],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color.suhoorGold.opacity(0.3), radius: 12)
                }
                .disabled(isPurchasing)
            } else if store.isLoading {
                ProgressView()
                    .tint(.white)
            }
        }
    }

    // MARK: - Footer

    private var footerLinks: some View {
        VStack(spacing: 8) {
            Button("Restore Purchases") {
                Task {
                    await store.restorePurchases()
                    if store.isPurchased { dismiss() }
                }
            }
            .font(.caption)
            .foregroundStyle(.white.opacity(0.5))

            HStack(spacing: 16) {
                Link("Privacy Policy",
                     destination: URL(string: "https://chadnewbry.github.io/suhoor/privacy")!)
                Link("Terms of Use",
                     destination: URL(string: "https://chadnewbry.github.io/suhoor/terms")!)
            }
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.35))
        }
        .padding(.bottom, 16)
    }
}

// MARK: - Feature Comparison Data

private enum FeatureValue {
    case yes, no, limited(String)
}

private struct FeatureRow {
    let name: String
    let free: FeatureValue
    let pro: FeatureValue
}

private let featureRows: [FeatureRow] = [
    .init(name: "Iftar/Sehri Countdown", free: .yes, pro: .yes),
    .init(name: "Prayer Times", free: .yes, pro: .yes),
    .init(name: "Fasting Tracker", free: .limited("5 days"), pro: .yes),
    .init(name: "Quran Reading", free: .limited("5 days"), pro: .yes),
    .init(name: "Quran Khatam Plan", free: .no, pro: .yes),
    .init(name: "Badges & Analytics", free: .no, pro: .yes),
    .init(name: "Year-over-Year Stats", free: .no, pro: .yes),
    .init(name: "Live Activity", free: .no, pro: .yes),
    .init(name: "Widgets", free: .no, pro: .yes),
    .init(name: "Audio Quran Recitation", free: .no, pro: .yes),
    .init(name: "Suhoor Meal Planning", free: .no, pro: .yes),
    .init(name: "Hydration Tracker", free: .no, pro: .yes),
    .init(name: "Apple Watch App", free: .no, pro: .yes),
]

// MARK: - Paywall Trigger Modifier

struct ProFeatureGate: ViewModifier {
    @ObservedObject var store = StoreService.shared
    @State private var showPaywall = false

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                if store.shouldShowPaywall {
                    showPaywall = true
                }
            }
            .allowsHitTesting(!store.shouldShowPaywall)
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
            }
    }
}

extension View {
    /// Gates this view behind Premium. Shows paywall on tap if not premium.
    func requiresPro() -> some View {
        modifier(ProFeatureGate())
    }

    /// Overlays a lock badge if not premium.
    func proLockOverlay() -> some View {
        overlay(alignment: .topTrailing) {
            if !StoreService.shared.isPremium {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(Color.suhoorGold.opacity(0.8))
                    .clipShape(Circle())
                    .padding(6)
            }
        }
    }
}

#Preview {
    PaywallView()
}
