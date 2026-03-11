import SwiftUI

struct WatchContentView: View {
    @State private var data: SharedData?
    @State private var hasFastedToday: Bool = false
    
    init() {
        let defaults = UserDefaults(suiteName: SharedData.suiteName)
        let todayKey = Self.todayFastingKey()
        _hasFastedToday = State(initialValue: defaults?.bool(forKey: todayKey) ?? false)
    }
    
    var body: some View {
        NavigationStack {
            if let data {
                ScrollView {
                    VStack(spacing: 12) {
                        // Header
                        Text("Ramadan Day \(data.ramadanDay)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        // Countdown card
                        countdownCard(data: data)
                        
                        // Prayer times list
                        prayerTimesList(data: data)
                        
                        // Fasting toggle
                        fastingToggle()
                    }
                    .padding(.horizontal, 4)
                }
                .navigationTitle("Suhoor")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                VStack(spacing: 8) {
                    Text("🌙")
                        .font(.title2)
                    Text("Suhoor")
                        .font(.headline)
                    Text("Open app to sync")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            data = SharedData.load()
        }
    }
    
    @ViewBuilder
    private func countdownCard(data: SharedData) -> some View {
        VStack(spacing: 4) {
            Text("🌙 \(data.nextPrayerName)")
                .font(.headline)
            
            Text(data.nextPrayerTime, style: .time)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(data.nextPrayerTime, style: .timer)
                .font(.title3.weight(.bold).monospacedDigit())
                .foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.32))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    @ViewBuilder
    private func prayerTimesList(data: SharedData) -> some View {
        VStack(spacing: 0) {
            ForEach(data.upcomingPrayers) { prayer in
                HStack {
                    Text(prayer.emoji)
                        .font(.caption2)
                    Text(prayer.name)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(prayer.isPassed ? .secondary : .primary)
                    Spacer()
                    Text(prayer.time, style: .time)
                        .font(.caption2)
                        .foregroundStyle(prayer.isPassed ? .tertiary : .secondary)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                
                if prayer.id != data.upcomingPrayers.last?.id {
                    Divider().background(Color.white.opacity(0.08))
                }
            }
        }
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    @ViewBuilder
    private func fastingToggle() -> some View {
        Button {
            hasFastedToday.toggle()
            let defaults = UserDefaults(suiteName: SharedData.suiteName)
            defaults?.set(hasFastedToday, forKey: Self.todayFastingKey())
        } label: {
            HStack {
                Image(systemName: hasFastedToday ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(hasFastedToday ? Color(red: 0.30, green: 0.78, blue: 0.55) : .secondary)
                Text(hasFastedToday ? "Fasted Today ✓" : "Mark as Fasted")
                    .font(.caption.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
    
    private static func todayFastingKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "fasted_\(formatter.string(from: Date()))"
    }
}

#Preview {
    WatchContentView()
}
