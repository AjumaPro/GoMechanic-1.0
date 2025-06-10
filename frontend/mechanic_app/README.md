# GoMechanic Mechanic App

A Flutter application for mechanics to manage their jobs, track earnings, and maintain their profile.

## Features

- Dashboard with quick stats and actions
- Active jobs management
- Completed jobs history
- Profile management
- Earnings tracking
- Job notifications
- Location-based services

## Getting Started

### Prerequisites

- Flutter SDK (>=2.17.0)
- Dart SDK (>=2.17.0)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/gomechanic-mechanic.git
```

2. Navigate to the project directory:
```bash
cd gomechanic-mechanic
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── home/
│   │   └── home_screen.dart
│   ├── jobs/
│   │   ├── active_jobs_screen.dart
│   │   └── completed_jobs_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── widgets/
│   ├── common/
│   └── jobs/
├── models/
├── services/
├── providers/
└── utils/
```

## Dependencies

- provider: State management
- shared_preferences: Local storage
- http: API communication
- intl: Internationalization
- flutter_svg: SVG support
- cached_network_image: Image caching
- url_launcher: URL handling
- image_picker: Image selection
- geolocator: Location services
- google_maps_flutter: Maps integration
- flutter_local_notifications: Push notifications

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- All contributors who have helped shape this project
