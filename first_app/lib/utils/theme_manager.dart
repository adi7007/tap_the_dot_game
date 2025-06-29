import 'package:flutter/material.dart';

class GameTheme {
  final String name;
  final LinearGradient backgroundGradient;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color dotColor;
  final Color textColor;
  final List<Color> levelColors;

  const GameTheme({
    required this.name,
    required this.backgroundGradient,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.dotColor,
    required this.textColor,
    required this.levelColors,
  });
}

class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  int _currentThemeIndex = 0;

  final List<GameTheme> _themes = [
    // Default Blue Theme
    const GameTheme(
      name: 'Ocean Blue',
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF667eea),
          Color(0xFF764ba2),
        ],
      ),
      primaryColor: Color(0xFF667eea),
      secondaryColor: Color(0xFF764ba2),
      accentColor: Colors.amber,
      dotColor: Color(0xFF667eea),
      textColor: Colors.white,
      levelColors: [
        Colors.green,
        Colors.orange,
        Colors.blue,
        Colors.purple,
      ],
    ),
    
    // Sunset Theme
    const GameTheme(
      name: 'Sunset',
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFff6b6b),
          Color(0xFFfeca57),
        ],
      ),
      primaryColor: Color(0xFFff6b6b),
      secondaryColor: Color(0xFFfeca57),
      accentColor: Colors.deepPurple,
      dotColor: Color(0xFFff6b6b),
      textColor: Colors.white,
      levelColors: [
        Colors.green,
        Colors.orange,
        Colors.red,
        Colors.purple,
      ],
    ),
    
    // Forest Theme
    const GameTheme(
      name: 'Forest',
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2d5a27),
          Color(0xFF4a7c59),
        ],
      ),
      primaryColor: Color(0xFF2d5a27),
      secondaryColor: Color(0xFF4a7c59),
      accentColor: Colors.amber,
      dotColor: Color(0xFF4a7c59),
      textColor: Colors.white,
      levelColors: [
        Colors.lightGreen,
        Colors.green,
        Colors.teal,
        Colors.blue,
      ],
    ),
    
    // Neon Theme
    const GameTheme(
      name: 'Neon',
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1a1a2e),
          Color(0xFF16213e),
        ],
      ),
      primaryColor: Color(0xFF0f3460),
      secondaryColor: Color(0xFFe94560),
      accentColor: Color(0xFF00ff88),
      dotColor: Color(0xFFe94560),
      textColor: Colors.white,
      levelColors: [
        Color(0xFF00ff88),
        Color(0xFF00d4ff),
        Color(0xFFff0080),
        Color(0xFFff6b35),
      ],
    ),
  ];

  GameTheme get currentTheme => _themes[_currentThemeIndex];
  
  List<GameTheme> get allThemes => _themes;

  void nextTheme() {
    _currentThemeIndex = (_currentThemeIndex + 1) % _themes.length;
  }

  void setTheme(int index) {
    if (index >= 0 && index < _themes.length) {
      _currentThemeIndex = index;
    }
  }

  Color getLevelColor(int level) {
    final colors = currentTheme.levelColors;
    return colors[(level - 1) % colors.length];
  }

  // Get dot color based on level
  Color getDotColor(int level) {
    if (level <= 5) return currentTheme.dotColor;
    if (level <= 10) return currentTheme.accentColor;
    if (level <= 15) return currentTheme.secondaryColor;
    return getLevelColor(level);
  }
} 