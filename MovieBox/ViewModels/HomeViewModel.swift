import Foundation
import Observation

// حالة سكشن واحد: أفلامه وهل يحمّل وهل فيه خطأ
struct MovieSection {
    var movies: [Movie] = []
    var isLoading = true
    var errorMessage: String?
    // كم صفحة موجودة عند TMDB، الافتراضي 1 فما يأثر على السكشنات الثانية
    var totalPages = 1
}

@MainActor
@Observable
final class HomeViewModel {

    private let movieService = MovieService()

    var trending = MovieSection()
    var nowPlaying = MovieSection()
    var topRated = MovieSection()

    // تتبع New Releases عشان الـ scroll اللانهائي
    // رقم الصفحة اللي وصلنا لها، نبدأ من 1
    private var nowPlayingPage = 1
    // قفل عشان ما نطلب نفس الصفحة مرتين
    private var isLoadingMoreNowPlaying = false

    // أول 5 أفلام من الرائج، تطلع في الكارد الكبير
    var featuredMovies: [Movie] { Array(trending.movies.dropFirst(10).prefix(5)) }

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

        // نرجع للصفحة الأولى بس لو التحديث نجح
        if nowPlaying.errorMessage == nil {
            nowPlayingPage = 1
        }
    }

    // تنادى لما يوصل المستخدم لآخر فيلم في New Releases
    func loadMoreNowPlayingIfNeeded(current movie: Movie) async {
        guard movie.id == nowPlaying.movies.last?.id,
              nowPlayingPage < nowPlaying.totalPages,
              !isLoadingMoreNowPlaying else { return }

        isLoadingMoreNowPlaying = true
        do {
            let response = try await movieService.nowPlayingMovies(page: nowPlayingPage + 1)
            let existingIDs = Set(nowPlaying.movies.map(\.id))
            nowPlaying.movies += response.results.filter { !existingIDs.contains($0.id) }
            nowPlayingPage += 1
            
        } catch {
            // فشل صفحة إضافية ما يمسح اللي عندي
        }
        isLoadingMoreNowPlaying = false
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
            return MovieSection(
                movies: response.results,
                isLoading: false,
                errorMessage: nil,
                totalPages: response.totalPages
            )
        } catch {
            return MovieSection(
                movies: old.movies,
                isLoading: false,
                errorMessage: error.localizedDescription,
                totalPages: old.totalPages
            )
        }
    }
}
