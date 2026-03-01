import WidgetKit
import SwiftUI

struct SuhoorWidgetsEntry: TimelineEntry {
    let date: Date
}

struct SuhoorWidgetsProvider: TimelineProvider {
    func placeholder(in context: Context) -> SuhoorWidgetsEntry {
        SuhoorWidgetsEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SuhoorWidgetsEntry) -> Void) {
        completion(SuhoorWidgetsEntry(date: Date()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SuhoorWidgetsEntry>) -> Void) {
        let entry = SuhoorWidgetsEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SuhoorWidgetsEntryView: View {
    var entry: SuhoorWidgetsProvider.Entry
    
    var body: some View {
        VStack(spacing: 4) {
            Text("🌙")
                .font(.title)
            Text("Suhoor")
                .font(.caption.weight(.semibold))
            Text("Iftar countdown")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

@main
struct SuhoorWidgets: Widget {
    let kind = "SuhoorWidgets"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SuhoorWidgetsProvider()) { entry in
            SuhoorWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Suhoor")
        .description("Ramadan countdown and prayer times.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}
