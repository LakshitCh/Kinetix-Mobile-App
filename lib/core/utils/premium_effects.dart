import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Haptic feedback and voice coaching utilities.
class PremiumEffects {
  static final FlutterTts _tts = FlutterTts();
  static bool _ttsInitialized = false;

  /// Initialize TTS engine.
  static Future<void> _initTts() async {
    if (_ttsInitialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.55); // 1.1x in web = slightly fast
    await _tts.setPitch(1.0);
    _ttsInitialized = true;
  }

  /// Trigger haptic feedback matching the web's navigator.vibrate() patterns.
  static void triggerHaptic(String type) {
    switch (type) {
      case 'light':
        HapticFeedback.lightImpact();
        break;
      case 'medium':
        HapticFeedback.mediumImpact();
        break;
      case 'heavy':
        HapticFeedback.heavyImpact();
        break;
      case 'success':
        HapticFeedback.mediumImpact();
        // Double pulse simulated with slight delay
        Future.delayed(const Duration(milliseconds: 150), () {
          HapticFeedback.mediumImpact();
        });
        break;
      case 'error':
        HapticFeedback.vibrate();
        break;
      default:
        HapticFeedback.mediumImpact();
    }
  }

  /// Speak feedback text using text-to-speech.
  static Future<void> speakFeedback(String text) async {
    await _initTts();
    await _tts.stop(); // Cancel any ongoing speech
    await _tts.speak(text);
  }

  /// Stop any ongoing speech.
  static Future<void> stopSpeech() async {
    await _tts.stop();
  }
}
