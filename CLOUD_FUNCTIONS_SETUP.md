# Cloud Functions Setup for Push Notifications

This Cloud Function automatically sends push notifications to users when notification documents are created in Firestore.

## How It Works

1. When a notification is created in the `notifications` collection
2. The Cloud Function triggers automatically
3. It retrieves the user's device tokens from Firestore
4. It sends the notification via Firebase Cloud Messaging (FCM)
5. Invalid tokens are automatically removed

## Prerequisites

- Firebase CLI installed: `npm install -g firebase-tools`
- Node.js 18+ installed
- Firebase project set up

## Installation & Deployment

### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Login to Firebase
```bash
firebase login
```

### 3. Initialize Firebase in your project (if not already done)
```bash
firebase init
```

### 4. Deploy the Cloud Function
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

### 5. Verify Deployment
```bash
firebase functions:list
```

You should see `sendNotificationOnCreate` in the list.

## Testing

### Test 1: Login and Check Notification
1. Open your app
2. Login with your account
3. Check Firebase Console → Firestore → `notifications` collection
4. You should see a new document with:
   - `userId`: Your user ID
   - `title`: "Welcome Back"
   - `body`: "Welcome back to SprintIndex!"
   - `type`: "welcome_back"

### Test 2: Check Device Tokens
1. Go to Firebase Console → Firestore → `users` collection
2. Open your user document
3. Check the `deviceTokens` array - should have your FCM token

### Test 3: Monitor Function Logs
```bash
firebase functions:log
```

Watch for messages like:
- "Notification sent to X devices for user Y"
- "No device tokens for user Y"
- "Error sending notification: ..."

## Troubleshooting

### Function not triggering?
1. Check if function is deployed: `firebase functions:list`
2. Check logs: `firebase functions:log`
3. Verify notification document is being created in Firestore

### Notification not received on device?
1. Check if device token is saved: Go to user document in Firestore
2. Check if `deviceTokens` array is not empty
3. Check function logs for errors
4. Ensure app has notification permissions enabled

### "No device tokens for user"?
1. Make sure you logged in (device token is saved on login)
2. Check that `DeviceTokenService().saveDeviceToken()` is called after login
3. Verify the token is in the `deviceTokens` array in Firestore

## Function Details

**Trigger**: `onCreate` - When a new document is created in `notifications` collection

**What it does**:
1. Reads the notification document
2. Gets the `userId` from the notification
3. Fetches user's device tokens from Firestore
4. Sends FCM message to each token
5. Removes invalid tokens automatically

**Error Handling**:
- Invalid tokens are automatically removed
- Errors are logged but don't stop the function
- If no tokens exist, function completes gracefully

## Monitoring

### View Real-time Logs
```bash
firebase functions:log --follow
```

### View Specific Function Logs
```bash
firebase functions:log sendNotificationOnCreate
```

### View Logs in Firebase Console
1. Go to Firebase Console
2. Functions → Logs
3. Filter by function name

## Cost

Cloud Functions have a generous free tier:
- 2 million invocations per month (free)
- 400,000 GB-seconds of compute time (free)

This function is very lightweight and will easily stay within free tier limits.

## Next Steps

1. Deploy the function: `firebase deploy --only functions`
2. Test by logging in to your app
3. Check Firebase Console for notifications
4. Monitor logs to ensure everything is working

Once deployed, all notifications will automatically be sent as push notifications to your device!
