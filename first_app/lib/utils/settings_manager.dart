import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_settings.dart';

class SettingsManager {
  static const String _settingsKey = 'game_settings';
  
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  GameSettings _settings = const GameSettings();

  GameSettings get settings => _settings;

  Future<void> initialize() async {
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson != null) {
      final settingsMap = json.decode(settingsJson);
      _settings = GameSettings.fromJson(settingsMap);
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(_settings.toJson());
    await prefs.setString(_settingsKey, settingsJson);
  }

  Future<void> updateSettings(GameSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
  }

  Future<void> updateDifficulty(DifficultyLevel difficulty) async {
    _settings = _settings.copyWith(difficulty: difficulty);
    await _saveSettings();
  }

  Future<void> updateGameMode(GameMode gameMode) async {
    _settings = _settings.copyWith(gameMode: gameMode);
    await _saveSettings();
  }

  Future<void> updateTimerDuration(int duration) async {
    _settings = _settings.copyWith(timerDuration: duration);
    await _saveSettings();
  }

  Future<void> toggleSound() async {
    _settings = _settings.copyWith(soundEnabled: !_settings.soundEnabled);
    await _saveSettings();
  }

  Future<void> toggleVibration() async {
    _settings = _settings.copyWith(vibrationEnabled: !_settings.vibrationEnabled);
    await _saveSettings();
  }

  Future<void> updateDotAnimation(DotAnimation animation) async {
    _settings = _settings.copyWith(dotAnimation: animation);
    await _saveSettings();
  }

  Future<void> updateDotColor(String color) async {
    _settings = _settings.copyWith(dotColor: color);
    await _saveSettings();
  }

  Future<void> updateBackgroundColor(String color) async {
    _settings = _settings.copyWith(backgroundColor: color);
    await _saveSettings();
  }

  Future<void> updateDotSize(double size) async {
    _settings = _settings.copyWith(dotSize: size);
    await _saveSettings();
  }

  Future<void> resetToDefaults() async {
    _settings = const GameSettings();
    await _saveSettings();
  }

  // Get available dot colors
  static List<Map<String, dynamic>> get availableDotColors => [
    {'name': 'Blue', 'value': 'blue', 'color': 0xFF2196F3},
    {'name': 'Red', 'value': 'red', 'color': 0xFFF44336},
    {'name': 'Green', 'value': 'green', 'color': 0xFF4CAF50},
    {'name': 'Purple', 'value': 'purple', 'color': 0xFF9C27B0},
    {'name': 'Orange', 'value': 'orange', 'color': 0xFFFF9800},
    {'name': 'Pink', 'value': 'pink', 'color': 0xFFE91E63},
    {'name': 'Teal', 'value': 'teal', 'color': 0xFF009688},
    {'name': 'Indigo', 'value': 'indigo', 'color': 0xFF3F51B5},
  ];

  // Get available background themes
  static List<Map<String, dynamic>> get availableBackgrounds => [
    {'name': 'Default', 'value': 'default', 'gradient': [0xFF1E3C72, 0xFF2A5298]},
    {'name': 'Sunset', 'value': 'sunset', 'gradient': [0xFFFF512F, 0xFFDD2476]},
    {'name': 'Ocean', 'value': 'ocean', 'gradient': [0xFF667eea, 0xFF764ba2]},
    {'name': 'Forest', 'value': 'forest', 'gradient': [0xFF134E5E, 0xFF71B280]},
    {'name': 'Fire', 'value': 'fire', 'gradient': [0xFFFF416C, 0xFFFF4B2B]},
    {'name': 'Night', 'value': 'night', 'gradient': [0xFF0F2027, 0xFF203A43]},
    {'name': 'Aurora', 'value': 'aurora', 'gradient': [0xFF667eea, 0xFF764ba2]},
    {'name': 'Neon', 'value': 'neon', 'gradient': [0xFF11998e, 0xFF38ef7d]},
  ];

  // Get available timer durations
  static List<int> get availableTimerDurations => [15, 30, 60, 120, 300];
} 