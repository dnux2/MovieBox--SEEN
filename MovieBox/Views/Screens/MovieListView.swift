import SwiftUI

struct MovieListView: View {

    @State private var viewModel: MovieListViewModel
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    init(kind: MovieListKind) {
        _viewModel = State(initialValue: MovieListViewModel(kind: kind))
    }

    var body: some View {
        content
            .background { AppBackground() }
            .navigationTitle(viewModel.kind.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if viewModel.movies.isEmpty {
                    await viewModel.fetchFirstPage()
                }
            }
    }

    // نفس الحالات الأربع
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.movies.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else if let message = viewModel.errorMessage, viewModel.movies.isEmpty {
            ErrorView(message: message) {
                Task { await viewModel.fetchFirstPage() }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else if viewModel.movies.isEmpty {
            EmptyStateView(message: "No movies found.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.movies) { movie in
                        NavigationLink(value: movie) {
                            MovieCard(movie: movie)
                        }
                        .buttonStyle(.plain)
                        .task {
                            await viewModel.loadMoreIfNeeded(current: movie)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .refreshable {
                await viewModel.fetchFirstPage()
            }
        }
    }
}

#Preview {
    NavigationStack {
        MovieListView(kind: .topRated)
    }
    .environment(FavoritesStore())
}


