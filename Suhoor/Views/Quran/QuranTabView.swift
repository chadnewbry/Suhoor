import SwiftUI

struct QuranTabView: View {
    @State private var selectedSection = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.suhoorIndigo.ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("Section", selection: $selectedSection) {
                        Text("Reading Plan").tag(0)
                        Text("Duas").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 8)

                    if selectedSection == 0 {
                        QuranReadingPlanView()
                    } else {
                        DuasView()
                    }
                }
            }
            .navigationTitle("Quran")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    QuranTabView()
}
