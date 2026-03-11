import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct SuhoorWidgetEntry: TimelineEntry {
    let date: Date
    let data: SharedData
    
    static var placeholder: SuhoorWidgetEntry {
        SuhoorWidgetEntry(date: Date(), data: .placeholder)
    }
}

// MARK: - Timeline Provider

struct SuhoorWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SuhoorWidgetEntry {
        .placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SuhoorWidgetEntry) -> Void) {
        let data = SharedData.load() ?? .placeholder
        completion(SuhoorWidgetEntry(date: Date(), data: data))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SuhoorWidgetEntry>) -> Void) {
        let data = SharedData.load() ?? .placeholder
        let entry = SuhoorWidgetEntry(date: Date(), data: data)
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: SuhoorWidgetEntry
    
    var body: some View {
        VStack(spacing: 6) {
            Text("🌙")
                .font(.title2)
            Text(entry.data.nextPrayerName)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
            Text(entry.data.nextPrayerTime, style: .time)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
            Text(entry.data.nextPrayerTime, style: .timer)
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.32))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(Color(red: 0.08, green: 0.07, blue: 0.20), for: .widget)
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: SuhoorWidgetEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Iftar countdown
            VStack(spacing: 4) {
                Text("🌇 Iftar")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
                Text(entry.data.iftarTime, style: .timer)
                    .font(.title3.weight(.bold).monospacedDigit())
                    .foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.32))
                Text(entry.data.iftarTime, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .background(.white.opacity(0.15))
            
            // Next 3 prayers
            VStack(alignment: .leading, spacing: 4) {
                ForEach(entry.data.upcomingPrayers.prefix(3)) { prayer in
                    HStack {
                        Text(prayer.emoji)
                            .font(.caption2)
                        Text(prayer.name)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.white)
                        Spacer()
                        Text(prayer.time, style: .time)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 4)
        .containerBackground(Color(red: 0.08, green: 0.07, blue: 0.20), for: .widget)
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let entry: SuhoorWidgetEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("🌙 Ramadan Day \(entry.data.ramadanDay)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.32))
                Spacer()
                Text("🔥 \(entry.data.fastingStreak) day streak")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            // Iftar & Sehri
            HStack(spacing: 12) {
                timeCard(emoji: "🌇", label: "Iftar", time: entry.data.iftarTime, showTimer: true)
                timeCard(emoji: "🌅", label: "Sehri", time: entry.data.sehriTime, showTimer: false)
            }
            
            Divider().background(.white.opacity(0.1))
            
            // All upcoming prayers
            VStack(spacing: 6) {
                ForEach(entry.data.upcomingPrayers) { prayer in
                    HStack {
                        Text(prayer.emoji)
                            .font(.caption)
                        Text(prayer.name)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                        Spacer()
                        Text(prayer.time, style: .time)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            
            Divider().background(.white.opacity(0.1))
            
            // Quran progress
            HStack {
                Text("📖 Quran")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                ProgressView(value: entry.data.quranProgress)
                    .frame(width: 80)
                    .tint(Color(red: 0.85, green: 0.68, blue: 0.32))
                Text("\(Int(entry.data.quranProgress * 100))%")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .containerBackground(Color(red: 0.08, green: 0.07, blue: 0.20), for: .widget)
    }
    
    private func timeCard(emoji: String, label: String, time: Date, showTimer: Bool) -> some View {
        VStack(spacing: 4) {
            Text("\(emoji) \(label)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
            if showTimer {
                Text(time, style: .timer)
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.32))
            }
            Text(time, style: .time)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Accessory Widgets

struct AccessoryCircularView: View {
    let entry: SuhoorWidgetEntry
    
    var body: some View {
        VStack(spacing: 1) {
            Text("🌙")
                .font(.caption)
            Text(entry.data.nextPrayerTime, style: .timer)
                .font(.caption2.monospacedDigit())
        }
    }
}

struct AccessoryRectangularView: View {
    let entry: SuhoorWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("🌙 \(entry.data.nextPrayerName)")
                .font(.caption.weight(.semibold))
            Text(entry.data.nextPrayerTime, style: .time)
                .font(.caption2)
            Text(entry.data.nextPrayerTime, style: .timer)
                .font(.caption2.monospacedDigit())
        }
    }
}

// MARK: - Widget Bundle

@main
struct SuhoorWidgetBundle: WidgetBundle {
    var body: some Widget {
        SuhoorPrayerWidget()
        SuhoorLiveActivityView()
    }
}

struct SuhoorPrayerWidget: Widget {
    let kind = "SuhoorWidgets"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SuhoorWidgetProvider()) { entry in
            switch WidgetFamily.current(entry: entry) {
            default:
                WidgetFamilyView(entry: entry)
            }
        }
        .configurationDisplayName("Suhoor")
        .description("Ramadan countdown and prayer times.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryRectangular])
    }
}

// Widget family router
struct WidgetFamilyView: View {
    @Environment(\.widgetFamily) var family
    let entry: SuhoorWidgetEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// Helper to avoid unused variable warning
private extension WidgetFamily {
    static func current(entry: SuhoorWidgetEntry) -> WidgetFamily? { nil }
}
