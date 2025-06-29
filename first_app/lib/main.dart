import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/start_screen.dart';
import 'utils/achievement_manager.dart';
import 'utils/settings_manager.dart';
import 'utils/vibration_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize managers
  await AchievementManager().initialize();
  await SettingsManager().initialize();
  await VibrationManager().initialize();
  
  runApp(const TapTheDotGame());
}

class TapTheDotGame extends StatelessWidget {
  const TapTheDotGame({super.key});

  @override
  Widget build(BuildContext context) {
    // Set preferred orientations to portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Tap the Dot - Speed Challenge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const StartScreen(),
    );
  }
}