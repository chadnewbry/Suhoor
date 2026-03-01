import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
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
            
            QuranView()
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
    }
}

#Preview {
    ContentView()
}
