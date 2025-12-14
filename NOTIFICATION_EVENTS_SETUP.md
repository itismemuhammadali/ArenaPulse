# Notification Events Setup

All notification events are now automatically triggered in your app. Here's what's configured:

## Authentication Events

### Welcome Notification (Sign Up)
- **Trigger**: User creates a new account
- **Title**: "Welcome to SprintIndex"
- **Body**: "Welcome to SprintIndex! Start connecting with sports enthusiasts."
- **Location**: `lib/src/services/auth_service.dart` → `_sendWelcomeNotification()`

### Welcome Back Notification (Login)
- **Trigger**: User logs in
- **Title**: "Welcome Back"
- **Body**: "Welcome back to SprintIndex!"
- **Location**: `lib/src/services/auth_service.dart` → `_sendWelcomeBackNotification()`

### Logout Notification
- **Trigger**: User logs out
- **Title**: "Logged Out"
- **Body**: "You have been logged out."
- **Location**: `lib/src/services/auth_service.dart` → `_sendLogoutNotification()`

## Message Events

### Direct Message Notification
- **Trigger**: User receives a direct message
- **Title**: "Message from [SenderName]"
- **Body**: First 3 words of message (truncated if longer)
- **Location**: `lib/src/services/message_service.dart` → `sendMessage()`
- **Notification Data**: 
  - `type`: "direct_message"
  - `chatId`: Conversation ID
  - `senderName`: Full name of sender

### Club Message Notification
- **Trigger**: User receives a message in a club they're a member of
- **Title**: "New message in [ClubName]"
- **Body**: "[SenderName]: [First 3 words of message]..."
- **Location**: `lib/src/services/message_service.dart` → `sendClubMessage()`
- **Notification Data**:
  - `type`: "club_message"
  - `clubId`: Club ID
  - `clubName`: Club name
  - `senderId`: Sender's name

## Social Events

### New Post Notification
- **Trigger**: User posts and has followers
- **Title**: "New post from [UserName]"
- **Body**: "[UserName] posted something new"
- **Location**: `lib/src/services/user_service.dart` → `createPost()`
- **Notification Data**:
  - `type`: "new_post"
  - `postId`: Post ID
  - `postUserId`: User who posted
  - `userName`: User's full name

### New Follower Notification
- **Trigger**: Someone follows the user
- **Title**: "New Follower"
- **Body**: "[FollowerName] started following you"
- **Location**: `lib/src/services/user_service.dart` → `followUser()`
- **Notification Data**:
  - `type`: "new_follow"
  - `followerId`: ID of person who followed
  - `followerName`: Name of person who followed

## How to Use

### Send Direct Message
```dart
final messageService = MessageService();
await messageService.sendMessage(
  recipientId: 'user_id',
  message: 'Hello there!',
);
// Notification automatically sent to recipient
```

### Send Club Message
```dart
final messageService = MessageService();
await messageService.sendClubMessage(
  clubId: 'club_id',
  message: 'Check this out!',
);
// Notification automatically sent to all club members except sender
```

### Create Post
```dart
final userService = UserService();
await userService.createPost(
  content: 'Just finished an amazing game!',
  imageUrls: ['url1', 'url2'],
);
// Notification automatically sent to all followers
```

### Follow User
```dart
final userService = UserService();
await userService.followUser('user_id');
// Notification automatically sent to the followed user
```

## Notification Storage

All notifications are stored in Firestore under the `notifications` collection with the following structure:

```
notifications/
├── {docId}
│   ├── userId: string (recipient)
│   ├── title: string
│   ├── body: string
│   ├── type: string (welcome, welcome_back, logout, direct_message, club_message, new_post, new_follow)
│   ├── createdAt: timestamp
│   └── [type-specific fields]
```

## Message Truncation

Messages longer than 3 words are automatically truncated:
- "Hello there friend" → "Hello there friend"
- "This is a very long message" → "This is a..."

## Backend Integration

To send notifications from your backend (Node.js example):

```javascript
const admin = require('firebase-admin');

// Send to user's device tokens
const userTokens = await getUserTokens(userId);
const message = {
  notification: {
    title: 'New Message',
    body: 'You have a new message'
  },
  data: {
    type: 'direct_message',
    chatId: 'chat_123'
  }
};

for (const token of userTokens) {
  await admin.messaging().send({ ...message, token });
}
```

## Testing

1. Create two test accounts
2. Log in with first account - should see "Welcome Back" notification
3. Send a message to second account - should see message notification
4. Create a post - followers should see post notification
5. Follow another user - they should see follow notification
6. Log out - should see logout notification

All notifications are automatically saved to Firestore and can be viewed in the notifications screen.
