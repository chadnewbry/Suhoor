import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = StoreService.shared
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorText = ""

    var body: some View {
        ZStack {
            // Background
            backgroundGradient

            ScrollView {
                VStack(spacing: 24) {
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

                    // Header
                    headerSection

                    // Feature comparison
                    featureComparisonSection

                    // Subscription cards
                    subscriptionCards

                    // CTA Button
                    purchaseButton

                    // Restore + Legal
                    footerLinks
                }
                .padding()
            }
        }
        .task {
            await store.loadProducts()
            // Default select annual
            if selectedProduct == nil {
                selectedProduct = store.annualProduct
            }
        }
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorText)
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.03, blue: 0.15),
                    Color(red: 0.08, green: 0.07, blue: 0.22),
                    Color(red: 0.05, green: 0.04, blue: 0.16)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Stars
            GeometryReader { geo in
                ForEach(0..<30, id: \.self) { i in
                    Circle()
                        .fill(.white.opacity(Double.random(in: 0.1...0.4)))
                        .frame(width: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height * 0.5)
                        )
                }
            }

            // Crescent moon
            VStack {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.suhoorGold, Color.suhoorAmber],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.suhoorGold.opacity(0.4), radius: 20)
                    .padding(.top, 40)
                Spacer()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 60)

            Text("Make This Ramadan\nYour Best")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)

            Text("Unlock the full Suhoor experience")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
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
                    .frame(width: 50)
                Text("Pro")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.suhoorGold)
                    .frame(width: 50)
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
                        .frame(width: 50)
                    featureIcon(row.pro)
                        .frame(width: 50)
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

    // MARK: - Subscription Cards

    private var subscriptionCards: some View {
        VStack(spacing: 12) {
            if let monthly = store.monthlyProduct {
                subscriptionCard(
                    product: monthly,
                    title: "Monthly",
                    price: monthly.displayPrice,
                    subtitle: "per month",
                    badge: nil,
                    hasTrial: true
                )
            }

            if let annual = store.annualProduct {
                subscriptionCard(
                    product: annual,
                    title: "Annual",
                    price: annual.displayPrice,
                    subtitle: "per year",
                    badge: "BEST VALUE",
                    hasTrial: true
                )
            }

            if let lifetime = store.lifetimeProduct {
                subscriptionCard(
                    product: lifetime,
                    title: "Lifetime",
                    price: lifetime.displayPrice,
                    subtitle: "one-time purchase",
                    badge: nil,
                    hasTrial: false
                )
            }
        }
    }

    private func subscriptionCard(
        product: Product,
        title: String,
        price: String,
        subtitle: String,
        badge: String?,
        hasTrial: Bool
    ) -> some View {
        let isSelected = selectedProduct?.id == product.id
        let isAnnual = product.id == SuhoorProduct.proAnnual.rawValue

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedProduct = product
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)

                        if let badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.suhoorGold)
                                .clipShape(Capsule())
                        }

                        if hasTrial {
                            Text("3-day free trial")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(Color.suhoorGold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.suhoorGold.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                Text(price)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(isSelected ? Color.suhoorGold : .white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.suhoorGold.opacity(0.12) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Color.suhoorGold : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .scaleEffect(isAnnual && isSelected ? 1.02 : 1.0)
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        Button {
            guard let product = selectedProduct else { return }
            isPurchasing = true
            Task {
                do {
                    let success = try await store.purchase(product)
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
                    Text(selectedProduct?.id == SuhoorProduct.proLifetime.rawValue
                        ? "Purchase Lifetime Access"
                        : "Start Free Trial")
                        .font(.body.weight(.bold))
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
        }
        .disabled(selectedProduct == nil || isPurchasing)
    }

    // MARK: - Footer

    private var footerLinks: some View {
        VStack(spacing: 8) {
            Button("Restore Purchases") {
                Task { await store.restorePurchases() }
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

            Text("Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.")
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.25))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
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
    .init(name: "Fasting History", free: .limited("Current"), pro: .yes),
    .init(name: "Duas Collection", free: .limited("5"), pro: .yes),
    .init(name: "Dua Audio", free: .no, pro: .yes),
    .init(name: "Khatam Tracker", free: .no, pro: .yes),
    .init(name: "Meal Suggestions", free: .no, pro: .yes),
    .init(name: "Hydration Tracker", free: .no, pro: .yes),
    .init(name: "Deeds Checklist", free: .no, pro: .yes),
    .init(name: "Laylat al-Qadr Content", free: .no, pro: .yes),
    .init(name: "Widget Sizes", free: .limited("Small"), pro: .yes),
    .init(name: "Watch Complication", free: .no, pro: .yes),
    .init(name: "Azan Sounds", free: .limited("1"), pro: .yes),
    .init(name: "Color Themes", free: .limited("1"), pro: .yes),
]

// MARK: - Paywall Trigger Modifier

struct ProFeatureGate: ViewModifier {
    @ObservedObject var store = StoreService.shared
    @State private var showPaywall = false

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                if !store.isPro {
                    showPaywall = true
                }
            }
            .allowsHitTesting(!store.isPro)
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
            }
    }
}

extension View {
    /// Gates this view behind a Pro subscription. Shows paywall on tap if not Pro.
    func requiresPro() -> some View {
        modifier(ProFeatureGate())
    }

    /// Overlays a lock badge if not Pro.
    func proLockOverlay() -> some View {
        overlay(alignment: .topTrailing) {
            if !StoreService.shared.isPro {
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
