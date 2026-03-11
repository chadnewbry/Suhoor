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
                    .listRowBackground(Color.suhoorSurface)

                    // MARK: - Display
                    Section {
                        NavigationLink {
                            DisplaySettingsView()
                        } label: {
                            Label("Display & Appearance", systemImage: "paintbrush")
                        }
                    } header: {
                        Text("Display")
                    }
                    .listRowBackground(Color.suhoorSurface)

                    // MARK: - Subscription
                    Section {
                        NavigationLink {
                            SubscriptionSettingsView()
                        } label: {
                            Label("Subscription", systemImage: "crown")
                        }
                    } header: {
                        Text("Subscription")
                    }
                    .listRowBackground(Color.suhoorSurface)

                    // MARK: - iCloud Sync
                    Section {
                        HStack {
                            Label("iCloud Sync", systemImage: "icloud")
                            Spacer()
                            Text("Coming Soon")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.suhoorSurface)
                                .clipShape(Capsule())
                        }
                    } header: {
                        Text("Sync")
                    } footer: {
                        Text("CloudKit sync will be available in v1.1")
                    }
                    .listRowBackground(Color.suhoorSurface)

                    // MARK: - Support
                    Section {
                        NavigationLink {
                            SupportView()
                        } label: {
                            Label("Help & Support", systemImage: "questionmark.circle")
                        }
                    } header: {
                        Text("Support")
                    }
                    .listRowBackground(Color.suhoorSurface)

                    // MARK: - Legal
                    Section {
                        Link(destination: URL(string: "https://chadnewbry.github.io/suhoor/privacy")!) {
                            Label("Privacy Policy", systemImage: "hand.raised")
                        }
                        Link(destination: URL(string: "https://chadnewbry.github.io/suhoor/terms")!) {
                            Label("Terms of Use", systemImage: "doc.text")
                        }
                    } header: {
                        Text("Legal")
                    }
                    .listRowBackground(Color.suhoorSurface)

                    // MARK: - About
                    Section {
                        NavigationLink {
                            AboutView()
                        } label: {
                            Label("About Suhoor", systemImage: "info.circle")
                        }
                    }
                    .listRowBackground(Color.suhoorSurface)
                }
                .scrollContentBackground(.hidden)
                .foregroundStyle(Color.suhoorTextPrimary)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
