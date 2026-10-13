<img width="1080" height="1080" alt="Discover, search and save your favorite movies-2" src="https://github.com/user-attachments/assets/87ac8c93-1fd8-4be3-90b3-fb796ac1bbbe" />
# SEEN

A movie discovery app for iOS built with SwiftUI and the TMDB API. Browse movies, search, view details, and save your favorites.

## Features

- Home with Trending, Now Playing and Top Rated sections, plus "See All" lists with infinite scroll
- Pull-to-refresh
- Movie details screen
- Search with debounce, plus empty and no-results states
- Favorites saved locally on the device
- Clear loading, error and empty states (try it in airplane mode)
- Light and dark mode support

## Tech

- SwiftUI, iOS 17+
- `TabView` for Home / Search / Favorites, with one `NavigationStack` per tab
- async/await networking with `URLSession`, through a single shared `APIClient`
- `Codable` models matching the TMDB JSON
- `@Observable` view models that expose loading / loaded / empty / error states
- Debounced search using `.task(id:)`
- `UserDefaults` for locally saved favorites
- Semantic system colors, so light and dark mode work out of the box
## Architecture

The app uses MVVM with a small service layer, so each part of the code has one clear job.

```
MovieBox/
  Models/       Codable models (Movie, MovieDetail, Genre, ...)
  Services/     APIClient, MovieService, FavoritesStore, Config
  ViewModels/   Screen state and logic
  Views/        Screens and reusable components
```

### Data flow

`View -> ViewModel -> MovieService -> APIClient -> TMDB`

Results come back the same way. If a request fails, `APIClient` throws an `APIError`, the view model catches it and sets `errorMessage`, and the view shows an error screen with a "Try again" button.

### Design decisions

- **Networking stays out of the views.** `URLSession` is used only in `APIClient`, so views never build URLs or decode JSON.
- **One shared `APIClient`.** The base URL, auth header, status check, decoding and error mapping live in one place.
- **State lives in the view model.** Each screen reads `isLoading`, `errorMessage` and its data, so loading, loaded, empty and error states work the same way everywhere.
- **Shared code is reused.** Common UI is in `Views/Components` and common requests are in `MovieService`.
- **Navigation is declared in one place.** `MainTabView` holds one `NavigationStack` per tab, and screens only use `NavigationLink(value:)`.
- **View models have no UI code**, which keeps their logic easy to read and to test.
## Setup

1. Get a Read Access Token from [TMDB](https://www.themoviedb.org/settings/api).
2. Copy `Secrets.example.xcconfig` to `Secrets.xcconfig` and put your token in it:

```
   TMDB_TOKEN = your_token_here
```

3. Open `MovieBox.xcodeproj` in Xcode and run.

`Secrets.xcconfig` is in `.gitignore`, so the token is never committed.

## Credits

This product uses the TMDB API but is not endorsed or certified by TMDB.

