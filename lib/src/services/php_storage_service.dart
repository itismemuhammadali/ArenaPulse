import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PhpStorageService {
  static final PhpStorageService _instance = PhpStorageService._internal();
  factory PhpStorageService() => _instance;
  PhpStorageService._internal();

  /// Manually override the backend URL if hosted online (e.g. 'https://yourdomain.com/backend')
  static String? customBaseUrl;

  /// Resolves the current backend URL dynamically based on platform
  String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!.replaceAll(RegExp(r'/+$'), '');
    }

    // Web runs against localhost:8080
    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    // Android emulator maps 10.0.2.2 to the host machine's localhost
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }

    // iOS simulator & desktop platforms
    return 'http://localhost:8080';
  }

  /// Uploads a media file (image or video) to the PHP backend.
  /// 
  /// [folder] can be 'profiles', 'posts', 'clubs', 'facilities', or 'nets'.
  /// Returns the full public URL of the uploaded file on success, or null on failure.
  Future<String?> uploadFile({
    required XFile file,
    String folder = 'general',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/upload.php');
      final request = http.MultipartRequest('POST', uri);

      // Read bytes directly from XFile (works on Web, Android, iOS without dart:io File issues)
      final bytes = await file.readAsBytes();
      final filename = file.name.isNotEmpty 
          ? file.name 
          : 'media_${DateTime.now().millisecondsSinceEpoch}.jpg';

      request.fields['folder'] = folder;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['url'] != null) {
          debugPrint('✅ [PhpStorageService] Upload success: ${data['url']}');
          return data['url'] as String;
        } else {
          debugPrint('❌ [PhpStorageService] Server error: ${data['message']}');
          return null;
        }
      } else {
        debugPrint('❌ [PhpStorageService] HTTP ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [PhpStorageService] Exception during upload: $e');
      return null;
    }
  }

  /// Deletes a file from the PHP backend via its public URL.
  Future<bool> deleteFile({required String fileUrl}) async {
    try {
      final uri = Uri.parse('$baseUrl/delete.php');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': fileUrl}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint('❌ [PhpStorageService] Exception during delete: $e');
      return false;
    }
  }
}
