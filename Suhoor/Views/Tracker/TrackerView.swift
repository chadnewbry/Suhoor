import SwiftUI

struct TrackerView: View {
    @State private var store = FastingStore()
    @State private var selectedDay: FastingDay?
    @State private var showConfetti = false
    @State private var celebratedMilestone: Int?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.suhoorIndigo.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Summary Stats
                        FastingStatsBar(
                            totalFasted: store.totalFasted,
                            currentStreak: store.currentStreak,
                            longestStreak: store.longestStreak
                        )

                        // Ramadan Grid
                        RamadanGridView(
                            days: store.days,
                            currentDay: store.currentDayNumber,
                            onDayTap: { day in selectedDay = day }
                        )

                        // Ashra Progress
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ashra Progress")
                                .font(.headline)
                                .foregroundStyle(Color.suhoorTextPrimary)

                            ForEach(Ashra.allCases) { ashra in
                                AshraCard(ashra: ashra, completion: store.ashraCompletion(ashra))
                            }
                        }
                        .padding(.horizontal)

                        // Menstrual Mode
                        if store.menstrualModeEnabled {
                            MenstrualModeSection(store: store)
                        }

                        // Makeup Fasts
                        if !store.makeupFasts.isEmpty {
                            MakeupFastSection(store: store)
                        }
                    }
                    .padding(.vertical)
                }

                // Confetti overlay
                if showConfetti {
                    ConfettiView()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
            .navigationTitle("Fasting Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedDay) { day in
                FastingLogSheet(day: day, store: store)
                    .presentationDetents([.medium])
            }
            .onAppear {
                HealthKitService.shared.requestAuthorization()
            }
            .onChange(of: store.currentStreak) { _, newStreak in
                checkMilestone(newStreak)
            }
        }
    }

    private func checkMilestone(_ streak: Int) {
        let milestones = [7, 15, 21, 30]
        if milestones.contains(streak), celebratedMilestone != streak {
            celebratedMilestone = streak
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showConfetti = false
            }
        }
    }
}

// MARK: - Stats Bar

struct FastingStatsBar: View {
    let totalFasted: Int
    let currentStreak: Int
    let longestStreak: Int

    var body: some View {
        HStack(spacing: 0) {
            StatItem(value: "\(totalFasted)/30", label: "Fasted")
            Divider().frame(height: 40).background(Color.suhoorDivider)
            StatItem(value: "\(currentStreak)", label: "Streak")
            Divider().frame(height: 40).background(Color.suhoorDivider)
            StatItem(value: "\(longestStreak)", label: "Best")
        }
        .padding(.vertical, 12)
        .background(Color.suhoorSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.suhoorGold)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.suhoorTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TrackerView()
        .preferredColorScheme(.dark)
}
