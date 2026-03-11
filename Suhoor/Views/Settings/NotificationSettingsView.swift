import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var manager = NotificationManager.shared
    
    var body: some View {
        List {
            // Azan Notifications
            Section {
                ForEach(Prayer.allCases.filter(\.hasAzan)) { prayer in
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: azanBinding(for: prayer)) {
                            Label("\(prayer.emoji) \(prayer.displayName) Azan", systemImage: "bell")
                        }
                        
                        if manager.settings.azanEnabled[prayer.rawValue] == true {
                            Picker("Sound", selection: azanSoundBinding(for: prayer)) {
                                ForEach(AzanSound.allCases) { sound in
                                    Text(sound.displayName).tag(sound.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                            .font(.caption)
                        }
                    }
                    .padding(.vertical, 2)
                }
            } header: {
                Text("Azan Notifications")
            }
            
            // Sehri & Iftar
            Section {
                Toggle(isOn: $manager.settings.preSehriAlarmEnabled) {
                    Label("Pre-Sehri Wake Up", systemImage: "alarm")
                }
                
                if manager.settings.preSehriAlarmEnabled {
                    Stepper("\(manager.settings.preSehriMinutesBefore) min before",
                            value: $manager.settings.preSehriMinutesBefore,
                            in: 10...60, step: 5)
                        .font(.caption)
                }
                
                Toggle(isOn: $manager.settings.iftarWarningEnabled) {
                    Label("Iftar Warning", systemImage: "clock.badge.exclamationmark")
                }
                
                Toggle(isOn: $manager.settings.iftarTimeEnabled) {
                    Label("Iftar Time Alert", systemImage: "moon.stars")
                }
            } header: {
                Text("Sehri & Iftar")
            }
            
            // Reminders
            Section {
                Toggle(isOn: $manager.settings.quranReminderEnabled) {
                    Label("Quran Reading", systemImage: "book")
                }
                
                if manager.settings.quranReminderEnabled {
                    DatePicker("Reminder Time",
                               selection: $manager.settings.quranReminderTime,
                               displayedComponents: .hourAndMinute)
                        .font(.caption)
                }
                
                Toggle(isOn: $manager.settings.fastingLogReminderEnabled) {
                    Label("Fasting Log Reminder", systemImage: "pencil.circle")
                }
                
                if manager.settings.fastingLogReminderEnabled {
                    DatePicker("Reminder Time",
                               selection: $manager.settings.fastingLogReminderTime,
                               displayedComponents: .hourAndMinute)
                        .font(.caption)
                }
            } header: {
                Text("Daily Reminders")
            }
            
            // Permission status
            Section {
                HStack {
                    Text("Notification Permission")
                    Spacer()
                    Text(manager.isPermissionGranted ? "Granted ✅" : "Not Granted ⚠️")
                        .font(.caption)
                        .foregroundStyle(manager.isPermissionGranted ? .green : .orange)
                }
                
                if !manager.isPermissionGranted {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            } header: {
                Text("Status")
            }
        }
        .navigationTitle("Notifications")
        .scrollContentBackground(.hidden)
        .background(Color.suhoorIndigo)
        .foregroundStyle(Color.suhoorTextPrimary)
    }
    
    private func azanBinding(for prayer: Prayer) -> Binding<Bool> {
        Binding(
            get: { manager.settings.azanEnabled[prayer.rawValue] ?? true },
            set: { manager.settings.azanEnabled[prayer.rawValue] = $0 }
        )
    }
    
    private func azanSoundBinding(for prayer: Prayer) -> Binding<String> {
        Binding(
            get: { manager.settings.azanSound[prayer.rawValue] ?? AzanSound.makkah.rawValue },
            set: { manager.settings.azanSound[prayer.rawValue] = $0 }
        )
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
