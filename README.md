# Food Scanner App

A Flutter application that allows users to scan food product barcodes and analyze ingredients for health information.

## Features

- Scan food product barcodes using the device camera
- Analyze ingredients to identify harmful and safe components
- Get detailed information about each ingredient
- User-friendly interface with intuitive navigation

## Screenshots

(Screenshots will be added after the app is built)

## Getting Started

### Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS development)

### Installation

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/food_scanner.git
   ```

2. Navigate to the project directory:
   ```
   cd food_scanner
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart           # App entry point
├── models/             # Data models
│   └── product_model.dart
├── screens/            # App screens
│   ├── home_screen.dart
│   ├── scanner_screen.dart
│   ├── results_screen.dart
│   └── about_screen.dart
```

## How It Works

1. **Home Screen**: The main landing page with options to scan a product or view information about the app.
2. **Scanner Screen**: Uses the device camera to scan product barcodes.
3. **Results Screen**: Displays the analysis of the scanned product's ingredients, categorizing them as harmful or safe.
4. **About Screen**: Provides information about the app, how it works, and its data sources.

## Implementation Details

- The app uses `flutter_barcode_scanner` for barcode scanning functionality.
- In a production environment, the app would connect to a food database API to fetch ingredient information.
- For this template, we're using mock data to demonstrate the functionality.

## Future Enhancements

- Connect to a real food database API
- Add user accounts to save scan history
- Implement dietary preference filters (vegan, gluten-free, etc.)
- Add alternative product recommendations
- Implement offline mode for previously scanned products

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Flutter](https://flutter.dev/)
- [flutter_barcode_scanner](https://pub.dev/packages/flutter_barcode_scanner)
- [Open Food Facts](https://world.openfoodfacts.org/) (for inspiration on food data structure) 