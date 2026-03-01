import SwiftUI

struct WatchContentView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("🌙")
                .font(.title2)
            Text("Suhoor")
                .font(.headline)
            Text("Iftar in --:--")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    WatchContentView()
}
