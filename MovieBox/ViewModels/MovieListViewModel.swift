import Foundation
import Observation
import SwiftData
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
    // Cache for this list, it is created in setUp
    private var cache: MovieCache?

    // Each kind has its own section name, so it never mixes with Home
    private var cacheSection: String {
        switch kind {
        case .trending: return "list_trending"
        case .nowPlaying: return "list_nowPlaying"
        case .topRated: return "list_topRated"
        }
    }
    
    init(kind: MovieListKind) {
        self.kind = kind
    }
    // Called once from the View, because only the View has the ModelContext
    func setUp(context: ModelContext) {
        if cache == nil {
            cache = MovieCache(context: context)
        }
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
            // Save only the first page
            cache?.save(response.results, section: cacheSection)
        } catch {
            errorMessage = error.localizedDescription
            // Use saved movies only if the screen is empty
            if movies.isEmpty, let saved = cache?.load(section: cacheSection) {
                movies = saved
            }
        }

        isLoading = false
    }

    // ينادى من كل كارد، ويحمّل الصفحة الجاية بس لو هذا آخر فيلم
    func loadMoreIfNeeded(current movie: Movie) async {
      //هل هذا اخر فلم بالصفحه
        guard movie.id == movies.last?.id,
              //هل فيه صفحات باقي ماتحملت
              page < totalPages,
              //هل في طلب شغال حاليا
              !isLoadingMore else { return }

        isLoadingMore = true
        do {
            let response = try await request(page: page + 1)
            // نضيف بس الأفلام اللي ما عندنا، عشان ما يتكرر نفس الـ id
            let existingIDs = Set(movies.map(\.id))
            movies += response.results.filter { !existingIDs.contains($0.id) }

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
