import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.suhoorIndigo.ignoresSafeArea()
                List {
                    Section {
                        NavigationLink {
                            NotificationSettingsView()
                        } label: {
                            Label("Notifications", systemImage: "bell.badge")
                        }
                    }
                    
                    Section {
                        Label("Location", systemImage: "location")
                        Label("Calculation Method", systemImage: "function")
                    } header: {
                        Text("Prayer Times")
                    }
                    
                    Section {
                        Label("About Suhoor", systemImage: "info.circle")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
