import 'package:vibration/vibration.dart';

class VibrationManager {
  static final VibrationManager _instance = VibrationManager._internal();
  factory VibrationManager() => _instance;
  VibrationManager._internal();

  bool _isEnabled = true;
  bool _isAvailable = false;

  bool get isEnabled => _isEnabled;
  bool get isAvailable => _isAvailable;

  Future<void> initialize() async {
    _isAvailable = await Vibration.hasVibrator();
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  Future<void> vibrateSuccess() async {
    if (!_isEnabled || !_isAvailable) return;
    
    try {
      await Vibration.vibrate(duration: 50);
    } catch (e) {
      // Ignore vibration errors
    }
  }

  Future<void> vibrateMiss() async {
    if (!_isEnabled || !_isAvailable) return;
    
    try {
      await Vibration.vibrate(pattern: [0, 100, 50, 100]);
    } catch (e) {
      // Ignore vibration errors
    }
  }

  Future<void> vibrateCombo(int combo) async {
    if (!_isEnabled || !_isAvailable) return;
    
    try {
      // Vibration pattern based on combo level
      List<int> pattern = [];
      for (int i = 0; i < combo; i++) {
        pattern.addAll([0, 50, 50]);
      }
      await Vibration.vibrate(pattern: pattern);
    } catch (e) {
      // Ignore vibration errors
    }
  }

  Future<void> vibrateAchievement() async {
    if (!_isEnabled || !_isAvailable) return;
    
    try {
      await Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 200]);
    } catch (e) {
      // Ignore vibration errors
    }
  }

  Future<void> vibrateGameEnd() async {
    if (!_isEnabled || !_isAvailable) return;
    
    try {
      await Vibration.vibrate(pattern: [0, 300, 200, 300]);
    } catch (e) {
      // Ignore vibration errors
    }
  }

  Future<void> vibrateButtonPress() async {
    if (!_isEnabled || !_isAvailable) return;
    
    try {
      await Vibration.vibrate(duration: 20);
    } catch (e) {
      // Ignore vibration errors
    }
  }
} 