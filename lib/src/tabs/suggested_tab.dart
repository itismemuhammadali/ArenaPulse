import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_chat_app/src/utils/post_engagement_util.dart';
import 'package:sports_chat_app/src/services/image_cache_service.dart';
import 'package:sports_chat_app/src/screens/user_profile_screen.dart';
import 'comments_tab.dart';

class SuggestedTab extends StatefulWidget {
  const SuggestedTab({super.key});

  @override
  State<SuggestedTab> createState() => _SuggestedTabState();
}

class _SuggestedTabState extends State<SuggestedTab> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: _getFollowingUserIds(),
      builder: (context, followingSnapshot) {
        if (followingSnapshot.hasError) {
          return Center(child: Text('Error: ${followingSnapshot.error}'));
        }

        if (followingSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
          );
        }

        final followingUserIds = followingSnapshot.data ?? [];

        return StreamBuilder<List<String>>(
          stream: _getUserClubIds(),
          builder: (context, clubsSnapshot) {
            if (clubsSnapshot.hasError) {
              return Center(child: Text('Error: ${clubsSnapshot.error}'));
            }

            if (clubsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
              );
            }

            final userClubIds = clubsSnapshot.data ?? [];

            return StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('posts')
                  .snapshots(),
              builder: (context, postsSnapshot) {
                if (postsSnapshot.hasError) {
                  return Center(child: Text('Error: ${postsSnapshot.error}'));
                }

                if (postsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
                  );
                }

                var posts = postsSnapshot.data?.docs ?? [];

                // Filter posts: show posts from following users, public profiles, or club posts
                posts = posts.where((postDoc) {
                  final post = postDoc.data() as Map<String, dynamic>;
                  final userId = post['userId'] as String?;
                  
                  if (userId == null) return false;
                  
                  // Don't show own posts
                  if (userId == _auth.currentUser?.uid) return false;
                  
                  return true;
                }).toList();

                // Sort by createdAt descending
                posts.sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  return (bTime?.toDate() ?? DateTime(2000)).compareTo(aTime?.toDate() ?? DateTime(2000));
                });

                // Now filter by following, public profile, or club membership
                return FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: _filterPostsByFollowingOrPublicOrClub(posts, followingUserIds, userClubIds),
                  builder: (context, filteredSnapshot) {
                    if (filteredSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
                      );
                    }

                    final filteredPosts = filteredSnapshot.data ?? [];

                    if (filteredPosts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lightbulb_outline,
                                size: 40,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Suggestions Yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Follow users or join clubs to see their posts here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index].data() as Map<String, dynamic>;
                        final postId = filteredPosts[index].id;
                        return _buildPostCard(post, postId);
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Stream<List<String>> _getFollowingUserIds() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('following')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Stream<List<String>> _getUserClubIds() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('clubs')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Future<List<QueryDocumentSnapshot>> _filterPostsByFollowingOrPublicOrClub(
    List<QueryDocumentSnapshot> posts,
    List<String> followingUserIds,
    List<String> userClubIds,
  ) async {
    final filtered = <QueryDocumentSnapshot>[];
    final currentUserId = _auth.currentUser?.uid;

    for (final postDoc in posts) {
      final post = postDoc.data() as Map<String, dynamic>;
      final userId = post['userId'] as String?;
      final clubId = post['clubId'] as String?;
      final isPermanent = post['isPermanent'] ?? true;

      if (userId == null) continue;

      // If post is from a club, check if user is a member
      if (clubId != null) {
        try {
          // Check if user is a member of this club
          final clubDoc = await _firestore.collection('clubs').doc(clubId).get();
          if (clubDoc.exists) {
            final memberIds = List<String>.from(clubDoc.data()?['memberIds'] ?? []);
            if (memberIds.contains(currentUserId)) {
              filtered.add(postDoc);
              continue;
            }
          }
        } catch (e) {
          debugPrint('Error checking club membership: $e');
        }
      }

      // For user posts, only show permanent ones
      if (clubId == null && !isPermanent) {
        continue;
      }

      // If user is in following list, include the post
      if (followingUserIds.contains(userId)) {
        filtered.add(postDoc);
        continue;
      }

      // Check if user's profile is public (only for non-club posts)
      if (clubId == null) {
        try {
          final userDoc = await _firestore.collection('users').doc(userId).get();
          if (userDoc.exists) {
            final isPrivate = userDoc.data()?['isPrivate'] as bool? ?? false;
            if (!isPrivate) {
              filtered.add(postDoc);
            }
          }
        } catch (e) {
          debugPrint('Error checking user profile: $e');
        }
      }
    }

    return filtered;
  }

  Widget _buildPostCard(Map<String, dynamic> post, String postId) {
    final timestamp = post['createdAt'] as Timestamp?;
    final date = timestamp?.toDate();
    final timeAgo = date != null ? _getTimeAgo(date) : '';

    return FutureBuilder<String>(
      future: _getUserSports(post['userId']),
      builder: (context, snapshot) {
        final sportsText = snapshot.data ?? 'Sports';
        
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .snapshots(),
          builder: (context, postSnapshot) {
            final currentPost = postSnapshot.data?.data() as Map<String, dynamic>? ?? post;
            final currentLikesCount = currentPost['likesCount'] ?? 0;
            final currentDislikesCount = currentPost['dislikesCount'] ?? 0;
            final currentLikePercentage = PostEngagementUtil.calculateLikePercentage(currentLikesCount, currentDislikesCount);
            final currentDislikePercentage = PostEngagementUtil.calculateDislikePercentage(currentLikesCount, currentDislikesCount);
            
            return _buildPostCardContent(
              context,
              currentPost,
              postId,
              sportsText,
              timeAgo,
              currentLikePercentage,
              currentDislikePercentage,
              currentCommentsCount: currentPost['commentsCount'] ?? 0,
            );
          },
        );
      },
    );
  }

  Widget _buildPostCardContent(
    BuildContext context,
    Map<String, dynamic> post,
    String postId,
    String sportsText,
    String timeAgo,
    int likePercentage,
    int dislikePercentage, {
    required int currentCommentsCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with profile info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          userId: post['userId'] ?? '',
                          userName: post['userName'] ?? 'user',
                        ),
                      ),
                    );
                  },
                  child: RepaintBoundary(
                    child: ImageCacheService.loadProfileImage(
                      imageUrl: post['profilePictureUrl']?.toString() ?? '',
                      radius: 24,
                      fallbackInitial: (post['userName'] ?? 'U')[0].toUpperCase(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                            userId: post['userId'] ?? '',
                            userName: post['userName'] ?? 'user',
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['fullName'] ?? 'Unknown User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$sportsText • $timeAgo',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showPostMenu(context, postId, post['userId']),
                  child: Icon(Icons.more_horiz, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          
          // Text content if available
          if (post['text'] != null && post['text'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post['text'],
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
          
          // Image if available
          if (post['imageUrl'] != null && post['imageUrl'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Image.network(
                post['imageUrl'],
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  );
                },
              ),
            ),
          
          // Stats bar at bottom
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Likes button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _toggleLike(postId),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_upward,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$likePercentage%',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  // Dislikes button
                  if (post['allowDislikes'] == true)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _toggleDislike(postId),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_downward,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$dislikePercentage%',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(width: 20),
                  
                  // Comments
                  if (post['allowComments'] == true)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => CommentsTab(
                              postId: postId,
                              postAuthorName: post['fullName'] ?? 'Unknown',
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.chat_bubble,
                                color: const Color(0xFFFF8C00),
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'View ${currentCommentsCount == 1 ? '1 comment' : '$currentCommentsCount comments'}',
                                style: const TextStyle(
                                  color: Color(0xFFFF8C00),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getUserSports(String userId) async {
    try {
      final sportsDoc = await FirebaseFirestore.instance
          .collection('user_sports')
          .doc(userId)
          .get();
      
      if (sportsDoc.exists) {
        final data = sportsDoc.data()!;
        final sports = <String>[];
        int i = 1;
        while (data.containsKey('sport$i')) {
          sports.add(data['sport$i'] as String);
          i++;
        }
        // Remove duplicates
        final uniqueSports = sports.toSet().toList();
        return uniqueSports.isNotEmpty ? uniqueSports.join(', ') : 'Sports';
      }
      return 'Sports';
    } catch (e) {
      return 'Sports';
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _toggleLike(String postId) async {
    await PostEngagementUtil.toggleLike(postId);
  }

  Future<void> _toggleDislike(String postId) async {
    await PostEngagementUtil.toggleDislike(postId);
  }

  void _showPostMenu(BuildContext context, String postId, String? postUserId) {
    final currentUserId = _auth.currentUser?.uid;
    final isPostOwner = currentUserId == postUserId;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPostOwner)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Post'),
                onTap: () {
                  Navigator.pop(context);
                  _deletePost(postId);
                },
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Close'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePost(String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestore.collection('posts').doc(postId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
