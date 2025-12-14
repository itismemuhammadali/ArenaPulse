# FCM & APNs Notification Setup Guide

This guide covers setting up Firebase Cloud Messaging (FCM) for Android and Apple Push Notifications (APNs) for iOS.

## Android Setup (FCM)

### 1. Firebase Console Configuration
- Go to [Firebase Console](https://console.firebase.google.com/)
- Select your project (sprintindex)
- Navigate to **Project Settings** → **Cloud Messaging**
- Copy your **Server API Key** (you'll need this for sending notifications)

### 2. Android Configuration (Already Done)
- ✅ `firebase_messaging` package added to pubspec.yaml
- ✅ Google Services plugin configured in build.gradle
- ✅ POST_NOTIFICATIONS permission added to AndroidManifest.xml
- ✅ NotificationService initialized in main.dart

### 3. Testing FCM on Android
```bash
# Build and run on Android device/emulator
flutter run
```

The app will automatically:
- Request notification permissions
- Retrieve and log the FCM token
- Handle foreground and background messages

## iOS Setup (APNs)

### 1. Apple Developer Account Setup
1. Go to [Apple Developer Portal](https://developer.apple.com/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Create or select your App ID (com.example.sportsChatApp)
4. Enable **Push Notifications** capability

### 2. Create APNs Certificate
1. In Apple Developer Portal, go to **Certificates**
2. Create a new certificate:
   - Select **Apple Push Notification service SSL (Sandbox & Production)**
   - Follow the CSR process
3. Download the certificate and add it to your Keychain

### 3. Export Certificate for Firebase
1. In Keychain Access, find your APNs certificate
2. Right-click → **Export**
3. Save as `.p8` file (or `.p12` if using older format)
4. Upload to Firebase Console:
   - Go to **Project Settings** → **Cloud Messaging**
   - Under **iOS app configuration**, upload your APNs certificate

### 4. Xcode Configuration
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** project
3. Go to **Signing & Capabilities**
4. Add **Push Notifications** capability
5. Ensure your Team ID is set correctly

### 5. Update iOS Bundle ID (if needed)
In `lib/firebase_options.dart`, update the iOS bundle ID:
```dart
iosBundleId: 'com.example.sportsChatApp',  // Update this to match your bundle ID
```

## Notification Service Features

The `NotificationService` class provides:

### Initialize Notifications
```dart
await NotificationService().initialize();
```

### Get Device Token
```dart
final token = await NotificationService().getDeviceToken();
// Save this token to Firestore for sending targeted notifications
```

### Subscribe to Topics
```dart
await NotificationService().subscribeToTopic('sports_news');
```

### Unsubscribe from Topics
```dart
await NotificationService().unsubscribeFromTopic('sports_news');
```

## Sending Notifications

### From Firebase Console
1. Go to **Messaging** → **Create your first campaign**
2. Select **Firebase Notification messages**
3. Enter title and body
4. Target by:
   - User segment
   - Topic
   - Device token

### From Backend (Node.js Example)
```javascript
const admin = require('firebase-admin');

const message = {
  notification: {
    title: 'New Message',
    body: 'You have a new message from John'
  },
  data: {
    type: 'message',
    chatId: 'chat_123'
  },
  token: 'device_token_here'
};

admin.messaging().send(message)
  .then((response) => console.log('Message sent:', response))
  .catch((error) => console.log('Error sending message:', error));
```

### Send to Topic
```javascript
const message = {
  notification: {
    title: 'Sports Update',
    body: 'Your favorite team won!'
  },
  data: {
    type: 'sports_update'
  },
  topic: 'sports_news'
};

admin.messaging().send(message);
```

## Notification Data Structure

When sending notifications, include a `type` field in the data payload:

```json
{
  "notification": {
    "title": "New Message",
    "body": "You have a new message"
  },
  "data": {
    "type": "message",
    "chatId": "chat_123",
    "senderId": "user_456"
  }
}
```

Supported types:
- `message` - Direct message notification
- `club` - Club-related notification
- `friend_request` - Friend request notification
- `sports_update` - Sports news/update

## Troubleshooting

### Android
- **No notifications received**: Check if POST_NOTIFICATIONS permission is granted
- **Token not generated**: Ensure Google Play Services is installed on device
- **Background messages not working**: Verify `_firebaseMessagingBackgroundHandler` is properly decorated with `@pragma('vm:entry-point')`

### iOS
- **No notifications received**: Verify APNs certificate is uploaded to Firebase
- **Certificate errors**: Ensure certificate is in `.p8` format and not expired
- **Push Notifications capability missing**: Add it in Xcode under Signing & Capabilities

## Next Steps

1. Save device tokens to Firestore when users log in
2. Implement navigation logic in `_navigateToScreen()` method
3. Add custom notification UI for foreground messages
4. Set up backend to send notifications based on app events
5. Test with both foreground and background states
