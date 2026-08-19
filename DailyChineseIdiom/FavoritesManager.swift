import Foundation
import Combine

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()

    private let key = "favoriteIdiomIds"
    private let defaults: UserDefaults

    @Published private(set) var favoriteIds: [String]

    private init() {
        let store = UserDefaults(suiteName: AppGroup.identifier) ?? .standard
        self.defaults = store
        self.favoriteIds = store.stringArray(forKey: key) ?? []
    }

    func isFavorite(_ idiom: Idiom) -> Bool {
        favoriteIds.contains(idiom.id)
    }

    func toggleFavorite(_ idiom: Idiom) {
        if let index = favoriteIds.firstIndex(of: idiom.id) {
            favoriteIds.remove(at: index)
        } else {
            favoriteIds.insert(idiom.id, at: 0)
        }
        save()
    }

    func removeFavorite(id: String) {
        favoriteIds.removeAll { $0 == id }
        save()
    }

    var favoriteIdioms: [Idiom] {
        favoriteIds.compactMap { IdiomProvider.shared.idiomById($0) }
    }

    private func save() {
        defaults.set(favoriteIds, forKey: key)
    }
}
