import Foundation

class IdiomProvider {
    static let shared = IdiomProvider()
    private var idioms: [Idiom] = []
    
    private init() {
        loadIdioms()
    }
    
    private func loadIdioms() {
        print("Current bundle identifier: \(Bundle.main.bundleIdentifier ?? "unknown")")
        print("Current bundle path: \(Bundle.main.bundlePath)")
        
        let possiblePaths = [
            "idioms",
            "Resources/idioms",
            "Shared/Resources/idioms",
            "../Shared/Resources/idioms",
            "../../Shared/Resources/idioms",
            "../DailyChineseIdiom/Resources/idioms"
        ]
        
        // Try main bundle with all paths
        for path in possiblePaths {
            if let url = Bundle.main.url(forResource: path, withExtension: "json") {
                print("✅ Found idioms.json at path: \(path)")
                loadFromURL(url)
                return
            }
        }
        
        // Try widget bundle with all paths
        if let widgetBundle = Bundle(identifier: "Daily.DailyChineseIdiom.DailyIdiom") {
            print("Widget bundle path: \(widgetBundle.bundlePath)")
            for path in possiblePaths {
                if let url = widgetBundle.url(forResource: path, withExtension: "json") {
                    print("✅ Found idioms.json in widget bundle at path: \(path)")
                    loadFromURL(url)
                    return
                }
            }
        }
        
        print("❌ Failed to find idioms.json. Searched in paths:")
        possiblePaths.forEach { print("- \($0)") }
    }
    
    private func loadFromURL(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            idioms = try JSONDecoder().decode([Idiom].self, from: data)
            print("Successfully loaded \(idioms.count) idioms")
        } catch {
            print("Error decoding idioms: \(error)")
        }
    }
    
    func idiomForDate() -> Idiom {
        if idioms.isEmpty {
            print("Warning: Using sample idiom because no idioms were loaded")
            return sampleIdiom
        }
        
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % max(1, idioms.count)
        return idioms[index]
    }
}

// Sample idiom for fallback
private let sampleIdiom = Idiom(
    characters: "塞翁失马",
    pinyin: "sài wēng shī mǎ",
    meaning: "A blessing in disguise",
    example: "Losing his job led him to find his true calling",
    chineseExample: "失业反而让他找到了真正的使命",
    theme: "Life Philosophy",
    description: "This story comes from a famous Chinese parable about an old man whose lost horse returned with more horses."
) 