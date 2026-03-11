import SwiftUI
import StoreKit

struct SubscriptionSettingsView: View {
    @ObservedObject private var store = StoreService.shared
    @State private var isRestoring = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    @State private var showPaywall = false

    var body: some View {
        List {
            Section {
                HStack {
                    Label("Current Plan", systemImage: "sparkles")
                    Spacer()
                    Text(currentPlanName)
                        .foregroundStyle(store.isPro ? Color.suhoorGold : .secondary)
                }

                if !store.isPro {
                    Button {
                        showPaywall = true
                    } label: {
                        Label("Upgrade to Pro", systemImage: "crown.fill")
                            .foregroundStyle(Color.suhoorGold)
                    }
                }

                if store.isPro {
                    Button {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            Task {
                                try? await AppStore.showManageSubscriptions(in: windowScene)
                            }
                        }
                    } label: {
                        Label("Manage Subscription", systemImage: "creditcard")
                    }
                }

                Button {
                    restorePurchases()
                } label: {
                    if isRestoring {
                        HStack {
                            Label("Restoring...", systemImage: "arrow.clockwise")
                            Spacer()
                            ProgressView()
                        }
                    } else {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }
                }
                .disabled(isRestoring)
            } header: {
                Text("Subscription")
            }
            .listRowBackground(Color.suhoorSurface)
        }
        .scrollContentBackground(.hidden)
        .background(Color.suhoorIndigo)
        .foregroundStyle(Color.suhoorTextPrimary)
        .navigationTitle("Subscription")
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK") {}
        } message: {
            Text(restoreMessage)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var currentPlanName: String {
        if store.purchasedProductIDs.contains(SuhoorProduct.proLifetime.rawValue) {
            return "Pro (Lifetime)"
        } else if store.purchasedProductIDs.contains(SuhoorProduct.proAnnual.rawValue) {
            return "Pro (Annual)"
        } else if store.purchasedProductIDs.contains(SuhoorProduct.proMonthly.rawValue) {
            return "Pro (Monthly)"
        }
        return "Free"
    }

    private func restorePurchases() {
        isRestoring = true
        Task {
            await store.restorePurchases()
            restoreMessage = store.isPro
                ? "Purchases restored successfully! Welcome back."
                : "No previous purchases found."
            isRestoring = false
            showRestoreAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        SubscriptionSettingsView()
    }
}
