import SwiftUI

struct HealthKitSyncView: View {
    @State private var settings = UserSettings.shared
    @State private var syncStatus: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                Text("Apple Health")
                    .font(.headline)
                    .foregroundStyle(Color.suhoorTextPrimary)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { settings.isHealthKitEnabled },
                    set: { newValue in
                        settings.isHealthKitEnabled = newValue
                        if newValue { requestAccess() }
                    }
                ))
                .tint(Color.suhoorGold)
            }

            if settings.isHealthKitEnabled {
                Text(syncStatus.isEmpty ? "Completed fasts sync to Apple Health" : syncStatus)
                    .font(.caption)
                    .foregroundStyle(Color.suhoorTextSecondary)
            }
        }
        .padding(20)
        .background(Color.suhoorNavy)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            if settings.isHealthKitEnabled {
                syncStatus = HealthKitService.shared.isAuthorized ? "✅ Connected" : "⏳ Requesting access..."
            }
        }
    }

    private func requestAccess() {
        Task {
            do {
                try await HealthKitService.shared.requestAuthorization()
                syncStatus = "✅ Connected"
            } catch {
                syncStatus = "⚠️ Access denied"
            }
        }
    }
}
