import SwiftUI
import WidgetKit

// MARK: - Watch Complication Timeline Entry

struct SuhoorWatchEntry: TimelineEntry {
    let date: Date
    let data: SharedData
    
    static var placeholder: SuhoorWatchEntry {
        SuhoorWatchEntry(date: Date(), data: .placeholder)
    }
}

// MARK: - Watch Complication Provider

struct SuhoorWatchProvider: TimelineProvider {
    func placeholder(in context: Context) -> SuhoorWatchEntry {
        .placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SuhoorWatchEntry) -> Void) {
        let data = SharedData.load() ?? .placeholder
        completion(SuhoorWatchEntry(date: Date(), data: data))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SuhoorWatchEntry>) -> Void) {
        let data = SharedData.load() ?? .placeholder
        let entry = SuhoorWatchEntry(date: Date(), data: data)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Circular Complication

struct SuhoorCircularComplication: View {
    let entry: SuhoorWatchEntry
    
    var body: some View {
        VStack(spacing: 1) {
            Text("🌙")
                .font(.caption)
            Text(entry.data.nextPrayerTime, style: .timer)
                .font(.system(.caption2, design: .monospaced))
        }
    }
}

// MARK: - Rectangular Complication

struct SuhoorRectangularComplication: View {
    let entry: SuhoorWatchEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("🌙")
                    .font(.caption2)
                Text(entry.data.nextPrayerName)
                    .font(.caption.weight(.semibold))
            }
            
            Text(entry.data.iftarTime, style: .timer)
                .font(.caption.weight(.bold).monospacedDigit())
                .foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.32))
            
            Text("Iftar at \(entry.data.iftarTime, style: .time)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Corner Complication

struct SuhoorCornerComplication: View {
    let entry: SuhoorWatchEntry
    
    var body: some View {
        Text(entry.data.nextPrayerTime, style: .timer)
            .font(.system(.caption2, design: .monospaced))
            .widgetLabel {
                Text("🌙 \(entry.data.nextPrayerName)")
            }
    }
}

// MARK: - Widget Registration

struct SuhoorWatchComplication: Widget {
    let kind = "SuhoorWatchComplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SuhoorWatchProvider()) { entry in
            SuhoorComplicationView(entry: entry)
        }
        .configurationDisplayName("Suhoor")
        .description("Iftar countdown and next prayer time.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryCorner,
            .accessoryInline
        ])
    }
}

struct SuhoorComplicationView: View {
    @Environment(\.widgetFamily) var family
    let entry: SuhoorWatchEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            SuhoorCircularComplication(entry: entry)
        case .accessoryRectangular:
            SuhoorRectangularComplication(entry: entry)
        case .accessoryCorner:
            SuhoorCornerComplication(entry: entry)
        case .accessoryInline:
            Text("🌙 \(entry.data.nextPrayerName) \(entry.data.nextPrayerTime, style: .timer)")
        default:
            SuhoorCircularComplication(entry: entry)
        }
    }
}
