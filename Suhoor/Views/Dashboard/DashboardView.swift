import SwiftUI

struct DashboardView: View {
    var body: some View {
        ZStack {
            Color.suhoorIndigo.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Dashboard")
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
    DashboardView()
}
