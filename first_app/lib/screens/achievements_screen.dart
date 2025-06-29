import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../utils/achievement_manager.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  final AchievementManager _achievementManager = AchievementManager();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAchievements();
  }

  Future<void> _initializeAchievements() async {
    await _achievementManager.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unlocked'),
            Tab(text: 'Stats'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAllAchievementsTab(),
            _buildUnlockedAchievementsTab(),
            _buildStatsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllAchievementsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _achievementManager.achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievementManager.achievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildUnlockedAchievementsTab() {
    final unlockedAchievements = _achievementManager.unlockedAchievements;
    if (unlockedAchievements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'No achievements unlocked yet!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white54,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Keep playing to unlock achievements!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: unlockedAchievements.length,
      itemBuilder: (context, index) {
        final achievement = unlockedAchievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatCard(
            'Total Taps',
            _achievementManager.totalTaps.toString(),
            Icons.touch_app,
            Colors.blue,
          ),
          _buildStatCard(
            'Total Games',
            _achievementManager.totalGames.toString(),
            Icons.games,
            Colors.green,
          ),
          _buildStatCard(
            'Current Streak',
            _achievementManager.currentStreak.toString(),
            Icons.local_fire_department,
            Colors.orange,
          ),
          _buildStatCard(
            'Max Streak',
            _achievementManager.maxStreak.toString(),
            Icons.local_fire_department,
            Colors.red,
          ),
          _buildStatCard(
            'Max Combo',
            _achievementManager.maxCombo.toString(),
            Icons.flash_on,
            Colors.yellow,
          ),
          _buildStatCard(
            'Best Accuracy',
            '${_achievementManager.bestAccuracy.toStringAsFixed(1)}%',
            Icons.gps_fixed,
            Colors.purple,
          ),
          _buildStatCard(
            'Best Reaction Time',
            _achievementManager.bestReactionTime > 0
                ? '${_achievementManager.bestReactionTime}ms'
                : 'N/A',
            Icons.speed,
            Colors.teal,
          ),
          _buildStatCard(
            'Highest Level',
            _achievementManager.highestLevel.toString(),
            Icons.trending_up,
            Colors.indigo,
          ),
          const SizedBox(height: 16),
          _buildProgressSection(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final totalAchievements = _achievementManager.achievements.length;
    final unlockedAchievements = _achievementManager.unlockedAchievements.length;
    final progress = totalAchievements > 0 ? unlockedAchievements / totalAchievements : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Achievement Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '$unlockedAchievements / $totalAchievements achievements unlocked',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% complete',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final progress = _achievementManager.getAchievementProgress(achievement);
    final isUnlocked = achievement.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnlocked 
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked 
              ? Colors.amber.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.2),
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUnlocked 
                ? Colors.amber.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            achievement.icon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            decoration: isUnlocked ? TextDecoration.none : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isUnlocked ? Colors.amber : Colors.blue,
              ),
              minHeight: 4,
            ),
            const SizedBox(height: 4),
            Text(
              _getProgressText(achievement, progress),
              style: TextStyle(
                color: Colors.white60,
                fontSize: 10,
              ),
            ),
            if (isUnlocked && achievement.unlockedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Unlocked: ${_formatDate(achievement.unlockedAt!)}',
                style: TextStyle(
                  color: Colors.amber.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
        trailing: isUnlocked
            ? const Icon(
                Icons.check_circle,
                color: Colors.amber,
                size: 24,
              )
            : const Icon(
                Icons.lock_outline,
                color: Colors.white54,
                size: 24,
              ),
      ),
    );
  }

  String _getProgressText(Achievement achievement, double progress) {
    if (progress >= 1.0) return 'Complete!';
    
    switch (achievement.type) {
      case AchievementType.taps:
        final current = _achievementManager.totalTaps;
        return '$current / ${achievement.requirement} taps';
      case AchievementType.combo:
        final current = _achievementManager.maxCombo;
        return '$current / ${achievement.requirement}x combo';
      case AchievementType.accuracy:
        final current = _achievementManager.bestAccuracy;
        return '${current.toStringAsFixed(1)}% / ${achievement.requirement}%';
      case AchievementType.speed:
        final current = _achievementManager.bestReactionTime;
        if (current == 0) return 'No record yet';
        return '${current}ms / ${achievement.requirement}ms';
      case AchievementType.level:
        final current = _achievementManager.highestLevel;
        return 'Level $current / ${achievement.requirement}';
      case AchievementType.streak:
        final current = _achievementManager.maxStreak;
        return '$current / ${achievement.requirement} games';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 