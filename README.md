<img width="1080" height="1080" alt="Discover, search and save your favorite movies-2" src="https://github.com/user-attachments/assets/87ac8c93-1fd8-4be3-90b3-fb796ac1bbbe" />
# SEEN

A movie discovery app for iOS built with SwiftUI and the TMDB API. Browse popular movies, search with debounce, view details, and save your favorites.

## Features

•⁠  ⁠Home grid of popular movies with pull-to-refresh and infinite scroll
•⁠  ⁠Movie details screen
•⁠  ⁠Search with debounce, plus empty and no-results states
•⁠  ⁠Favorites saved locally on the device
•⁠  ⁠Clear loading, error and empty states (try it in airplane mode)
•⁠  ⁠Light and dark mode support

## Tech

•⁠  ⁠SwiftUI, iOS 17+
•⁠  ⁠⁠ NavigationStack ⁠ (one per tab) with a ⁠ TabView ⁠ for Home / Search / Favorites
•⁠  ⁠async/await networking with ⁠ URLSession ⁠, through a single shared ⁠ APIClient ⁠
•⁠  ⁠⁠ Codable ⁠ models matching the TMDB JSON
•⁠  ⁠⁠ @Observable ⁠ view models that expose loading / loaded / empty / error states
•⁠  ⁠Debounced search using ⁠ .task(id:) ⁠
•⁠  ⁠⁠ UserDefaults ⁠ for locally saved favorites
•⁠  ⁠Semantic system colors, so light and dark mode work out of the box

## Project structure


MovieBox/
  Models/       Codable models (Movie, MovieDetail, ...)
  Services/     APIClient, MovieService, FavoritesStore, Config
  ViewModels/   Screen logic and state (loading / loaded / empty / error)
  Views/        Screens and reusable components


Networking is kept out of the views, so each screen only talks to its view model.

## Setup

1.⁠ ⁠Get a Read Access Token from [TMDB](https://www.themoviedb.org/settings/api).
2.⁠ ⁠Copy ⁠ Secrets.example.xcconfig ⁠ to ⁠ Secrets.xcconfig ⁠ and put your token in it:

   TMDB_TOKEN = your_token_here

3.⁠ ⁠Open ⁠ MovieBox.xcodeproj ⁠ in Xcode and run.

⁠ Secrets.xcconfig ⁠ is in ⁠ .gitignore ⁠, so the token is never committed.

## Credits

This product uses the TMDB API but is not endorsed or certified by TMDB.

