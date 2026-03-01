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
        return count
    }
    
    private var totalFasted: Int {
        fastingDays.values.filter { $0 == .fasted }.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats
                    HStack(spacing: 16) {
                        statCard(title: "Current Streak", value: "\(streak)", icon: "flame.fill")
                        statCard(title: "Days Fasted", value: "\(totalFasted)/30", icon: "checkmark.circle.fill")
                    }
                    .padding(.horizontal)
                    
                    // Calendar grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                        ForEach(1...30, id: \.self) { day in
                            dayCell(day: day)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Legend
                    HStack(spacing: 16) {
                        legendItem(color: .suhoorSuccess, label: "Fasted")
                        legendItem(color: .red.opacity(0.7), label: "Missed")
                        legendItem(color: .orange.opacity(0.7), label: "Excused")
                    }
                    .font(.caption)
                    .foregroundStyle(Color.suhoorTextSecondary)
                }
                .padding(.vertical)
            }
            .background(Color.suhoorIndigo.ignoresSafeArea())
            .navigationTitle("Fasting Tracker")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear { loadDays() }
    }
    
    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.suhoorGold)
            Text(value)
                .font(.title.weight(.bold))
                .foregroundStyle(Color.suhoorTextPrimary)
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.suhoorTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.suhoorSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func dayCell(day: Int) -> some View {
        Button {
            cycleFastingStatus(for: day)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorForDay(day))
                    .frame(height: 44)
                
                VStack(spacing: 2) {
                    Text("\(day)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.suhoorTextPrimary)
                    if let status = fastingDays[day] {
                        Circle()
                            .fill(statusColor(status))
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
    }
    
    private func colorForDay(_ day: Int) -> Color {
        if day == currentDay {
            return Color.suhoorGold.opacity(0.2)
        }
        return Color.suhoorSurface
    }
    
    private func statusColor(_ status: FastingStatus) -> Color {
        switch status {
        case .fasted: return .suhoorSuccess
        case .missed: return .red.opacity(0.7)
        case .excused: return .orange.opacity(0.7)
        }
    }
    
    private func cycleFastingStatus(for day: Int) {
        guard day <= currentDay else { return }
        let allStatuses = FastingStatus.allCases
        if let current = fastingDays[day], let idx = allStatuses.firstIndex(of: current) {
            let next = (idx + 1) % allStatuses.count
            if next == 0 {
                fastingDays.removeValue(forKey: day)
            } else {
                fastingDays[day] = allStatuses[next]
            }
        } else {
            fastingDays[day] = .fasted
        }
        saveDays()
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
        }
    }
    
    // Persistence
    private static let storageKey = "suhoor_fasting_tracker"
    
    private func saveDays() {
        let data = fastingDays.mapValues { $0.rawValue }
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: Self.storageKey)
        }
    }
    
    private func loadDays() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let decoded = try? JSONDecoder().decode([Int: String].self, from: data) else { return }
        fastingDays = decoded.compactMapValues { FastingStatus(rawValue: $0) }
    }
}

#Preview {
    TrackerView()
}
