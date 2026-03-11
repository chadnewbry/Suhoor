import SwiftUI

/// Wraps content that requires Pro. Shows a blurred preview with upgrade prompt if not Pro.
struct ProFeatureOverlayView<Content: View>: View {
    @ObservedObject private var store = StoreService.shared
    @State private var showPaywall = false
    let featureName: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        if store.isPro {
            content()
        } else {
            content()
                .blur(radius: 3)
                .allowsHitTesting(false)
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundStyle(Color.suhoorGold)

                        Text("Pro Feature")
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text(featureName)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))

                        Button {
                            showPaywall = true
                        } label: {
                            Text("Upgrade")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.suhoorGold)
                                .clipShape(Capsule())
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                    )
                }
                .fullScreenCover(isPresented: $showPaywall) {
                    PaywallView()
                }
        }
    }
}
