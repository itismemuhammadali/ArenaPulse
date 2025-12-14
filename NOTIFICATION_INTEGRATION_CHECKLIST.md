# Notification Integration Checklist

## ✅ Completed Setup

- [x] Added `firebase_messaging` to pubspec.yaml
- [x] Created `NotificationService` class
- [x] Created `DeviceTokenService` class
- [x] Created `NotificationHandler` class
- [x] Updated `main.dart` to initialize notifications
- [x] Added POST_NOTIFICATIONS permission to AndroidManifest.xml
- [x] Created documentation files

## 📋 Next Steps

### 1. Android Configuration
- [ ] Build and test on Android device/emulator
- [ ] Verify FCM token is generated and logged
- [ ] Test foreground notifications
- [ ] Test background notifications
- [ ] Test notification tap handling

### 2. iOS Configuration
- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Add Push Notifications capability
- [ ] Configure APNs certificate in Firebase Console
- [ ] Update bundle ID in firebase_options.dart if needed
- [ ] Build and test on iOS device (simulator won't receive notifications)
- [ ] Verify APNs token is generated
- [ ] Test foreground notifications
- [ ] Test background notifications

### 3. Firestore Integration
- [ ] Update user document schema to include deviceTokens
- [ ] Call `DeviceTokenService().saveDeviceToken()` after user login
- [ ] Call `DeviceTokenService().removeDeviceToken()` on user logout
- [ ] Create notification preferences collection/document

### 4. Backend Integration
- [ ] Set up Firebase Admin SDK
- [ ] Implement notification sending functions
- [ ] Create API endpoints for sending notifications
- [ ] Test sending notifications to single device
- [ ] Test sending notifications to topic
- [ ] Implement error handling and retry logic

### 5. App Integration
- [ ] Implement navigation logic in `NotificationHandler`
- [ ] Add event bus or state management for navigation
- [ ] Handle notification tap in different app states
- [ ] Add notification UI for foreground messages
- [ ] Test all notification types (message, club, friend_request, sports_update)

### 6. Testing
- [ ] Test with app in foreground
- [ ] Test with app in background
- [ ] Test with app terminated
- [ ] Test on both Android and iOS
- [ ] Test with multiple devices
- [ ] Test topic subscriptions
- [ ] Test notification preferences

## 📱 Testing Commands

### Android
```bash
# Build and run
flutter run

# View logs
adb logcat | grep "Notification\|FCM"
```

### iOS
```bash
# Build and run
flutter run -d ios

# View logs
log stream --predicate 'process == "Runner"' --level debug
```

## 🔗 Important Links

- [Firebase Messaging Documentation](https://firebase.flutter.dev/docs/messaging/overview)
- [Firebase Console](https://console.firebase.google.com/)
- [Apple Developer Portal](https://developer.apple.com/)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

## 📝 Notes

- Device tokens can change, so refresh them periodically
- Always request permissions before sending notifications
- Test with real devices for iOS (simulator doesn't support APNs)
- Keep APNs certificate updated and not expired
- Monitor notification delivery rates in Firebase Console
