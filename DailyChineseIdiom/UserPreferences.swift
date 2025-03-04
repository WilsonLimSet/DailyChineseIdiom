import SwiftUI
import WidgetKit

class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    @AppStorage(AppGroup.showMetaphoricMeaningKey, store: UserDefaults(suiteName: AppGroup.identifier))
    var showMetaphoricMeaning: Bool = false {
        didSet {
            AppGroup.updateWidgetPreference(showMetaphoricMeaning: showMetaphoricMeaning)
        }
    }
    
    private init() {}
    
    func getMeaningForIdiom(_ idiom: Idiom) -> String {
        if showMetaphoricMeaning {
            return idiom.metaphoric_meaning ?? idiom.meaning
        }
        return idiom.meaning
    }
} 