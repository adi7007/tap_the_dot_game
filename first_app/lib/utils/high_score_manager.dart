import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_result.dart';

class HighScoreManager {
  static const String _highScoresKey = 'high_scores';
  static const int _maxScores = 5;

  // Save a new score
  Future<void> saveScore(GameResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final scores = await getHighScores();
    
    // Add new score
    scores.add(result);
    
    // Sort by reaction time (lower is better) and then by level (higher is better)
    scores.sort((a, b) {
      if (a.reactionTime != b.reactionTime) {
        return a.reactionTime.compareTo(b.reactionTime);
      }
      return b.level.compareTo(a.level);
    });
    
    // Keep only top scores
    if (scores.length > _maxScores) {
      scores.removeRange(_maxScores, scores.length);
    }
    
    // Save to SharedPreferences
    final scoresJson = scores.map((score) => score.toJson()).toList();
    await prefs.setString(_highScoresKey, jsonEncode(scoresJson));
  }

  // Get all high scores
  Future<List<GameResult>> getHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scoresString = prefs.getString(_highScoresKey);
    
    if (scoresString == null || scoresString.isEmpty) {
      return [];
    }
    
    try {
      final scoresJson = jsonDecode(scoresString) as List;
      return scoresJson
          .map((json) => GameResult.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  // Clear all high scores
  Future<void> clearHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_highScoresKey);
  }

  // Check if a score is a high score
  Future<bool> isHighScore(GameResult result) async {
    final scores = await getHighScores();
    
    if (scores.length < _maxScores) {
      return true;
    }
    
    // Check if this score is better than the worst high score
    final worstScore = scores.last;
    if (result.reactionTime < worstScore.reactionTime) {
      return true;
    }
    
    if (result.reactionTime == worstScore.reactionTime && result.level > worstScore.level) {
      return true;
    }
    
    return false;
  }

  // Get the best score
  Future<GameResult?> getBestScore() async {
    final scores = await getHighScores();
    return scores.isNotEmpty ? scores.first : null;
  }

  // Get average reaction time from all scores
  Future<double> getAverageReactionTime() async {
    final scores = await getHighScores();
    if (scores.isEmpty) return 0.0;
    
    final total = scores.fold<int>(0, (sum, score) => sum + score.reactionTime);
    return total / scores.length;
  }
} 