import Foundation
import WidgetKit

enum AppGroup {
    static let identifier = "group.com.wilsonlimsetiawan.dailychinese"
    static let showMetaphoricMeaningKey = "showMetaphoricMeaning"
    static let useTraditionalCharactersKey = "useTraditionalCharacters"
    
    static func updateWidgetPreference(showMetaphoricMeaning: Bool, useTraditionalCharacters: Bool) {
        // Update the shared UserDefaults
        if let defaults = UserDefaults(suiteName: identifier) {
            defaults.set(showMetaphoricMeaning, forKey: showMetaphoricMeaningKey)
            defaults.set(useTraditionalCharacters, forKey: useTraditionalCharactersKey)
            defaults.synchronize()
            
            // Also update standard UserDefaults as a fallback
            UserDefaults.standard.set(showMetaphoricMeaning, forKey: showMetaphoricMeaningKey)
            UserDefaults.standard.set(useTraditionalCharacters, forKey: useTraditionalCharactersKey)
            UserDefaults.standard.synchronize()
        }
        
        // Force reload all widget timelines
        DispatchQueue.main.async {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
