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
    
    // Sample idiom for testing
    private let sampleIdiom = Idiom(
        characters: "加油",
        pinyin: "jiā yóu",
        meaning: "keep going",
        example: "You can do it!"
    )

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            idiom: sampleIdiom
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            idiom: sampleIdiom
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            idiom: sampleIdiom
        )
        
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let idiom: Idiom
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
    
    // Small square widget
    private var smallWidget: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(entry.idiom.characters)
                .font(.system(size: 36, weight: .bold))
                .minimumScaleFactor(0.5)
                .foregroundColor(.primary)
            
            Text(entry.idiom.pinyin)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Text(entry.idiom.meaning)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding()
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
                    .lineLimit(3)
                
                if let example = entry.idiom.example {
                    Text(example)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .italic()
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
    
    // Large vertical widget
    private var largeWidget: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(entry.idiom.characters)
                .font(.system(size: 72, weight: .bold))
                .minimumScaleFactor(0.5)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                Text(entry.idiom.pinyin)
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
                
                Text(entry.idiom.meaning)
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if let example = entry.idiom.example {
                    Text(example)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .italic()
                        .padding(.top, 8)
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
        idiom: Idiom(
            characters: "学习",
            pinyin: "xué xí",
            meaning: "to study",
            example: nil
        )
    )
}

#Preview(as: .systemMedium) {
    DailyIdiom()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        idiom: Idiom(
            characters: "一举两得",
            pinyin: "yī jǔ liǎng dé",
            meaning: "to kill two birds with one stone",
            example: "Learning Chinese while having fun is 一举两得"
        )
    )
}

#Preview(as: .systemLarge) {
    DailyIdiom()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        idiom: Idiom(
            characters: "熟能生巧",
            pinyin: "shú néng shēng qiǎo",
            meaning: "practice makes perfect",
            example: "Keep practicing and you'll improve naturally"
        )
    )
}
