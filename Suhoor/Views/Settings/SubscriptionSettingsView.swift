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
                    Label("Status", systemImage: "sparkles")
                    Spacer()
                    Text(statusText)
                        .foregroundStyle(store.isPurchased ? Color.suhoorGold : .secondary)
                }

                if !store.isPurchased {
                    if store.isInFreeTier {
                        HStack {
                            Label("Free Days Remaining", systemImage: "calendar.badge.clock")
                            Spacer()
                            Text("\(store.freeDaysRemaining) of \(StoreService.maxFreeDays)")
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button {
                        showPaywall = true
                    } label: {
                        Label("Upgrade to Premium — $2.99", systemImage: "crown.fill")
                            .foregroundStyle(Color.suhoorGold)
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
                Text("Premium")
            }
            .listRowBackground(Color.suhoorSurface)
        }
        .scrollContentBackground(.hidden)
        .background(Color.suhoorIndigo)
        .foregroundStyle(Color.suhoorTextPrimary)
        .navigationTitle("Premium")
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK") {}
        } message: {
            Text(restoreMessage)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var statusText: String {
        if store.isPurchased {
            return "Premium (Lifetime)"
        } else if store.isInFreeTier {
            return "Free Trial"
        }
        return "Free"
    }

    private func restorePurchases() {
        isRestoring = true
        Task {
            await store.restorePurchases()
            restoreMessage = store.isPurchased
                ? "Purchase restored successfully! Welcome back."
                : "No previous purchase found."
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
