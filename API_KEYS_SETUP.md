# API Keys Setup Guide

This guide will help you configure all the necessary API keys and configuration files for the Sports Chat App.

## 🔐 Security First

**IMPORTANT**: Never commit actual API keys to version control. This repository uses template files to keep your keys secure.

## 📋 Setup Checklist

### 1. Environment Configuration

1. Copy the template file:
   ```bash
   cp api_keys_template.env api_keys.env
   ```

2. Edit `api_keys.env` with your actual API keys (see sections below)

### 2. Firebase Configuration Files

You need to add these Firebase configuration files (they're gitignored for security):

#### Android Configuration
- File: `android/app/google-services.json`
- Get from: Firebase Console > Project Settings > General > Your apps > Android app
- Download and place in `android/app/` directory

#### iOS Configuration  
- File: `ios/Runner/GoogleService-Info.plist`
- Get from: Firebase Console > Project Settings > General > Your apps > iOS app
- Download and place in `ios/Runner/` directory

### 3. Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Create or select your project
3. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Maps JavaScript API
   - Geocoding API
   - Places API
4. Create API key and add to `api_keys.env`
5. Update `web/index.html` with your key

### 4. Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project or select existing
3. Enable these services:
   - Authentication (Google Sign-In)
   - Firestore Database
   - Storage
   - Cloud Functions
   - Cloud Messaging
4. Get configuration values from Project Settings

### 5. Push Notifications Setup

1. In Firebase Console > Project Settings > Cloud Messaging
2. Generate new private key for server authentication
3. Add FCM Server Key to `api_keys.env`
4. For web push, generate key pair and add to `api_keys.env`

### 6. Android Release Setup

1. Generate release keystore:
   ```bash
   keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
   ```

2. Get SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore my-release-key.jks -alias my-key-alias
   ```

3. Add SHA-1 to Firebase project (Project Settings > General > Your apps > Android)

### 7. iOS Setup

1. Add iOS app in Firebase Console
2. Configure Bundle ID: `com.example.sportsChatApp`
3. Add Team ID from Apple Developer account
4. Download GoogleService-Info.plist

## 🔧 Configuration Files to Update

After setting up API keys, update these files with your values:

### web/index.html
Replace the Google Maps API key:
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_ACTUAL_API_KEY"></script>
```

### Android Configuration
- Update `android/app/build.gradle` with your package name
- Ensure `google-services.json` is in place

### iOS Configuration  
- Update `ios/Runner/Info.plist` with your Bundle ID
- Ensure `GoogleService-Info.plist` is in place

## 🚀 Testing Your Setup

1. Run the app: `flutter run`
2. Test Google Sign-In
3. Test location services
4. Test push notifications
5. Test image upload to Firebase Storage

## 🆘 Troubleshooting

### Common Issues:

1. **Google Sign-In fails**: Check SHA-1 fingerprint in Firebase
2. **Maps not loading**: Verify API key and enabled APIs
3. **Notifications not working**: Check FCM configuration
4. **Build fails**: Ensure all config files are in place

### Debug Commands:

```bash
# Check Flutter doctor
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get

# Check Firebase connection
flutter packages pub run firebase_tools:firebase --version
```

## 📱 Platform-Specific Notes

### Android
- Minimum SDK: 21
- Target SDK: Latest
- Requires Google Play Services

### iOS  
- Minimum iOS: 12.0
- Requires Xcode 12+
- Apple Developer account needed for release

## 🔒 Security Best Practices

1. Never commit `api_keys.env` to version control
2. Use different Firebase projects for dev/staging/production
3. Restrict API keys to specific apps/domains
4. Regularly rotate API keys
5. Monitor API usage in Google Cloud Console

## 📞 Support

If you encounter issues:
1. Check this guide first
2. Review Firebase Console for configuration errors
3. Check Flutter doctor output
4. Verify all dependencies are up to date

---

**Remember**: Keep your API keys secure and never share them publicly!