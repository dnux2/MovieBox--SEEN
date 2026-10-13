import SwiftUI

enum AppTab {
    case home, search, favorites
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(onSearchTap: { selectedTab = .search })
                .tabItem { Label("Home", systemImage: "house") }
                .tag(AppTab.home)

            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(AppTab.search)

            FavoritesView()
                .tabItem { Label("Favorites", systemImage: "heart") }
                .tag(AppTab.favorites)
        }
    }
}

#Preview {
    MainTabView()
        .environment(FavoritesStore())
}
