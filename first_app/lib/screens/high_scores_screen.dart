import 'package:flutter/material.dart';
import '../models/game_result.dart';
import '../utils/high_score_manager.dart';
import '../utils/theme_manager.dart';

class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({super.key});

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen>
    with TickerProviderStateMixin {
  List<GameResult> _highScores = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final ThemeManager _themeManager = ThemeManager();

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _loadHighScores();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadHighScores() async {
    final scores = await HighScoreManager().getHighScores();
    setState(() {
      _highScores = scores;
      _isLoading = false;
    });
    _animationController.forward();
  }

  Future<void> _clearHighScores() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear High Scores'),
        content: const Text('Are you sure you want to clear all high scores? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HighScoreManager().clearHighScores();
      setState(() {
        _highScores.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeManager.currentTheme;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced Header
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.textColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.textColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: theme.textColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'High Scores',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _clearHighScores,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: theme.textColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading scores...',
                              style: TextStyle(
                                color: theme.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _highScores.isEmpty
                        ? _buildEmptyState(theme)
                        : _buildHighScoresList(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(GameTheme theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.textColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.textColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                size: 60,
                color: theme.textColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No High Scores Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Play a game to set your first high score!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.textColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Tap the dot as fast as you can!',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighScoresList(GameTheme theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _highScores.length,
        itemBuilder: (context, index) {
          final score = _highScores[index];
          final isTopScore = index == 0;
          
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final delay = index * 0.1;
              final animationValue = (_animationController.value - delay).clamp(0.0, 1.0);
              
              return Transform.translate(
                offset: Offset(0, 50 * (1 - animationValue)),
                child: Opacity(
                  opacity: animationValue,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: _buildScoreCard(score, index + 1, isTopScore, theme),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildScoreCard(GameResult score, int rank, bool isTopScore, GameTheme theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.textColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: isTopScore
            ? Border.all(
                color: theme.accentColor,
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          // Enhanced Rank indicator
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isTopScore 
                  ? theme.accentColor 
                  : _themeManager.getLevelColor(rank).withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: isTopScore 
                    ? theme.accentColor 
                    : _themeManager.getLevelColor(rank).withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: isTopScore
                  ? Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 24,
                    )
                  : Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isTopScore ? Colors.white : _themeManager.getLevelColor(rank),
                      ),
                    ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Enhanced Score details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${score.reactionTime}ms',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    if (isTopScore) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.accentColor,
                              theme.accentColor.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'BEST',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: _themeManager.getLevelColor(score.level),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Level ${score.level}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _themeManager.getLevelColor(score.level),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.center_focus_strong,
                      color: theme.accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${score.accuracy.toStringAsFixed(1)}% accuracy',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Colors.grey[600],
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${score.successfulTaps}/${score.totalTaps} taps',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.schedule,
                      color: Colors.grey[600],
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      score.formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Enhanced Trophy icon for top 3
          if (rank <= 3)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: rank == 1 
                    ? theme.accentColor.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                rank == 1 ? Icons.emoji_events : Icons.workspace_premium,
                color: rank == 1 ? theme.accentColor : Colors.grey[400],
                size: 24,
              ),
            ),
        ],
      ),
    );
  }
} 