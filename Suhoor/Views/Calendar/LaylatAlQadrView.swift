import SwiftUI

struct LaylatAlQadrView: View {
    var viewModel: CalendarViewModel
    @State private var selectedNight: Int = 27

    private let oddNights = [21, 23, 25, 27, 29]

    private let nightDuas: [Int: String] = [
        21: "اللهم إنك عفو تحب العفو فاعف عني\nO Allah, You are pardoning and love pardon, so pardon me.",
        23: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً\nOur Lord, give us good in this world and good in the Hereafter.",
        25: "اللهم اجعلني من عتقائك من النار\nO Allah, make me among those You free from the Fire.",
        27: "اللهم إنك عفو كريم تحب العفو فاعف عني\nO Allah, You are the Most Generous Pardoner, You love to pardon, so pardon me.",
        29: "اللهم تقبل منا إنك أنت السميع العليم\nO Allah, accept from us. You are the All-Hearing, All-Knowing.",
    ]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Laylat al-Qadr")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.suhoorTextPrimary)
                    Text("The Night of Power — Last 10 Nights")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
                Spacer()
                Image(systemName: "moon.stars.fill")
                    .font(.title2)
                    .foregroundStyle(Color.suhoorGold)
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(oddNights, id: \.self) { night in
                        nightPill(night)
                    }
                }
                .padding(.horizontal, 16)
            }

            if let dua = nightDuas[selectedNight] {
                VStack(spacing: 8) {
                    Text("Du'a for Night \(selectedNight)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.suhoorGold)
                    Text(dua)
                        .font(.callout)
                        .foregroundStyle(Color.suhoorTextPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.purple.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)
            }

            if let deeds = viewModel.qadrDeeds["night_\(selectedNight)"] {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tonight's Ibadah Checklist")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.suhoorTextPrimary)
                        .padding(.horizontal, 16)

                    ForEach(deeds) { deed in
                        Button {
                            viewModel.toggleQadrDeed(night: selectedNight, deedId: deed.id)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: deed.completed ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(deed.completed ? Color.suhoorSuccess : Color.suhoorTextSecondary)
                                Text("\(deed.emoji) \(deed.name)")
                                    .font(.subheadline)
                                    .foregroundStyle(deed.completed ? Color.suhoorTextSecondary : Color.suhoorTextPrimary)
                                    .strikethrough(deed.completed)
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

    private func nightPill(_ night: Int) -> some View {
        let isSelected = night == selectedNight
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedNight = night }
        } label: {
            VStack(spacing: 4) {
                Text("☆").font(.caption)
                Text("\(night)").font(.subheadline.weight(.bold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple.opacity(0.3) : Color.suhoorSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isSelected ? Color.purple : Color.suhoorDivider, lineWidth: 1)
                    )
            )
            .foregroundStyle(isSelected ? Color.suhoorGold : Color.suhoorTextSecondary)
        }
    }
}

#Preview {
    ZStack {
        Color.suhoorIndigo.ignoresSafeArea()
        LaylatAlQadrView(viewModel: CalendarViewModel())
    }
    .preferredColorScheme(.dark)
}
