import SwiftUI

struct FavoritesView: View {

    @Environment(FavoritesStore.self) private var favorites

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
       
            Group {
                if favorites.movies.isEmpty {
                    EmptyStateView(message: "No favorites yet. Tap the heart on a movie to save it.")
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(favorites.movies) { movie in
                                NavigationLink(value: movie) {
                                    MovieCard(movie: movie)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { AppBackground() }
            .navigationTitle("Favorites")
                    }
    }

