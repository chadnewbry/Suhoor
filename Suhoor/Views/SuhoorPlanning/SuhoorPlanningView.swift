import SwiftUI

struct SuhoorPlanningView: View {
    @StateObject private var hydrationService = HydrationService.shared
    @StateObject private var checklistService = SehriChecklistService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Section header
                HStack {
                    Text("Suhoor Planning")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.suhoorTextPrimary)
                    Spacer()
                    Text("🌙")
                        .font(.title2)
                }
                .padding(.horizontal, 4)

                // Hydration tracker (Pro)
                ProFeatureOverlayView(featureName: "Hydration Tracker") {
                    HydrationTrackerView(hydrationService: hydrationService)
                }

                // Meal suggestion (Pro)
                ProFeatureOverlayView(featureName: "Meal Suggestions") {
                    SuhoorMealCardView()
                }

                // Pre-sehri checklist (free)
                SehriChecklistView(checklistService: checklistService)

                // Hydration history (Pro)
                ProFeatureOverlayView(featureName: "Hydration History") {
                    HydrationHistoryView(hydrationService: hydrationService)
                }
            }
            .padding(16)
        }
        .background(Color.suhoorIndigo.ignoresSafeArea())
        .accessibilityIdentifier("suhoorPlanningView")
    }
}

#Preview {
    SuhoorPlanningView()
}
