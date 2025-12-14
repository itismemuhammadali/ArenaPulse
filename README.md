# 🏆 Sports Chat App

A comprehensive Flutter application for sports enthusiasts to connect, chat, and share their passion for sports. Built with Firebase backend and real-time features.

## ✨ Features

- 🔐 **Authentication**: Google Sign-In integration
- 💬 **Real-time Chat**: Instant messaging with Firebase Firestore
- 📸 **Media Sharing**: Photo and video sharing capabilities
- 🗺️ **Location Services**: Google Maps integration for location sharing
- 🔔 **Push Notifications**: Real-time notifications for messages and events
- 😊 **Emoji Support**: Rich emoji picker for enhanced messaging
- 🏃‍♂️ **Sports Features**: Specialized features for sports communities
- 📱 **Cross-Platform**: Runs on Android, iOS, and Web

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Firebase account
- Google Cloud Platform account (for Maps API)
- Android Studio / Xcode for mobile development

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Muhammadali2025222/sports-chat-app.git
   cd sports_chat_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Keys** (IMPORTANT!)
   ```bash
   cp api_keys_template.env api_keys.env
   ```
   Then edit `api_keys.env` with your actual API keys. See [API_KEYS_SETUP.md](API_KEYS_SETUP.md) for detailed instructions.

4. **Add Firebase Configuration Files**
   - Download `google-services.json` from Firebase Console → place in `android/app/`
   - Download `GoogleService-Info.plist` from Firebase Console → place in `ios/Runner/`

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ✅ Web
- ⚠️ Windows (Limited support)
- ⚠️ macOS (Limited support)
- ⚠️ Linux (Limited support)

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language

### Backend & Services
- **Firebase Auth** - User authentication
- **Cloud Firestore** - Real-time database
- **Firebase Storage** - File storage
- **Cloud Functions** - Server-side logic
- **Firebase Messaging** - Push notifications

### APIs & Integrations
- **Google Maps API** - Location services
- **Google Sign-In** - Authentication
- **Geolocator** - Location tracking
- **Image Picker** - Camera/gallery access

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point
├── assets/                   # Images and static assets
├── models/                   # Data models
├── services/                 # Firebase and API services
├── screens/                  # UI screens
├── widgets/                  # Reusable UI components
└── utils/                    # Helper functions

android/                      # Android-specific code
ios/                         # iOS-specific code
web/                         # Web-specific code
functions/                   # Firebase Cloud Functions
```

## 🔧 Configuration

### Firebase Setup
1. Create Firebase project
2. Enable Authentication, Firestore, Storage, Functions
3. Configure security rules (see `firestore.rules` and `storage.rules`)
4. Deploy Cloud Functions: `firebase deploy --only functions`

### Google Maps Setup
1. Enable Maps SDK for Android/iOS/JavaScript
2. Create API key with proper restrictions
3. Update `web/index.html` with your API key

For detailed setup instructions, see [API_KEYS_SETUP.md](API_KEYS_SETUP.md).

## 🔔 Push Notifications

The app includes comprehensive push notification support:
- Real-time message notifications
- Event notifications
- Background notification handling
- Custom notification sounds and actions

See [COMPLETE_NOTIFICATIONS_GUIDE.md](COMPLETE_NOTIFICATIONS_GUIDE.md) for setup details.

## 🏗️ Development

### Running Tests
```bash
flutter test
```

### Building for Production

**Android:**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

### Code Quality
- Uses `flutter_lints` for code analysis
- Follows Flutter/Dart style guidelines
- Includes comprehensive error handling

## 📋 Available Scripts

- `flutter run` - Run in development mode
- `flutter build` - Build for production
- `flutter test` - Run tests
- `flutter clean` - Clean build cache
- `flutter doctor` - Check development setup

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Troubleshooting

### Common Issues

1. **Build failures**: Run `flutter clean && flutter pub get`
2. **Firebase connection issues**: Check configuration files
3. **Maps not loading**: Verify API key and enabled services
4. **Notifications not working**: Check FCM setup and permissions

### Getting Help

- Check [API_KEYS_SETUP.md](API_KEYS_SETUP.md) for configuration help
- Review Firebase Console for service status
- Run `flutter doctor` to check development environment
- Check the [Issues](../../issues) page for known problems

## 📞 Support

For support and questions:
- Create an issue in this repository
- Check existing documentation files
- Review Firebase and Flutter documentation

---

**⚠️ Security Note**: Never commit API keys or sensitive configuration to version control. Use the provided template files and follow the setup guide.
