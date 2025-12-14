# Notification Debug Checklist

## Quick Diagnosis

### 1. Check if Notifications are Being Saved
```
Firebase Console > Firestore > notifications collection
- Count total documents
- Check if new ones appear when you send a notification
- If NO new documents: Issue is in app code (not saving)
- If YES new documents: Issue is in Cloud Functions (not sending)
```

### 2. Check Notification Document Structure
```
Click on a notification document and verify:
✓ recipientUserId: valid user ID
✓ fcmToken: long string (not empty)
✓ title: not empty
✓ body: not empty
✓ data.type: valid type (direct_message, club_message, etc.)
✓ sent: false (before Cloud Function processes)
✓ createdAt: timestamp
```

### 3. Check Cloud Functions Logs
```
Firebase Console > Functions > sendNotificationOnCreate
Look for your notification ID in logs:
- 📨 Processing notification [ID] = Function triggered
- ✅ Notification [ID] sent successfully = Success
- ❌ Error sending notification [ID] = Failed
```

## Step-by-Step Debugging

### Step 1: Verify FCM Token is Stored
```
1. Open app and check console for:
   "✅ Device FCM Token: [token]"
   
2. Go to Firestore > users > [your user ID]
   
3. Verify fcmToken field exists and has a value
   
If NO token:
- App didn't initialize notification service
- Check main.dart for NotificationService().initialize()
- Check console for permission errors
```

### Step 2: Send Test Notification Manually
```
1. Go to Firebase Console > Firestore
2. Create new document in notifications collection:
   {
     "recipientUserId": "YOUR_USER_ID",
     "fcmToken": "YOUR_FCM_TOKEN",
     "title": "Test",
     "body": "Test notification",
     "data": {
       "type": "direct_message"
     },
     "sent": false,
     "createdAt": SERVER_TIMESTAMP
   }
   
3. Watch Cloud Functions logs for processing
4. Check if notification appears on device
```

### Step 3: Check for Missing FCM Tokens
```
Run this query in Firestore:
- Collection: users
- Where: fcmToken does not exist OR fcmToken == ""

Any results = Users without tokens won't receive notifications
Solution: They need to open app to get token
```

### Step 4: Monitor Real-Time
```
1. Open Cloud Functions logs
2. Open app and send a notification
3. Watch logs for:
   - 📨 Processing notification
   - ✅ Notification sent
   - ❌ Error messages
```

## Common Issues & Fixes

### Issue: Notifications Saved but Not Sent
**Cause**: Cloud Function error or invalid FCM token

**Fix**:
1. Check Cloud Functions logs for error
2. Verify fcmToken is valid
3. Check if token is from same Firebase project
4. Retry function runs every 5 minutes

### Issue: Notifications Not Saved
**Cause**: App not saving to Firestore

**Fix**:
1. Check app console for errors
2. Verify Firestore rules allow writes
3. Verify recipientId and fcmToken are populated
4. Check network connectivity

### Issue: Some Notifications Missing
**Cause**: Batch operations or timing issues

**Fix**:
1. Check if using batch writes
2. Verify all notifications have required fields
3. Check Cloud Functions timeout (5 minutes)
4. Check Firestore write quota

## Monitoring Commands

### Check Notification Success Rate
```
Firebase Console > Firestore > notifications
- Count where sent == true
- Count where sent == false
- Calculate: success_rate = true_count / (true_count + false_count)
```

### Check Retry Status
```
Firebase Console > Firestore > notifications
- Filter: retryCount > 0
- These are notifications that failed and were retried
```

### Check Error Messages
```
Firebase Console > Firestore > notifications
- Filter: sent == false
- Check 'error' field for error message
- Common errors:
  - "Missing recipientUserId or fcmToken"
  - "messaging/invalid-argument"
  - "messaging/registration-token-not-registered"
```

## Testing Checklist

- [ ] App initializes notification service
- [ ] FCM token is generated and stored in Firestore
- [ ] Notification document is created in Firestore
- [ ] Cloud Function processes notification
- [ ] Notification appears on device
- [ ] Notification appears in correct channel
- [ ] Notification actions work (Android/iOS)
- [ ] Retry function processes failed notifications
- [ ] Multiple notifications work correctly
- [ ] Different notification types work

## Performance Monitoring

### Metrics to Track
- Notification creation time
- Cloud Function processing time
- Delivery time (creation to device)
- Success rate
- Retry rate
- Error rate by type

### Optimization Tips
- Batch notifications when possible
- Use topics for broadcast notifications
- Monitor Cloud Functions quota
- Clean up old notifications periodically
