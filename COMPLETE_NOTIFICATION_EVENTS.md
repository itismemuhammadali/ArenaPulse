# Complete Notification Events Documentation

All notification events are now fully integrated into your app. Here's the complete list:

## Authentication Events

| Event | Trigger | Title | Body |
|-------|---------|-------|------|
| Welcome | User signs up | "Welcome to SprintIndex" | "Welcome to SprintIndex! Start connecting with sports enthusiasts." |
| Welcome Back | User logs in | "Welcome Back" | "Welcome back to SprintIndex!" |
| Logout | User logs out | "Logged Out" | "You have been logged out." |

## Post Events

| Event | Trigger | Title | Body |
|-------|---------|-------|------|
| Post Upload Success | Post created successfully | "Post Published" | "Your post has been published successfully" |
| Post Upload Failed | Post creation fails | "Post Upload Failed" | "Failed to upload post: [error message]" |
| Comment | Someone comments on post | "New Comment" | "[Commenter]: [First 3 words of comment]..." |
| Like | Someone likes post | "Post Liked" | "[Liker] liked your post" |
| Dislike | Someone dislikes post | "Post Disliked" | "[Disliker] disliked your post" |

## Message Events

| Event | Trigger | Title | Body |
|-------|---------|-------|------|
| Direct Message | User receives DM | "Message from [Sender]" | "[First 3 words of message]..." |
| Club Message | User receives club message | "New message in [Club]" | "[Sender]: [First 3 words]..." |

## Social Events

| Event | Trigger | Title | Body |
|-------|---------|-------|------|
| New Follower | Someone follows user | "New Follower" | "[Follower] started following you" |
| New Post | Follower posts | "New post from [User]" | "[User] posted something new" |
| Profile Update | User updates profile | "Profile Updated" | "[User] updated their profile" |

## Event Events

| Event | Trigger | Title | Body |
|-------|---------|-------|------|
| Event Created | Event is created | "Event Created" | "Event '[Name]' has been created" |
| Event Deleted | Event is deleted | "Event Deleted" | "Event '[Name]' has been deleted" |
| Event Completed | Event is marked complete | "Event Completed" | "Event '[Name]' has been completed" |

## Poll Events

| Event | Trigger | Title | Body |
|-------|---------|-------|------|
| Poll Created | Poll is created | "Poll Created" | "Poll '[Title]' has been created" |
| Poll Deleted | Poll is deleted | "Poll Deleted" | "Poll '[Title]' has been deleted" |
| Poll Completed | Poll is marked complete | "Poll Completed" | "Poll '[Title]' has been completed" |

## Club Events

| Event | Trigger | Title | Body |
|-------|---------|-------|------|
| Club Created | Club is created | "New Club Created" | "Club '[Name]' has been created" |
| Club Joined | Member joins club | "New Member" | "[Member] joined [Club]" |
| Club Deleted | Club is deleted | "Club Deleted" | "Club '[Name]' has been deleted" |
| Club Member Removed | Member is removed | "Removed from Club" | "You have been removed from [Club]" |
| Club Member Exited | Member leaves club | "Member Left" | "[Member] left [Club]" |

## Location Events

| Event | Trigger | Title | Body |
|-------|---------|-------|------|
| Nearby Club | Club within 5km | "Club Nearby" | "[Club] is [distance] km away" |

## Usage Examples

### Post Events
```dart
final userService = UserService();

// Create post (sends success/failure notification)
await userService.createPost(
  content: 'Amazing game today!',
  imageUrls: ['url1', 'url2'],
);

// Like post (sends like notification to post owner)
await userService.likePost(
  postId: 'post_123',
  postOwnerId: 'user_456',
);

// Comment on post (sends comment notification)
await userService.commentOnPost(
  postId: 'post_123',
  postOwnerId: 'user_456',
  comment: 'Great post!',
);

// Update profile (sends notification to followers)
await userService.updateProfile(
  fullName: 'John Doe',
  age: 25,
  bio: 'Sports enthusiast',
);
```

### Event Events
```dart
final eventService = EventService();

// Create event (sends notification to invited users)
await eventService.createEvent(
  eventName: 'Basketball Game',
  description: 'Friendly match',
  eventDate: DateTime.now().add(Duration(days: 7)),
  location: 'Central Park',
  invitedUserIds: ['user_1', 'user_2'],
);

// Complete event (sends notification to attendees)
await eventService.completeEvent('event_123');

// Delete event (sends notification to invited users)
await eventService.deleteEvent('event_123');
```

### Poll Events
```dart
final pollService = PollService();

// Create poll (sends notification to recipients)
await pollService.createPoll(
  pollTitle: 'Best Sport?',
  options: ['Basketball', 'Football', 'Tennis'],
  recipientIds: ['user_1', 'user_2'],
);

// Complete poll (sends notification to creator)
await pollService.completePoll('poll_123');

// Delete poll (sends notification to creator)
await pollService.deletePoll('poll_123');
```

### Club Events
```dart
final clubService = ClubService();

// Create club (sends notification to all members)
await clubService.createClub(
  clubName: 'Basketball Lovers',
  memberIds: ['user_1', 'user_2'],
  onlyAdminCanMessage: false,
);

// Add member (sends notification to all members)
await clubService.addMemberToClub('club_123', 'user_3');

// Remove member (sends notification to removed member and others)
await clubService.removeMemberFromClub('club_123', 'user_3');

// Exit club (sends notification to remaining members)
await clubService.exitClub('club_123');

// Delete club (sends notification to all members)
await clubService.deleteClub('club_123');
```

### Location Events
```dart
final locationService = LocationService();

// Get nearby clubs (within 5km)
final nearbyClubs = await locationService.getNearbyClubs();

// Check and notify nearby clubs
await locationService.checkAndNotifyNearbyClubs();

// Update club location
await locationService.updateClubLocation(
  clubId: 'club_123',
  latitude: 40.7128,
  longitude: -74.0060,
);
```

## Notification Storage

All notifications are stored in Firestore under `notifications` collection:

```
notifications/
├── {docId}
│   ├── userId: string (recipient)
│   ├── title: string
│   ├── body: string
│   ├── type: string
│   ├── createdAt: timestamp
│   └── [type-specific fields]
```

## Notification Types

- `welcome` - User signup
- `welcome_back` - User login
- `logout` - User logout
- `direct_message` - Direct message
- `club_message` - Club message
- `new_follow` - New follower
- `new_post` - Follower posted
- `profile_update` - Profile updated
- `post_upload` - Post upload result
- `comment` - Comment on post
- `like` - Post liked
- `dislike` - Post disliked
- `event_created` - Event created
- `event_deleted` - Event deleted
- `event_completed` - Event completed
- `poll_created` - Poll created
- `poll_deleted` - Poll deleted
- `poll_completed` - Poll completed
- `club_created` - Club created
- `club_joined` - Member joined club
- `club_deleted` - Club deleted
- `club_removed` - Member removed from club
- `club_exited` - Member left club
- `nearby_club` - Club within 5km

## Message Truncation

Messages longer than 3 words are automatically truncated:
- "Hello there friend" → "Hello there friend"
- "This is a very long message" → "This is a..."

## Backend Integration

To send notifications from your backend:

```javascript
const admin = require('firebase-admin');

// Send to user's device tokens
const userTokens = await getUserTokens(userId);
const message = {
  notification: {
    title: 'New Event',
    body: 'Basketball game tomorrow'
  },
  data: {
    type: 'event_created',
    eventName: 'Basketball Game'
  }
};

for (const token of userTokens) {
  await admin.messaging().send({ ...message, token });
}
```

## Testing Checklist

- [ ] Sign up - receive welcome notification
- [ ] Login - receive welcome back notification
- [ ] Create post - receive success notification
- [ ] Comment on post - post owner receives notification
- [ ] Like post - post owner receives notification
- [ ] Follow user - user receives notification
- [ ] Create event - invited users receive notification
- [ ] Create poll - recipients receive notification
- [ ] Create club - all members receive notification
- [ ] Join club - all members receive notification
- [ ] Update profile - followers receive notification
- [ ] Check nearby clubs - receive nearby club notifications
- [ ] Logout - receive logout notification

All notifications are automatically saved to Firestore and can be displayed in your notifications screen.
