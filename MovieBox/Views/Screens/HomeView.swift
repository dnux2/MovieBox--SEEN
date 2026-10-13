import SwiftUI

struct HomeView: View {

    @State private var viewModel = HomeViewModel()
    @Environment(FavoritesStore.self) private var favorites

    // أي فيلم في النص من الكارد الكبير، للنقاط
    @State private var featuredID: Int?

    // لما أضغط على البحث، MainTabView يبدّل التاب
    var onSearchTap: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                content
            }
            .background { AppBackground() }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
            }
            .navigationDestination(for: MovieListKind.self) { kind in
                MovieListView(kind: kind)
            }
        }
        .task {
            // ما أحمّل من جديد لو عندي أفلام
            if viewModel.trending.movies.isEmpty {
                await viewModel.fetchAll()
            }
        }
    }

    // MARK: - الهيدر

    private var header: some View {
        HStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityLabel("Seen")

            Spacer()

            Button(action: onSearchTap) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - المحتوى

    @ViewBuilder
    private var content: some View {
        if viewModel.allFailed, let message = viewModel.trending.errorMessage {
            // كل الطلبات فشلت، خطأ واحد للشاشة كلها
            ErrorView(message: message) {
                Task { await viewModel.fetchAll() }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    featuredCarousel

                    section(title: "Top 10 This Week", kind: .trending, state: viewModel.trending) {
                        rankedList(viewModel.trending.movies)
                    }

                    section(title: "New Releases", kind: .nowPlaying, state: viewModel.nowPlaying) {
                        posterList(viewModel.nowPlaying.movies)
                    }

                    section(title: "Top Rated", kind: .topRated, state: viewModel.topRated) {
                        topRatedList
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .refreshable {
                await viewModel.fetchAll()
            }
        }
    }

    // MARK: - سكشن عام: عنوان + See All + الحالات الأربع

    private func section<Content: View>(
        title: String,
        kind: MovieListKind,
        state: MovieSection,
        @ViewBuilder loaded: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.primary)
                Spacer()
                NavigationLink("See All", value: kind)
                    .font(.subheadline)
            }
            .padding(.horizontal, 20)

            if state.isLoading && state.movies.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 160)

            } else if let message = state.errorMessage, state.movies.isEmpty {
                ErrorView(message: message) {
                    Task { await viewModel.fetchAll() }
                }
                .frame(maxWidth: .infinity, minHeight: 160)

            } else if state.movies.isEmpty {
                EmptyStateView(message: "No movies found.")
                    .frame(maxWidth: .infinity, minHeight: 160)

            } else {
                loaded()
            }
        }
    }

    // MARK: - بوستر بحجم ثابت (للقائمتين الأفقيتين)

    private func posterImage(_ movie: Movie, width: CGFloat, height: CGFloat) -> some View {
        Color(.tertiarySystemBackground)
            .frame(width: width, height: height)
            .overlay {
                if movie.posterURL == nil {
                    Image(systemName: "film").foregroundStyle(.secondary)
                } else {
                    AsyncImage(url: movie.posterURL) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else if phase.error != nil {
                            Image(systemName: "film").foregroundStyle(.secondary)
                        } else {
                            ProgressView()
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Top 10: رقم كبير ورا البوستر

    private func rankedList(_ movies: [Movie]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(Array(movies.prefix(10).enumerated()), id: \.element.id) { index, movie in
                    NavigationLink(value: movie) {
                        // spacing سالب عشان البوستر يغطي جزء من الرقم
                        HStack(alignment: .bottom, spacing: -22) {
                            Text("\(index + 1)")
                                .font(.system(size: 100, weight: .black, design: .rounded))
                                .foregroundStyle(Color.accentColor)
                                .shadow(color: .white ,radius: 0,x : 1.5 ,y:1.5)
                                .shadow(color: .black ,radius: 0,x : -1.5 ,y:-1.5)
                                .shadow(color: .black ,radius: 0,x : 1.5 ,y:-1.5)
                            posterImage(movie, width: 125, height: 185)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - New Releases: بوسترات والتقييم شارة عليها

    private func posterList(_ movies: [Movie]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(movies) { movie in
                    NavigationLink(value: movie) {
                        posterImage(movie, width: 140, height: 210)
                            .overlay(alignment: .topTrailing) {
                                HStack(spacing: 3) {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                    Text(String(format: "%.1f", movie.voteAverage))
                                        .foregroundStyle(.white)
                                }
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.black.opacity(0.6))
                                .clipShape(Capsule())
                                .padding(8)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Top Rated: قائمة عمودية، أول 5 بس والباقي من See All

    private var topRatedList: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.topRated.movies.prefix(5)) { movie in
                NavigationLink(value: movie) {
                    MovieRowView(movie: movie)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        

    }


    // MARK: - كارد Featured (بالنص ويتحرك جانبياً)

    @ViewBuilder
    private var featuredCarousel: some View {
        if !viewModel.featuredMovies.isEmpty {
            VStack(spacing: 14) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(viewModel.featuredMovies) { movie in
                            featuredCard(movie)
                                // العرض هنا أصلاً بدون الهوامش، فما نطرح شي
                                .containerRelativeFrame(.horizontal)
                                // اللي بالنص كبير، واللي على الجنب أصغر وأخف
                                .scrollTransition(.animated.threshold(.visible(0.9))) { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                        .opacity(phase.isIdentity ? 1 : 0.6)
                                }
                                .id(movie.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                // الهامش على الجهتين نفسه، فالكارد بالنص ويبان طرف اللي قبله واللي بعده
                .contentMargins(.horizontal, 44, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $featuredID)

                // النقاط تحت الكارد
                HStack(spacing: 6) {
                    ForEach(viewModel.featuredMovies) { movie in
                        let isCurrent = movie.id == (featuredID ?? viewModel.featuredMovies.first?.id)
                        Capsule()
                            .fill(isCurrent ? Color.accentColor : Color.secondary.opacity(0.4))
                            .frame(width: isCurrent ? 22 : 7, height: 7)
                    }
                }
                .animation(.easeInOut, value: featuredID)
            }

        } else if viewModel.trending.isLoading {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemBackground))
                .aspectRatio(2/3, contentMode: .fit)
                .overlay { ProgressView() }
                .padding(.horizontal, 44)
        }
    }

    private func featuredCard(_ movie: Movie) -> some View {
        Color(.tertiarySystemBackground)
            .aspectRatio(2/3, contentMode: .fit)
            .overlay {
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
            }
            .overlay(alignment: .bottomLeading) {
                featuredInfo(movie)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // النص والأزرار فوق الصورة، دايم أبيض لأن تحته تدرج أسود
    private func featuredInfo(_ movie: Movie) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("FEATURED TODAY")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(red: 0.349, green: 0.373, blue: 1.0)) // 595FFF
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(movie.title)
                .font(.title.bold())
                .foregroundStyle(.white)
                .lineLimit(2)

            Text(movie.overview)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(2)

            HStack(spacing: 12) {
                NavigationLink(value: movie) {
                    Label("More Details", systemImage: "info.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)

                Button {
                    favorites.toggle(movie)
                } label: {
                    Image(systemName: favorites.isFavorite(movie) ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundStyle(favorites.isFavorite(movie) ? .red : .white)
                        .frame(width: 52, height: 52)
                        .background(.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding(20)
        .padding(.top, 60) // عشان التدرج يبدأ من فوق بنعومة
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    HomeView(onSearchTap: {})
        .environment(FavoritesStore())
}
