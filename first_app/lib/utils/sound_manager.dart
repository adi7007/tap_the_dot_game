import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  late AudioPlayer _spawnPlayer;
  late AudioPlayer _tapPlayer;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _spawnPlayer = AudioPlayer();
    _tapPlayer = AudioPlayer();
    
    // Set volume to a reasonable level
    await _spawnPlayer.setVolume(0.5);
    await _tapPlayer.setVolume(0.6);
    
    _isInitialized = true;
  }

  Future<void> playDotSpawn() async {
    if (!_isInitialized) await initialize();
    try {
      await _spawnPlayer.play(AssetSource('sounds/dot_spawn.wav'));
    } catch (e) {
      // Silently handle errors for placeholder files
    }
  }

  Future<void> playDotTap() async {
    if (!_isInitialized) await initialize();
    try {
      await _tapPlayer.play(AssetSource('sounds/dot_tap.wav'));
    } catch (e) {
      // Silently handle errors for placeholder files
    }
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _spawnPlayer.dispose();
      await _tapPlayer.dispose();
      _isInitialized = false;
    }
  }
} 