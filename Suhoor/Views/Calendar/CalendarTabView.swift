import SwiftUI

struct CalendarTabView: View {
    @State private var viewModel = CalendarViewModel()
    @State private var selectedSection: CalendarSection = .imsakiya
    @State private var showPrayerTimes = false

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
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Ramadan Calendar")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(Color.suhoorTextPrimary)
                            if let day = viewModel.currentRamadanDay {
                                Text("Day \(day) of \(viewModel.rows.count)")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.suhoorGold)
                            }
                        }
                        Spacer()

                        Button { showPrayerTimes = true } label: {
                            Image(systemName: "clock")
                                .font(.title3)
                                .foregroundStyle(Color.suhoorGold)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

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
            .navigationDestination(isPresented: $showPrayerTimes) {
                PrayerTimesView()
            }
        }
    }
}

#Preview {
    CalendarTabView()
        .preferredColorScheme(.dark)
}
