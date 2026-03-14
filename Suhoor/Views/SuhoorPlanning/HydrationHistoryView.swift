import SwiftUI

struct HydrationHistoryView: View {
    @ObservedObject var hydrationService: HydrationService
    
    private var allDays: [SimpleHydrationEntry] {
        var days = hydrationService.weeklyHistory
        days.append(hydrationService.todayEntry)
        return days.suffix(7).sorted { $0.date < $1.date }
    }
    
    private var maxGlasses: Int {
        max(allDays.map(\.target).max() ?? 8, allDays.map(\.glasses).max() ?? 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Hydration")
                .font(.headline)
                .foregroundStyle(Color.suhoorTextPrimary)
            
            if allDays.isEmpty {
                Text("Start tracking to see your history")
                    .font(.caption)
                    .foregroundStyle(Color.suhoorTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(allDays) { entry in
                        VStack(spacing: 6) {
                            // Bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(barColor(for: entry))
                                .frame(height: barHeight(for: entry))
                            
                            // Day label
                            Text(dayLabel(for: entry.date))
                                .font(.system(size: 10))
                                .foregroundStyle(Color.suhoorTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 100)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.suhoorSurface)
        )
    }
    
    private func barHeight(for entry: SimpleHydrationEntry) -> CGFloat {
        guard maxGlasses > 0 else { return 10 }
        return max(CGFloat(entry.glasses) / CGFloat(maxGlasses) * 80, 4)
    }
    
    private func barColor(for entry: SimpleHydrationEntry) -> Color {
        entry.progress >= 1.0 ? .cyan : .blue.opacity(0.6)
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

#Preview {
    ZStack {
        Color.suhoorIndigo.ignoresSafeArea()
        HydrationHistoryView(hydrationService: .shared)
    }
}
