import SwiftUI
import WidgetKit

/// Backed by the shared app-group store so the widget sees the same values.
///
/// These are deliberately `@Published` rather than `@AppStorage`: `@AppStorage` only drives
/// view updates when it is declared inside a View. Inside an ObservableObject it writes the
/// value but never fires `objectWillChange`, so screens observing this object would keep
/// rendering the old setting until something else forced a redraw.
class UserPreferences: ObservableObject {
    static let shared = UserPreferences()

    private let store: UserDefaults

    @Published var meaningDisplayMode: MeaningDisplayMode {
        didSet { persist() }
    }

    @Published var useTraditionalCharacters: Bool {
        didSet { persist() }
    }

    private init() {
        let store = UserDefaults(suiteName: AppGroup.identifier) ?? .standard
        self.store = store
        self.meaningDisplayMode = AppGroup.meaningDisplayMode(from: store)
        self.useTraditionalCharacters = store.bool(forKey: AppGroup.useTraditionalCharactersKey)
    }

    private func persist() {
        AppGroup.updateWidgetPreference(
            meaningDisplayMode: meaningDisplayMode,
            useTraditionalCharacters: useTraditionalCharacters
        )
    }

    func getMeaningForIdiom(_ idiom: Idiom) -> String {
        meaningDisplayMode.text(literal: idiom.meaning, metaphoric: idiom.metaphoric_meaning)
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
