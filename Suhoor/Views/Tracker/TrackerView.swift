import SwiftUI

struct TrackerView: View {
    private let dataManager = DataManager.shared
    // TODO: Calculate actual Hijri Ramadan year; using Gregorian year for now
    private let ramadanYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tracker")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(Color.suhoorTextPrimary)
                        Text("Ramadan \(String(ramadanYear))")
                            .font(.subheadline)
                            .foregroundStyle(Color.suhoorTextSecondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // Ramadan Scorecard
                RamadanScorecardView(
                    dataManager: dataManager,
                    ramadanYear: ramadanYear
                )
                .padding(.horizontal)

                // Daily Deeds Checklist
                DailyDeedsView(
                    dataManager: dataManager,
                    date: Date(),
                    ramadanYear: ramadanYear
                )
                .padding(.horizontal)

                // Badges Grid
                BadgesGridView(
                    dataManager: dataManager,
                    ramadanYear: ramadanYear
                )
                .padding(.horizontal)

                // Year over Year Comparison
                YearComparisonView(
                    dataManager: dataManager,
                    currentYear: ramadanYear
                )
                .padding(.horizontal)

                // Share Button
                ShareableSummaryView(
                    dataManager: dataManager,
                    ramadanYear: ramadanYear
                )
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding(.top)
        }
        .background(Color.suhoorIndigo.ignoresSafeArea())
        .onAppear {
            // Check and award badges on view appearance
            dataManager.checkAndAwardStreakBadges(ramadanYear: ramadanYear)
            dataManager.checkAndAwardKhatamBadge(ramadanYear: ramadanYear)
            dataManager.checkAndAwardDeedMasterBadge(ramadanYear: ramadanYear)
        }
    }
}

#Preview {
    TrackerView()
}
