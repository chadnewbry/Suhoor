import SwiftUI

struct DailyFastLogView: View {
    let dataManager: DataManager
    let ramadanYear: Int
    let hijriService = HijriCalendarService.shared

    @State private var todayRecord: FastingRecord?
    @State private var showExcuseReason = false
    @State private var selectedExcuse: ExcuseReason = .illness
    @State private var notes = ""
    @State private var showNotes = false

    private var todayDayNumber: Int? {
        hijriService.ramadanDayNumber(for: .now, adjustment: UserSettings.shared.hijriAdjustment)
    }

    private var fastDurationText: String? {
        guard let record = todayRecord else { return nil }
        let duration = record.fastEndTime.timeIntervalSince(record.fastStartTime)
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let startFmt = formatted(time: record.fastStartTime)
        let endFmt = formatted(time: record.fastEndTime)
        return "\(hours) hours \(minutes) minutes (Imsak \(startFmt) → Iftar \(endFmt))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mark Today's Fast")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.suhoorTextPrimary)

            if let dayNum = todayDayNumber {
                Text("Day \(dayNum) of Ramadan")
                    .font(.subheadline)
                    .foregroundStyle(Color.suhoorTextSecondary)
            }

            if let record = todayRecord {
                HStack(spacing: 12) {
                    Circle()
                        .fill(record.status == .fasted ? Color.suhoorSuccess :
                              record.status == .missed ? Color.red : Color.suhoorWarning)
                        .frame(width: 12, height: 12)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.status == .fasted ? "Fasted ✅" :
                             record.status == .missed ? "Missed ❌" : "Excused ⏸️")
                            .font(.headline)
                            .foregroundStyle(Color.suhoorTextPrimary)
                        if let reason = record.excuseReason {
                            Text(reason.rawValue.capitalized)
                                .font(.caption)
                                .foregroundStyle(Color.suhoorTextSecondary)
                        }
                    }
                    Spacer()
                    Button("Edit") {
                        dataManager.deleteFastingRecord(record)
                        todayRecord = nil
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.suhoorGold)
                }

                if let durationText = fastDurationText {
                    Text(durationText)
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }

                if let n = record.notes, !n.isEmpty {
                    Text(n)
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                        .italic()
                }
            } else {
                HStack(spacing: 12) {
                    FastOptionButton(emoji: "✅", label: "Fasted", color: .suhoorSuccess) {
                        logFast(status: .fasted)
                    }
                    FastOptionButton(emoji: "❌", label: "Missed", color: .red) {
                        logFast(status: .missed)
                    }
                    FastOptionButton(emoji: "⏸️", label: "Excused", color: .suhoorWarning) {
                        showExcuseReason = true
                    }
                }

                if showExcuseReason {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reason")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.suhoorTextPrimary)
                        Picker("Reason", selection: $selectedExcuse) {
                            ForEach(ExcuseReason.allCases, id: \.self) { reason in
                                Text(excuseDisplayName(reason)).tag(reason)
                            }
                        }
                        .pickerStyle(.segmented)

                        Button("Confirm") {
                            logFast(status: .excused, excuse: selectedExcuse)
                            showExcuseReason = false
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.suhoorIndigo)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.suhoorGold)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                Button {
                    showNotes.toggle()
                } label: {
                    HStack {
                        Image(systemName: "note.text")
                        Text(showNotes ? "Hide notes" : "Add notes")
                    }
                    .font(.caption)
                    .foregroundStyle(Color.suhoorTextSecondary)
                }

                if showNotes {
                    TextField("Optional notes...", text: $notes, axis: .vertical)
                        .font(.subheadline)
                        .foregroundStyle(Color.suhoorTextPrimary)
                        .padding(10)
                        .background(Color.suhoorSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .lineLimit(3)
                }
            }
        }
        .padding(20)
        .background(Color.suhoorNavy)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear { loadToday() }
    }

    private func loadToday() {
        todayRecord = dataManager.fastingRecord(for: .now)
    }

    private func logFast(status: FastingStatus, excuse: ExcuseReason? = nil) {
        guard let dayNum = todayDayNumber else { return }
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: .now)
        let defaultStart = calendar.date(bySettingHour: 4, minute: 47, second: 0, of: startOfDay)!
        let defaultEnd = calendar.date(bySettingHour: 19, minute: 10, second: 0, of: startOfDay)!

        let record = dataManager.addFastingRecord(
            date: .now,
            dayNumber: dayNum,
            ramadanYear: ramadanYear,
            status: status,
            excuseReason: excuse,
            notes: notes.isEmpty ? nil : notes,
            fastStartTime: defaultStart,
            fastEndTime: defaultEnd
        )
        todayRecord = record
        notes = ""
        showNotes = false

        if UserSettings.shared.isHealthKitEnabled && status == .fasted {
            Task { try? await HealthKitService.shared.saveFastingRecord(record) }
        }
    }

    private func formatted(time: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        return fmt.string(from: time)
    }

    private func excuseDisplayName(_ reason: ExcuseReason) -> String {
        switch reason {
        case .menstruation: return "Period"
        case .travel: return "Travel"
        case .illness: return "Illness"
        case .other: return "Other"
        }
    }
}

private struct FastOptionButton: View {
    let emoji: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(emoji).font(.title)
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.suhoorTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.3), lineWidth: 1))
        }
    }
}
