import SwiftUI

struct MakeupFastTrackerView: View {
    let dataManager: DataManager

    @State private var pendingFasts: [MakeupFast] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Makeup Fasts")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.suhoorTextPrimary)
                Spacer()
                if !pendingFasts.isEmpty {
                    Text("\(pendingFasts.filter(\.isPending).count) to make up")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.suhoorWarning)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.suhoorWarning.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            if pendingFasts.isEmpty {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color.suhoorSuccess)
                    Text("No makeup fasts needed — Alhamdulillah!")
                        .font(.subheadline)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
                .padding(.vertical, 8)
            } else {
                ForEach(pendingFasts, id: \.originalDate) { fast in
                    MakeupFastRow(fast: fast) {
                        dataManager.completeMakeupFast(fast)
                        loadPending()
                    }
                }
            }
        }
        .padding(20)
        .background(Color.suhoorNavy)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear { loadPending() }
    }

    private func loadPending() {
        pendingFasts = dataManager.pendingMakeupFasts()
    }
}

private struct MakeupFastRow: View {
    let fast: MakeupFast
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(formatted(date: fast.originalDate))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.suhoorTextPrimary)
                Text(fast.reason.capitalized)
                    .font(.caption)
                    .foregroundStyle(Color.suhoorTextSecondary)
            }
            Spacer()
            if fast.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.suhoorSuccess)
            } else {
                Button("Mark Done") { onComplete() }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.suhoorIndigo)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.suhoorGold)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }

    private func formatted(date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return fmt.string(from: date)
    }
}
