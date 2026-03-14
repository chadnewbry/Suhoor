import SwiftUI

struct NotificationSettingsView: View {
    @Environment(NotificationManager.self) private var manager
    @Environment(UserPreferences.self) private var preferences

    var body: some View {
        @Bindable var prefs = preferences

        List {
            // Azan Notifications
            Section {
                Toggle(isOn: $prefs.fajrAzan) {
                    Label("\(Prayer.fajr.emoji) Fajr Azan", systemImage: "bell")
                }
                Toggle(isOn: $prefs.dhuhrAzan) {
                    Label("\(Prayer.dhuhr.emoji) Dhuhr Azan", systemImage: "bell")
                }
                Toggle(isOn: $prefs.asrAzan) {
                    Label("\(Prayer.asr.emoji) Asr Azan", systemImage: "bell")
                }
                Toggle(isOn: $prefs.maghribAzan) {
                    Label("\(Prayer.maghrib.emoji) Maghrib Azan", systemImage: "bell")
                }
                Toggle(isOn: $prefs.ishaAzan) {
                    Label("\(Prayer.isha.emoji) Isha Azan", systemImage: "bell")
                }
            } header: {
                Text("Azan Notifications")
            }

            // Sehri & Iftar
            Section {
                Toggle(isOn: $prefs.preSehriAlarmEnabled) {
                    Label("Pre-Sehri Wake Up", systemImage: "alarm")
                }

                if preferences.preSehriAlarmEnabled {
                    Picker("Minutes Before", selection: $prefs.preSehriMinutesBefore) {
                        Text("15 min").tag(15)
                        Text("30 min").tag(30)
                        Text("45 min").tag(45)
                        Text("60 min").tag(60)
                    }
                    .pickerStyle(.segmented)
                    .font(.caption)
                }

                Toggle(isOn: $prefs.iftarWarningEnabled) {
                    Label("Iftar Warning", systemImage: "clock.badge.exclamationmark")
                }

                Toggle(isOn: $prefs.iftarDuaEnabled) {
                    Label("Iftar Dua Alert", systemImage: "moon.stars")
                }
            } header: {
                Text("Sehri & Iftar")
            }

            // Reminders
            Section {
                Toggle(isOn: $prefs.quranReminderEnabled) {
                    Label("Quran Reading", systemImage: "book")
                }

                if preferences.quranReminderEnabled {
                    DatePicker("Reminder Time",
                               selection: $prefs.quranReminderTime,
                               displayedComponents: .hourAndMinute)
                        .font(.caption)
                }

                Toggle(isOn: $prefs.hydrationRemindersEnabled) {
                    Label("Hydration Reminders", systemImage: "drop")
                }
            } header: {
                Text("Daily Reminders")
            } footer: {
                Text("Hydration reminders are sent every \(preferences.hydrationIntervalMinutes) minutes between Iftar and Sehri.")
            }

            // Permission status
            Section {
                HStack {
                    Text("Notification Permission")
                    Spacer()
                    Text(manager.isAuthorized ? "Granted" : "Not Granted")
                        .font(.caption)
                        .foregroundStyle(manager.isAuthorized ? .green : .orange)
                }

                if !manager.isAuthorized {
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
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
            .environment(NotificationManager.shared)
            .environment(UserPreferences.shared)
    }
}
