import SwiftUI

// QuranView is now split into:
// - QuranTabView (container with Reading Plan / Duas segments)
// - QuranReadingPlanView (30-day reading plan with progress)
// - ReadingSessionView (reading session with timer and page logging)
// - DuasView (duas collection, unchanged)
//
// This file is kept for backward compatibility.

struct QuranView: View {
    var body: some View {
        QuranReadingPlanView()
    }
}

#Preview {
    NavigationStack {
        QuranView()
    }
}
