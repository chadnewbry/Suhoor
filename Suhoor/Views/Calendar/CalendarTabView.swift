import SwiftUI

struct CalendarTabView: View {
    @State private var viewModel = CalendarViewModel()
    @State private var selectedSection: CalendarSection = .imsakiya

    enum CalendarSection: String, CaseIterable {
        case imsakiya = "Imsakiya"
        case qadr = "Laylat al-Qadr"
        case eid = "Eid"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.suhoorIndigo.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with Hijri-Gregorian dual display
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Ramadan Calendar")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(Color.suhoorTextPrimary)
                            HStack(spacing: 8) {
                                if let day = viewModel.currentRamadanDay {
                                    Text("Day \(day) of \(viewModel.rows.count)")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.suhoorGold)
                                    Text("•")
                                        .foregroundStyle(Color.suhoorTextSecondary)
                                }
                                Text(HijriCalendarService.shared.hijriDateString(from: .now))
                                    .font(.subheadline)
                                    .foregroundStyle(Color.suhoorTextSecondary)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    // Prominent Eid countdown in final 5 days
                    if let days = viewModel.daysUntilEid, days <= 5 && days > 0 {
                        eidBanner(days)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                    }

                    Picker("Section", selection: $selectedSection) {
                        ForEach(CalendarSection.allCases, id: \.self) { section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    ScrollView {
                        switch selectedSection {
                        case .imsakiya:
                            ImsakiyaView(viewModel: viewModel)
                                .padding(.horizontal, 8)
                        case .qadr:
                            LaylatAlQadrView(viewModel: viewModel)
                                .padding(.horizontal, 16)
                        case .eid:
                            EidCountdownView(viewModel: viewModel)
                                .padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
    }

    private func eidBanner(_ days: Int) -> some View {
        HStack {
            Image(systemName: "moon.stars.fill")
                .foregroundStyle(Color.suhoorGold)
            Text("Eid al-Fitr in \(days) day\(days == 1 ? "" : "s")!")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.suhoorTextPrimary)
            Spacer()
            Text("🎉")
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.suhoorGold.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.suhoorGold.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    CalendarTabView()
        .preferredColorScheme(.dark)
}
