import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: StoreService
    @State private var selectedTab = 0
    @State private var showPaywall = false

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "building.columns")
                }
                .tag(0)

            TrackerView()
                .tabItem {
                    Label("Tracker", systemImage: "timer")
                }
                .tag(1)

            QuranTabView()
                .tabItem {
                    Label("Quran", systemImage: "book")
                }
                .tag(2)

            CalendarTabView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(4)
        }
        .tint(.suhoorGold)
        .overlay(alignment: .top) {
            if !store.isPurchased {
                freeDaysBanner
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
        .task {
            await store.refreshEntitlements()
            await store.loadProducts()
            store.recordAppUsageDay()
        }
    }

    // MARK: - Free Days Banner

    private var freeDaysBanner: some View {
        Group {
            if store.isInFreeTier {
                Button {
                    showPaywall = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                        Text("\(store.freeDaysRemaining) free day\(store.freeDaysRemaining == 1 ? "" : "s") remaining")
                            .font(.caption.weight(.medium))
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [Color.suhoorGold, Color.suhoorAmber],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.suhoorGold.opacity(0.3), radius: 8)
                }
                .padding(.top, 4)
            } else if store.shouldShowPaywall {
                Button {
                    showPaywall = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                        Text("Upgrade to Premium")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [Color.suhoorGold, Color.suhoorAmber],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.suhoorGold.opacity(0.3), radius: 8)
                }
                .padding(.top, 4)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(StoreService.shared)
}
