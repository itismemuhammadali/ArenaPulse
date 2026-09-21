import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceGuidanceService {
  static final VoiceGuidanceService _instance = VoiceGuidanceService._internal();
  factory VoiceGuidanceService() => _instance;
  VoiceGuidanceService._internal();

  FlutterTts? _tts;
  bool _isMuted = false;
  bool _isInitialized = false;
  String? _lastSpokenText;

  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      stop();
    }
  }

  Future<void> _initTts() async {
    if (_isInitialized) return;
    try {
      _tts = FlutterTts();
      await _tts!.setLanguage('en-US');
      await _tts!.setSpeechRate(0.5);
      await _tts!.setVolume(1.0);
      await _tts!.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('VoiceGuidanceService: TTS initialization skipped or unsupported: $e');
    }
  }

  /// Speak a turn or navigation instruction
  Future<void> speak(String text) async {
    if (_isMuted || text.trim().isEmpty) return;
    if (_lastSpokenText == text) return; // Avoid repetitive announcements

    _lastSpokenText = text;

    try {
      await _initTts();
      if (_tts != null) {
        await _tts!.stop();
        await _tts!.speak(text);
      }
    } catch (e) {
      debugPrint('VoiceGuidanceService speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      if (_tts != null) {
        await _tts!.stop();
      }
    } catch (_) {}
  }

  void reset() {
    _lastSpokenText = null;
    stop();
  }
}
