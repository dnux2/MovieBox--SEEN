import SwiftUI

struct MovieDetailView: View {

    let movie: Movie
    @State private var viewModel: MovieDetailViewModel
    @Environment(FavoritesStore.self) private var favorites
    @Environment(\.dismiss) private var dismiss

    init(movie: Movie) {
        self.movie = movie
        _viewModel = State(initialValue: MovieDetailViewModel(movieID: movie.id))
    }

    var body: some View {
        ZStack {
            backdrop

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // مساحة فاضية عشان البوستر يبان فوق والنص ينزل تحت
                    Color.clear.frame(height: 400)

                    titleBlock
                    details
                        .padding(.top, 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        // الأزرار فوق الصفحة بدل الـ toolbar، عشان ما تتكرر الدوائر
        .overlay(alignment: .top) { topButtons }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if viewModel.detail == nil {
                await viewModel.fetchDetail()
            }
        }
    }

    // MARK: - الخلفية: البوستر على الصفحة كلها

    private var backdrop: some View {
        GeometryReader { geo in
            AsyncImage(url: movie.largePosterURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    Image(systemName: "film")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                } else {
                    ProgressView()
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .background(Color.black)
        // تدرج أسود يغمّق الأسفل عشان النص يتقرا
        .overlay {
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.1), location: 0.0),
                    .init(color: .black.opacity(0.35), location: 0.45),
                    .init(color: .black.opacity(0.92), location: 0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - الأزرار

    private var topButtons: some View {
        HStack {
            circleButton(systemName: "chevron.left") { dismiss() }
            Spacer()
            circleButton(
                systemName: favorites.isFavorite(movie) ? "heart.fill" : "heart",
                color: favorites.isFavorite(movie) ? .red : .white
            ) { favorites.toggle(movie) }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func circleButton(
        systemName: String,
        color: Color = .white,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(.black.opacity(0.35))
                .clipShape(Circle())
        }
    }

    // MARK: - العنوان

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(movie.title)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
                .lineLimit(3)

            if let detail = viewModel.detail {
                HStack(spacing: 8) {
                    Text(detail.releaseYear)
                    if !detail.runtimeText.isEmpty {
                        Text("•")
                        Text(detail.runtimeText)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    // MARK: - الأربع حالات للجزء اللي ينجاب من الشبكة

    @ViewBuilder
    private var details: some View {
        if viewModel.isLoading {
            ProgressView()
                .tint(.white)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)

        } else if let message = viewModel.errorMessage {
            ErrorView(message: message) {
                Task { await viewModel.fetchDetail() }
            }
            .frame(maxWidth: .infinity)

        } else if let detail = viewModel.detail {
            VStack(alignment: .leading, spacing: 20) {

                if !detail.genres.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(detail.genres) { genre in
                                Text(genre.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(.white.opacity(0.18))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", detail.voteAverage))
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    if !detail.reviewsText.isEmpty {
                        Text("(\(detail.reviewsText))")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Overview")
                        .font(.title3.bold())
                        .foregroundStyle(.white)

                    Text(detail.overview.isEmpty ? "No overview available." : detail.overview)
                        .foregroundStyle(.white.opacity(0.8))
                        .lineSpacing(4)
                }
            }
        }
    }
}
