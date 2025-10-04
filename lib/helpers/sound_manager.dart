import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isMuted = false;

  static bool get isMuted => _isMuted;

  static Future<void> playTap() async {
    if (_isMuted) return;
    await _player.play(AssetSource('sounds/tap.mp3'));
  }

  static Future<void> playCorrect() async {
    if (_isMuted) return;
    await _player.play(AssetSource('sounds/correct.mp3'));
  }

  static Future<void> playWrong() async {
    if (_isMuted) return;
    await _player.play(AssetSource('sounds/wrong.mp3'));
  }
}
