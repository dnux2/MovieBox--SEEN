import Foundation

struct Movie: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let overview: String
    
//يكمل لي الباث لرابط البوستر
    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)")
    }
    // نسخة أكبر للبوستر، للكارد الكبير في الهوم
    var largePosterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w780\(posterPath)")
    }
//اخذ سنه الاصدار فقط من التاريخ بدون الشهر واليوم
//كمان لو كانت nil مايطلع لي مشكله
    var releaseYear: String {
        String(releaseDate?.prefix(4) ?? "")
    }
}
