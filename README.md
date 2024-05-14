# Terpiez

Terpiez is a gamified, location-based app that lets users discover, find, and catch virtual creatures called Terpiez. Utilizing various Flutter packages and services, Terpiez offers an engaging user experience with background location tracking, notifications, and Google Maps integration.

## Features

- **User Authentication and Secure Storage**: Securely collect and store Redis server credentials.
- **Background Services**: Track user location and send notifications in the background.
- **Google Maps Integration**: Display user location and nearby Terpiez on an interactive map.
- **Shake Detection**: Allow users to catch Terpiez by shaking their device.
- **Sound Effects**: Play a sound when a Terpiez is caught.
- **Data Management**: Use shared preferences for local data management and Redis for real-time updates.
- **Multi-Provider Architecture**: Manage state across the app with the provider package.
- **User Preferences**: Toggle sound effects and reset data through a preferences screen.
- **Detailed Views**: Provide detailed information about individual Terpiez.

## Getting Started

### Prerequisites

- Flutter SDK
- Android Studio or Xcode
- Redis server credentials

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/TerpiezTracker.git
   cd TerpiezTracker
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## Usage

### Initial Setup

- On the first run, enter your Redis server credentials to authenticate.
- If the credentials are valid, the app will proceed to the main interface.

### Main Interface

- **Finder Tab**: Displays a Google Map with your location and nearby Terpiez. Shake your device to catch Terpiez within range.
- **Statistics Tab**: Shows your user statistics, including the number of Terpiez caught and days active.
- **List Tab**: Lists all the Terpiez you've caught with detailed information.

### Preferences

- **Sound Effects**: Toggle sound effects for catching Terpiez.
- **Reset Data**: Clear all user data and reset progress.

## Architecture

- **Main Entry Point**: Initializes the app and checks for stored credentials.
- **Background Service Manager**: Manages background tasks and notifications.
- **Redis Service**: Handles interactions with the Redis server for fetching and storing data.
- **Terpiez Service**: Manages fetching and storing Terpiez details and images.
- **Provider Classes**: Manage the app's state and provide data to the UI.
- **UI Components**: Various widgets for displaying the app's UI.

## Dependencies

- `flutter`
- `provider`
- `google_maps_flutter`
- `geolocator`
- `flutter_background_service`
- `flutter_secure_storage`
- `shared_preferences`
- `http`
- `redis`
- `path_provider`
- `shake`
- `sensors_plus`
- `audioplayers`

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you have suggestions or improvements.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- Thanks to the Flutter community for their valuable packages and support.
- Special thanks to the University of Maryland for providing resources and inspiration for this project.

---

Enjoy catching Terpiez!
