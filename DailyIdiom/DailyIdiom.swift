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
    let showMetaphoricMeaning: Bool
    let useTraditionalCharacters: Bool
}

class Provider: NSObject, TimelineProvider {
    typealias Entry = SimpleEntry
    private let userDefaults = UserDefaults(suiteName: AppGroup.identifier)
    
    override init() {
        super.init()
        
        // Register for app group user defaults changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: userDefaults
        )
        
        // Also register for standard UserDefaults changes as a fallback
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: UserDefaults.standard
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func userDefaultsDidChange(_ notification: Notification) {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        // Get the latest values safely
        let showMetaphoricMeaning = getUserDefaultsBool(forKey: AppGroup.showMetaphoricMeaningKey)
        let useTraditionalCharacters = getUserDefaultsBool(forKey: AppGroup.useTraditionalCharactersKey)
        return SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            idiom: IdiomProvider.shared.idiomForDate(),
            showMetaphoricMeaning: showMetaphoricMeaning,
            useTraditionalCharacters: useTraditionalCharacters
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        // Get the latest values safely
        let showMetaphoricMeaning = getUserDefaultsBool(forKey: AppGroup.showMetaphoricMeaningKey)
        let useTraditionalCharacters = getUserDefaultsBool(forKey: AppGroup.useTraditionalCharactersKey)
        let entry = SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            idiom: IdiomProvider.shared.idiomForDate(),
            showMetaphoricMeaning: showMetaphoricMeaning,
            useTraditionalCharacters: useTraditionalCharacters
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: currentDate.addingTimeInterval(86400))
        let idiom = IdiomProvider.shared.idiomForDate()
        
        // Get the latest values safely
        let showMetaphoricMeaning = getUserDefaultsBool(forKey: AppGroup.showMetaphoricMeaningKey)
        let useTraditionalCharacters = getUserDefaultsBool(forKey: AppGroup.useTraditionalCharactersKey)
        
        let entries = [
            SimpleEntry(
                date: currentDate,
                configuration: ConfigurationAppIntent(),
                idiom: idiom,
                showMetaphoricMeaning: showMetaphoricMeaning,
                useTraditionalCharacters: useTraditionalCharacters
            ),
            SimpleEntry(
                date: midnight,
                configuration: ConfigurationAppIntent(),
                idiom: idiom,
                showMetaphoricMeaning: showMetaphoricMeaning,
                useTraditionalCharacters: useTraditionalCharacters
            )
        ]
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    // Helper method to safely access UserDefaults
    private func getUserDefaultsBool(forKey key: String) -> Bool {
        // Try to access the shared UserDefaults first
        if let defaults = userDefaults {
            let value = defaults.bool(forKey: key)
            return value
        }
        
        // Fall back to standard UserDefaults if shared UserDefaults is not available
        let value = UserDefaults.standard.bool(forKey: key)
        return value
    }
}

struct DailyIdiomEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    private func getMeaning(_ idiom: Idiom) -> String {
        if entry.showMetaphoricMeaning {
            return idiom.metaphoric_meaning ?? idiom.meaning
        }
        return idiom.meaning
    }
    
    private func getCharacters(_ idiom: Idiom) -> String {
        if entry.useTraditionalCharacters, let traditional = idiom.traditionalCharacters {
            return traditional
        }
        return idiom.characters
    }
    
    private func getChineseExample(_ idiom: Idiom) -> String? {
        if entry.useTraditionalCharacters, let traditional = idiom.chineseExample_tr {
            return traditional
        }
        return idiom.chineseExample
    }
    
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
        // Only show the Chinese characters and pinyin
        Text(getCharacters(entry.idiom))
            .font(.system(size: 48, weight: .bold))
            .minimumScaleFactor(0.5)
            .foregroundColor(.primary)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 1)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 6)

        Text(entry.idiom.pinyin)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(.secondary)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 16)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
}
    
   private var mediumWidget: some View {
    HStack(spacing: 20) {
        // Left side with Chinese characters
        Text(getCharacters(entry.idiom))
            .font(.system(size: 56, weight: .bold))
            .minimumScaleFactor(0.5)
            .foregroundColor(.primary)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.1), radius: 1.5)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)

        // Right side with pinyin and meaning
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.idiom.pinyin)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(getMeaning(entry.idiom))
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
    
   private var largeWidget: some View {
    VStack(alignment: .center, spacing: 16) {
        // Decorative element at top
        HStack {
            decorativeLine
            Text("每日成语")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary.opacity(0.7))
                .padding(.horizontal, 8)
            decorativeLine
        }
        .padding(.top, 4)

        // Main characters with enhanced styling
        Text(getCharacters(entry.idiom))
            .font(.system(size: 72, weight: .bold))
            .minimumScaleFactor(0.6)
            .foregroundColor(.primary)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.15), radius: 2)
            .padding(.vertical, 4)

        // Pinyin with enhanced styling
        Text(entry.idiom.pinyin)
            .font(.system(size: 22, weight: .medium, design: .rounded))
            .foregroundColor(.secondary)
            .lineLimit(1)
            .padding(.bottom, 4)

        // Divider
        Rectangle()
            .frame(height: 1)
            .foregroundColor(Color.secondary.opacity(0.2))
            .padding(.horizontal, 40)

        // Meaning with enhanced styling
        Text(getMeaning(entry.idiom))
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .padding(.vertical, 4)
            .padding(.horizontal, 20)

        // Example section with enhanced styling
        if let example = entry.idiom.example {
            VStack(spacing: 8) {
                if let chineseExample = getChineseExample(entry.idiom) {
                    Text(chineseExample)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                }

                Text(example)
                    .font(.system(size: 14, weight: .light, design: .serif))
                    .foregroundColor(.secondary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .italic()
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}

// Decorative line for the large widget
private var decorativeLine: some View {
    Rectangle()
        .frame(height: 1)
        .foregroundColor(Color.secondary.opacity(0.3))
}
}

struct DailyIdiom: Widget {
    let kind: String = "DailyIdiom"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DailyIdiomEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                DailyIdiomEntryView(entry: entry)
                    .padding()
                    .background()
            }
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
        idiom: IdiomProvider.shared.idiomForDate(),
        showMetaphoricMeaning: UserDefaults(suiteName: AppGroup.identifier)?.bool(forKey: AppGroup.showMetaphoricMeaningKey) ?? false,
        useTraditionalCharacters: UserDefaults(suiteName: AppGroup.identifier)?.bool(forKey: AppGroup.useTraditionalCharactersKey) ?? false
    )
}

#Preview(as: .systemMedium) {
    DailyIdiom()
} timeline: {
    let idiom = IdiomProvider.shared.idiomForDate()
    // First entry with literal meaning
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        idiom: idiom,
        showMetaphoricMeaning: false,
        useTraditionalCharacters: false
    )
    // Second entry with metaphorical meaning
    SimpleEntry(
        date: .now.addingTimeInterval(1),
        configuration: ConfigurationAppIntent(),
        idiom: idiom,
        showMetaphoricMeaning: true,
        useTraditionalCharacters: true
    )
}

#Preview(as: .systemLarge) {
    DailyIdiom()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        idiom: IdiomProvider.shared.idiomForDate(),
        showMetaphoricMeaning: UserDefaults(suiteName: AppGroup.identifier)?.bool(forKey: AppGroup.showMetaphoricMeaningKey) ?? false,
        useTraditionalCharacters: UserDefaults(suiteName: AppGroup.identifier)?.bool(forKey: AppGroup.useTraditionalCharactersKey) ?? false
    )
}



