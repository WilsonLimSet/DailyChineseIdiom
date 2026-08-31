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

        var ids = store.stringArray(forKey: key) ?? []
        if store.integer(forKey: FavoritesMigration.migrationVersionKey) < FavoritesMigration.currentVersion {
            ids = FavoritesMigration.migrate(ids)
            store.set(ids, forKey: key)
            store.set(FavoritesMigration.currentVersion, forKey: FavoritesMigration.migrationVersionKey)
        }
        self.favoriteIds = ids
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
