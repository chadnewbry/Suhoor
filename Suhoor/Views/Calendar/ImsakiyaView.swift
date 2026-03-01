import SwiftUI

struct ImsakiyaView: View {
    var viewModel: CalendarViewModel

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm"
        return f
    }()

    private let columns = ["Day", "Date", "Imsak", "Fajr", "Rise", "Dhuhr", "Asr", "Mgrb", "Isha"]

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
                        ForEach(viewModel.rows) { row in
                            dayRow(row)
                                .id(row.ramadanDay)
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

            Text(row.gregorianDateString)
                .font(.caption2)
                .frame(maxWidth: .infinity)

            timeCell(row.prayerTimes.imsak)
            timeCell(row.prayerTimes.fajr)
            timeCell(row.prayerTimes.sunrise)
            timeCell(row.prayerTimes.dhuhr)
            timeCell(row.prayerTimes.asr)
            timeCell(row.prayerTimes.maghrib)
            timeCell(row.prayerTimes.isha)
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
    }

    private func timeCell(_ date: Date) -> some View {
        Text(timeFormatter.string(from: date))
            .font(.caption2.monospacedDigit())
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    ImsakiyaView(viewModel: CalendarViewModel())
        .preferredColorScheme(.dark)
}
