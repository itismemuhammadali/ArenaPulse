import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum UserRole {
  customer,
  facilityOwner,
  superAdmin,
}

class RoleService {
  static final RoleService _instance = RoleService._internal();
  factory RoleService() => _instance;
  RoleService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Designated Super Admin emails
  static const List<String> _superAdminEmails = [
    'admin@sprintindex.com',
    'muhammadali2025222@gmail.com',
  ];

  /// Get current user's role
  Future<UserRole> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return UserRole.customer;

    // Direct super admin email check for immediate access
    if (user.email != null && _superAdminEmails.contains(user.email!.toLowerCase())) {
      return UserRole.superAdmin;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return UserRole.customer;

      final data = doc.data();
      final roleStr = data?['role'] as String?;

      if (roleStr == 'super_admin') {
        return UserRole.superAdmin;
      } else if (roleStr == 'facility_owner') {
        return UserRole.facilityOwner;
      }

      // Check if user already owns any facilities in Firestore
      final facilityQuery = await _firestore
          .collection('facilities')
          .where('ownerId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (facilityQuery.docs.isNotEmpty) {
        // Upgrade role in document
        await _firestore.collection('users').doc(user.uid).update({
          'role': 'facility_owner',
        });
        return UserRole.facilityOwner;
      }

      return UserRole.customer;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return UserRole.customer;
    }
  }

  /// Check if user is Super Admin
  Future<bool> isSuperAdmin() async {
    final role = await getCurrentUserRole();
    return role == UserRole.superAdmin;
  }

  /// Check if user is Facility / Net Owner
  Future<bool> isFacilityOwner() async {
    final role = await getCurrentUserRole();
    return role == UserRole.facilityOwner || role == UserRole.superAdmin;
  }

  /// Update user role
  Future<void> setUserRole(String userId, UserRole role) async {
    String roleStr = 'customer';
    if (role == UserRole.facilityOwner) roleStr = 'facility_owner';
    if (role == UserRole.superAdmin) roleStr = 'super_admin';

    await _firestore.collection('users').doc(userId).set({
      'role': roleStr,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
