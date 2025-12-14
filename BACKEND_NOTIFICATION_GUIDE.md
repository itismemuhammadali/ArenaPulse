# Backend Notification Integration Guide

## Firebase Admin SDK Setup

### Node.js
```bash
npm install firebase-admin
```

### Initialize
```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const messaging = admin.messaging();
```

## Sending Notifications

### Send to Single Device
```javascript
const message = {
  notification: {
    title: 'New Message',
    body: 'You have a new message from John'
  },
  data: {
    type: 'message',
    chatId: 'chat_123',
    senderId: 'user_456'
  },
  token: 'device_token_here'
};

messaging.send(message)
  .then(response => console.log('Message sent:', response))
  .catch(error => console.log('Error:', error));
```

### Send to Multiple Devices
```javascript
const tokens = ['token1', 'token2', 'token3'];

messaging.sendMulticast({
  notification: { title: 'Update', body: 'New content available' },
  data: { type: 'update' },
  tokens: tokens
});
```

### Send to Topic
```javascript
messaging.send({
  notification: { title: 'Sports News', body: 'Lakers won!' },
  data: { type: 'sports_update' },
  topic: 'sports_news'
});
```

### Send to User Segment
```javascript
// Subscribe users to topic
messaging.subscribeToTopic(tokens, 'premium_users');

// Send to topic
messaging.send({
  notification: { title: 'Premium Feature', body: 'New feature available' },
  topic: 'premium_users'
});
```

## Common Notification Types

### Message Notification
```javascript
const sendMessageNotification = async (recipientId, senderId, message) => {
  const userTokens = await getUserTokens(recipientId);
  
  const payload = {
    notification: {
      title: 'New Message',
      body: message.substring(0, 100)
    },
    data: {
      type: 'message',
      chatId: message.chatId,
      senderId: senderId,
      senderName: message.senderName
    }
  };

  for (const token of userTokens) {
    await messaging.send({ ...payload, token });
  }
};
```

### Club Update Notification
```javascript
const sendClubNotification = async (clubId, title, body) => {
  const members = await getClubMembers(clubId);
  const tokens = await getDeviceTokens(members);

  await messaging.sendMulticast({
    notification: { title, body },
    data: {
      type: 'club',
      clubId: clubId,
      action: 'new_post'
    },
    tokens: tokens
  });
};
```

### Friend Request Notification
```javascript
const sendFriendRequestNotification = async (recipientId, senderId) => {
  const userTokens = await getUserTokens(recipientId);
  const senderName = await getUserName(senderId);

  const payload = {
    notification: {
      title: 'Friend Request',
      body: `${senderName} sent you a friend request`
    },
    data: {
      type: 'friend_request',
      userId: senderId,
      userName: senderName
    }
  };

  for (const token of userTokens) {
    await messaging.send({ ...payload, token });
  }
};
```

## Error Handling

```javascript
const sendNotificationWithRetry = async (message, maxRetries = 3) => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await messaging.send(message);
    } catch (error) {
      if (error.code === 'messaging/invalid-registration-token') {
        // Remove invalid token from database
        console.log('Invalid token, removing from database');
        break;
      }
      if (i === maxRetries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
};
```

## Best Practices

1. **Store device tokens securely** in Firestore
2. **Remove invalid tokens** when sending fails
3. **Use topics** for broadcast notifications
4. **Include meaningful data** in notification payload
5. **Test with both foreground and background** states
6. **Monitor delivery rates** and errors
7. **Respect user preferences** before sending
8. **Use appropriate notification types** (data vs notification)
