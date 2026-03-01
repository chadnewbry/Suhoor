import SwiftUI

struct DailyDeedsView: View {
    let dataManager: DataManager
    let date: Date
    let ramadanYear: Int
    @State private var deeds: [DeedEntry] = []
    @State private var showAddDeed = false
    @State private var customDeedLabel = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily Deeds")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.suhoorTextPrimary)
                Spacer()
                Button {
                    showAddDeed = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.suhoorGold)
                }
            }

            if deeds.isEmpty {
                Text("Loading deeds...")
                    .font(.subheadline)
                    .foregroundStyle(Color.suhoorTextSecondary)
            } else {
                ForEach(deeds, id: \.deedTypeRaw) { deed in
                    DeedRow(deed: deed) {
                        dataManager.toggleDeed(deed)
                        refreshDeeds()
                    } onDelete: {
                        if deed.deedType == .custom {
                            dataManager.deleteDeed(deed)
                            refreshDeeds()
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.suhoorNavy)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            dataManager.ensureDefaultDeeds(for: date, ramadanYear: ramadanYear)
            refreshDeeds()
        }
        .alert("Add Custom Deed", isPresented: $showAddDeed) {
            TextField("Deed name", text: $customDeedLabel)
            Button("Add") {
                guard !customDeedLabel.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                dataManager.addDeedEntry(
                    date: date,
                    deedType: .custom,
                    customLabel: customDeedLabel,
                    ramadanYear: ramadanYear
                )
                customDeedLabel = ""
                refreshDeeds()
            }
            Button("Cancel", role: .cancel) { customDeedLabel = "" }
        }
    }

    private func refreshDeeds() {
        deeds = dataManager.deedEntries(for: date, ramadanYear: ramadanYear)
    }
}

private struct DeedRow: View {
    let deed: DeedEntry
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: deed.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(deed.isCompleted ? Color.suhoorSuccess : Color.suhoorTextSecondary)
            }

            Text(deed.displayEmoji)
                .font(.title3)

            Text(deed.displayLabel)
                .font(.subheadline)
                .foregroundStyle(deed.isCompleted ? Color.suhoorTextSecondary : Color.suhoorTextPrimary)
                .strikethrough(deed.isCompleted)

            Spacer()

            if deed.deedType == .custom {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
