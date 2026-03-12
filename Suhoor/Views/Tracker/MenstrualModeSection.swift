import SwiftUI

struct MenstrualModeSection: View {
    let store: FastingStore
    @State private var periodStartDay: Int = 1
    @State private var periodDays: Int = 7
    @State private var showingConfirmation = false
    
    private let comfortDuas = [
        ("اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ", "O Allah, I ask You for well-being."),
        ("رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ", "Our Lord, give us good in this world and good in the Hereafter, and save us from the punishment of the Fire.")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
                Text("Menstrual Mode")
                    .font(.headline)
                    .foregroundStyle(Color.suhoorTextPrimary)
            }
            
            HStack {
                Stepper("Start Day: \(periodStartDay)", value: $periodStartDay, in: 1...30)
                    .foregroundStyle(Color.suhoorTextPrimary)
            }
            
            HStack {
                Stepper("Duration: \(periodDays) days", value: $periodDays, in: 1...14)
                    .foregroundStyle(Color.suhoorTextPrimary)
            }
            
            Button {
                showingConfirmation = true
            } label: {
                Label("Mark Period Days", systemImage: "calendar.badge.exclamationmark")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink.opacity(0.8))
            .confirmationDialog("Mark days \(periodStartDay)–\(min(periodStartDay + periodDays - 1, 30)) as excused?", isPresented: $showingConfirmation) {
                Button("Mark as Excused") {
                    store.markPeriodDays(from: periodStartDay, count: periodDays)
                }
                Button("Cancel", role: .cancel) {}
            }
            
            // Comfort duas
            VStack(alignment: .leading, spacing: 8) {
                Text("Comfort Duas")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.suhoorAmber)
                
                ForEach(comfortDuas, id: \.0) { dua in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dua.0)
                            .font(.caption)
                            .foregroundStyle(Color.suhoorAmber)
                        Text(dua.1)
                            .font(.caption2)
                            .foregroundStyle(Color.suhoorTextSecondary)
                            .italic()
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.suhoorSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

#Preview {
    MenstrualModeSection(store: FastingStore())
        .background(Color.suhoorIndigo)
        .preferredColorScheme(.dark)
}
