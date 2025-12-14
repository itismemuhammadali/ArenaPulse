# Notification Troubleshooting Guide

## Issue: Not All Notifications Saved or Triggered

### Root Causes

1. **Missing FCM Token** - Most common issue
   - Notifications aren't saved if recipient has no fcmToken
   - Check: Firestore > users collection > user doc > fcmToken field

2. **Cloud Function Not Triggering**
   - Function might be disabled or have errors
   - Check: Firebase Console > Functions > sendNotificationOnCreate logs

3. **Invalid Notification Data**
   - Missing required fields (recipientUserId, fcmToken, title, body)
   - Check: Firestore > notifications collection > document structure

### Debugging Steps

#### Step 1: Check FCM Tokens
```
Firestore > users collection
For each user, verify:
- fcmToken field exists
- Token is not empty
- Token format looks valid (long string)
```

#### Step 2: Check Notification Documents
```
Firestore > notifications collection
For each notification, verify:
- recipientUserId: exists and valid
- fcmToken: exists and matches user's token
- title: not empty
- body: not empty
- data.type: valid notification type
- sent: false (before processing)
- createdAt: timestamp
```

#### Step 3: Check Cloud Functions Logs
```
Firebase Console > Functions > sendNotificationOnCreate
Look for:
- 📨 Processing notification (should see for each notification)
- ✅ Notification sent successfully (should see for successful ones)
- ❌ Error messages (shows what went wrong)
```

#### Step 4: Check Retry Function
```
Firebase Console > Functions > retryFailedNotifications
Runs every 5 minutes to retry failed notifications
Check logs for:
- 🔄 Checking for failed notifications
- Retry attempts and results
```

### Common Error Codes

| Error | Cause | Solution |
|-------|-------|----------|
| `messaging/invalid-argument` | Invalid FCM token | Refresh token in app |
| `messaging/registration-token-not-registered` | Token expired | User needs to reopen app |
| `messaging/mismatched-credential` | Wrong Firebase project | Check firebase.json |
| `messaging/third-party-auth-error` | FCM service issue | Retry, usually temporary |

### Quick Fixes

1. **Force Token Refresh**
   - Close and reopen app
   - Check console for new token
   - Verify it's saved in Firestore

2. **Test Notification Manually**
   - Go to Firebase Console > Messaging
   - Send test notification to device
   - If it works, issue is with your code

3. **Check Firestore Rules**
   - Ensure notifications collection is writable
   - Check security rules aren't blocking writes

4. **Monitor in Real-Time**
   - Open Cloud Functions logs
   - Send a test notification
   - Watch logs for processing steps
