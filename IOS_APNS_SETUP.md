# iOS APNs Setup Guide for SprintIndex

## Your Credentials
- **Key Name**: NotificationsKey
- **Key ID**: MKQDG48V57
- **Team ID**: 9266W3NRNQ
- **Service**: Apple Push Notifications service (APNs)
- **File**: .p8 file (already downloaded)

## Step 1: Upload .p8 File to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your **sprintindex** project
3. Navigate to **Project Settings** (gear icon) → **Cloud Messaging** tab
4. Scroll to **iOS app configuration** section
5. Click **Upload APNs Certificate**
6. Upload your `.p8` file
7. Enter your **Team ID**: `9266W3NRNQ`
8. Enter your **Key ID**: `MKQDG48V57`
9. Click **Upload**

## Step 2: Verify iOS App Configuration in Firebase

1. In Firebase Console, go to **Project Settings** → **Your apps**
2. Select your iOS app (should be listed as `com.sprintindex.app` or similar)
3. Verify the following:
   - Bundle ID is correct
   - APNs certificate is uploaded (you should see a green checkmark)
   - Team ID matches: `9266W3NRNQ`

## Step 3: Configure Xcode Project

1. Open `ios/Runner.xcworkspace` in Xcode (NOT the .xcodeproj file)
2. Select the **Runner** project in the left sidebar
3. Select the **Runner** target
4. Go to **Signing & Capabilities** tab
5. Click **+ Capability** button
6. Search for and add **Push Notifications**
7. Verify your Team ID is set correctly in the Signing section

## Step 4: Update Firebase Options (if needed)

Check `lib/firebase_options.dart` and ensure iOS configuration is correct:

```dart
static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'sprintindex-XXXXX',
  iosBundleId: 'com.sprintindex.app', // Verify this matches your bundle ID
);
```

## Step 5: Build and Test on iOS Device

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

**Important**: You MUST test on a physical iOS device. Simulators cannot receive push notifications.

## Step 6: Verify Notification Permissions

When the app launches on iOS:
1. User will see a permission prompt: "Allow 'SprintIndex' to send you notifications?"
2. User must tap **Allow**
3. Check the console logs for the device token (should print something like: `FCM Token: eX...`)

## Step 7: Save Device Token to Firestore

The app automatically saves the device token when the user logs in. Verify in Firestore:

1. Go to Firebase Console → **Firestore Database**
2. Navigate to `users/{userId}`
3. Check the `deviceTokens` array contains the iOS token

## Step 8: Test Sending Notifications

### Option A: Firebase Console
1. Go to **Messaging** → **Create your first campaign**
2. Select **Firebase Notification messages**
3. Enter:
   - **Title**: "Test Notification"
   - **Body**: "This is a test"
4. Click **Send test message**
5. Select your iOS device
6. Click **Test**

### Option B: Cloud Function (Backend)
The app already has a Cloud Function that sends notifications. Test it by:

1. Creating a notification document in Firestore:
```
Collection: notifications
Document: {
  userId: "user_id_here",
  title: "Test",
  body: "Test notification",
  type: "message",
  createdAt: timestamp
}
```

2. The Cloud Function will automatically send it to all device tokens

## Troubleshooting

### Issue: "APNs certificate not configured"
- **Solution**: Verify the .p8 file is uploaded in Firebase Console with correct Team ID and Key ID

### Issue: No notifications received on iOS device
- **Checklist**:
  - ✅ Push Notifications capability added in Xcode
  - ✅ APNs certificate uploaded to Firebase
  - ✅ Testing on physical device (not simulator)
  - ✅ User granted notification permission
  - ✅ Device token saved to Firestore
  - ✅ App is in background or foreground (both should work)

### Issue: Device token not generated
- **Solution**: 
  - Check console logs for errors
  - Ensure `firebase_messaging` package is properly initialized
  - Verify Firebase project ID is correct in `firebase_options.dart`

### Issue: Certificate expired
- **Solution**: 
  - Generate a new .p8 file from Apple Developer Portal
  - Upload the new certificate to Firebase Console
  - Redeploy the app

## Certificate Renewal

APNs certificates don't expire, but if you need to regenerate:

1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/certificates/list)
2. Create a new **Apple Push Notification service SSL (Sandbox & Production)** certificate
3. Download and export as .p8
4. Upload to Firebase Console
5. No app changes needed

## Next Steps

1. ✅ Upload .p8 file to Firebase
2. ✅ Configure Xcode with Push Notifications capability
3. ✅ Build and test on physical iOS device
4. ✅ Verify device token is saved
5. ✅ Send test notification from Firebase Console
6. ✅ Implement notification handling in app (already done in `NotificationService`)

## References

- [Firebase Cloud Messaging - iOS Setup](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [Apple Push Notification Service](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server)
- [Flutter Firebase Messaging](https://pub.dev/packages/firebase_messaging)
