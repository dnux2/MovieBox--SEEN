import Foundation
import SwiftData

@Model
final class CachedMovie{
    
    var id: Int
    var title: String
    var posterPath: String?
    var releaseDate: String?
    var voteAverage: Double
    var overview: String
    
    //Section like : trending , nowPlaying , topRated
    var section : String
    // order
    var position: Int
    // saving time
    var savedAt : Date
     
    // Converts a Movie into a CachedMovie for storage
    init(movie: Movie, section: String, position: Int) {
        self.id = movie.id
        self.title = movie.title
        self.posterPath = movie.posterPath
        self.releaseDate = movie.releaseDate
        self.voteAverage = movie.voteAverage
        self.overview = movie.overview
        self.section = section
        self.position = position
        self.savedAt = Date()
    }
    // Converts a CachedMovie back into a Movie to use in the screens
    func toMovie() -> Movie{
        Movie(
            id:id,
            title: title
            ,posterPath: posterPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            overview: overview
        )
  
    }
}
