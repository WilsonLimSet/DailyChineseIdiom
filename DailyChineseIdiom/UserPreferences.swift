import SwiftUI
import WidgetKit

class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    @AppStorage(AppGroup.showMetaphoricMeaningKey, store: UserDefaults(suiteName: AppGroup.identifier))
    var showMetaphoricMeaning: Bool = false {
        didSet {
            AppGroup.updateWidgetPreference(showMetaphoricMeaning: showMetaphoricMeaning, useTraditionalCharacters: useTraditionalCharacters)
        }
    }
    
    @AppStorage(AppGroup.useTraditionalCharactersKey, store: UserDefaults(suiteName: AppGroup.identifier))
    var useTraditionalCharacters: Bool = false {
        didSet {
            AppGroup.updateWidgetPreference(showMetaphoricMeaning: showMetaphoricMeaning, useTraditionalCharacters: useTraditionalCharacters)
        }
    }
    
    private init() {}
    
    func getMeaningForIdiom(_ idiom: Idiom) -> String {
        if showMetaphoricMeaning {
            return idiom.metaphoric_meaning ?? idiom.meaning
        }
        return idiom.meaning
    }
    
    func getCharactersForIdiom(_ idiom: Idiom) -> String {
        if useTraditionalCharacters, let traditional = idiom.traditionalCharacters {
            return traditional
        }
        return idiom.characters
    }
    
    func getChineseExampleForIdiom(_ idiom: Idiom) -> String? {
        if useTraditionalCharacters, let traditional = idiom.chineseExample_tr {
            return traditional
        }
        return idiom.chineseExample
    }
    
    func getDescriptionForIdiom(_ idiom: Idiom) -> String {
        if useTraditionalCharacters, let traditional = idiom.description_tr {
            return traditional
        }
        return idiom.description
    }
} 