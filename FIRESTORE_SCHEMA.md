# Firestore Schema for Notifications

## Users Collection

```
users/{userId}
├── deviceTokens: string[] (array of FCM tokens)
├── lastTokenUpdate: timestamp
├── notificationPreferences: {
│   ├── messagesEnabled: boolean
│   ├── clubUpdatesEnabled: boolean
│   ├── friendRequestsEnabled: boolean
│   └── sportsUpdatesEnabled: boolean
├── subscribedTopics: string[] (array of topic names)
└── ...other user fields
```

## Example User Document
```json
{
  "uid": "user_123",
  "email": "user@example.com",
  "deviceTokens": [
    "fcm_token_1",
    "fcm_token_2"
  ],
  "lastTokenUpdate": "2024-12-07T10:30:00Z",
  "notificationPreferences": {
    "messagesEnabled": true,
    "clubUpdatesEnabled": true,
    "friendRequestsEnabled": true,
    "sportsUpdatesEnabled": false
  },
  "subscribedTopics": [
    "sports_news",
    "club_updates"
  ]
}
```

## Notification Payload Examples

### Message Notification
```json
{
  "notification": {
    "title": "New Message",
    "body": "John: Hey, how are you?"
  },
  "data": {
    "type": "message",
    "chatId": "chat_123",
    "senderId": "user_456",
    "senderName": "John"
  }
}
```

### Club Notification
```json
{
  "notification": {
    "title": "Club Update",
    "body": "New post in Basketball Club"
  },
  "data": {
    "type": "club",
    "clubId": "club_789",
    "clubName": "Basketball Club",
    "action": "new_post"
  }
}
```

### Friend Request Notification
```json
{
  "notification": {
    "title": "Friend Request",
    "body": "Sarah sent you a friend request"
  },
  "data": {
    "type": "friend_request",
    "userId": "user_789",
    "userName": "Sarah"
  }
}
```

### Sports Update Notification
```json
{
  "notification": {
    "title": "Sports Update",
    "body": "Lakers won 120-115 against Celtics"
  },
  "data": {
    "type": "sports_update",
    "updateId": "update_456",
    "sport": "basketball"
  }
}
```
