import SwiftUI

struct MovieCard: View {
    let movie: Movie

    @State private var image: UIImage?
    @State private var failed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            poster

            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .foregroundStyle(.secondary)
                }
                .font(.headline)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // المكان ثابت 2:3 سواء نزلت الصورة أو لا، فالبطاقات كلها بنفس الحجم
    private var poster: some View {
        Color(.tertiarySystemBackground)
            .aspectRatio(2/3, contentMode: .fit)
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if movie.posterURL == nil || failed {
                    // الفيلم ما له بوستر أو فشل التحميل
                    Image(systemName: "film")
                        .font(.title)
                        .foregroundStyle(.secondary)
                } else {
                    ProgressView()
                }
            }
            .clipped()
            .task(id: movie.posterURL) {
                await loadPoster()
            }
    }

     // نطلب الصورة من APIClient، وهو اللي يعيد المحاولة 3 مرات
    private func loadPoster() async {
        guard let url = movie.posterURL else { return }
        failed = false

        if let data = await APIClient().loadImageData(from: url),
           let loaded = UIImage(data: data) {
            image = loaded
        } else if !Task.isCancelled {
            failed = true
        }
    }
}
#Preview {
    MovieCard(movie: Movie(
        id: 27205,
        title: "Inception",
        posterPath: "/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg",
        releaseDate: "2010-07-15",
        voteAverage: 8.4,
        overview: "A thief who steals secrets through dreams."
    ))
    .frame(width: 180)
    .padding()
}
