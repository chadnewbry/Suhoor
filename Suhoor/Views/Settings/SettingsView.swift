import SwiftUI

struct SettingsView: View {
    @State private var menstrualMode = UserDefaults.standard.bool(forKey: "suhoor_menstrual_mode")
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.suhoorIndigo.ignoresSafeArea()
                
                List {
                    Section("Fasting") {
                        Toggle(isOn: $menstrualMode) {
                            Label("Menstrual Mode", systemImage: "heart.fill")
                        }
                        .tint(.pink)
                        .onChange(of: menstrualMode) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: "suhoor_menstrual_mode")
                        }
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
