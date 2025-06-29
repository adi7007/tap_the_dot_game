enum AchievementType {
  taps,
  combo,
  accuracy,
  speed,
  level,
  streak,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final int requirement;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.requirement,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    AchievementType? type,
    int? requirement,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      requirement: requirement ?? this.requirement,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type.index,
      'requirement': requirement,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: AchievementType.values[json['type'] as int],
      requirement: json['requirement'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'] as int)
          : null,
    );
  }

  // Static list of all available achievements
  static List<Achievement> get allAchievements => [
        // Tap achievements
        const Achievement(
          id: 'first_tap',
          title: 'First Tap',
          description: 'Tap your first dot',
          icon: '🎯',
          type: AchievementType.taps,
          requirement: 1,
        ),
        const Achievement(
          id: 'tap_master',
          title: 'Tap Master',
          description: 'Tap 50 dots',
          icon: '🎯',
          type: AchievementType.taps,
          requirement: 50,
        ),
        const Achievement(
          id: 'tap_expert',
          title: 'Tap Expert',
          description: 'Tap 100 dots',
          icon: '🎯',
          type: AchievementType.taps,
          requirement: 100,
        ),
        const Achievement(
          id: 'tap_legend',
          title: 'Tap Legend',
          description: 'Tap 500 dots',
          icon: '🎯',
          type: AchievementType.taps,
          requirement: 500,
        ),

        // Combo achievements
        const Achievement(
          id: 'combo_starter',
          title: 'Combo Starter',
          description: 'Get a 3x combo',
          icon: '🔥',
          type: AchievementType.combo,
          requirement: 3,
        ),
        const Achievement(
          id: 'combo_master',
          title: 'Combo Master',
          description: 'Get a 10x combo',
          icon: '🔥',
          type: AchievementType.combo,
          requirement: 10,
        ),
        const Achievement(
          id: 'combo_legend',
          title: 'Combo Legend',
          description: 'Get a 20x combo',
          icon: '🔥',
          type: AchievementType.combo,
          requirement: 20,
        ),

        // Accuracy achievements
        const Achievement(
          id: 'accurate',
          title: 'Accurate',
          description: 'Achieve 90% accuracy',
          icon: '🎯',
          type: AchievementType.accuracy,
          requirement: 90,
        ),
        const Achievement(
          id: 'perfect',
          title: 'Perfect',
          description: 'Achieve 100% accuracy',
          icon: '🎯',
          type: AchievementType.accuracy,
          requirement: 100,
        ),

        // Speed achievements
        const Achievement(
          id: 'speed_demon',
          title: 'Speed Demon',
          description: 'Average reaction time under 300ms',
          icon: '⚡',
          type: AchievementType.speed,
          requirement: 300,
        ),
        const Achievement(
          id: 'lightning',
          title: 'Lightning',
          description: 'Average reaction time under 200ms',
          icon: '⚡',
          type: AchievementType.speed,
          requirement: 200,
        ),

        // Level achievements
        const Achievement(
          id: 'level_up',
          title: 'Level Up',
          description: 'Reach level 10',
          icon: '📈',
          type: AchievementType.level,
          requirement: 10,
        ),
        const Achievement(
          id: 'high_level',
          title: 'High Level',
          description: 'Reach level 25',
          icon: '📈',
          type: AchievementType.level,
          requirement: 25,
        ),
        const Achievement(
          id: 'max_level',
          title: 'Max Level',
          description: 'Reach level 50',
          icon: '📈',
          type: AchievementType.level,
          requirement: 50,
        ),

        // Streak achievements
        const Achievement(
          id: 'streak_beginner',
          title: 'Streak Beginner',
          description: 'Play 5 games in a row',
          icon: '🔥',
          type: AchievementType.streak,
          requirement: 5,
        ),
        const Achievement(
          id: 'streak_master',
          title: 'Streak Master',
          description: 'Play 10 games in a row',
          icon: '🔥',
          type: AchievementType.streak,
          requirement: 10,
        ),
      ];
} 