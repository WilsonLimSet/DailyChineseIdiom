import Foundation
import WidgetKit

enum AppGroup {
    static let identifier = "group.com.wilsonlimsetiawan.dailychinese"
    static let showMetaphoricMeaningKey = "showMetaphoricMeaning"
    
    static func updateWidgetPreference(showMetaphoricMeaning: Bool) {
        // Update the shared UserDefaults
        if let defaults = UserDefaults(suiteName: identifier) {
            defaults.set(showMetaphoricMeaning, forKey: showMetaphoricMeaningKey)
            defaults.synchronize()
            
            // Also update standard UserDefaults as a fallback
            UserDefaults.standard.set(showMetaphoricMeaning, forKey: showMetaphoricMeaningKey)
            UserDefaults.standard.synchronize()
        }
        
        // Force reload all widget timelines
        DispatchQueue.main.async {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
