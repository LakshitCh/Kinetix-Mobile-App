import 'package:audioplayers/audioplayers.dart';

/// Utility for playing synthesized feedback sounds.
class SoundUtils {
  static final AudioPlayer _player = AudioPlayer();

  /// Plays a short success beep sound.
  /// Uses a simple approach since Flutter doesn't have direct Web Audio API.
  static Future<void> playSuccessSound() async {
    try {
      // Use system notification sound as a lightweight alternative
      await _player.play(
        AssetSource('sounds/success_beep.mp3'),
        volume: 0.3,
      );
    } catch (e) {
      // Silently fail if sound asset is not available
    }
  }

  static void dispose() {
    _player.dispose();
  }
}
