import SwiftUI

struct WatchContentView: View {
    let data: SharedData?
    
    init() {
        self.data = SharedData.load()
    }
    
    var body: some View {
        if let data = data {
            VStack(spacing: 8) {
                Text("Day \(data.ramadanDay)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text("🌙 \(data.nextPrayerName)")
                    .font(.headline)
                
                Text(data.nextPrayerTime, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(data.nextPrayerTime, style: .timer)
                    .font(.title3.weight(.bold).monospacedDigit())
                    .foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.32))
                
                Divider()
                
                HStack {
                    VStack(spacing: 2) {
                        Text("Iftar")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(data.iftarTime, style: .time)
                            .font(.caption2.weight(.semibold))
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text("Sehri")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(data.sehriTime, style: .time)
                            .font(.caption2.weight(.semibold))
                    }
                }
                .padding(.horizontal)
            }
        } else {
            VStack(spacing: 8) {
                Text("🌙")
                    .font(.title2)
                Text("Suhoor")
                    .font(.headline)
                Text("Open app to sync")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    WatchContentView()
}
