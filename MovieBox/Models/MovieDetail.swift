import Foundation

struct MovieDetail: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let runtime: Int?
    let genres: [Genre]
    let voteCount: Int?


    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    var releaseYear: String {
        String(releaseDate?.prefix(4) ?? "")
    }
//يحسب وقت الفيلم
    var runtimeText: String {
        guard let runtime, runtime > 0 else { return "" }
        return "\(runtime / 60)h \(runtime % 60)m"
    }
    var reviewsText: String {
          guard let voteCount, voteCount > 0 else { return "" }
          if voteCount >= 1000 {
              return String(format: "%.1fk reviews", Double(voteCount) / 1000)
          }
          return "\(voteCount) reviews"
      }
}
