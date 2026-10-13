import Foundation
import Observation

// الأنواع الثلاثة اللي ممكن يفتحها See All
enum MovieListKind: String, Hashable {
    case trending = "Trending Now"
    case nowPlaying = "New Releases"
    case topRated = "Top Rated"
}

@MainActor
@Observable
final class MovieListViewModel {

    private let movieService = MovieService()
    let kind: MovieListKind

    var movies: [Movie] = []
    var isLoading = true
    var errorMessage: String?

    private var page = 1
    private var totalPages = 1
    private var isLoadingMore = false

    init(kind: MovieListKind) {
        self.kind = kind
    }

    // تحميل أول مرة أو السحب للتحديث، يبدأ من الصفحة 1
    func fetchFirstPage() async {
        if movies.isEmpty { isLoading = true }
        errorMessage = nil

        do {
            let response = try await request(page: 1)
            movies = response.results
            page = 1
            totalPages = response.totalPages
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // ينادى من كل كارد، ويحمّل الصفحة الجاية بس لو هذا آخر فيلم
    func loadMoreIfNeeded(current movie: Movie) async {
        guard movie.id == movies.last?.id,
              page < totalPages,
              !isLoadingMore else { return }

        isLoadingMore = true
        do {
            let response = try await request(page: page + 1)
            movies += response.results
            page += 1
        } catch {
            // فشل صفحة إضافية ما يمسح اللي عندي، بس ما أحمّل أكثر
        }
        isLoadingMore = false
    }

    // يختار الدالة المناسبة حسب النوع
    private func request(page: Int) async throws -> MovieListResponse {
        switch kind {
        case .trending: return try await movieService.trendingMovies(page: page)
        case .nowPlaying: return try await movieService.nowPlayingMovies(page: page)
        case .topRated: return try await movieService.topRatedMovies(page: page)
        }
    }
}
