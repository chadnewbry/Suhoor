import SwiftUI

struct RamadanCalendarView: View {
    let dataManager: DataManager
    let ramadanYear: Int
    let hijriService = HijriCalendarService.shared

    @State private var selectedDay: Int?
    @State private var showDayDetail = false

    private var records: [Int: FastingRecord] {
        let all = dataManager.fastingRecords(forRamadanYear: ramadanYear)
        return Dictionary(uniqueKeysWithValues: all.map { ($0.dayNumber, $0) })
    }

    private var currentDay: Int? {
        hijriService.ramadanDayNumber(for: .now, adjustment: UserSettings.shared.hijriAdjustment)
    }

    private var totalDays: Int {
        let hijriYear = hijriService.currentRamadanHijriYear(adjustment: UserSettings.shared.hijriAdjustment)
        return hijriService.ramadanLength(hijriYear: hijriYear)
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 6)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ramadan Calendar")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.suhoorTextPrimary)

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(1...totalDays, id: \.self) { day in
                    CalendarDayCell(
                        day: day,
                        record: records[day],
                        isToday: day == currentDay,
                        isFuture: currentDay.map { day > $0 } ?? true
                    )
                    .onTapGesture {
                        selectedDay = day
                        showDayDetail = true
                    }
                }
            }

            // Legend
            HStack(spacing: 16) {
                LegendDot(color: .suhoorSuccess, label: "Fasted")
                LegendDot(color: .red, label: "Missed")
                LegendDot(color: .suhoorWarning, label: "Excused")
                LegendDot(color: .gray.opacity(0.4), label: "Future")
            }
            .font(.caption2)
        }
        .padding(20)
        .background(Color.suhoorNavy)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .sheet(isPresented: $showDayDetail) {
            if let day = selectedDay {
                DayDetailSheet(
                    dataManager: dataManager,
                    ramadanYear: ramadanYear,
                    dayNumber: day,
                    existingRecord: records[day]
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

private struct CalendarDayCell: View {
    let day: Int
    let record: FastingRecord?
    let isToday: Bool
    let isFuture: Bool

    private var bgColor: Color {
        if let record {
            switch record.status {
            case .fasted: return .suhoorSuccess
            case .missed: return .red
            case .excused: return .suhoorWarning
            }
        }
        return isFuture ? Color.gray.opacity(0.2) : Color.suhoorSurface
    }

    var body: some View {
        Text("\(day)")
            .font(.system(.caption, design: .rounded, weight: isToday ? .bold : .medium))
            .foregroundStyle(isToday ? Color.suhoorIndigo : Color.suhoorTextPrimary)
            .frame(width: 40, height: 40)
            .background(bgColor.opacity(record != nil ? 0.7 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday ? Color.suhoorGold : Color.clear, lineWidth: 2)
            )
    }
}

private struct LegendDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).foregroundStyle(Color.suhoorTextSecondary)
        }
    }
}

struct DayDetailSheet: View {
    let dataManager: DataManager
    let ramadanYear: Int
    let dayNumber: Int
    let existingRecord: FastingRecord?
    @Environment(\.dismiss) private var dismiss

    @State private var selectedStatus: FastingStatus = .fasted
    @State private var selectedExcuse: ExcuseReason = .illness
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Day \(dayNumber)")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.suhoorTextPrimary)

                if let record = existingRecord {
                    VStack(spacing: 8) {
                        Text(record.status == .fasted ? "✅ Fasted" :
                             record.status == .missed ? "❌ Missed" : "⏸️ Excused")
                            .font(.title2)
                        if let reason = record.excuseReason {
                            Text(reason.rawValue.capitalized)
                                .foregroundStyle(Color.suhoorTextSecondary)
                        }
                        if let n = record.notes, !n.isEmpty {
                            Text(n).italic().foregroundStyle(Color.suhoorTextSecondary)
                        }
                        let dur = record.fastEndTime.timeIntervalSince(record.fastStartTime)
                        let h = Int(dur) / 3600
                        let m = (Int(dur) % 3600) / 60
                        Text("\(h)h \(m)m fast")
                            .font(.caption)
                            .foregroundStyle(Color.suhoorTextSecondary)
                    }
                } else {
                    Text("No record yet")
                        .foregroundStyle(Color.suhoorTextSecondary)
                }

                Spacer()
            }
            .padding()
            .background(Color.suhoorIndigo.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.suhoorGold)
                }
            }
        }
    }
}
