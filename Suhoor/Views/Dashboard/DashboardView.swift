import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
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

                    // MARK: - Location & Times Header
                    LocationHeader(
                        cityName: viewModel.locationName,
                        sehriTime: viewModel.sehriTimeFormatted,
                        iftarTime: viewModel.iftarTimeFormatted,
                        streak: viewModel.currentStreak
                    )

                    if viewModel.isRamadan {
                        ramadanContent
                    } else {
                        nonRamadanContent
                    }

                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
            }
            .refreshable {
                viewModel.refresh()
            }
            .background(
                (viewModel.isNightMode ? Color.suhoorNight : Color.suhoorIndigo)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 1.0), value: viewModel.isNightMode)
            )
        }
    }

    // MARK: - Ramadan Content

    @ViewBuilder
    private var ramadanContent: some View {
        // Live Countdown Hero
        CountdownArcView(
            progress: viewModel.fastingProgress,
            label: viewModel.countdownLabel,
            hours: viewModel.countdownFormatted.hours,
            minutes: viewModel.countdownFormatted.minutes,
            seconds: viewModel.countdownFormatted.seconds,
            isNightMode: viewModel.isNightMode
        )
        .padding(.top, 8)

        // Ramadan Day Card
        RamadanDayCard(fastingDay: viewModel.fastingDay)

        // Next Prayer Card
        NextPrayerCard(
            nextPrayer: viewModel.nextPrayer,
            allPrayers: viewModel.prayerTimes,
            now: viewModel.now,
            expanded: $viewModel.showAllPrayers
        )

        // Daily Verse
        DailyVerseCard(verse: viewModel.verse)

        // Quick Stats
        QuickStatsRow(
            fastsCompleted: viewModel.fastsCompleted,
            streak: viewModel.currentStreak,
            quranJuz: viewModel.quranJuz,
            deedsToday: viewModel.deedsToday
        )

        // Deed of the Day
        DeedOfTheDayCard(deed: viewModel.deed)
    }

    // MARK: - Non-Ramadan Content

    @ViewBuilder
    private var nonRamadanContent: some View {
        // Countdown to next Ramadan
        VStack(spacing: 16) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.suhoorGold.opacity(0.5))
                .padding(.top, 20)

            Text("Ramadan starts in")
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.suhoorTextSecondary)

            Text("\(viewModel.daysUntilRamadan) days")
                .font(.system(size: 56, weight: .ultraLight, design: .rounded))
                .foregroundStyle(Color.suhoorGold)

            Text("Keep preparing with daily prayers")
                .font(.subheadline)
                .foregroundStyle(Color.suhoorTextSecondary)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.suhoorSurface, in: RoundedRectangle(cornerRadius: 20))

        // Prayer times still shown outside Ramadan
        NextPrayerCard(
            nextPrayer: viewModel.nextPrayer,
            allPrayers: viewModel.prayerTimes,
            now: viewModel.now,
            expanded: $viewModel.showAllPrayers
        )

        DailyVerseCard(verse: viewModel.verse)
    }
}

// MARK: - Location Header

private struct LocationHeader: View {
    let cityName: String
    let sehriTime: String
    let iftarTime: String
    let streak: Int

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.suhoorGold.opacity(0.7))
                    Text(cityName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.suhoorTextPrimary)
                }
                HStack(spacing: 12) {
                    Label(sehriTime, systemImage: "sun.horizon")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                    Label(iftarTime, systemImage: "sunset")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
            }
            Spacer()
            if streak > 0 {
                Text("🔥 \(streak)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.suhoorAmber)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.suhoorAmber.opacity(0.12), in: Capsule())
            }
        }
    }
}

#Preview {
    DashboardView()
        .preferredColorScheme(.dark)
}
