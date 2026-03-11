import ActivityKit
import SwiftUI
import WidgetKit

struct SuhoorLiveActivityView: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SuhoorActivityAttributes.self) { context in
            // Lock Screen / Banner view
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded regions
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.eventName)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.7))
                        Text("Day \(context.state.ramadanDay)")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.eventTime, style: .timer)
                        .font(.title2.weight(.bold).monospacedDigit())
                        .foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.32))
                        .multilineTextAlignment(.trailing)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("\(context.state.eventName) Countdown")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(context.state.eventTime, style: .time)
                            .font(.caption)
                    }
                    .foregroundStyle(.white.opacity(0.5))
                }
            } compactLeading: {
                Text("🌙")
                    .font(.caption)
            } compactTrailing: {
                Text(context.state.eventTime, style: .timer)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.32))
            } minimal: {
                Text("🌙")
                    .font(.caption2)
            }
        }
    }
    
    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<SuhoorActivityAttributes>) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Ramadan Day \(context.state.ramadanDay)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(context.state.eventName)
                    .font(.title2.weight(.bold))
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(context.state.eventTime, style: .time)
                        .font(.subheadline)
                }
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(context.state.eventTime, style: .timer)
                    .font(.title.weight(.bold).monospacedDigit())
                    .foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.32))
                Text("remaining")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .activityBackgroundTint(Color(red: 0.08, green: 0.07, blue: 0.20))
    }
}
