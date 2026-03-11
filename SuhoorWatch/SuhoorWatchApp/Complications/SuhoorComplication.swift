import ClockKit
import SwiftUI

final class ComplicationDataSource: NSObject, CLKComplicationDataSource {
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let data = SharedData.load()
        
        switch complication.family {
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText(
                line1TextProvider: CLKSimpleTextProvider(text: "🌙"),
                line2TextProvider: CLKRelativeDateTextProvider(
                    date: data?.nextPrayerTime ?? Date(),
                    style: .timer,
                    units: [.hour, .minute]
                )
            )
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText(
                line1TextProvider: CLKSimpleTextProvider(text: data?.nextPrayerName ?? "—"),
                line2TextProvider: CLKRelativeDateTextProvider(
                    date: data?.nextPrayerTime ?? Date(),
                    style: .timer,
                    units: [.hour, .minute]
                )
            )
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            
        case .utilitarianSmall, .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat(
                textProvider: CLKSimpleTextProvider(text: "\(data?.nextPrayerName ?? "—") \(formatTime(data?.nextPrayerTime))")
            )
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularStackText(
                line1TextProvider: CLKSimpleTextProvider(text: data?.nextPrayerName ?? "🌙"),
                line2TextProvider: CLKRelativeDateTextProvider(
                    date: data?.nextPrayerTime ?? Date(),
                    style: .timer,
                    units: [.hour, .minute]
                )
            )
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            
        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularStandardBody(
                headerTextProvider: CLKSimpleTextProvider(text: "🌙 \(data?.nextPrayerName ?? "Suhoor")"),
                body1TextProvider: CLKRelativeDateTextProvider(
                    date: data?.iftarTime ?? Date(),
                    style: .timer,
                    units: [.hour, .minute]
                ),
                body2TextProvider: CLKSimpleTextProvider(text: "Iftar countdown")
            )
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            
        default:
            handler(nil)
        }
    }
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptor = CLKComplicationDescriptor(
            identifier: "SuhoorComplication",
            displayName: "Suhoor",
            supportedFamilies: [
                .circularSmall,
                .modularSmall,
                .utilitarianSmall,
                .utilitarianSmallFlat,
                .graphicCircular,
                .graphicRectangular
            ]
        )
        handler([descriptor])
    }
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "--:--" }
        let f = DateFormatter()
        f.dateFormat = "h:mm"
        return f.string(from: date)
    }
}
