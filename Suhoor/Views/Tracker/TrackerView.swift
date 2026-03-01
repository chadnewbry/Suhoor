import SwiftUI

struct TrackerView: View {
    private let dataManager = DataManager.shared
    private let hijriService = HijriCalendarService.shared

    private var ramadanYear: Int {
        hijriService.currentRamadanHijriYear(adjustment: UserSettings.shared.hijriAdjustment)
    }

    @State private var selectedSection = 0

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

                // Section picker
                Picker("Section", selection: $selectedSection) {
                    Text("Fasting").tag(0)
                    Text("Deeds").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if selectedSection == 0 {
                    // FASTING TRACKER
                    
                    // Daily Fast Log
                    DailyFastLogView(
                        dataManager: dataManager,
                        ramadanYear: ramadanYear
                    )
                    .padding(.horizontal)

                    // Fasting Streak
                    FastingStreakView(
                        dataManager: dataManager,
                        ramadanYear: ramadanYear
                    )
                    .padding(.horizontal)

                    // Ramadan Calendar
                    RamadanCalendarView(
                        dataManager: dataManager,
                        ramadanYear: ramadanYear
                    )
                    .padding(.horizontal)

                    // Ashra Progress
                    AshraProgressView(
                        dataManager: dataManager,
                        ramadanYear: ramadanYear
                    )
                    .padding(.horizontal)

                    // Makeup Fast Tracker
                    MakeupFastTrackerView(dataManager: dataManager)
                        .padding(.horizontal)

                    // HealthKit Sync
                    HealthKitSyncView()
                        .padding(.horizontal)

                } else {
                    // DEEDS & ANALYTICS (existing)
                    
                    RamadanScorecardView(
                        dataManager: dataManager,
                        ramadanYear: ramadanYear
                    )
                    .padding(.horizontal)

                    DailyDeedsView(
                        dataManager: dataManager,
                        date: Date(),
                        ramadanYear: ramadanYear
                    )
                    .padding(.horizontal)

                    BadgesGridView(
                        dataManager: dataManager,
                        ramadanYear: ramadanYear
                    )
                    .padding(.horizontal)

                    YearComparisonView(
                        dataManager: dataManager,
                        currentYear: ramadanYear
                    )
                    .padding(.horizontal)

                    ShareableSummaryView(
                        dataManager: dataManager,
                        ramadanYear: ramadanYear
                    )
                    .padding(.horizontal)
                }

                Spacer(minLength: 32)
            }
            .padding(.top)
        }
        .background(Color.suhoorIndigo.ignoresSafeArea())
        .onAppear {
            dataManager.checkAndAwardStreakBadges(ramadanYear: ramadanYear)
            dataManager.checkAndAwardKhatamBadge(ramadanYear: ramadanYear)
            dataManager.checkAndAwardDeedMasterBadge(ramadanYear: ramadanYear)
        }
    }
}

#Preview {
    TrackerView()
}
