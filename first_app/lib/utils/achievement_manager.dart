import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/game_result.dart';

class AchievementManager {
  static const String _achievementsKey = 'achievements';
  static const String _statsKey = 'player_stats';
  
  static final AchievementManager _instance = AchievementManager._internal();
  factory AchievementManager() => _instance;
  AchievementManager._internal();

  List<Achievement> _achievements = [];
  Map<String, int> _playerStats = {};

  // Player statistics
  int get totalTaps => _playerStats['total_taps'] ?? 0;
  int get totalGames => _playerStats['total_games'] ?? 0;
  int get currentStreak => _playerStats['current_streak'] ?? 0;
  int get maxStreak => _playerStats['max_streak'] ?? 0;
  int get maxCombo => _playerStats['max_combo'] ?? 0;
  double get bestAccuracy => _playerStats['best_accuracy']?.toDouble() ?? 0.0;
  int get bestReactionTime => _playerStats['best_reaction_time'] ?? 0;
  int get highestLevel => _playerStats['highest_level'] ?? 0;

  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements => 
      _achievements.where((a) => a.isUnlocked).toList();
  List<Achievement> get lockedAchievements => 
      _achievements.where((a) => !a.isUnlocked).toList();

  Future<void> initialize() async {
    await _loadAchievements();
    await _loadPlayerStats();
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_achievementsKey);
    
    if (achievementsJson != null) {
      final List<dynamic> achievementsList = json.decode(achievementsJson);
      _achievements = achievementsList
          .map((json) => Achievement.fromJson(json))
          .toList();
    } else {
      // Initialize with default achievements
      _achievements = Achievement.allAchievements;
      await _saveAchievements();
    }
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = json.encode(
      _achievements.map((a) => a.toJson()).toList(),
    );
    await prefs.setString(_achievementsKey, achievementsJson);
  }

  Future<void> _loadPlayerStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);
    
    if (statsJson != null) {
      _playerStats = Map<String, int>.from(json.decode(statsJson));
    } else {
      _playerStats = {};
    }
  }

  Future<void> _savePlayerStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = json.encode(_playerStats);
    await prefs.setString(_statsKey, statsJson);
  }

  Future<void> updateStats(GameResult gameResult) async {
    // Update basic stats
    _playerStats['total_taps'] = totalTaps + gameResult.successfulTaps;
    _playerStats['total_games'] = totalGames + 1;
    
    // Update streak
    final now = DateTime.now();
    final lastGameDate = _playerStats['last_game_date'] != null
        ? DateTime.fromMillisecondsSinceEpoch(_playerStats['last_game_date']!)
        : null;
    
    if (lastGameDate != null && 
        now.difference(lastGameDate).inDays <= 1) {
      _playerStats['current_streak'] = currentStreak + 1;
    } else {
      _playerStats['current_streak'] = 1;
    }
    
    _playerStats['last_game_date'] = now.millisecondsSinceEpoch;
    _playerStats['max_streak'] = max(_playerStats['max_streak'] ?? 0, 
                                   _playerStats['current_streak'] ?? 0);
    
    // Update other stats
    _playerStats['max_combo'] = max(maxCombo, gameResult.maxCombo);
    _playerStats['best_accuracy'] = max(bestAccuracy.round(), 
                                       gameResult.accuracy.round());
    
    if (gameResult.reactionTime > 0 && 
        (bestReactionTime == 0 || gameResult.reactionTime < bestReactionTime)) {
      _playerStats['best_reaction_time'] = gameResult.reactionTime;
    }
    
    _playerStats['highest_level'] = max(highestLevel, gameResult.level);
    
    await _savePlayerStats();
    await _checkAchievements();
  }

  Future<void> _checkAchievements() async {
    bool hasNewAchievements = false;
    
    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      if (achievement.isUnlocked) continue;
      
      bool shouldUnlock = false;
      
      switch (achievement.type) {
        case AchievementType.taps:
          shouldUnlock = totalTaps >= achievement.requirement;
          break;
        case AchievementType.combo:
          shouldUnlock = maxCombo >= achievement.requirement;
          break;
        case AchievementType.accuracy:
          shouldUnlock = bestAccuracy >= achievement.requirement;
          break;
        case AchievementType.speed:
          shouldUnlock = bestReactionTime > 0 && 
                        bestReactionTime <= achievement.requirement;
          break;
        case AchievementType.level:
          shouldUnlock = highestLevel >= achievement.requirement;
          break;
        case AchievementType.streak:
          shouldUnlock = maxStreak >= achievement.requirement;
          break;
      }
      
      if (shouldUnlock) {
        _achievements[i] = achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        hasNewAchievements = true;
      }
    }
    
    if (hasNewAchievements) {
      await _saveAchievements();
    }
  }

  Future<void> resetAchievements() async {
    _achievements = Achievement.allAchievements;
    await _saveAchievements();
  }

  Future<void> resetStats() async {
    _playerStats = {};
    await _savePlayerStats();
  }

  // Get achievement progress for a specific achievement
  double getAchievementProgress(Achievement achievement) {
    switch (achievement.type) {
      case AchievementType.taps:
        return (totalTaps / achievement.requirement).clamp(0.0, 1.0);
      case AchievementType.combo:
        return (maxCombo / achievement.requirement).clamp(0.0, 1.0);
      case AchievementType.accuracy:
        return (bestAccuracy / achievement.requirement).clamp(0.0, 1.0);
      case AchievementType.speed:
        if (bestReactionTime == 0) return 0.0;
        return (achievement.requirement / bestReactionTime).clamp(0.0, 1.0);
      case AchievementType.level:
        return (highestLevel / achievement.requirement).clamp(0.0, 1.0);
      case AchievementType.streak:
        return (maxStreak / achievement.requirement).clamp(0.0, 1.0);
    }
  }

  // Get recently unlocked achievements
  List<Achievement> getRecentlyUnlocked({int count = 5}) {
    final unlocked = unlockedAchievements;
    unlocked.sort((a, b) => (b.unlockedAt ?? DateTime(1900))
        .compareTo(a.unlockedAt ?? DateTime(1900)));
    return unlocked.take(count).toList();
  }
} 