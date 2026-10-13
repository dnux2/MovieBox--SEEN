<img width="1080" height="1080" alt="Discover, search and save your favorite movies-2" src="https://github.com/user-attachments/assets/87ac8c93-1fd8-4be3-90b3-fb796ac1bbbe" />

# SEEN

A movie discovery app for iOS built with SwiftUI and the TMDB API. Browse trending movies, search seamlessly, view details, and save your favorites.

---

## Key Features

•⁠  ⁠*Trending Movies:* Responsive grid with pull-to-refresh and infinite pagination.
•⁠  ⁠*Instant Search:* Debounced search queries with built-in empty and no-results states.
•⁠  ⁠*Detailed Insights:* Complete movie detail view.
•⁠  ⁠*Local Favorites:* Save favorite movies locally for offline access.
•⁠  ⁠*State Handling:* Dedicated UI states for Loading, Loaded, Empty, and Errors (offline-ready).
•⁠  ⁠*Adaptive UI:* Native support for Dark and Light modes using semantic system colors.

---

## Tech Stack

•⁠  ⁠*Framework:* SwiftUI (iOS 17+)
•⁠  ⁠*Architecture:* MVVM + Service Layer with ⁠ @Observable ⁠ state management
•⁠  ⁠*Navigation:* ⁠ NavigationStack ⁠ with modern ⁠ TabView ⁠ structure
•⁠  ⁠*Networking:* Async/await using native ⁠ URLSession ⁠ and ⁠ Codable ⁠
•⁠  ⁠*Persistence:* ⁠ UserDefaults ⁠ for lightweight local storage
•⁠  ⁠*Search Optimization:* ⁠ .task(id:) ⁠ for debounced API calls

---

## Project Structure


MovieBox/
├── Models/       # Codable data structures (Movie, MovieDetail, etc.)
├── Services/     # APIClient, MovieService, FavoritesStore, Config
├── ViewModels/   # Screen state management (@Observable) and business logic
└── Views/        # SwiftUI screens and modular UI components

Networking is kept strictly out of the views, so each screen only talks to its view model, isolating business logic within the service layer.

---

## Setup & Installation

1.⁠ ⁠Get a Read Access Token from [TMDB](https://www.themoviedb.org/settings/api).
2.⁠ ⁠Create your local config file from the example:
   ```bash
   cp Secrets.example.xcconfig Secrets.xcconfig

 * Add your token inside Secrets.xcconfig:
   TMDB_TOKEN = your_token_here

 * Open MovieBox.xcodeproj in Xcode and build/run.
Note: Secrets.xcconfig is ignored by Git to keep API tokens secure.
Credits
This product uses the TMDB API but is not endorsed or certified by TMD
This product uses the TMDB API but is not endorsed or certified by TMDB.
