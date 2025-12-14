# Quick Notification Reference

## All Notifications at a Glance

| Event | Trigger | Recipient | Notification |
|-------|---------|-----------|--------------|
| **Direct Message** | User sends message | Message recipient | "Message from [Name]" |
| **Club Message** | User sends club message | All club members | "New message in [Club]" |
| **Follow** | User follows another | Followed user | "[Name] started following you" |
| **Join Request** | User requests to join club | Club admin | "[Name] wants to join [Club]" |
| **Join Approved** | Admin approves request | Requesting user | "Your request to join [Club] approved!" |
| **Join Rejected** | Admin rejects request | Requesting user | "Your request to join [Club] declined" |

## How to Send Notifications

### Direct Message (Automatic)
```dart
// In MessageService.sendMessage()
// Automatically calls:
await NotificationUtil.sendDirectMessageNotification(
  recipientId: recipientId,
  senderName: senderName,
  message: message,
  chatId: conversationId,
);
```

### Club Message (Automatic)
```dart
// In MessageService.sendClubMessage()
// Automatically calls:
await NotificationUtil.sendClubMessageNotification(
  clubId: clubId,
  clubName: clubName,
  senderName: senderName,
  message: message,
  memberIds: otherMembers,
);
```

### Follow (Automatic)
```dart
// In FollowService.followUser()
// Automatically calls:
await NotificationUtil.sendFollowNotification(
  userId: targetUserId,
  followerName: followerName,
  followerId: user.uid,
);
```

### Club Join Request (Automatic)
```dart
// In ClubJoinService.requestToJoinClub()
// Automatically calls:
await NotificationUtil.sendClubJoinRequestNotification(
  adminId: adminId,
  clubName: clubName,
  requesterName: userName,
  requesterId: userId,
  clubId: clubId,
);
```

### Club Join Approved (Automatic)
```dart
// In ClubJoinService.approveJoinRequest()
// Automatically calls:
await NotificationUtil.sendClubJoinApprovedNotification(
  userId: userId,
  clubName: clubName,
  clubId: clubId,
);
```

### Club Join Rejected (Automatic)
```dart
// In ClubJoinService.rejectJoinRequest()
// Automatically calls:
await NotificationUtil.sendClubJoinRejectedNotification(
  userId: userId,
  clubName: clubName,
  clubId: clubId,
);
```

## Notification Flow

```
User Action
    ↓
Service Method
    ↓
NotificationUtil Method
    ↓
Get FCM Token
    ↓
Create Notification Document
    ↓
Cloud Function Sends via FCM
    ↓
User Receives Notification
```

## Testing Checklist

- [ ] Direct message notification received
- [ ] Club message notification received
- [ ] Follow notification received
- [ ] Club join request notification received (admin)
- [ ] Club join approved notification received (user)
- [ ] Club join rejected notification received (user)
- [ ] Notifications work when app is closed
- [ ] Notifications work when app is open
- [ ] Notification taps navigate to correct screen

## Troubleshooting

**No notifications received?**
1. Check FCM token is stored: Firestore > users > [userId] > fcmToken
2. Check Cloud Functions are deployed: `firebase functions:list`
3. Check notification permissions: Android/iOS settings
4. Check logs: `firebase functions:log`

**Notifications not showing when app closed?**
1. Verify background handler is set up
2. Check notification channel is created
3. Verify Android/iOS permissions

**Wrong notification content?**
1. Check notification data structure
2. Verify message truncation (3 words max)
3. Check sender name is being fetched correctly

