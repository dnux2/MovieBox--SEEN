import SwiftUI
import SwiftData

@main
struct MovieBoxApp: App {
    @State private var favorites = FavoritesStore()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environment(favorites)

//                if showSplash {
//                    SplashView()
//                        .transition(.opacity)
//                        .zIndex(1)
//                }
//            }
//            .task {
//                try? await Task.sleep(for: .seconds(1))
//                withAnimation(.easeInOut(duration: 0.4)) {
//                    showSplash = false
//                }
            }
            
        }.modelContainer(for: CachedMovie.self)
        // Creates the storage for CachedMovie and shares it with the whole app

    }
}
