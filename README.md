# 🌍 City Explorer

A Flutter mobile application that lets users discover places in cities, view live weather information, and chat in real-time with other users exploring the same city. Built with clean architecture, BLoC state management, and offline support.

## ✨ Features

- **🔐 Guest Authentication** - Simple login with username only
- **🏙️ City Places Explorer** - Search for places using OpenStreetMap + Nominatim API
- **🌤️ Live Weather Information** - Real-time weather data using OpenWeatherMap API
- **💬 Real-time Chat** - WebSocket-based city chat rooms
- **📱 Offline Support** - Caches places and messages using Hive
- **🏗️ Clean Architecture** - Domain/Data/Presentation layers
- **🔄 BLoC State Management** - Reactive state management
- **🧪 Unit Tests** - Weather parsing and caching logic tests

## 📸 Screenshots

*Add your app screenshots here*

## 🛠️ Setup Instructions

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/amanvermanbd11111/city_explorer.git
   cd city_explorer
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure API Key**
   
   Open `lib/core/constants/api_constants.dart` and add your OpenWeatherMap API key:
   ```dart
   static const String openWeatherMapApiKey = 'your_api_key_here';
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔑 API Setup

### OpenWeatherMap API (Required for Weather)

1. **Sign up** at [OpenWeatherMap](https://openweathermap.org/api)
2. **Get your free API key** from the dashboard
3. **Add the key** to `lib/core/constants/api_constants.dart`:
   ```dart
   static const String openWeatherMapApiKey = 'your_actual_api_key_here';
   ```

### APIs Used (No Setup Required)

- **Nominatim API**: Free OpenStreetMap geocoding service
  - URL: `https://nominatim.openstreetmap.org/search`
  - No API key required
  - Used for place search functionality

- **WebSocket Echo Service**: Free testing WebSocket service
  - URL: `wss://ws.postman-echo.com/raw`
  - No API key required  
  - Used for real-time chat functionality
  - 

## 🏗️ Project Structure

```
lib/
├── core/                   # Core utilities and constants
│   ├── constants/         # API URLs and configuration
│   ├── error/            # Error handling and exceptions
│   ├── network/          # HTTP client and network utilities
│   └── utils/            # Helper utilities and logger
├── data/                  # Data layer
│   ├── datasources/      # Remote APIs and local storage
│   ├── models/           # Data models with JSON serialization
│   └── repositories/     # Repository implementations
├── domain/               # Domain layer
│   ├── entities/         # Business entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Business logic use cases
└── presentation/         # Presentation layer
    ├── blocs/            # BLoC state management
    ├── pages/            # UI screens
    └── widgets/          # Reusable UI components
```

## 📱 Usage Guide

### Getting Started

1. **Launch the app** and enter your name for guest login
2. **Search for cities** using the search bar on the home screen
3. **Explore places** by tapping on search results
4. **View weather** information for any selected place
5. **Join city chats** to connect with other explorers

### Features Walkthrough

#### 🔍 Searching Places
- Enter any city name (e.g., "London", "Paris", "New York")
- Browse through the list of places found
- Tap on any place for detailed information

#### 🌤️ Weather Information
- Weather data loads automatically for selected places
- Shows temperature, humidity, and weather conditions
- Updates in real-time using OpenWeatherMap API

#### 💬 City Chat
- Each city has its own chat room
- Messages appear instantly when sent
- Chat history is cached locally for offline viewing
- Connect with other users exploring the same city

#### 📱 Offline Features
- **Cached Places**: Last searched places available offline
- **Cached Messages**: Last 20 messages per city stored locally
- **Last Search**: Quick access to your most recent search

## 🧪 Testing

### Run Unit Tests
```bash
flutter test
```

### Test Coverage
The project includes unit tests for:
- Weather data parsing from OpenWeatherMap API
- Local caching logic with Hive
- API integration with Nominatim service

### Manual Testing Checklist

- [ ] Guest login works with any username
- [ ] City search returns relevant places
- [ ] Weather information loads correctly
- [ ] Chat messages send and appear immediately
- [ ] Offline caching works when disconnected
- [ ] Navigation between screens is smooth
- [ ] App handles network errors gracefully

## 🔧 Development

### Hot Reload
```bash
# In your running Flutter session
r  # Hot reload
R  # Hot restart
q  # Quit
```

### Code Generation
```bash
# Regenerate JSON serialization and Hive adapters
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Analysis
```bash
# Check for code issues
flutter analyze

# Format code
flutter format .
```

## 📦 Dependencies

### Production Dependencies
- `flutter_bloc: ^8.1.6` - State management
- `equatable: ^2.0.5` - Value equality
- `http: ^1.2.2` - HTTP client
- `hive: ^2.2.3` - Local storage
- `hive_flutter: ^1.1.0` - Flutter integration for Hive
- `web_socket_channel: ^3.0.3` - WebSocket support
- `json_annotation: ^4.8.1` - JSON serialization
- `cached_network_image: ^3.4.1` - Image caching

### Development Dependencies
- `flutter_test` - Testing framework
- `hive_generator: ^2.0.1` - Code generation for Hive
- `build_runner: ^2.4.13` - Code generation runner
- `json_serializable: ^6.7.1` - JSON serialization generator
- `flutter_lints: ^5.0.0` - Linting rules

## 🐛 Troubleshooting

### Common Issues

**Places search returns "No places found"**
- Check internet connection
- Verify the city name spelling
- Try searching for major cities like "London" or "Paris"

**Weather not loading**
- Ensure you've added your OpenWeatherMap API key
- Check if the API key is valid and active
- Verify internet connection

**Chat not working**
- Check WebSocket connection status (should show "Connected")
- Try disconnecting and reconnecting
- Check if messages appear in debug logs

**Build errors**
- Run `flutter clean` and `flutter pub get`
- Regenerate code: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- Check Flutter and Dart SDK versions

### Debug Logs
The app includes comprehensive logging. Check your Flutter console for:
- `[DEBUG]` - API calls and responses
- `[INFO]` - General information
- `[ERROR]` - Error details

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 API References

- **[Nominatim API Documentation](https://nominatim.org/release-docs/develop/api/Search/)**
- **[OpenWeatherMap API Documentation](https://openweathermap.org/api/one-call-3)**
- **[Postman Echo WebSocket Documentation](https://docs.postman-echo.com/)**

## 🙏 Acknowledgments

- OpenStreetMap contributors for the Nominatim geocoding service
- OpenWeatherMap for weather data API
- Flutter team for the amazing framework
- BLoC library maintainers for state management

---

**Built with ❤️ using Flutter and BLoC**

For support or questions, please open an issue in the GitHub repository.