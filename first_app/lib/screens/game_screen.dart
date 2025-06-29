import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/high_score_manager.dart';
import '../utils/sound_manager.dart';
import '../utils/theme_manager.dart';
import '../models/game_result.dart';
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
  
  // Timing
  late Stopwatch _reactionTimer;
  Timer? _dotSpawnTimer;
  Timer? _gameTimer;
  final int _gameDuration = 30000; // 30 seconds
  
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
  
  // UI
  late AnimationController _uiAnimationController;
  late Animation<double> _uiFadeAnimation;

  // Managers
  final SoundManager _soundManager = SoundManager();
  final ThemeManager _themeManager = ThemeManager();

  @override
  void initState() {
    super.initState();
    _reactionTimer = Stopwatch();
    _soundManager.initialize();
    
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
    _uiAnimationController.dispose();
    _dotSpawnTimer?.cancel();
    _gameTimer?.cancel();
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
      _dotSize = 80.0;
    });
    
    _scheduleNextDot();
    _startGameTimer();
  }

  void _scheduleNextDot() {
    if (!_isGameStarted) return;
    
    // Enhanced difficulty scaling
    int minDelay = _calculateMinDelay();
    int maxDelay = _calculateMaxDelay();
    int delay = Random().nextInt(maxDelay - minDelay) + minDelay;
    
    _dotSpawnTimer = Timer(Duration(milliseconds: delay), () {
      if (_isGameStarted) {
        _spawnDot();
      }
    });
  }

  int _calculateMinDelay() {
    // More aggressive scaling
    if (_currentLevel <= 5) return max(800, 2500 - (_currentLevel * 200));
    if (_currentLevel <= 10) return max(500, 1500 - ((_currentLevel - 5) * 100));
    if (_currentLevel <= 15) return max(300, 1000 - ((_currentLevel - 10) * 50));
    return max(200, 750 - ((_currentLevel - 15) * 25));
  }

  int _calculateMaxDelay() {
    // More aggressive scaling
    if (_currentLevel <= 5) return max(1200, 3500 - (_currentLevel * 200));
    if (_currentLevel <= 10) return max(800, 2000 - ((_currentLevel - 5) * 100));
    if (_currentLevel <= 15) return max(500, 1300 - ((_currentLevel - 10) * 50));
    return max(300, 1000 - ((_currentLevel - 15) * 25));
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
    _soundManager.playDotSpawn();
  }

  void _onDotTap() {
    if (!_isDotVisible) return;
    
    _reactionTimer.stop();
    _currentReactionTime = _reactionTimer.elapsedMilliseconds;
    
    setState(() {
      _isDotVisible = false;
      _totalTaps++;
      _successfulTaps++;
    });
    
    // Play tap sound
    _soundManager.playDotTap();
    
    _dotAnimationController.reverse().then((_) {
      _reactionTimer.reset();
      _isWaitingForDot = true;
      _scheduleNextDot();
    });
    
    // Enhanced leveling system
    _updateLevel();
  }

  void _updateLevel() {
    int newLevel = _currentLevel;
    double newDotSize = _dotSize;
    
    // Level up every 3 successful taps (more frequent)
    if (_successfulTaps % 3 == 0) {
      newLevel++;
      // More aggressive size reduction
      newDotSize = max(25.0, _dotSize - 8.0);
    }
    
    // Additional size reduction every 10 taps
    if (_successfulTaps % 10 == 0) {
      newDotSize = max(20.0, newDotSize - 5.0);
    }
    
    if (newLevel != _currentLevel || newDotSize != _dotSize) {
      setState(() {
        _currentLevel = newLevel;
        _dotSize = newDotSize;
      });
    }
  }

  void _onMissedTap() {
    setState(() {
      _totalTaps++;
    });
  }

  void _startGameTimer() {
    _gameTimer = Timer(Duration(milliseconds: _gameDuration), () {
      _endGame();
    });
  }

  void _endGame() {
    setState(() {
      _isGameStarted = false;
      _isDotVisible = false;
      _isWaitingForDot = false;
    });
    
    _dotSpawnTimer?.cancel();
    _gameTimer?.cancel();
    _glowAnimationController.stop();
    
    // Calculate average reaction time
    double averageReactionTime = _successfulTaps > 0 
        ? _currentReactionTime / _successfulTaps 
        : 0.0;
    
    // Save high score
    final gameResult = GameResult(
      reactionTime: averageReactionTime.round(),
      totalTaps: _totalTaps,
      successfulTaps: _successfulTaps,
      level: _currentLevel,
      timestamp: DateTime.now(),
    );
    
    HighScoreManager().saveScore(gameResult);
    
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Level indicator with theme color
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
                              style: TextStyle(
                                color: theme.textColor,
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
                            Icon(
                              Icons.score,
                              color: theme.primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_successfulTaps/$_totalTaps',
                              style: TextStyle(
                                color: theme.textColor,
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
                                        return Container(
                                          width: _dotSize,
                                          height: _dotSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _themeManager.getDotColor(_currentLevel),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _themeManager.getDotColor(_currentLevel).withValues(alpha: 0.6 * _glowAnimation.value),
                                                blurRadius: 20 * _glowAnimation.value,
                                                spreadRadius: 5 * _glowAnimation.value,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.circle,
                                            color: theme.textColor,
                                            size: _dotSize * 0.7,
                                          ),
                                        );
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
                                      color: theme.textColor,
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
                                    color: theme.textColor,
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
                                    backgroundColor: theme.textColor,
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
      ..color = theme.textColor.withValues(alpha: 0.05)
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