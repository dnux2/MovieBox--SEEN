import SwiftUI

struct SearchView: View {

    @State private var viewModel = SearchViewModel()

    var body: some View {
       
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background { AppBackground() }
                .navigationTitle("Search")
                
                .searchable(text: $viewModel.query, prompt: "Search movies")
                // كل ما تغيّر النص، SwiftUI يلغي المهمة القديمة ويبدأ جديدة
                .task(id: viewModel.query) {
                    await viewModel.search()
                }
        
    }

    // كل حالة لها شكل مختلف
    @ViewBuilder
    private var content: some View {
        if viewModel.trimmedQuery.isEmpty {
            EmptyStateView(message: "Search for a movie by title.")

        } else if viewModel.isLoading && viewModel.movies.isEmpty {
            ProgressView()

        } else if let message = viewModel.errorMessage, viewModel.movies.isEmpty {
            ErrorView(message: message) {
                Task { await viewModel.search() }
            }

        } else if viewModel.movies.isEmpty {
            EmptyStateView(message: "No results for “\(viewModel.trimmedQuery)”.")

        } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.movies) { movie in
                        NavigationLink(value: movie) {
                            MovieRowView(movie: movie)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
    }
}
