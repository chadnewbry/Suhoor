import SwiftUI

struct ImsakiyaView: View {
    var viewModel: CalendarViewModel
    @State private var selectedDate: Date?

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm"
        return f
    }()

    private let columns = ["Day", "Hijri", "Date", "Sehri", "Iftar", "Fast"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Imsakiya — Ramadan \(HijriCalendarService.shared.currentRamadanHijriYear())")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.suhoorGold)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            headerRow
                .background(Color.suhoorNavy)

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedRows, id: \.ashra.rawValue) { group in
                            ashraHeader(group.ashra)

                            ForEach(group.rows) { row in
                                dayRow(row)
                                    .id(row.ramadanDay)
                                    .onTapGesture {
                                        selectedDate = row.gregorianDate
                                    }
                            }
                        }
                    }
                }
                .onAppear {
                    if let current = viewModel.currentRamadanDay {
                        withAnimation { proxy.scrollTo(current, anchor: .center) }
                    }
                }
            }
        }
        .background(Color.suhoorIndigo)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .sheet(item: $selectedDate) { date in
            NavigationStack {
                PrayerTimesView(initialDate: date)
            }
        }
    }

    // MARK: - Ashra Grouping

    private struct AshraGroup {
        let ashra: HijriCalendarService.Ashra
        let rows: [ImsakiyaRow]
    }

    private var groupedRows: [AshraGroup] {
        let hijri = HijriCalendarService.shared
        var groups: [HijriCalendarService.Ashra: [ImsakiyaRow]] = [:]
        for row in viewModel.rows {
            let ashra = hijri.ashra(for: row.ramadanDay)
            groups[ashra, default: []].append(row)
        }
        let order: [HijriCalendarService.Ashra] = [.first, .second, .third]
        return order.compactMap { ashra in
            guard let rows = groups[ashra], !rows.isEmpty else { return nil }
            return AshraGroup(ashra: ashra, rows: rows)
        }
    }

    // MARK: - Subviews

    private func ashraHeader(_ ashra: HijriCalendarService.Ashra) -> some View {
        HStack {
            Rectangle()
                .fill(ashraColor(ashra))
                .frame(width: 3)
            Text(ashra.rawValue)
                .font(.caption.weight(.bold))
                .foregroundStyle(ashraColor(ashra))
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(ashraColor(ashra).opacity(0.08))
    }

    private func ashraColor(_ ashra: HijriCalendarService.Ashra) -> Color {
        switch ashra {
        case .first: return Color.suhoorSuccess
        case .second: return Color.suhoorAmber
        case .third: return Color.purple
        }
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            ForEach(columns, id: \.self) { col in
                Text(col)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color.suhoorGold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
    }

    private func dayRow(_ row: ImsakiyaRow) -> some View {
        let isCurrent = row.ramadanDay == viewModel.currentRamadanDay

        return HStack(spacing: 0) {
            Text("\(row.ramadanDay)")
                .font(.caption.weight(isCurrent ? .bold : .regular))
                .frame(maxWidth: .infinity)

            Text("\(row.ramadanDay) Ram")
                .font(.caption2)
                .frame(maxWidth: .infinity)

            Text(row.gregorianDateString)
                .font(.caption2)
                .frame(maxWidth: .infinity)

            timeCell(row.prayerTimes.fajr)
            timeCell(row.prayerTimes.maghrib)

            Text(row.fastingDuration)
                .font(.caption2.monospacedDigit())
                .frame(maxWidth: .infinity)
        }
        .foregroundStyle(isCurrent ? Color.suhoorGold : Color.suhoorTextPrimary)
        .padding(.vertical, 6)
        .background(
            isCurrent ? Color.suhoorGold.opacity(0.15) :
            row.isOddLastNight ? Color.purple.opacity(0.12) :
            row.isLastTenNights ? Color.purple.opacity(0.06) :
            Color.clear
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color.suhoorDivider),
            alignment: .bottom
        )
        .contentShape(Rectangle())
    }

    private func timeCell(_ date: Date) -> some View {
        Text(timeFormatter.string(from: date))
            .font(.caption2.monospacedDigit())
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Date Identifiable for sheet(item:)

extension Date: @retroactive Identifiable {
    public var id: TimeInterval { timeIntervalSinceReferenceDate }
}

#Preview {
    NavigationStack {
        ImsakiyaView(viewModel: CalendarViewModel())
    }
    .preferredColorScheme(.dark)
}
