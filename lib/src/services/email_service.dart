import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';

class EmailService {
  static const String _resetBaseUrl = 'https://sprintindex.com/reset-password'; // Update with your domain
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Generate secure reset token (32 bytes = 256 bits)
  String _generateSecureToken() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', ''); // Remove padding
  }

  // Check if user exists
  Future<bool> userExists(String email) async {
    try {
      // Normalize email to lowercase for comparison
      final normalizedEmail = email.toLowerCase().trim();
      
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return true;
      }
      
      // Try case-insensitive search by getting all users and checking manually
      final allUsers = await _firestore.collection('users').get();
      for (var doc in allUsers.docs) {
        final userData = doc.data();
        final userEmail = userData['email']?.toString().toLowerCase().trim() ?? '';
        if (userEmail == normalizedEmail) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // Save reset token to Firestore
  Future<String?> _saveResetToken({
    required String email,
    required String token,
  }) async {
    try {
      // Hash the token for storage (never store plain tokens)
      final hashedToken = sha256.convert(utf8.encode(token)).toString();
      
      await _firestore.collection('password_resets').doc(email).set({
        'token': hashedToken,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 1)), // 1 hour expiration
        ),
        'used': false,
      });
      return null; // Success
    } catch (e) {
      return 'Error saving reset token: ${e.toString()}';
    }
  }

  // Verify reset token
  Future<Map<String, dynamic>> verifyResetToken({
    required String email,
    required String token,
  }) async {
    try {
      final doc = await _firestore.collection('password_resets').doc(email).get();
      
      if (!doc.exists) {
        return {'success': false, 'message': 'Invalid or expired reset link'};
      }

      final data = doc.data()!;
      final hashedToken = data['token'] as String;
      final expiresAt = data['expiresAt'] as Timestamp;
      final used = data['used'] as bool;

      if (used) {
        return {'success': false, 'message': 'This reset link has already been used'};
      }

      if (DateTime.now().isAfter(expiresAt.toDate())) {
        return {'success': false, 'message': 'Reset link has expired. Please request a new one'};
      }

      // Hash the provided token and compare
      final providedHashedToken = sha256.convert(utf8.encode(token)).toString();
      if (hashedToken != providedHashedToken) {
        return {'success': false, 'message': 'Invalid reset link'};
      }

      return {'success': true, 'message': 'Token verified successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error verifying token: ${e.toString()}'};
    }
  }

  // Mark reset token as used
  Future<void> markResetTokenAsUsed(String email) async {
    await _firestore.collection('password_resets').doc(email).update({
      'used': true,
    });
  }

  // Send password reset email via Cloud Function
  Future<String?> sendPasswordResetEmail({
    required String toEmail,
    required String token,
  }) async {
    try {
      final resetUrl = '$_resetBaseUrl?email=${Uri.encodeComponent(toEmail)}&token=${Uri.encodeComponent(token)}';
      
      await _functions.httpsCallable('sendPasswordResetEmail').call({
        'email': toEmail,
        'resetUrl': resetUrl,
      });
      
      return null; // Success
    } catch (e) {
      return 'Error sending email: ${e.toString()}';
    }
  }



  // Send password reset link
  Future<String?> sendPasswordResetLink(String email) async {
    try {
      // Generate secure token
      final token = _generateSecureToken();
      
      // Save token to Firestore
      final saveError = await _saveResetToken(email: email, token: token);
      if (saveError != null) return saveError;
      
      // Send email with reset link
      final emailError = await sendPasswordResetEmail(toEmail: email, token: token);
      if (emailError != null) return emailError;
      
      return null; // Success
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
