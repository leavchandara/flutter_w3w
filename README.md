# What3words Flutter Integration

This project implements a complete What3words integration in Flutter using Dio for API calls and Provider for state management.

## Features

1. **AutoSuggest** - Intelligent suggestions as users type
2. **Convert to What3words Address** - Convert coordinates to What3words addresses  
3. **Map Grid Overlay** - Display What3words grid on Google Maps
4. **Convert to Coordinates** - Convert What3words addresses back to coordinates

## Setup

### 1. Get Your What3words API Key

1. Visit [What3words Developer Portal](https://developer.what3words.com/)
2. Sign up and create a new project
3. Copy your API key

### 2. Add API Key

Replace `YOUR_WHAT3WORDS_API_KEY` in `lib/main.dart` with your actual API key:

```dart
W3WProvider(
  apiKey: 'your_actual_api_key_here',
)
```

### 3. Google Maps Setup (Optional - for Map tab)

#### Android
1. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Add it to `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
    <!-- ... -->
</application>
```

#### iOS
1. Add your Google Maps API key to `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Installation

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```
lib/
├── main.dart                       # Main application entry point
├── models/
│   └── w3w_models.dart            # Data models for What3words API
├── services/
│   └── w3w_api_service.dart       # API service using Dio
├── providers/
│   └── w3w_provider.dart          # State management with Provider
└── widgets/
    ├── w3w_auto_suggest_field.dart # AutoSuggest input field
    ├── w3w_address_card.dart       # Display address information
    └── w3w_map_widget.dart         # Map with grid overlay
```

## Usage Examples

### AutoSuggest
```dart
W3WAutoSuggestField(
  focus: W3WCoordinates(lat: 51.5074, lng: -0.1278), // Optional focus point
  onSuggestionSelected: (suggestion) {
    // Handle selected suggestion
    print('Selected: ${suggestion.words}');
  },
)
```

### Convert Coordinates to Words
```dart
final provider = context.read<W3WProvider>();
await provider.convertToWords(lat: 51.5074, lng: -0.1278);
if (provider.currentAddress != null) {
  print('Address: ${provider.currentAddress!.words}');
}
```

### Convert Words to Coordinates
```dart
final provider = context.read<W3WProvider>();
await provider.convertToCoordinates(words: 'index.home.raft');
if (provider.currentAddress != null) {
  print('Coordinates: ${provider.currentAddress!.coordinates}');
}
```

### Error Handling
```dart
Consumer<W3WProvider>(
  builder: (context, provider, child) {
    if (provider.error != null) {
      return W3WErrorWidget(
        error: provider.error!,
        onRetry: () => provider.clearError(),
      );
    }
    // ... normal UI
  },
)
```

## API Service Features

The `W3WApiService` provides:
- Comprehensive error handling with custom error types
- Request timeout configuration
- Logging capabilities  
- Support for all What3words API endpoints
- Flexible parameter handling for clipping and focus

## State Management

The `W3WProvider` manages:
- Loading states for UI feedback
- Error states with retry capabilities
- Current address data
- AutoSuggest suggestions
- Grid data for map overlay

## UI Components

### W3WAutoSuggestField
- Real-time suggestions as user types
- Dropdown with suggestion details (country, nearest place, rank)
- Configurable focus point and clipping options

### W3WAddressCard  
- Displays What3words address with coordinates
- Copy functionality
- Navigation integration
- Clean, card-based design

### W3WMapWidget
- Google Maps integration
- Grid line overlay
- Tap-to-convert functionality
- Marker placement for addresses

## Dependencies

- `dio`: HTTP client for API requests
- `provider`: State management
- `google_maps_flutter`: Map integration
- `geolocator`: Location services
- `permission_handler`: Handle permissions

## Testing

Run tests with:
```bash
flutter test
```

The project includes widget tests for the main app components and provider functionality.

## Error Handling

The app handles various error scenarios:
- Network timeouts and connection issues
- Invalid What3words addresses
- API key issues
- Location permission problems
- Invalid coordinates

## Performance Considerations

- Grid updates are optimized to prevent excessive API calls
- AutoSuggest has built-in debouncing
- Map interactions are throttled for better performance
- Error states provide clear retry mechanisms

## License

This project is for demonstration purposes. Make sure to comply with What3words and Google Maps API terms of service.
