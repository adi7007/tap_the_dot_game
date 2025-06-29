class GameResult {
  final int reactionTime; // Average reaction time in milliseconds
  final int totalTaps; // Total number of taps attempted
  final int successfulTaps; // Number of successful dot taps
  final int level; // Level reached
  final DateTime timestamp; // When the game was played
  final int maxCombo; // Maximum combo achieved
  final int totalScore; // Total score with combo multipliers
  final int gameDuration; // Game duration in milliseconds
  final String difficulty; // Difficulty level
  final String gameMode; // Game mode (classic, timer, endless)
  final double accuracy; // Accuracy percentage

  GameResult({
    required this.reactionTime,
    required this.totalTaps,
    required this.successfulTaps,
    required this.level,
    required this.timestamp,
    this.maxCombo = 0,
    this.totalScore = 0,
    this.gameDuration = 30000,
    this.difficulty = 'medium',
    this.gameMode = 'classic',
    this.accuracy = 0.0,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'reactionTime': reactionTime,
      'totalTaps': totalTaps,
      'successfulTaps': successfulTaps,
      'level': level,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'maxCombo': maxCombo,
      'totalScore': totalScore,
      'gameDuration': gameDuration,
      'difficulty': difficulty,
      'gameMode': gameMode,
      'accuracy': accuracy,
    };
  }

  // Create from JSON
  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      reactionTime: json['reactionTime'] as int,
      totalTaps: json['totalTaps'] as int,
      successfulTaps: json['successfulTaps'] as int,
      level: json['level'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      maxCombo: json['maxCombo'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      gameDuration: json['gameDuration'] as int? ?? 30000,
      difficulty: json['difficulty'] as String? ?? 'medium',
      gameMode: json['gameMode'] as String? ?? 'classic',
      accuracy: json['accuracy'] as double? ?? 0.0,
    );
  }

  // Calculate accuracy percentage
  double get calculatedAccuracy {
    if (totalTaps == 0) return 0.0;
    return (successfulTaps / totalTaps) * 100;
  }

  // Get formatted date string
  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  // Get formatted time string
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Get formatted game duration
  String get formattedDuration {
    final seconds = gameDuration ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${remainingSeconds}s';
  }

  // Get score per second
  double get scorePerSecond {
    if (gameDuration == 0) return 0.0;
    return totalScore / (gameDuration / 1000);
  }

  // Get taps per second
  double get tapsPerSecond {
    if (gameDuration == 0) return 0.0;
    return successfulTaps / (gameDuration / 1000);
  }
} 