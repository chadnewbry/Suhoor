import SwiftUI

struct RamadanGridView: View {
    let days: [FastingDay]
    let currentDay: Int
    let onDayTap: (FastingDay) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ramadan Calendar")
                .font(.headline)
                .foregroundStyle(Color.suhoorTextPrimary)
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(days) { day in
                    DayCircle(day: day, isToday: day.id == currentDay)
                        .onTapGesture { onDayTap(day) }
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                LegendItem(color: .suhoorSuccess, label: "Fasted")
                LegendItem(color: .red.opacity(0.8), label: "Missed")
                LegendItem(color: .orange, label: "Excused")
                LegendItem(color: Color.white.opacity(0.2), label: "Future")
            }
            .font(.caption2)
        }
        .padding()
        .background(Color.suhoorSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct DayCircle: View {
    let day: FastingDay
    let isToday: Bool
    
    private var fillColor: Color {
        switch day.status {
        case .fasted: .suhoorSuccess
        case .missed: .red.opacity(0.8)
        case .excused: .orange
        case .future, .unknown: Color.white.opacity(0.12)
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(fillColor)
                .frame(width: 44, height: 44)
            
            if isToday {
                Circle()
                    .strokeBorder(Color.suhoorGold, lineWidth: 2.5)
                    .frame(width: 44, height: 44)
            }
            
            Text("\(day.id)")
                .font(.caption.weight(isToday ? .bold : .medium))
                .foregroundStyle(day.status == .future ? Color.suhoorTextSecondary : .white)
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).foregroundStyle(Color.suhoorTextSecondary)
        }
    }
}

#Preview {
    RamadanGridView(
        days: (1...30).map { FastingDay(id: $0, status: $0 <= 5 ? .fasted : $0 == 6 ? .missed : .future) },
        currentDay: 7,
        onDayTap: { _ in }
    )
    .background(Color.suhoorIndigo)
    .preferredColorScheme(.dark)
}
