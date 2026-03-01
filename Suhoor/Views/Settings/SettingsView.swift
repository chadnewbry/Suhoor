import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.suhoorIndigo.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Settings")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Color.suhoorTextPrimary)
                Text("Coming soon")
                    .font(.subheadline)
                    .foregroundStyle(Color.suhoorTextSecondary)
            }
        }
    }
}

#Preview {
    SettingsView()
}
