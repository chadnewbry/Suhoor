import SwiftUI
import StoreKit

struct SubscriptionSettingsView: View {
    @State private var isRestoring = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""

    var body: some View {
        List {
            Section {
                HStack {
                    Label("Current Plan", systemImage: "sparkles")
                    Spacer()
                    Text("Free")
                        .foregroundStyle(.secondary)
                }

                Button {
                    // Opens StoreKit subscription management
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        Task {
                            try? await AppStore.showManageSubscriptions(in: windowScene)
                        }
                    }
                } label: {
                    Label("Manage Subscription", systemImage: "creditcard")
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
        .foregroundStyle(.suhoorTextPrimary)
        .navigationTitle("Subscription")
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK") {}
        } message: {
            Text(restoreMessage)
        }
    }

    private func restorePurchases() {
        isRestoring = true
        Task {
            do {
                try await AppStore.sync()
                restoreMessage = "Purchases restored successfully."
            } catch {
                restoreMessage = "Unable to restore purchases. Please try again later."
            }
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
