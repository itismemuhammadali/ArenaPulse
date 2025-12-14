# Notification System - Complete Setup Guide

## ✅ Current Status

### Token Management
- **Getting Tokens**: ✅ FCM tokens are retrieved automatically via `NotificationService().getDeviceToken()`
- **Storing Tokens**: ✅ Tokens are stored in Firestore under `users/{userId}/fcmToken` when users log in
- **Token Updates**: ✅ Tokens are automatically updated on login via `DeviceTokenService().saveDeviceToken()`

### Sending Notifications
- **Cloud Functions**: ✅ Set up to listen for notification documents and send via FCM
- **Notification Collections**: 
  - `notifications` - For sending to individual users
  - `topicNotifications` - For sending to topic subscribers

## How to Send Notifications

### 1. From Flutter App (Client-Side)

```dart
import 'package:sports_chat_app/src/services/notification_service.dart';

// Send notification to a specific user
final notificationService = NotificationService();

bool success = await notificationService.sendNotificationToUser(
  recipientUserId: 'user123',
  title: 'New Message',
  body: 'You have a new message from John',
  data: {
    'type': 'message',
    'conversationId': 'conv456',
    'senderId': 'user789',
  },
);

// Send to multiple users
int successCount = await notificationService.sendNotificationToUsers(
  recipientUserIds: ['user1', 'user2', 'user3'],
  title: 'Club Event',
  body: 'New event posted in your club',
  data: {
    'type': 'club_event',
    'clubId': 'club123',
  },
);

// Send to a topic
bool topicSuccess = await notificationService.sendNotificationToTopic(
  topic: 'football_club_1',
  title: 'Match Update',
  body: 'Match starting in 30 minutes',
  data: {
    'type': 'match_update',
    'matchId': 'match123',
  },
);
```

### 2. From Cloud Functions (Server-Side)

The Cloud Functions automatically handle sending when documents are created in:
- `notifications/{notificationId}` - Sends to individual users
- `topicNotifications/{notificationId}` - Sends to topics

**Example: Creating a notification from Firestore**

```javascript
// This would be done from your backend or Cloud Function
await admin.firestore().collection('notifications').add({
  recipientUserId: 'user123',
  fcmToken: 'token_from_user_doc',
  title: 'New Message',
  body: 'You have a new message',
  data: {
    type: 'message',
    conversationId: 'conv456',
  },
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  sent: false,
});
```

## Notification Data Structure

### Individual User Notification
```json
{
  "recipientUserId": "user123",
  "fcmToken": "token_string",
  "title": "Notification Title",
  "body": "Notification body text",
  "data": {
    "type": "message|club_event|follow|comment|like",
    "relatedId": "id_of_related_object"
  },
  "createdAt": "timestamp",
  "sent": false
}
```

### Topic Notification
```json
{
  "topic": "football_club_1",
  "title": "Notification Title",
  "body": "Notification body text",
  "data": {
    "type": "match_update|event_reminder",
    "relatedId": "id_of_related_object"
  },
  "createdAt": "timestamp",
  "sent": false
}
```

## Use Cases

### 1. New Message Notification
```dart
await notificationService.sendNotificationToUser(
  recipientUserId: recipientId,
  title: 'New Message from $senderName',
  body: messagePreview,
  data: {
    'type': 'message',
    'conversationId': conversationId,
    'senderId': currentUserId,
  },
);
```

### 2. New Follower Notification
```dart
await notificationService.sendNotificationToUser(
  recipientUserId: profileOwnerId,
  title: '$followerName started following you',
  body: 'Check out their profile',
  data: {
    'type': 'follow',
    'followerId': followerId,
  },
);
```

### 3. Club Event Notification
```dart
await notificationService.sendNotificationToUsers(
  recipientUserIds: clubMemberIds,
  title: 'New event in ${clubName}',
  body: eventTitle,
  data: {
    'type': 'club_event',
    'clubId': clubId,
    'eventId': eventId,
  },
);
```

### 4. Post Comment Notification
```dart
await notificationService.sendNotificationToUser(
  recipientUserId: postOwnerId,
  title: '$commenterName commented on your post',
  body: commentPreview,
  data: {
    'type': 'comment',
    'postId': postId,
    'commentId': commentId,
  },
);
```

### 5. Post Like Notification
```dart
await notificationService.sendNotificationToUser(
  recipientUserId: postOwnerId,
  title: '$likerName liked your post',
  body: postPreview,
  data: {
    'type': 'like',
    'postId': postId,
    'likerId': likerId,
  },
);
```

## Deployment

### 1. Deploy Cloud Functions
```bash
cd functions
npm install
firebase deploy --only functions
```

### 2. Verify Setup
- Check Firebase Console > Cloud Functions for `sendNotificationOnCreate` and `sendTopicNotification`
- Check Firestore > Collections for `notifications` and `topicNotifications`
- Verify FCM tokens are being stored in user documents

## Testing

### 1. Test Token Retrieval
- Run app on device/emulator
- Check Firebase Console > Cloud Messaging > Registration tokens
- Or check Firestore user document for `fcmToken` field

### 2. Test Sending Notification
```dart
// In your app, call:
await NotificationService().sendNotificationToUser(
  recipientUserId: 'your_user_id',
  title: 'Test Notification',
  body: 'This is a test',
  data: {'type': 'test'},
);
```

### 3. Monitor Cloud Function Logs
```bash
firebase functions:log
```

## Troubleshooting

### Tokens Not Being Stored
- Ensure user is logged in before calling `DeviceTokenService().saveDeviceToken()`
- Check Firestore permissions allow write to `users/{userId}`
- Verify FCM is initialized in `main.dart`

### Notifications Not Received
- Check device has internet connection
- Verify app has notification permissions granted
- Check Cloud Function logs for errors
- Ensure `fcmToken` field exists in user document
- Verify notification data structure matches expected format

### Invalid Token Errors
- Tokens expire after ~60 days of inactivity
- Tokens are regenerated on app reinstall
- Tokens are device-specific

## Security Notes

- FCM tokens should be treated as sensitive data
- Only store tokens for authenticated users
- Implement rate limiting for notification sending
- Validate notification data before sending
- Use Firestore security rules to restrict notification creation

