import SwiftUI
import StoreKit

struct SettingsView: View {
    @StateObject private var settings = AppSettings.shared
    var body: some View {
        NavigationStack {
            ZStack {
                Color.suhoorIndigo.ignoresSafeArea()
                
                List {
                    // MARK: - Prayer Times
                    Section {
                        NavigationLink {
                            PrayerTimeSettingsView()
                        } label: {
                            Label("Prayer Time Configuration", systemImage: "function")
                        }
                    } header: {
                        Text("Prayer Times")
                    }
                    .listRowBackground(Color.suhoorSurface)

                    // MARK: - Notifications
                    Section {
                        NavigationLink {
                            NotificationSettingsView()
                        } label: {
                            Label("Notifications", systemImage: "bell.badge")
                        }
                    } header: {
                        Text("Notifications")
                    }
                    .listRowBackground(Color.suhoorSurface)

                    // MARK: - Fasting
                    Section {
                        NavigationLink {
                            FastingSettingsView()
                        } label: {
                            Label("Fasting Settings", systemImage: "moon.haze")
                        }

                    } header: {
                        Text("Fasting")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
