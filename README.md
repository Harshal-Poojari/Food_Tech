# Food Scanner App

A Flutter application that allows users to scan food products using their camera to get detailed nutritional information and ingredients.

## Features

- **Barcode Scanning**: Scan product barcodes to get detailed information
- **Image Recognition**: Take photos of nutrition labels for automatic processing
- **Allergen Alerts**: Get notified about allergens in scanned products
- **Scan History**: Keep track of all your previously scanned items
- **Beautiful UI**: Modern, animated interface with smooth transitions
- **Dark Mode Support**: Fully supports both light and dark themes

## Screenshots

(Screenshots will be added here)

## Technologies Used

- Flutter 3.7+
- Camera integration for barcode scanning and image capture
- ML Kit for text recognition and barcode scanning
- Advanced animations using flutter_animate
- Material Design 3 with custom theming

## Getting Started

### Prerequisites

- Flutter SDK 3.7.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Android SDK / Xcode (for iOS development)

### Installation

1. Clone the repository:
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

- `lib/animations/` - Animation utilities and constants
- `lib/models/` - Data models
- `lib/screens/` - UI screens
- `lib/services/` - Business logic and services
- `lib/themes/` - App theming
- `lib/widgets/` - Reusable UI components
- `lib/utils/` - Utility functions
- `lib/providers/` - State management

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [ML Kit](https://developers.google.com/ml-kit)
- [flutter_animate](https://pub.dev/packages/flutter_animate)
- [camera](https://pub.dev/packages/camera)
- [barcode_scan2](https://pub.dev/packages/barcode_scan2)
