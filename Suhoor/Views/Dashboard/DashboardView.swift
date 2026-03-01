import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Decorative stars
                HStack {
                    Spacer()
                    Image(systemName: "sparkle")
                        .font(.caption2)
                        .foregroundStyle(Color.suhoorGold.opacity(0.2))
                        .offset(x: -20, y: 8)
                    Image(systemName: "sparkle")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorGold.opacity(0.15))
                        .offset(x: 10, y: -5)
                }
                .padding(.top, 8)
                
                // MARK: - Live Countdown Hero
                CountdownArcView(
                    progress: viewModel.fastingProgress,
                    label: viewModel.countdownLabel,
                    hours: viewModel.countdownFormatted.hours,
                    minutes: viewModel.countdownFormatted.minutes,
                    seconds: viewModel.countdownFormatted.seconds
                )
                .padding(.top, 8)
                .contentShape(Circle())
                
                // MARK: - Ramadan Day Card
                RamadanDayCard(fastingDay: viewModel.fastingDay)
                
                // MARK: - Next Prayer Card
                NextPrayerCard(
                    nextPrayer: viewModel.nextPrayer,
                    allPrayers: viewModel.prayerTimes,
                    now: viewModel.now,
                    expanded: $viewModel.showAllPrayers
                )
                
                // MARK: - Daily Verse
                DailyVerseCard(verse: viewModel.verse)
                
                // MARK: - Quick Stats
                QuickStatsRow(
                    fastsCompleted: viewModel.fastsCompleted,
                    streak: viewModel.currentStreak,
                    quranJuz: viewModel.quranJuz,
                    deedsToday: viewModel.deedsToday
                )
                
                // MARK: - Deed of the Day
                DeedOfTheDayCard(deed: viewModel.deed)
                
                Spacer(minLength: 30)
            }
            .padding(.horizontal, 20)
        }
        .refreshable {
            viewModel.refresh()
        }
        .background(Color.suhoorIndigo.ignoresSafeArea())
    }
}

#Preview {
    DashboardView()
        .preferredColorScheme(.dark)
}
