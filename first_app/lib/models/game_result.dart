class GameResult {
  final int reactionTime; // Average reaction time in milliseconds
  final int totalTaps; // Total number of taps attempted
  final int successfulTaps; // Number of successful dot taps
  final int level; // Level reached
  final DateTime timestamp; // When the game was played

  GameResult({
    required this.reactionTime,
    required this.totalTaps,
    required this.successfulTaps,
    required this.level,
    required this.timestamp,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'reactionTime': reactionTime,
      'totalTaps': totalTaps,
      'successfulTaps': successfulTaps,
      'level': level,
      'timestamp': timestamp.millisecondsSinceEpoch,
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
    );
  }

  // Calculate accuracy percentage
  double get accuracy {
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
} 