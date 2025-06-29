enum DifficultyLevel { easy, medium, hard }
enum GameMode { classic, timer, endless }
enum DotAnimation { none, pulse, bounce, rotate, fade }

class GameSettings {
  final DifficultyLevel difficulty;
  final GameMode gameMode;
  final int timerDuration; // in seconds
  final bool soundEnabled;
  final bool vibrationEnabled;
  final DotAnimation dotAnimation;
  final String dotColor;
  final String backgroundColor;
  final double dotSize;

  const GameSettings({
    this.difficulty = DifficultyLevel.medium,
    this.gameMode = GameMode.classic,
    this.timerDuration = 30,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.dotAnimation = DotAnimation.pulse,
    this.dotColor = 'blue',
    this.backgroundColor = 'default',
    this.dotSize = 80.0,
  });

  GameSettings copyWith({
    DifficultyLevel? difficulty,
    GameMode? gameMode,
    int? timerDuration,
    bool? soundEnabled,
    bool? vibrationEnabled,
    DotAnimation? dotAnimation,
    String? dotColor,
    String? backgroundColor,
    double? dotSize,
  }) {
    return GameSettings(
      difficulty: difficulty ?? this.difficulty,
      gameMode: gameMode ?? this.gameMode,
      timerDuration: timerDuration ?? this.timerDuration,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      dotAnimation: dotAnimation ?? this.dotAnimation,
      dotColor: dotColor ?? this.dotColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      dotSize: dotSize ?? this.dotSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty.index,
      'gameMode': gameMode.index,
      'timerDuration': timerDuration,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'dotAnimation': dotAnimation.index,
      'dotColor': dotColor,
      'backgroundColor': backgroundColor,
      'dotSize': dotSize,
    };
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      difficulty: DifficultyLevel.values[json['difficulty'] as int],
      gameMode: GameMode.values[json['gameMode'] as int],
      timerDuration: json['timerDuration'] as int,
      soundEnabled: json['soundEnabled'] as bool,
      vibrationEnabled: json['vibrationEnabled'] as bool,
      dotAnimation: DotAnimation.values[json['dotAnimation'] as int],
      dotColor: json['dotColor'] as String,
      backgroundColor: json['backgroundColor'] as String,
      dotSize: json['dotSize'] as double,
    );
  }

  // Get spawn delay based on difficulty
  int get minSpawnDelay {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 1500;
      case DifficultyLevel.medium:
        return 1000;
      case DifficultyLevel.hard:
        return 500;
    }
  }

  int get maxSpawnDelay {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 2500;
      case DifficultyLevel.medium:
        return 2000;
      case DifficultyLevel.hard:
        return 1200;
    }
  }

  // Get dot size based on difficulty
  double get difficultyDotSize {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return dotSize + 20;
      case DifficultyLevel.medium:
        return dotSize;
      case DifficultyLevel.hard:
        return dotSize - 20;
    }
  }
} 