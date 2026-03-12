import SwiftUI

struct MakeupFastSection: View {
    let store: FastingStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Makeup Fasts")
                    .font(.headline)
                    .foregroundStyle(Color.suhoorTextPrimary)
                Spacer()
                Text("\(store.remainingMakeupCount) remaining")
                    .font(.caption)
                    .foregroundStyle(Color.suhoorTextSecondary)
            }
            
            ForEach(store.days.filter { $0.status == .missed || $0.status == .excused }) { day in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Day \(day.id)")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.suhoorTextPrimary)
                        if let reason = day.excuseReason {
                            Text(reason.rawValue)
                                .font(.caption)
                                .foregroundStyle(Color.suhoorTextSecondary)
                        } else {
                            Text("Missed")
                                .font(.caption)
                                .foregroundStyle(.red.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        store.toggleMadeUp(day.id)
                    } label: {
                        Image(systemName: day.madeUp ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundStyle(day.madeUp ? Color.suhoorSuccess : Color.suhoorTextSecondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.suhoorSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

#Preview {
    let store = FastingStore()
    MakeupFastSection(store: store)
        .background(Color.suhoorIndigo)
        .preferredColorScheme(.dark)
}
