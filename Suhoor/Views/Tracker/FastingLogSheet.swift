import SwiftUI

struct FastingLogSheet: View {
    let day: FastingDay
    let store: FastingStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedStatus: FastingStatus
    @State private var selectedReason: ExcuseReason?
    @State private var notes: String
    @State private var sehriTime: Date
    @State private var iftarTime: Date
    
    init(day: FastingDay, store: FastingStore) {
        self.day = day
        self.store = store
        _selectedStatus = State(initialValue: day.status == .future ? .fasted : day.status)
        _selectedReason = State(initialValue: day.excuseReason)
        _notes = State(initialValue: day.notes)
        
        let cal = Calendar.current
        _sehriTime = State(initialValue: day.sehriTime ?? cal.date(bySettingHour: 4, minute: 30, second: 0, of: Date())!)
        _iftarTime = State(initialValue: day.iftarTime ?? cal.date(bySettingHour: 18, minute: 15, second: 0, of: Date())!)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Day \(day.id) Status") {
                    Picker("Status", selection: $selectedStatus) {
                        Text("Fasted").tag(FastingStatus.fasted)
                        Text("Missed").tag(FastingStatus.missed)
                        Text("Excused").tag(FastingStatus.excused)
                    }
                    .pickerStyle(.segmented)
                }
                
                if selectedStatus == .excused {
                    Section("Reason") {
                        Picker("Reason", selection: $selectedReason) {
                            Text("Select...").tag(ExcuseReason?.none)
                            ForEach(ExcuseReason.allCases) { reason in
                                Text(reason.rawValue).tag(ExcuseReason?.some(reason))
                            }
                        }
                    }
                }
                
                if selectedStatus == .fasted {
                    Section("Fasting Times") {
                        DatePicker("Sehri", selection: $sehriTime, displayedComponents: .hourAndMinute)
                        DatePicker("Iftar", selection: $iftarTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section("Notes") {
                    TextField("Optional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .navigationTitle("Log Day \(day.id)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.updateDay(
                            day.id,
                            status: selectedStatus,
                            reason: selectedStatus == .excused ? selectedReason : nil,
                            notes: notes,
                            sehriTime: selectedStatus == .fasted ? sehriTime : nil,
                            iftarTime: selectedStatus == .fasted ? iftarTime : nil
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    FastingLogSheet(day: FastingDay(id: 5), store: FastingStore())
}
