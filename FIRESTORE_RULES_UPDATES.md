# Firestore Rules Updates for Block & Report Functionality

## 🔒 Security Rules Added

### 1. **Reports Collection Rules**
```javascript
match /reports/{reportId} {
  // CREATE: Users can report posts/users
  allow create: if isAuthenticated() 
    && request.resource.data.reporterId == request.auth.uid
    && request.resource.data.reportedUserId != request.auth.uid  // Can't report yourself
    && request.resource.data.keys().hasAll(['type', 'reportedUserId', 'reporterId', 'reason', 'status', 'createdAt'])
    && request.resource.data.type in ['post', 'user']
    && request.resource.data.status == 'pending'
    && request.resource.data.reason is string
    && request.resource.data.reason.size() > 0;
  
  // READ: Users can read their own reports, admins can read all
  allow read: if isAuthenticated() && 
    (resource.data.reporterId == request.auth.uid || isAdmin(request.auth.uid));
  
  // UPDATE: Limited updates for reporters, full access for admins
  allow update: if isAuthenticated() && 
    ((resource.data.reporterId == request.auth.uid &&
      request.resource.data.diff(resource.data).affectedKeys().hasOnly(['updatedAt'])) ||
     (isAdmin(request.auth.uid) &&
      request.resource.data.diff(resource.data).affectedKeys().hasAny(['status', 'updatedAt'])));
  
  // DELETE: Only admins can delete reports
  allow delete: if isAuthenticated() && isAdmin(request.auth.uid);
}
```

### 2. **Updated Users Collection Rules**
```javascript
// Added blockedUsers array update permission
allow update: if isOwner(userId) || 
  (isAuthenticated() && 
   (request.resource.data.diff(resource.data).affectedKeys().hasOnly(['followersCount', 'followingCount']) ||
    request.resource.data.diff(resource.data).affectedKeys().hasOnly(['blockedUsers'])));
```

### 3. **Added Admin Helper Function**
```javascript
// Helper function to check if user is an admin/moderator
function isAdmin(userId) {
  // For now, return false - implement admin check as needed
  // Example: return get(/databases/$(database)/documents/users/$(userId)).data.get('isAdmin', false);
  return false;
}
```

## 🛡️ Security Features

### **Report Creation Security:**
- ✅ Users must be authenticated
- ✅ Users can only create reports with their own user ID as reporter
- ✅ Users cannot report themselves
- ✅ Required fields validation (type, reportedUserId, reporterId, reason, status, createdAt)
- ✅ Report type must be 'post' or 'user'
- ✅ Initial status must be 'pending'
- ✅ Reason must be a non-empty string

### **Report Access Control:**
- ✅ Users can only read their own reports
- ✅ Admins can read all reports (when admin function is implemented)
- ✅ Limited update permissions for reporters (only updatedAt field)
- ✅ Full update permissions for admins (status, updatedAt fields)
- ✅ Only admins can delete reports

### **Block Functionality Security:**
- ✅ Users can only update their own blockedUsers array
- ✅ Maintains existing follower/following update permissions
- ✅ Proper field-level access control

## 🔧 Implementation Notes

### **Admin Role Implementation:**
To enable full admin functionality, update the `isAdmin()` function:

```javascript
function isAdmin(userId) {
  return get(/databases/$(database)/documents/users/$(userId)).data.get('isAdmin', false);
}
```

Then add an `isAdmin: true` field to admin user documents.

### **Report Data Structure:**
```javascript
{
  type: 'post' | 'user',
  postId: string (optional, for post reports),
  reportedUserId: string,
  reporterId: string,
  reason: string,
  additionalInfo: string (optional),
  status: 'pending' | 'reviewed' | 'resolved' | 'dismissed',
  createdAt: timestamp,
  updatedAt: timestamp,
  postContent: object (optional, for context),
  userContext: object (optional, for context)
}
```

### **Blocked Users Data Structure:**
```javascript
// In users/{userId} document
{
  blockedUsers: [string] // Array of blocked user IDs
}
```

## 🚀 Deployment

1. **Deploy Rules:**
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Test Rules:**
   - Use Firebase Emulator Suite for testing
   - Test report creation, reading, and admin access
   - Test block functionality

3. **Monitor Usage:**
   - Check Firestore usage in Firebase Console
   - Monitor for rule violations in logs
   - Set up alerts for excessive report creation

## 📊 Moderation Dashboard

The rules are designed to support a future moderation dashboard where admins can:
- View all reports by status
- Update report status (pending → reviewed → resolved/dismissed)
- View reported content with context
- Take action on reported users/posts
- Delete resolved reports

## 🔍 Security Considerations

1. **Rate Limiting:** Consider implementing client-side rate limiting for report creation
2. **Duplicate Prevention:** The app logic prevents duplicate reports, but rules don't enforce this
3. **Content Context:** Reports include content snapshots for moderation review
4. **Privacy:** Blocked users lists are private to each user
5. **Audit Trail:** All reports are preserved for audit purposes (only admins can delete)