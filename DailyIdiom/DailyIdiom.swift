//
//  DailyIdiom.swift
//  DailyIdiom
//
//  Created by Wilson Lim Setiawan on 1/4/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry
    typealias Configuration = ConfigurationAppIntent
    
    func placeholder(in context: Context) -> SimpleEntry {
        let idiom = IdiomProvider.shared.idiomForDate()
        return SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            idiom: WidgetIdiom(from: idiom)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let idiom = IdiomProvider.shared.idiomForDate()
        let entry = SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            idiom: WidgetIdiom(from: idiom)
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        let tomorrow = Calendar.current.startOfDay(for: currentDate.addingTimeInterval(86400))
        let idiom = IdiomProvider.shared.idiomForDate()
        let entry = SimpleEntry(
            date: currentDate,
            configuration: ConfigurationAppIntent(),
            idiom: WidgetIdiom(from: idiom)
        )
        
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let idiom: WidgetIdiom
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
    VStack(alignment: .center, spacing: 4) { 
        Text(entry.idiom.characters)
            .font(.system(size: 32, weight: .bold)) 
            .minimumScaleFactor(0.5)
            .foregroundColor(.primary)
        
        Text(entry.idiom.pinyin)
            .font(.system(size: 12)) 
            .foregroundColor(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.8) 
        
        Text(entry.idiom.meaning)
            .font(.system(size: 10)) 
            .foregroundColor(.secondary)
            .lineLimit(2)
            .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 4) 
    .padding(.vertical, 4)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(UIColor.systemBackground))
            .shadow(radius: 2)
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
                .lineLimit(2)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(UIColor.systemBackground))
            .shadow(radius: 2)
    )
}
    
   private var largeWidget: some View {
    VStack(alignment: .center, spacing: 12) { // Reduced spacing from 16
        Text(entry.idiom.characters)
            .font(.system(size: 72, weight: .bold))
            .minimumScaleFactor(0.5)
            .foregroundColor(.primary)
        
        VStack(spacing: 8) { // Reduced spacing from 12
            Text(entry.idiom.pinyin)
                .font(.system(size: 24))
                .foregroundColor(.secondary)
            
            Text(entry.idiom.meaning)
                .font(.system(size: 18))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let example = entry.idiom.example {
                VStack(spacing: 6) {
                    if let chineseExample = entry.idiom.chineseExample {
                        Text(chineseExample)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    
                    Text(example)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .italic()
                }
                .padding(.horizontal, 8)
            }
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(UIColor.systemBackground))
            .shadow(radius: 2)
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
        idiom: WidgetIdiom(from: IdiomProvider.shared.idiomForDate())
    )
}

#Preview(as: .systemMedium) {
    DailyIdiom()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        idiom: WidgetIdiom(from: IdiomProvider.shared.idiomForDate())
    )
}

#Preview(as: .systemLarge) {
    DailyIdiom()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        idiom: WidgetIdiom(from: IdiomProvider.shared.idiomForDate())
    )
}