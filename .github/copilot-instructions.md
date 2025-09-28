# What3words Flutter Project - AI Coding Agent Instructions

## Project Overview
This is a Flutter application implementing What3words integration with clean architecture principles. The project uses **Dio** for API calls, **Provider** for state management, and includes Google Maps integration with grid overlay functionality.

## Key Architecture Patterns

### State Management
- Uses **Provider** pattern with `ChangeNotifier`
- All What3words operations are managed through `W3WProvider` in `lib/providers/w3w_provider.dart`
- State includes loading, error, address data, suggestions, and grid sections
- Always use `context.read<W3WProvider>()` for operations and `Consumer<W3WProvider>` for UI updates

### API Service Layer
- `W3WApiService` in `lib/services/w3w_api_service.dart` handles all What3words API calls
- Uses Dio with comprehensive error handling and custom `W3WError` types
- Implements timeout configuration and request logging
- All API methods are async and return typed models

### Clean Architecture Structure
```
lib/
├── models/w3w_models.dart          # Data models (W3WAddress, W3WCoordinates, etc.)
├── services/w3w_api_service.dart   # API service layer
├── providers/w3w_provider.dart     # State management
├── widgets/                        # Reusable UI components
└── main.dart                       # App entry point with tabs
```

## Critical Implementation Details

### Error Handling Pattern
All API operations should handle both `W3WError` (custom) and generic exceptions:
```dart
try {
  await provider.someOperation();
  if (provider.error != null) {
    // Handle W3WError from API
  }
} catch (e) {
  // Handle other exceptions
}
```

### Widget Component Usage
- `W3WAutoSuggestField`: Provides real-time suggestions with focus point support
- `W3WAddressCard`: Displays address results with copy/navigation actions  
- `W3WMapWidget`: Google Maps with What3words grid overlay
- Always use `Consumer<W3WProvider>` to react to state changes

### API Key Configuration
- API key is set in `main.dart` in the `W3WProvider` constructor
- Replace `YOUR_WHAT3WORDS_API_KEY` with actual key for functionality
- Google Maps requires separate API key in Android/iOS platform files

## Platform-Specific Requirements

### Android Permissions (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS Permissions (`ios/Runner/Info.plist`)
- Location permissions with usage descriptions are required
- Google Maps API key must be configured in AppDelegate.swift

## Development Workflows

### Adding New What3words Features
1. Add API method to `W3WApiService`
2. Add corresponding provider method with error handling
3. Create/update UI widgets using `Consumer<W3WProvider>`
4. Handle loading, error, and success states consistently

### Testing Approach
- Widget tests use mocked `W3WProvider` with test API keys
- Use `ChangeNotifierProvider` wrapper in test setup
- Focus on testing state changes and UI responses to provider updates

### Key Dependencies to Maintain
- `dio: ^5.4.0` for HTTP requests
- `provider: ^6.1.1` for state management  
- `google_maps_flutter: ^2.5.3` for map functionality
- `geolocator: ^10.1.0` for location services

This architecture ensures separation of concerns, testability, and maintainable code for What3words integration features.