import Foundation

struct Idiom: Codable {
    let characters: String
    let pinyin: String
    let meaning: String
    let example: String?
    let chineseExample: String?
    let theme: String
    let description: String
}

class IdiomProvider {
    static let shared = IdiomProvider()
    private var idioms: [Idiom] = []
    
    init() {
        loadIdioms()
    }
    
    private func loadIdioms() {
        
        // First try the main app bundle
        if let mainBundleUrl = Bundle.main.url(forResource: "Resources/idioms", withExtension: "json") {
            loadFromURL(mainBundleUrl)
            return
        }
        
        // Then try the widget bundle
        if let widgetBundle = Bundle(identifier: "Daily.DailyChineseIdiom.DailyIdiom"),
           let widgetUrl = widgetBundle.url(forResource: "Resources/idioms", withExtension: "json") {
            loadFromURL(widgetUrl)
            return
        }
        
        // Try the main bundle with different paths
        let paths = ["idioms", "Resources/idioms", "../Resources/idioms"]
        for path in paths {
            if let url = Bundle.main.url(forResource: path, withExtension: "json") {
                loadFromURL(url)
                return
            }
        }
        
      
    }
    
    private func loadFromURL(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            idioms = try JSONDecoder().decode([Idiom].self, from: data)
        } catch {
        }
    }
    
    func idiomForDate(_ date: Date = Date()) -> Idiom {
        if idioms.isEmpty {
            return sampleIdiom
        }
        
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = (dayOfYear - 1) % idioms.count
        return idioms[index]
    }
}

// Fallback sample idiom in case of errors
let sampleIdiom = Idiom(
    characters: "塞翁失马",
    pinyin: "sài wēng shī mǎ",
    meaning: "A blessing in disguise",
    example: "Losing his job led him to find his true calling",
    chineseExample: "失业反而让他找到了真正的使命",
    theme: "Life Philosophy",
    description: "This story comes from a famous Chinese parable about an old man whose lost horse returned with more horses. When his son broke his leg riding one, it seemed unfortunate until it saved him from being drafted into war. The story teaches that apparent misfortune may turn out to be beneficial."
) 