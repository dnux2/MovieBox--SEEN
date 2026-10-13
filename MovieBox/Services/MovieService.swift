import Foundation

// هنا دوال الأفلام بأسماء واضحة، الـ ViewModel يناديها
// وما يحتاج يعرف شي عن الروابط أو الـ endpoints
struct MovieService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    // الأفلام الرائجة، لصفحة Home
    func popularMovies(page: Int = 1) async throws -> MovieListResponse {
        try await client.get("/movie/popular", queryItems: [
            URLQueryItem(name: "page", value: String(page))
        ])
    }

    // البحث بالاسم، لصفحة Search
    func searchMovies(query: String, page: Int = 1) async throws -> MovieListResponse {
        try await client.get("/search/movie", queryItems: [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page))
        ])
    }

    // تفاصيل فيلم واحد، لصفحة Detail
    func movieDetail(id: Int) async throws -> MovieDetail {
        try await client.get("/movie/\(id)")
    }
    
    func trendingMovies(page: Int = 1) async throws -> MovieListResponse {
        try await client.get("/trending/movie/week", queryItems: [
            URLQueryItem(name: "page", value: String(page))
        ])
    }

    func nowPlayingMovies(page: Int = 1) async throws -> MovieListResponse {
        try await client.get("/movie/now_playing", queryItems: [
            URLQueryItem(name: "page", value: String(page))
        ])
    }

    // الأعلى تقييم، سكشن Top Rated
    func topRatedMovies(page: Int = 1) async throws -> MovieListResponse {
        try await client.get("/movie/top_rated", queryItems: [
            URLQueryItem(name: "page", value: String(page))
        ])
    }
}
