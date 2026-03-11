import SwiftUI

struct CalendarTabView: View {
    @StateObject private var settings = AppSettings.shared
    
    private var ramadanDays: [RamadanDay] {
        let calendar = Calendar.current
        // Ramadan 2026 starts approximately Feb 18
        let startDate = calendar.date(from: DateComponents(year: 2026, month: 2, day: 18))!
        
        return (0..<30).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startDate)!
            let dayNum = offset + 1
            return RamadanDay(
                day: dayNum,
                date: date,
                sehriEnd: calendar.date(bySettingHour: 5, minute: 30 + (offset % 10), second: 0, of: date)!,
                iftarTime: calendar.date(bySettingHour: 18, minute: 10 + (offset % 15), second: 0, of: date)!
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(ramadanDays) { day in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Day \(day.day)")
                                .font(.headline)
                                .foregroundStyle(Color.suhoorTextPrimary)
                            Text(day.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(Color.suhoorTextSecondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "sunrise")
                                    .font(.caption2)
                                Text(day.sehriEnd, style: .time)
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundStyle(Color.suhoorAmber)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "sunset")
                                    .font(.caption2)
                                Text(day.iftarTime, style: .time)
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundStyle(Color.suhoorGold)
                        }
                    }
                    .listRowBackground(Color.suhoorSurface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.suhoorIndigo.ignoresSafeArea())
            .navigationTitle("Ramadan Calendar")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

private struct RamadanDay: Identifiable {
    let day: Int
    let date: Date
    let sehriEnd: Date
    let iftarTime: Date
    var id: Int { day }
}

#Preview {
    CalendarTabView()
}
