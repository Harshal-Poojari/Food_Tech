# Health Scanner App

A standalone Flutter application that enables users to scan food product barcodes and analyze ingredients for health insights. Unlike the main branch's `Food Scanner App`, this version has a distinct interface and operates independently.

## Features
- Scan food product barcodes using the device camera
- Analyze ingredients and provide health-related insights
- Display detailed ingredient information with health warnings
- User-friendly UI with a unique design

## Screenshots
(Screenshots will be added after the app is built)

## Getting Started

### Prerequisites
- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS development)

### Installation
1. Clone this repository and switch to the `health_scan` branch:
   ```sh
   git clone https://github.com/yourusername/food_scanner.git
   cd food_scanner
   git checkout health_scan
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the app:
   ```sh
   flutter run
   ```

## Project Structure
```
lib/
├── main.dart           # App entry point
├── models/             # Data models
│   └── ingredient_model.dart
├── screens/            # App screens
│   ├── home_screen.dart
│   ├── scan_screen.dart
│   ├── analysis_screen.dart
│   ├── info_screen.dart
│   └── settings_screen.dart
```

## How It Works
- **Home Screen**: Provides options to start a scan, view previous results, or access settings.
- **Scan Screen**: Uses the device camera to scan barcodes.
- **Analysis Screen**: Shows ingredient health impacts, warnings, and safe alternatives.
- **Info Screen**: Offers details on the app's functionality and sources.
- **Settings Screen**: Allows customization for dietary preferences and health filters.

## Implementation Details
- Uses `flutter_barcode_scanner` for barcode scanning.
- Health data is processed using a local database and potential API integration.
- UI and UX have been redesigned for improved usability.

## Future Enhancements
- Connect to a live health ingredient database.
- Add user authentication for personalized recommendations.
- Implement a history section for previously scanned items.
- Introduce AI-based health suggestions based on dietary needs.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments
- Flutter
- flutter_barcode_scanner
- Open Food Facts (for ingredient data reference)

