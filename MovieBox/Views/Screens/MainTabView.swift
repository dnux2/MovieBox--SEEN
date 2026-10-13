import SwiftUI

enum AppTab {
    case home, search, favorites
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab){
        // خاص للهوم
            NavigationStack {
                HomeView(onSearchTap: { selectedTab = .search })
                    .navigationDestination(for: Movie.self) { movie in
                        MovieDetailView(movie: movie)
                    }
                    .navigationDestination(for: MovieListKind.self) { kind in
                        MovieListView(kind: kind)
                    }
            }
            .tabItem { Label("Home", systemImage: "house") }
            .tag(AppTab.home)
            //خاص بالسيرش
            NavigationStack {
                SearchView()
                    .navigationDestination(for: Movie.self) { movie in
                        MovieDetailView(movie: movie)
                    }
            }
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
            .tag(AppTab.search)

            NavigationStack{
                FavoritesView()
                    .navigationDestination(for: Movie.self) { movie in
                        MovieDetailView(movie: movie)
                    }
            
            }.tabItem { Label("Favorites", systemImage: "heart") }
                .tag(AppTab.favorites)
            
        }
    }
}

#Preview {
    MainTabView()
        .environment(FavoritesStore())
}
