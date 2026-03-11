import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            SuhoorPlanningView()
                .navigationTitle("Dashboard")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.suhoorIndigo, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview {
    DashboardView()
}
