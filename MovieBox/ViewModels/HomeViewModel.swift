import Foundation
import Observation

// حالة سكشن واحد: أفلامه وهل يحمّل وهل فيه خطأ
struct MovieSection {
    var movies: [Movie] = []
    var isLoading = true
    var errorMessage: String?
}

@MainActor
@Observable
final class HomeViewModel {

    private let movieService = MovieService()

    var trending = MovieSection()
    var nowPlaying = MovieSection()
    var topRated = MovieSection()

    // أول 5 أفلام من الرائج، تطلع في الكارد الكبير
    var featuredMovies: [Movie] { Array(trending.movies.dropFirst(10).prefix(5))}

    // لو السكشنات الثلاث فاضية وكلها فيها خطأ، أعرض خطأ واحد للشاشة كلها
    var allFailed: Bool {
        [trending, nowPlaying, topRated].allSatisfy {
            $0.movies.isEmpty && $0.errorMessage != nil
        }
    }

    // تنادى أول مرة ومع السحب للتحديث ومع زر Try again
    func fetchAll() async {
        markLoading(&trending)
        markLoading(&nowPlaying)
        markLoading(&topRated)

        // async let يطلق الطلبات الثلاثة مع بعض
        async let t = makeSection(old: trending) { try await self.movieService.trendingMovies() }
        async let n = makeSection(old: nowPlaying) { try await self.movieService.nowPlayingMovies() }
        async let r = makeSection(old: topRated) { try await self.movieService.topRatedMovies() }

        trending = await t
        nowPlaying = await n
        topRated = await r
    }

    // الـ spinner بس لو السكشن فاضي، عشان السحب ما يخفي الأفلام
    private func markLoading(_ section: inout MovieSection) {
        if section.movies.isEmpty {
            section.isLoading = true
            section.errorMessage = nil
        }
    }

    // لو فشل وعندي أفلام قديمة، أخليها وما أمسحها
    private func makeSection(
        old: MovieSection,
        fetch: () async throws -> MovieListResponse
    ) async -> MovieSection {
        do {
            let response = try await fetch()
            return MovieSection(movies: response.results, isLoading: false, errorMessage: nil)
        } catch {
            return MovieSection(movies: old.movies, isLoading: false, errorMessage: error.localizedDescription)
        }
    }
}
