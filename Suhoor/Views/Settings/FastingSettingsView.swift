import SwiftUI
import HealthKit

struct FastingSettingsView: View {
    @StateObject private var settings = AppSettings.shared
    @State private var showingHealthKitAlert = false

    var body: some View {
        List {
            Section {
                Toggle(isOn: $settings.menstrualModeEnabled) {
                    Label("Menstrual Mode", systemImage: "calendar.badge.clock")
                }
            } header: {
                Text("Fasting Tracking")
            } footer: {
                Text("When enabled, days can be marked as exempt and tracked for makeup fasts.")
            }
            .listRowBackground(Color.suhoorSurface)

            Section {
                Toggle(isOn: $settings.healthKitSyncEnabled) {
                    Label("HealthKit Sync", systemImage: "heart.text.square")
                }
                .onChange(of: settings.healthKitSyncEnabled) { _, newValue in
                    if newValue {
                        requestHealthKitAuthorization()
                    }
                }
            } header: {
                Text("Health Integration")
            } footer: {
                Text("Sync fasting data with Apple Health for a complete wellness picture.")
            }
            .listRowBackground(Color.suhoorSurface)

            Section {
                Toggle(isOn: $settings.makeupFastRemindersEnabled) {
                    Label("Makeup Fast Reminders", systemImage: "arrow.counterclockwise")
                }
            } header: {
                Text("Reminders")
            } footer: {
                Text("Get reminded about missed fasts that need to be made up after Ramadan.")
            }
            .listRowBackground(Color.suhoorSurface)
        }
        .scrollContentBackground(.hidden)
        .background(Color.suhoorIndigo)
        .foregroundStyle(Color.suhoorTextPrimary)
        .navigationTitle("Fasting")
        .alert("HealthKit Access", isPresented: $showingHealthKitAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {
                settings.healthKitSyncEnabled = false
            }
        } message: {
            Text("Please enable HealthKit access in Settings to sync fasting data.")
        }
    }

    private func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            settings.healthKitSyncEnabled = false
            return
        }
        let store = HKHealthStore()
        let types: Set<HKSampleType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        store.requestAuthorization(toShare: types, read: types) { granted, _ in
            DispatchQueue.main.async {
                if !granted {
                    showingHealthKitAlert = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FastingSettingsView()
    }
}
