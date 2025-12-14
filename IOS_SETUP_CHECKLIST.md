# iOS Setup Checklist for SprintIndex

Your code is already configured for iOS notifications. Follow this checklist when you have a Mac and iPhone.

## ✅ Already Done (Code Level)

- ✅ `firebase_messaging` package added to pubspec.yaml
- ✅ NotificationService initialized in main.dart
- ✅ iOS permission requests configured
- ✅ Foreground and background message handlers set up
- ✅ Firebase options configured for iOS
- ✅ APNs Authentication Key uploaded to Firebase Console

## 📋 Steps to Complete When You Have Mac & iPhone

### Step 1: Open Xcode Project
```bash
# Navigate to iOS folder
cd ios

# Open the workspace (NOT the .xcodeproj)
open Runner.xcworkspace
```

### Step 2: Configure Signing & Capabilities
1. In Xcode, select **Runner** project (left sidebar)
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Verify your **Team ID** is set (should auto-populate)
5. Click **+ Capability** button
6. Search for and add **Push Notifications**
7. You should now see "Push Notifications" listed under Capabilities

### Step 3: Verify Bundle ID
1. Still in **Signing & Capabilities**
2. Check the **Bundle Identifier** (should be something like `com.example.sportsChatApp`)
3. This must match what's in Firebase Console

### Step 4: Update Firebase Bundle ID (if needed)
If your actual Bundle ID is different from `com.example.sportsChatApp`:

Edit `lib/firebase_options.dart`:
```dart
static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'AIzaSyC9Tsg4WDC0Nmpr88ce1iXg5wwfnxEAlnk',
  appId: '1:372891657980:ios:f41c5b6d44a6000ea6d979',
  messagingSenderId: '372891657980',
  projectId: 'sprintindex',
  iosBundleId: 'com.YOUR.ACTUAL.BUNDLE.ID', // Update this
  storageBucket: 'sprintindex.firebasestorage.app',
);
```

### Step 5: Build and Run
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build for iOS
flutter build ios

# Or run directly on device
flutter run -d <device_id>
```

### Step 6: Grant Notification Permission
1. When app launches on iPhone, you'll see: "Allow 'SprintIndex' to send you notifications?"
2. Tap **Allow**
3. Check Xcode console for device token (should print: `Device FCM Token: eX...`)

### Step 7: Verify Device Token in Firestore
1. Open Firebase Console
2. Go to **Firestore Database**
3. Navigate to `users/{your_user_id}`
4. Check `deviceTokens` array contains the iOS token

### Step 8: Test Notification
1. Go to Firebase Console → **Messaging**
2. Click **Create your first campaign**
3. Select **Firebase Notification messages**
4. Enter:
   - **Title**: "Test Notification"
   - **Body**: "This is a test"
5. Click **Send test message**
6. Select your iOS device
7. Click **Test**
8. You should receive the notification on your iPhone

## 🔧 Code Configuration (Already Done)

### NotificationService (lib/src/services/notification_service.dart)
- ✅ Requests iOS notification permissions
- ✅ Handles foreground messages with SnackBar
- ✅ Handles background messages
- ✅ Retrieves and logs device token
- ✅ Supports topic subscriptions

### Main App (lib/main.dart)
- ✅ Initializes Firebase
- ✅ Initializes NotificationService
- ✅ Sets up navigator key for routing

### Firebase Options (lib/firebase_options.dart)
- ✅ iOS configuration with correct credentials
- ✅ Bundle ID configured

## 🐛 Troubleshooting

### Issue: "Push Notifications capability not found"
- **Solution**: Make sure you're editing the **Runner** target, not the project

### Issue: No notifications received
- **Checklist**:
  - ✅ Push Notifications capability added in Xcode
  - ✅ APNs key uploaded to Firebase
  - ✅ Testing on physical device (not simulator)
  - ✅ User granted notification permission
  - ✅ Device token saved to Firestore
  - ✅ App is in background or foreground

### Issue: Device token not printing
- **Solution**: 
  - Check Xcode console for errors
  - Verify Firebase project ID is correct
  - Ensure `firebase_messaging` package is properly initialized

### Issue: "Invalid APNs certificate"
- **Solution**: 
  - Verify the .p8 file is correct
  - Check Team ID and Key ID are correct
  - Re-upload the certificate to Firebase

### Issue: Notifications go to spam
- **Solution**: 
  - Verify sender email is verified in Apple Developer Portal
  - Check notification payload is properly formatted
  - Ensure bundle ID matches across all configurations

## 📱 Device Token Flow

1. App launches → NotificationService.initialize()
2. Requests iOS notification permission
3. Gets device token from Firebase Messaging
4. Prints token to console: `Device FCM Token: ...`
5. Token is saved to Firestore in `users/{userId}/deviceTokens` array
6. Backend can now send notifications to this token

## 🔐 Security Notes

- Device tokens are stored securely in Firestore
- Tokens are automatically refreshed by Firebase
- Invalid tokens are removed from Firestore
- Never expose tokens in logs in production

## 📚 References

- [Firebase Cloud Messaging - iOS Setup](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [Flutter Firebase Messaging](https://pub.dev/packages/firebase_messaging)
- [Apple Push Notification Service](https://developer.apple.com/documentation/usernotifications)
- [Xcode Signing & Capabilities](https://developer.apple.com/documentation/xcode/signing-your-app)

## ✨ Next Steps

1. Get a Mac and iPhone
2. Follow the steps above
3. Test notifications end-to-end
4. Implement custom notification handling in `_navigateToScreen()` method
5. Set up backend to send notifications based on app events
