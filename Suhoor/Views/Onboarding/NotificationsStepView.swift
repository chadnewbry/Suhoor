import SwiftUI

struct NotificationsStepView: View {
    @Bindable var vm: OnboardingViewModel
    @State private var permissionRequested = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.suhoorGold)

            Text("Notifications")
                .font(.title.weight(.bold))
                .foregroundStyle(Color.suhoorTextPrimary)

            Text("Stay on track with timely reminders\nthroughout Ramadan.")
                .font(.subheadline)
                .foregroundStyle(Color.suhoorTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 0) {
                NotificationToggleRow(
                    icon: "alarm.fill",
                    title: "Sehri Wake-up",
                    subtitle: "30 minutes before Fajr",
                    isOn: $vm.suhoorNotification
                )
                Divider().background(Color.suhoorDivider)

                NotificationToggleRow(
                    icon: "clock.fill",
                    title: "Prayer Times",
                    subtitle: "All five daily prayers",
                    isOn: $vm.prayerTimesNotification
                )
                Divider().background(Color.suhoorDivider)

                NotificationToggleRow(
                    icon: "sunset.fill",
                    title: "Iftar Warning",
                    subtitle: "10 minutes before Maghrib",
                    isOn: $vm.iftarNotification
                )
                Divider().background(Color.suhoorDivider)

                NotificationToggleRow(
                    icon: "book.fill",
                    title: "Quran Reminder",
                    subtitle: "Daily reading reminder",
                    isOn: $vm.quranReminderNotification
                )
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.suhoorSurface))
            .padding(.horizontal, 32)

            Spacer()

            OnboardingButton(title: "Enable Notifications") {
                if !permissionRequested {
                    vm.requestNotificationPermission()
                    permissionRequested = true
                }
                vm.advance()
            }

            OnboardingSecondaryButton(title: "Maybe later") {
                vm.advance()
            }

            Spacer().frame(height: 20)
        }
    }
}

private struct NotificationToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.suhoorGold)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.suhoorTextPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.suhoorTextSecondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.suhoorGold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
