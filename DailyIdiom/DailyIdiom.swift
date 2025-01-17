//
//  DailyIdiom.swift
//  DailyIdiom
//
//  Created by Wilson Lim Setiawan on 1/4/25.
//

import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let idiom: Idiom
}

class Provider: TimelineProvider {
    typealias Entry = SimpleEntry
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            idiom: IdiomProvider.shared.idiomForDate()
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            idiom: IdiomProvider.shared.idiomForDate()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: currentDate.addingTimeInterval(86400))
        let idiom = IdiomProvider.shared.idiomForDate()
        
        let entry = SimpleEntry(
            date: currentDate,
            configuration: ConfigurationAppIntent(),
            idiom: idiom
        )
        
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }
}

struct DailyIdiomEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .systemLarge:
            largeWidget
        default:
            smallWidget
        }
    }
    
   private var smallWidget: some View {
    VStack(alignment: .center, spacing: 8) {
        Text(entry.idiom.characters)
            .font(.system(size: 36, weight: .bold))
            .minimumScaleFactor(0.4)
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
        
        Text(entry.idiom.pinyin)
            .font(.system(size: 14)) 
            .foregroundColor(.secondary)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
        
       
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 12)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ?
                    UIColor(white: 0.15, alpha: 1.0) :
                    .systemBackground
            }))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(uiColor: UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark ?
                            UIColor(white: 0.3, alpha: 1.0) :
                            UIColor(white: 0, alpha: 0.1)
                    }), lineWidth: 0.5)
            )
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 1)
    )
}
    
   // Medium horizontal widget
private var mediumWidget: some View {
    HStack(spacing: 16) {
        Text(entry.idiom.characters)
            .font(.system(size: 48, weight: .bold))
            .minimumScaleFactor(0.5)
            .foregroundColor(.primary)
        
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.idiom.pinyin)
                .font(.system(size: 18))
                .foregroundColor(.secondary)
            
            Text(entry.idiom.meaning)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.5)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ?
                    UIColor(white: 0.15, alpha: 1.0) :
                    .systemBackground
            }))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(uiColor: UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark ?
                            UIColor(white: 0.3, alpha: 1.0) :
                            UIColor(white: 0, alpha: 0.1)
                    }), lineWidth: 0.5)
            )
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 1)
    )
}
    
   private var largeWidget: some View {
    VStack(alignment: .center, spacing: 12) {
        Text(entry.idiom.characters)
            .font(.system(size: 72, weight: .bold))
            .minimumScaleFactor(0.5)
            .foregroundColor(.primary)
        
        VStack(spacing: 8) {
            Text(entry.idiom.pinyin)
                .font(.system(size: 23))
                .foregroundColor(.secondary)
                .lineLimit(2)

            
            Text(entry.idiom.meaning)
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if let example = entry.idiom.example {
                VStack(spacing: 6) {
                    if let chineseExample = entry.idiom.chineseExample {
                        Text(chineseExample)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    
                    Text(example)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .italic()
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                }
                .padding(.horizontal, 8)
            }
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ?
                    UIColor(white: 0.15, alpha: 1.0) :
                    .systemBackground
            }))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(uiColor: UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark ?
                            UIColor(white: 0.3, alpha: 1.0) :
                            UIColor(white: 0, alpha: 0.1)
                    }), lineWidth: 0.5)
            )
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 1)
    )
}
}

struct DailyIdiom: Widget {
    let kind: String = "DailyIdiom"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyIdiomEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daily Chinese Idiom")
        .description("Learn a new Chinese idiom every day")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    DailyIdiom()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        idiom: IdiomProvider.shared.idiomForDate()
    )
}

#Preview(as: .systemMedium) {
    DailyIdiom()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        idiom: IdiomProvider.shared.idiomForDate()
    )
}

#Preview(as: .systemLarge) {
    DailyIdiom()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        idiom: IdiomProvider.shared.idiomForDate()
    )}



