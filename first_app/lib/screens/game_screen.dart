import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/high_score_manager.dart';
import '../utils/sound_manager.dart';
import '../utils/theme_manager.dart';
import '../utils/vibration_manager.dart';
import '../utils/achievement_manager.dart';
import '../utils/settings_manager.dart';
import '../models/game_result.dart';
import '../models/game_settings.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  // Game state
  bool _isGameStarted = false;
  bool _isDotVisible = false;
  bool _isWaitingForDot = false;
  int _currentReactionTime = 0;
  int _totalTaps = 0;
  int _successfulTaps = 0;
  int _currentLevel = 1;
  int _currentCombo = 0;
  int _maxCombo = 0;
  int _totalScore = 0;
  int _gameStartTime = 0;
  int _remainingTime = 0;
  
  // Timing
  late Stopwatch _reactionTimer;
  Timer? _dotSpawnTimer;
  Timer? _gameTimer;
  Timer? _countdownTimer;
  
  // Dot properties
  double _dotSize = 80.0;
  double _dotX = 0.0;
  double _dotY = 0.0;
  
  // Animation
  late AnimationController _dotAnimationController;
  late Animation<double> _dotScaleAnimation;
  late Animation<double> _dotOpacityAnimation;
  late AnimationController _glowAnimationController;
  late Animation<double> _glowAnimation;
  late AnimationController _comboAnimationController;
  late Animation<double> _comboScaleAnimation;
  
  // UI
  late AnimationController _uiAnimationController;
  late Animation<double> _uiFadeAnimation;

  // Managers
  final SoundManager _soundManager = SoundManager();
  final ThemeManager _themeManager = ThemeManager();
  final VibrationManager _vibrationManager = VibrationManager();
  final AchievementManager _achievementManager = AchievementManager();
  final SettingsManager _settingsManager = SettingsManager();
  
  late GameSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = _settingsManager.settings;
    _reactionTimer = Stopwatch();
    _initializeManagers();
    _setupAnimations();
  }

  Future<void> _initializeManagers() async {
    await _soundManager.initialize();
    await _vibrationManager.initialize();
  }

  void _setupAnimations() {
    // Dot animation
    _dotAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _dotScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dotAnimationController,
      curve: Curves.elasticOut,
    ));
    _dotOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dotAnimationController,
      curve: Curves.easeIn,
    ));
    
    // Glow animation for dot
    _glowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Combo animation
    _comboAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _comboScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _comboAnimationController,
      curve: Curves.elasticOut,
    ));
    
    // UI animation
    _uiAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _uiFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _uiAnimationController,
      curve: Curves.easeIn,
    ));
    
    _uiAnimationController.forward();
  }

  @override
  void dispose() {
    _dotAnimationController.dispose();
    _glowAnimationController.dispose();
    _comboAnimationController.dispose();
    _uiAnimationController.dispose();
    _dotSpawnTimer?.cancel();
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
    _soundManager.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isGameStarted = true;
      _isWaitingForDot = true;
      _totalTaps = 0;
      _successfulTaps = 0;
      _currentLevel = 1;
      _currentCombo = 0;
      _maxCombo = 0;
      _totalScore = 0;
      _dotSize = _settings.difficultyDotSize;
      _gameStartTime = DateTime.now().millisecondsSinceEpoch;
    });
    
    _scheduleNextDot();
    _startGameTimer();
  }

  void _scheduleNextDot() {
    if (!_isGameStarted) return;
    
    int minDelay = _settings.minSpawnDelay;
    int maxDelay = _settings.maxSpawnDelay;
    
    // Adjust based on level
    if (_currentLevel > 5) {
      minDelay = max(300, minDelay - (_currentLevel - 5) * 50);
      maxDelay = max(800, maxDelay - (_currentLevel - 5) * 50);
    }
    
    int delay = Random().nextInt(maxDelay - minDelay) + minDelay;
    
    _dotSpawnTimer = Timer(Duration(milliseconds: delay), () {
      if (_isGameStarted) {
        _spawnDot();
      }
    });
  }

  void _spawnDot() {
    if (!_isGameStarted) return;
    
    final random = Random();
    final size = MediaQuery.of(context).size;
    
    // Calculate safe area for dot placement
    double maxX = size.width - _dotSize;
    double maxY = size.height - _dotSize - 200; // Account for UI elements
    
    setState(() {
      _dotX = random.nextDouble() * maxX;
      _dotY = random.nextDouble() * maxY + 100; // Start below top UI
      _isDotVisible = true;
      _isWaitingForDot = false;
    });
    
    _reactionTimer.start();
    _dotAnimationController.forward();
    _glowAnimationController.repeat(reverse: true);
    
    // Play spawn sound
    if (_settings.soundEnabled) {
      _soundManager.playDotSpawn();
    }
  }

  void _onDotTap() {
    if (!_isDotVisible) return;
    
    _reactionTimer.stop();
    _currentReactionTime = _reactionTimer.elapsedMilliseconds;
    
    // Calculate score with combo multiplier
    int baseScore = 100;
    int comboMultiplier = _currentCombo > 0 ? _currentCombo : 1;
    int score = baseScore * comboMultiplier;
    
    setState(() {
      _isDotVisible = false;
      _totalTaps++;
      _successfulTaps++;
      _currentCombo++;
      _maxCombo = max(_maxCombo, _currentCombo);
      _totalScore += score;
    });
    
    // Play tap sound and vibrate
    if (_settings.soundEnabled) {
      _soundManager.playDotTap();
    }
    if (_settings.vibrationEnabled) {
      _vibrationManager.vibrateSuccess();
    }
    
    // Show combo animation
    if (_currentCombo > 1) {
      _comboAnimationController.forward().then((_) {
        _comboAnimationController.reverse();
      });
      if (_settings.vibrationEnabled) {
        _vibrationManager.vibrateCombo(_currentCombo);
      }
    }
    
    _dotAnimationController.reverse().then((_) {
      _reactionTimer.reset();
      _isWaitingForDot = true;
      _scheduleNextDot();
    });
    
    // Enhanced leveling system
    _updateLevel();
  }

  void _onMissedTap() {
    setState(() {
      _totalTaps++;
      _currentCombo = 0; // Reset combo on miss
    });
    
    if (_settings.vibrationEnabled) {
      _vibrationManager.vibrateMiss();
    }
  }

  void _updateLevel() {
    int newLevel = _currentLevel;
    double newDotSize = _dotSize;
    
    // Level up every 3 successful taps
    if (_successfulTaps % 3 == 0) {
      newLevel++;
      newDotSize = max(25.0, _dotSize - 5.0);
    }
    
    // Additional size reduction every 10 taps
    if (_successfulTaps % 10 == 0) {
      newDotSize = max(20.0, newDotSize - 3.0);
    }
    
    if (newLevel != _currentLevel || newDotSize != _dotSize) {
      setState(() {
        _currentLevel = newLevel;
        _dotSize = newDotSize;
      });
    }
  }

  void _startGameTimer() {
    int gameDuration;
    
    switch (_settings.gameMode) {
      case GameMode.classic:
        gameDuration = 30000; // 30 seconds
        break;
      case GameMode.timer:
        gameDuration = _settings.timerDuration * 1000;
        break;
      case GameMode.endless:
        gameDuration = -1; // No time limit
        break;
    }
    
    if (gameDuration > 0) {
      _remainingTime = gameDuration;
      _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_remainingTime > 0) {
          setState(() {
            _remainingTime -= 100;
          });
        } else {
          timer.cancel();
          _endGame();
        }
      });
    }
  }

  void _endGame() {
    setState(() {
      _isGameStarted = false;
      _isDotVisible = false;
      _isWaitingForDot = false;
    });
    
    _dotSpawnTimer?.cancel();
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
    _glowAnimationController.stop();
    
    if (_settings.vibrationEnabled) {
      _vibrationManager.vibrateGameEnd();
    }
    
    // Calculate game duration
    int gameDuration = DateTime.now().millisecondsSinceEpoch - _gameStartTime;
    
    // Calculate average reaction time
    double averageReactionTime = _successfulTaps > 0 
        ? _currentReactionTime / _successfulTaps 
        : 0.0;
    
    // Calculate accuracy
    double accuracy = _totalTaps > 0 ? (_successfulTaps / _totalTaps) * 100 : 0.0;
    
    // Save high score
    final gameResult = GameResult(
      reactionTime: averageReactionTime.round(),
      totalTaps: _totalTaps,
      successfulTaps: _successfulTaps,
      level: _currentLevel,
      timestamp: DateTime.now(),
      maxCombo: _maxCombo,
      totalScore: _totalScore,
      gameDuration: gameDuration,
      difficulty: _settings.difficulty.toString().split('.').last,
      gameMode: _settings.gameMode.toString().split('.').last,
      accuracy: accuracy,
    );
    
    HighScoreManager().saveScore(gameResult);
    _achievementManager.updateStats(gameResult);
    
    // Navigate to result screen
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ResultScreen(gameResult: gameResult),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Color _getDotColor() {
    final colorData = SettingsManager.availableDotColors
        .firstWhere((c) => c['value'] == _settings.dotColor);
    return Color(colorData['color']);
  }

  Widget _buildAnimatedDot() {
    Widget dot = Container(
      width: _dotSize,
      height: _dotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getDotColor(),
        boxShadow: [
          BoxShadow(
            color: _getDotColor().withValues(alpha: 0.6 * _glowAnimation.value),
            blurRadius: 20 * _glowAnimation.value,
            spreadRadius: 5 * _glowAnimation.value,
          ),
        ],
      ),
      child: Icon(
        Icons.circle,
        color: Colors.white,
        size: _dotSize * 0.7,
      ),
    );

    // Apply custom animations based on settings
    switch (_settings.dotAnimation) {
      case DotAnimation.pulse:
        dot = dot.animate(onPlay: (controller) => controller.repeat())
            .scale(duration: 1.seconds, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2))
            .then()
            .scale(duration: 1.seconds, begin: const Offset(1.2, 1.2), end: const Offset(0.8, 0.8));
        break;
      case DotAnimation.bounce:
        dot = dot.animate(onPlay: (controller) => controller.repeat())
            .moveY(duration: 1.seconds, begin: 0, end: -10)
            .then()
            .moveY(duration: 1.seconds, begin: -10, end: 0);
        break;
      case DotAnimation.rotate:
        dot = dot.animate(onPlay: (controller) => controller.repeat())
            .rotate(duration: 2.seconds, begin: 0, end: 1);
        break;
      case DotAnimation.fade:
        dot = dot.animate(onPlay: (controller) => controller.repeat())
            .fadeIn(duration: 1.seconds)
            .then()
            .fadeOut(duration: 1.seconds);
        break;
      case DotAnimation.none:
        break;
    }

    return dot;
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
              // Top UI
              FadeTransition(
                opacity: _uiFadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Timer (for timer mode)
                      if (_settings.gameMode == GameMode.timer && _isGameStarted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(_remainingTime / 1000).ceil()}s',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Level indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _themeManager.getLevelColor(_currentLevel).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _themeManager.getLevelColor(_currentLevel).withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  color: _themeManager.getLevelColor(_currentLevel),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Level $_currentLevel',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Score indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.primaryColor.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.score,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$_totalScore',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Combo indicator
                          if (_currentCombo > 1)
                            ScaleTransition(
                              scale: _comboScaleAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.flash_on,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_currentCombo}x',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Accuracy indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.gps_fixed,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_successfulTaps/$_totalTaps (${_totalTaps > 0 ? (_successfulTaps / _totalTaps * 100).toStringAsFixed(1) : "0.0"}%)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Game area
              Expanded(
                child: GestureDetector(
                  onTapDown: (details) {
                    if (_isGameStarted) {
                      if (_isDotVisible) {
                        _onDotTap();
                      } else {
                        _onMissedTap();
                      }
                    }
                  },
                  child: SizedBox(
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // Animated background pattern
                        Positioned.fill(
                          child: CustomPaint(
                            painter: AnimatedBackgroundPainter(
                              theme: theme,
                              animation: _uiAnimationController,
                            ),
                          ),
                        ),
                        
                        // Dot with glow effect
                        if (_isDotVisible)
                          Positioned(
                            left: _dotX,
                            top: _dotY,
                            child: AnimatedBuilder(
                              animation: _dotAnimationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _dotScaleAnimation.value,
                                  child: Opacity(
                                    opacity: _dotOpacityAnimation.value,
                                    child: AnimatedBuilder(
                                      animation: _glowAnimation,
                                      builder: (context, child) {
                                        return _buildAnimatedDot();
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        
                        // Waiting message with animation
                        if (_isWaitingForDot && _isGameStarted)
                          Center(
                            child: AnimatedBuilder(
                              animation: _uiAnimationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 0.8 + (0.2 * _uiAnimationController.value),
                                  child: Text(
                                    'Get Ready...',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(2, 2),
                                          blurRadius: 4,
                                          color: Colors.black.withValues(alpha: 0.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        
                        // Start game message
                        if (!_isGameStarted)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Tap to Start',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(2, 2),
                                        blurRadius: 4,
                                        color: Colors.black.withValues(alpha: 0.3),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _startGame,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: theme.primaryColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 8,
                                    shadowColor: Colors.black.withValues(alpha: 0.3),
                                  ),
                                  child: const Text(
                                    'Start Game',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced background painter with animation
class AnimatedBackgroundPainter extends CustomPainter {
  final GameTheme theme;
  final Animation<double> animation;

  AnimatedBackgroundPainter({
    required this.theme,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;
    
    // Animated grid pattern
    final offset = animation.value * 50;
    
    for (double i = offset; i < size.width + 50; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = offset; i < size.height + 50; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 