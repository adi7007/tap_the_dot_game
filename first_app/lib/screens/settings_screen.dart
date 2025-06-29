import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../utils/settings_manager.dart';
import '../utils/vibration_manager.dart';
import '../utils/sound_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsManager _settingsManager = SettingsManager();
  final VibrationManager _vibrationManager = VibrationManager();
  final SoundManager _soundManager = SoundManager();
  
  late GameSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = _settingsManager.settings;
    _initializeManagers();
  }

  Future<void> _initializeManagers() async {
    await _vibrationManager.initialize();
    await _soundManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                'Game Mode',
                [
                  _buildGameModeTile(),
                  _buildTimerDurationTile(),
                ],
              ),
              _buildSection(
                'Difficulty',
                [
                  _buildDifficultyTile(),
                ],
              ),
              _buildSection(
                'Customization',
                [
                  _buildDotColorTile(),
                  _buildBackgroundTile(),
                  _buildDotSizeTile(),
                  _buildDotAnimationTile(),
                ],
              ),
              _buildSection(
                'Audio & Haptics',
                [
                  _buildSoundTile(),
                  _buildVibrationTile(),
                ],
              ),
              _buildSection(
                'Reset',
                [
                  _buildResetTile(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGameModeTile() {
    return ListTile(
      title: const Text('Game Mode', style: TextStyle(color: Colors.white)),
      subtitle: Text(
        _getGameModeName(_settings.gameMode),
        style: TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
      onTap: () => _showGameModeDialog(),
    );
  }

  Widget _buildTimerDurationTile() {
    if (_settings.gameMode != GameMode.timer) return const SizedBox.shrink();
    
    return ListTile(
      title: const Text('Timer Duration', style: TextStyle(color: Colors.white)),
      subtitle: Text(
        '${_settings.timerDuration} seconds',
        style: TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
      onTap: () => _showTimerDurationDialog(),
    );
  }

  Widget _buildDifficultyTile() {
    return ListTile(
      title: const Text('Difficulty', style: TextStyle(color: Colors.white)),
      subtitle: Text(
        _getDifficultyName(_settings.difficulty),
        style: TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
      onTap: () => _showDifficultyDialog(),
    );
  }

  Widget _buildDotColorTile() {
    return ListTile(
      title: const Text('Dot Color', style: TextStyle(color: Colors.white)),
      subtitle: Text(
        _getDotColorName(_settings.dotColor),
        style: TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
      onTap: () => _showDotColorDialog(),
    );
  }

  Widget _buildBackgroundTile() {
    return ListTile(
      title: const Text('Background', style: TextStyle(color: Colors.white)),
      subtitle: Text(
        _getBackgroundName(_settings.backgroundColor),
        style: TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
      onTap: () => _showBackgroundDialog(),
    );
  }

  Widget _buildDotSizeTile() {
    return ListTile(
      title: const Text('Dot Size', style: TextStyle(color: Colors.white)),
      subtitle: Text(
        '${_settings.dotSize.round()}',
        style: TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
      onTap: () => _showDotSizeDialog(),
    );
  }

  Widget _buildDotAnimationTile() {
    return ListTile(
      title: const Text('Dot Animation', style: TextStyle(color: Colors.white)),
      subtitle: Text(
        _getAnimationName(_settings.dotAnimation),
        style: TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
      onTap: () => _showAnimationDialog(),
    );
  }

  Widget _buildSoundTile() {
    return SwitchListTile(
      title: const Text('Sound Effects', style: TextStyle(color: Colors.white)),
      subtitle: Text(
        _settings.soundEnabled ? 'On' : 'Off',
        style: TextStyle(color: Colors.white70),
      ),
      value: _settings.soundEnabled,
      onChanged: (value) async {
        await _settingsManager.toggleSound();
        if (!mounted) return;
        setState(() {
          _settings = _settingsManager.settings;
        });
      },
      activeColor: Colors.blue,
    );
  }

  Widget _buildVibrationTile() {
    return SwitchListTile(
      title: const Text('Vibration', style: TextStyle(color: Colors.white)),
      subtitle: Text(
        _settings.vibrationEnabled ? 'On' : 'Off',
        style: TextStyle(color: Colors.white70),
      ),
      value: _settings.vibrationEnabled,
      onChanged: (value) async {
        await _settingsManager.toggleVibration();
        if (!mounted) return;
        setState(() {
          _settings = _settingsManager.settings;
        });
      },
      activeColor: Colors.blue,
    );
  }

  Widget _buildResetTile() {
    return ListTile(
      title: const Text('Reset to Defaults', style: TextStyle(color: Colors.red)),
      leading: const Icon(Icons.restore, color: Colors.red),
      onTap: () => _showResetDialog(),
    );
  }

  // Dialog methods
  void _showGameModeDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Game Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: GameMode.values.map((mode) {
            return ListTile(
              title: Text(_getGameModeName(mode)),
              subtitle: Text(_getGameModeDescription(mode)),
              onTap: () async {
                final navigatorContext = dialogContext;
                await _settingsManager.updateGameMode(mode);
                if (!mounted) return;
                setState(() {
                  _settings = _settingsManager.settings;
                });
                if (navigatorContext.mounted) {
                  Navigator.pop(navigatorContext);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTimerDurationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Timer Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SettingsManager.availableTimerDurations.map((duration) {
            return ListTile(
              title: Text('$duration seconds'),
              onTap: () async {
                final navigatorContext = dialogContext;
                await _settingsManager.updateTimerDuration(duration);
                if (!mounted) return;
                setState(() {
                  _settings = _settingsManager.settings;
                });
                if (navigatorContext.mounted) {
                  Navigator.pop(navigatorContext);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DifficultyLevel.values.map((difficulty) {
            return ListTile(
              title: Text(_getDifficultyName(difficulty)),
              subtitle: Text(_getDifficultyDescription(difficulty)),
              onTap: () async {
                final navigatorContext = dialogContext;
                await _settingsManager.updateDifficulty(difficulty);
                if (!mounted) return;
                setState(() {
                  _settings = _settingsManager.settings;
                });
                if (navigatorContext.mounted) {
                  Navigator.pop(navigatorContext);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDotColorDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Dot Color'),
        content: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2,
          ),
          itemCount: SettingsManager.availableDotColors.length,
          itemBuilder: (context, index) {
            final color = SettingsManager.availableDotColors[index];
            return ListTile(
              title: Text(color['name']),
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(color['color']),
                  shape: BoxShape.circle,
                ),
              ),
              onTap: () async {
                final navigatorContext = dialogContext;
                await _settingsManager.updateDotColor(color['value']);
                if (!mounted) return;
                setState(() {
                  _settings = _settingsManager.settings;
                });
                if (navigatorContext.mounted) {
                  Navigator.pop(navigatorContext);
                }
              },
            );
          },
        ),
      ),
    );
  }

  void _showBackgroundDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Background'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SettingsManager.availableBackgrounds.map((bg) {
            return ListTile(
              title: Text(bg['name']),
              leading: Container(
                width: 40,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(bg['gradient'][0]),
                      Color(bg['gradient'][1]),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onTap: () async {
                final navigatorContext = dialogContext;
                await _settingsManager.updateBackgroundColor(bg['value']);
                if (!mounted) return;
                setState(() {
                  _settings = _settingsManager.settings;
                });
                if (navigatorContext.mounted) {
                  Navigator.pop(navigatorContext);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDotSizeDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Dot Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [60, 70, 80, 90, 100].map((size) {
            return ListTile(
              title: Text('$size'),
              onTap: () async {
                final navigatorContext = dialogContext;
                await _settingsManager.updateDotSize(size.toDouble());
                if (!mounted) return;
                setState(() {
                  _settings = _settingsManager.settings;
                });
                if (navigatorContext.mounted) {
                  Navigator.pop(navigatorContext);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAnimationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Dot Animation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DotAnimation.values.map((animation) {
            return ListTile(
              title: Text(_getAnimationName(animation)),
              subtitle: Text(_getAnimationDescription(animation)),
              onTap: () async {
                final navigatorContext = dialogContext;
                await _settingsManager.updateDotAnimation(animation);
                if (!mounted) return;
                setState(() {
                  _settings = _settingsManager.settings;
                });
                if (navigatorContext.mounted) {
                  Navigator.pop(navigatorContext);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to defaults?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigatorContext = dialogContext;
              await _settingsManager.resetToDefaults();
              if (!mounted) return;
              setState(() {
                _settings = _settingsManager.settings;
              });
              if (navigatorContext.mounted) {
                Navigator.pop(navigatorContext);
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getGameModeName(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return 'Classic';
      case GameMode.timer:
        return 'Timer Mode';
      case GameMode.endless:
        return 'Endless Mode';
    }
  }

  String _getGameModeDescription(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return '30-second challenge';
      case GameMode.timer:
        return 'Custom time limit';
      case GameMode.endless:
        return 'Play until you miss';
    }
  }

  String _getDifficultyName(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  String _getDifficultyDescription(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'Larger dots, slower spawn';
      case DifficultyLevel.medium:
        return 'Balanced challenge';
      case DifficultyLevel.hard:
        return 'Smaller dots, faster spawn';
    }
  }

  String _getDotColorName(String color) {
    final colorData = SettingsManager.availableDotColors
        .firstWhere((c) => c['value'] == color);
    return colorData['name'];
  }

  String _getBackgroundName(String background) {
    final bgData = SettingsManager.availableBackgrounds
        .firstWhere((b) => b['value'] == background);
    return bgData['name'];
  }

  String _getAnimationName(DotAnimation animation) {
    switch (animation) {
      case DotAnimation.none:
        return 'None';
      case DotAnimation.pulse:
        return 'Pulse';
      case DotAnimation.bounce:
        return 'Bounce';
      case DotAnimation.rotate:
        return 'Rotate';
      case DotAnimation.fade:
        return 'Fade';
    }
  }

  String _getAnimationDescription(DotAnimation animation) {
    switch (animation) {
      case DotAnimation.none:
        return 'No animation';
      case DotAnimation.pulse:
        return 'Scale in and out';
      case DotAnimation.bounce:
        return 'Bounce up and down';
      case DotAnimation.rotate:
        return 'Rotate continuously';
      case DotAnimation.fade:
        return 'Fade in and out';
    }
  }
} 