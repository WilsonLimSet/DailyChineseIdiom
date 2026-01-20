import Foundation

class IdiomProvider {
    static let shared = IdiomProvider()
    private var idioms: [Idiom] = []
    
    private init() {
        loadIdioms()
    }
    
    private func loadIdioms() {
        let possiblePaths = [
            "idioms",
            "Resources/idioms",
            "Shared/Resources/idioms",
            "../Resources/idioms",
            "../Shared/Resources/idioms",
            "../../Shared/Resources/idioms"
        ]
        
        // Try main bundle with all paths
        for path in possiblePaths {
            if let url = Bundle.main.url(forResource: path, withExtension: "json") {
                loadFromURL(url)
                return
            }
        }
        
        // Try widget bundle with all paths
        if let widgetBundle = Bundle(identifier: "com.wilsonlimsetiawan.dailychineseidiom.widget") {
            for path in possiblePaths {
                if let url = widgetBundle.url(forResource: path, withExtension: "json") {
                    loadFromURL(url)
                    return
                }
            }
        }
    }
    
    private func loadFromURL(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            idioms = try JSONDecoder().decode([Idiom].self, from: data)
        } catch {
            // Silently fall back to sample idiom
        }
    }
    
    func idiomForDate(_ date: Date = Date()) -> Idiom {
        if idioms.isEmpty {
            return sampleIdiom
        }

        let calendar = Calendar.current
        // Reference date: Jan 1, 2025
        let referenceComponents = DateComponents(year: 2025, month: 1, day: 1)
        let referenceDate = calendar.date(from: referenceComponents) ?? date

        // Calculate days since reference date
        let daysSinceReference = calendar.dateComponents([.day], from: referenceDate, to: date).day ?? 0
        let index = abs(daysSinceReference) % max(1, idioms.count)
        return idioms[index]
    }
    
    func randomIdiom() -> Idiom {
        if idioms.isEmpty {
            return sampleIdiom
        }
        
        let currentIdiom = idiomForDate()
        var randomIdiom: Idiom
        
        repeat {
            randomIdiom = idioms.randomElement() ?? sampleIdiom
        } while randomIdiom.id == currentIdiom.id && idioms.count > 1
        
        return randomIdiom
    }
}
