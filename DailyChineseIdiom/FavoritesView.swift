import SwiftUI

struct FavoritesView: View {
    @StateObject private var favorites = FavoritesManager.shared
    @StateObject private var preferences = UserPreferences.shared

    private var idioms: [Idiom] {
        favorites.favoriteIdioms
    }

    var body: some View {
        Group {
            if idioms.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "star.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No Favorites Yet")
                        .font(.headline)
                    Text("Tap the star on any idiom to pin it here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(idioms, id: \.id) { idiom in
                        NavigationLink {
                            IdiomDetailView(idiom: idiom, date: nil, presentedAsSheet: false)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(preferences.getCharactersForIdiom(idiom))
                                    .font(.title2)
                                    .bold()
                                Text(idiom.pinyin)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(preferences.getMeaningForIdiom(idiom))
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            favorites.removeFavorite(id: idioms[index].id)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
    }
}
