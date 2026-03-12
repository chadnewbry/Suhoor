import SwiftUI

struct EidCountdownView: View {
    var viewModel: CalendarViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Eid al-Fitr")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.suhoorTextPrimary)
                    if let days = viewModel.daysUntilEid {
                        if days == 0 {
                            Text("Eid Mubarak! 🎉")
                                .font(.subheadline)
                                .foregroundStyle(Color.suhoorGold)
                        } else {
                            Text("\(days) day\(days == 1 ? "" : "s") remaining")
                                .font(.subheadline)
                                .foregroundStyle(Color.suhoorTextSecondary)
                        }
                    }
                }
                Spacer()
                if let days = viewModel.daysUntilEid, days > 0 {
                    countdownCircle(days)
                } else {
                    Text("🎊").font(.system(size: 40))
                }
            }
            .padding(.horizontal, 16)

            if let days = viewModel.daysUntilEid, days <= 10, days > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Eid Preparation")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.suhoorGold)
                        .padding(.horizontal, 16)

                    ForEach(viewModel.eidChecklist) { item in
                        Button {
                            viewModel.toggleEidItem(item.id)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(item.completed ? Color.suhoorSuccess : Color.suhoorTextSecondary)
                                Text("\(item.emoji) \(item.name)")
                                    .font(.subheadline)
                                    .foregroundStyle(item.completed ? Color.suhoorTextSecondary : Color.suhoorTextPrimary)
                                    .strikethrough(item.completed)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.suhoorSurface)
        )
    }

    private func countdownCircle(_ days: Int) -> some View {
        ZStack {
            Circle()
                .stroke(Color.suhoorDivider, lineWidth: 4)
                .frame(width: 56, height: 56)
            Circle()
                .trim(from: 0, to: CGFloat(30 - days) / 30.0)
                .stroke(Color.suhoorGold, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 56, height: 56)
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(days)")
                    .font(.title3.weight(.bold).monospacedDigit())
                    .foregroundStyle(Color.suhoorGold)
                Text("days")
                    .font(.caption2)
                    .foregroundStyle(Color.suhoorTextSecondary)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.suhoorIndigo.ignoresSafeArea()
        EidCountdownView(viewModel: CalendarViewModel())
    }
    .preferredColorScheme(.dark)
}
