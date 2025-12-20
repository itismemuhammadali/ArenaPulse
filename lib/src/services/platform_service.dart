import 'dart:io';
import 'package:flutter/services.dart';

class PlatformService {
  static const MethodChannel _channel = MethodChannel('com.example.sports_chat_app/maps');

  static Future<void> setMapsApiKey(String apiKey) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('setMapsApiKey', {'apiKey': apiKey});
        print('Android Maps API key set successfully');
      } catch (e) {
        print('Error setting Android Maps API key: $e');
      }
    }
    // iOS doesn't need this as it reads from GoogleService-Info.plist
  }
}