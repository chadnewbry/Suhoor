import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: StoreService
    @State private var selectedTab = 0
    @State private var showPaywall = false
    @State private var hasShownOnboardingPaywall = false

    private let onboardingPaywallKey = "has_shown_onboarding_paywall"

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
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear {
            // Show paywall after onboarding (first launch), soft/dismissible
            if !UserDefaults.standard.bool(forKey: onboardingPaywallKey) && !store.isPro {
                UserDefaults.standard.set(true, forKey: onboardingPaywallKey)
                // Slight delay so the app loads first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showPaywall = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(StoreService.shared)
}
