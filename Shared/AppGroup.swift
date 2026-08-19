import Foundation
import WidgetKit

/// How an idiom's English translation is presented in the app and widgets.
enum MeaningDisplayMode: String, CaseIterable {
    case literal
    case deeper
    case both

    /// Joins the two meanings when both are shown; falls back gracefully when an
    /// idiom has no separate metaphoric meaning.
    func text(literal: String, metaphoric: String?) -> String {
        switch self {
        case .literal:
            return literal
        case .deeper:
            return metaphoric ?? literal
        case .both:
            guard let metaphoric, metaphoric != literal else { return literal }
            return "\(literal) · \(metaphoric)"
        }
    }
}

enum AppGroup {
    static let identifier = "group.com.wilsonlimsetiawan.dailychinese"
    static let showMetaphoricMeaningKey = "showMetaphoricMeaning"
    static let useTraditionalCharactersKey = "useTraditionalCharacters"
    static let meaningDisplayModeKey = "meaningDisplayMode"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: identifier)
    }

    /// Reads the meaning mode from the shared store, falling back to the legacy
    /// boolean for users who set their preference before the "both" option existed.
    static func meaningDisplayMode(from defaults: UserDefaults?) -> MeaningDisplayMode {
        let store = defaults ?? .standard
        if let raw = store.string(forKey: meaningDisplayModeKey),
           let mode = MeaningDisplayMode(rawValue: raw) {
            return mode
        }
        return store.bool(forKey: showMetaphoricMeaningKey) ? .deeper : .literal
    }

    /// Before the app target was entitled to the shared app group, preference writes
    /// landed in a container the widget could not read. Those values were mirrored into
    /// standard UserDefaults, so recover them the first time the shared store is empty.
    static func migrateLegacyPreferencesIfNeeded() {
        guard let defaults = sharedDefaults else { return }

        var migrated = false
        for key in [showMetaphoricMeaningKey, useTraditionalCharactersKey, meaningDisplayModeKey] {
            if defaults.object(forKey: key) == nil,
               let legacyValue = UserDefaults.standard.object(forKey: key) {
                defaults.set(legacyValue, forKey: key)
                migrated = true
            }
        }

        // Seed the new three-way setting from the old on/off switch
        if defaults.object(forKey: meaningDisplayModeKey) == nil {
            let mode: MeaningDisplayMode = defaults.bool(forKey: showMetaphoricMeaningKey) ? .deeper : .literal
            defaults.set(mode.rawValue, forKey: meaningDisplayModeKey)
            migrated = true
        }

        if migrated {
            DispatchQueue.main.async {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    static func updateWidgetPreference(meaningDisplayMode: MeaningDisplayMode, useTraditionalCharacters: Bool) {
        // Update the shared UserDefaults
        if let defaults = sharedDefaults {
            defaults.set(meaningDisplayMode.rawValue, forKey: meaningDisplayModeKey)
            defaults.set(meaningDisplayMode != .literal, forKey: showMetaphoricMeaningKey)
            defaults.set(useTraditionalCharacters, forKey: useTraditionalCharactersKey)
            defaults.synchronize()

            // Also update standard UserDefaults as a fallback
            UserDefaults.standard.set(meaningDisplayMode.rawValue, forKey: meaningDisplayModeKey)
            UserDefaults.standard.set(meaningDisplayMode != .literal, forKey: showMetaphoricMeaningKey)
            UserDefaults.standard.set(useTraditionalCharacters, forKey: useTraditionalCharactersKey)
        }

        // Force reload all widget timelines
        DispatchQueue.main.async {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
