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

        // The reference below is a *Gregorian* date, so it must be resolved against a
        // Gregorian calendar. Calendar.current follows the user's region: on a Minguo
        // (Taiwan), Japanese, Islamic or Persian calendar, `year: 2025` lands centuries
        // away — which gave those users a different idiom from everyone else, and made
        // HistoryView's `startDate...Date()` an invalid range that traps at runtime.
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let referenceComponents = DateComponents(year: 2025, month: 1, day: 1)
        guard let referenceDate = calendar.date(from: referenceComponents) else {
            return idioms[0]
        }

        // Compare whole days, so the idiom turns over at the user's local midnight
        // rather than drifting with the time of day or a DST transition.
        let daysSinceReference = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: referenceDate),
            to: calendar.startOfDay(for: date)
        ).day ?? 0

        // Modulo that stays in range for dates before the reference too; `abs` would
        // mirror them, showing 2024-12-31 the same idiom as 2025-01-02.
        let count = idioms.count
        let index = ((daysSinceReference % count) + count) % count
        return idioms[index]
    }
    
    func idiomById(_ id: String) -> Idiom? {
        idioms.first(where: { $0.id == id })
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
