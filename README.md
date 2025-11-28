# 🎵 HipHop & RNB Bingo!

A vibrant HipHop & RNB themed bingo game built with Flutter, featuring immersive animations, music, and multi-platform support.

## 📱 Features

- **Interactive Bingo Gameplay**: Classic bingo mechanics with a modern HipHop & RNB twist
- **Rich Animations**: Powered by Lottie and Rive for smooth, engaging visuals
- **Audio Experience**: Background music and sound effects using audioplayers
- **QR Code Integration**: Scan QR codes to join games quickly
- **Multi-Platform Authentication**: Sign in with Google, Apple, or Facebook
- **Local & Remote Games**: Play locally or join remote multiplayer sessions
- **Responsive Design**: Adapts to different screen sizes with flutter_screenutil
- **Demo Balance System**: Practice mode with virtual balance
- **Secure Storage**: User data protected with flutter_secure_storage
- **Haptic Feedback**: Enhanced tactile response for iOS/Android devices

## 🛠️ Tech Stack

### State Management
- **flutter_bloc** & **bloc**: BLoC pattern for state management
- **provider**: Lightweight state management
- **equatable**: Value equality for state comparison

### UI/UX
- **lottie** & **rive**: Advanced animations
- **google_fonts**: Custom typography
- **flutter_svg**: Scalable vector graphics
- **cached_network_image**: Optimized image loading
- **super_tooltip**: Enhanced tooltips
- **flutter_spinkit**: Loading animations

### Audio
- **audioplayers**: Background music and sound effects

### Authentication
- **google_sign_in**: Google authentication
- **sign_in_with_apple**: Apple Sign-In
- **flutter_facebook_auth**: Facebook authentication
- **flutter_secure_storage**: Secure credential storage

### Utilities
- **dio**: HTTP client for API requests
- **sqflite**: Local SQLite database
- **shared_preferences**: Key-value storage
- **path_provider**: File system access
- **mobile_scanner**: QR code scanning
- **google_ml_kit**: Machine learning capabilities
- **flutter_dotenv**: Environment configuration
- **get_it**: Dependency injection

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.2.0 <4.0.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- A code editor (VS Code, Android Studio, etc.)

### Installation

1. **Clone the repository**
   ```bash
   https://github.com/Jossyboydgenius/HIPHOP-RNB-BINGO.git
   cd HIPHOP---RNB-BINGO
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   
   Create a `.env` file in the root directory:
   ```env
   API_BASE_URL=your_api_base_url
   WEB_URL=your_web_url
   MIXPANEL_TOKEN=your_mixpanel_token
   ```

4. **Generate app icons**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
lib/
├── app/
│   ├── flavor_config.dart      # App configuration
│   └── locator.dart            # Service locator setup
├── blocs/
│   ├── auth/                   # Authentication BLoC
│   ├── balance/                # Balance management BLoC
│   └── bingo_game/             # Game logic BLoC
├── enums/
│   └── modal_type.dart         # Modal type definitions
├── models/
│   ├── called_board.dart       # Called board model
│   └── game_model.dart         # Game data model
├── routes/
│   └── app_routes.dart         # App navigation routes
├── services/
│   ├── apple_auth_service.dart
│   ├── auth_service.dart
│   ├── facebook_auth_service.dart
│   ├── game_service.dart
│   ├── game_sound_service.dart
│   ├── google_auth_service.dart
│   └── navigation_service.dart
├── themes/
│   └── app_theme.dart          # App theming
├── views/
│   ├── demo_balance_screen.dart
│   ├── game_details_screen.dart
│   ├── game_screen.dart
│   ├── home_screen.dart
│   ├── input_code_screen.dart
│   ├── onboarding_screen.dart
│   ├── qr_code_scanner_screen.dart
│   ├── remote_game_details_screen.dart
│   └── splash_screen.dart
├── widgets/
│   ├── app_background.dart
│   ├── app_banner.dart
│   ├── app_button.dart
│   ├── app_colors.dart
│   └── app_gif.dart
└── main.dart                   # App entry point
```

## 🎮 How to Play

1. **Sign In**: Use Google, Apple, or Facebook to authenticate
2. **Join Game**: Either scan a QR code, enter a game code, or start a new game
3. **Play Bingo**: Mark numbers as they're called
4. **Win**: Complete a pattern (line, full house, etc.) to win!

## 🔧 Configuration

### Supported Platforms
- ✅ iOS
- ✅ Android
- ✅ Web

### Screen Orientation
The app is locked to portrait mode for optimal gameplay experience.

### Custom Fonts
- **DMSans**: Primary UI font
- **MochiyPopOne**: Decorative headings
- **Poppins**: Body text with multiple weights (300-900)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is private and not published to pub.dev.

## 🐛 Troubleshooting

### Common Issues

**Issue**: Build fails with environment variable errors  
**Solution**: Ensure your `.env` file is properly configured with all required variables.

**Issue**: Authentication not working  
**Solution**: Verify that OAuth credentials are correctly set up in your Firebase/Google/Apple/Facebook console.

**Issue**: QR scanner not working  
**Solution**: Ensure camera permissions are granted in your device settings.

## 📞 Support

For issues, questions, or contributions, please open an issue in the GitHub repository.

---

Built with ❤️ using Flutter!
