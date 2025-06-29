# Tap the Dot - Speed Challenge

A fast-paced mobile game built with Flutter where players test their reaction time by tapping dots that appear randomly on the screen.

## 🎮 Game Features

- **Random Dot Spawning**: Dots appear at random locations and intervals
- **Reaction Time Tracking**: Measures and displays your reaction time in milliseconds
- **Progressive Difficulty**: Dots get smaller and spawn faster as you level up
- **High Score System**: Stores and displays your top 5 best scores locally
- **Beautiful UI**: Clean, animated interface with smooth transitions
- **Responsive Design**: Works perfectly on both Android and iOS devices

## 🏆 Gameplay

1. **Start Screen**: Tap "Start Game" to begin
2. **Game Screen**: Wait for dots to appear and tap them as quickly as possible
3. **Scoring**: Your reaction time is measured for each successful tap
4. **Leveling**: Every 5 successful taps increases the level and difficulty
5. **Results**: View your performance statistics and see if you achieved a high score
6. **High Scores**: Check your best performances and compete with yourself

## 📱 Screenshots

The game features three main screens:
- **Start Screen**: Welcome screen with game instructions
- **Game Screen**: Main gameplay area with dot spawning and timing
- **Result Screen**: Detailed performance breakdown with play again option
- **High Scores Screen**: Leaderboard of your best performances

## 🛠️ Technical Features

- **Local Storage**: High scores persist using SharedPreferences
- **Smooth Animations**: Elastic animations for dot appearance and UI transitions
- **Responsive Layout**: Adapts to different screen sizes and orientations
- **Clean Architecture**: Well-organized code with separate models, screens, and utilities
- **Error Handling**: Graceful handling of edge cases and data corruption

## 🚀 Installation

1. **Prerequisites**: Make sure you have Flutter installed on your system
2. **Clone/Download**: Get the project files
3. **Dependencies**: Run `flutter pub get` to install dependencies
4. **Run**: Execute `flutter run` to start the game

```bash
flutter pub get
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── game_result.dart      # Game result data model
├── screens/
│   ├── start_screen.dart     # Welcome screen
│   ├── game_screen.dart      # Main gameplay
│   ├── result_screen.dart    # Results display
│   └── high_scores_screen.dart # Leaderboard
└── utils/
    └── high_score_manager.dart # Score persistence logic
```

## 🎯 Game Mechanics

- **Reaction Time**: Measured from dot appearance to tap
- **Accuracy**: Percentage of successful taps vs total taps
- **Leveling**: Automatic difficulty increase every 5 successful taps
- **Scoring**: Based on average reaction time and level reached
- **High Scores**: Top 5 scores sorted by reaction time and level

## 🎨 UI/UX Features

- **Gradient Backgrounds**: Beautiful purple-blue gradients
- **Smooth Transitions**: Page transitions and animations
- **Visual Feedback**: Animated dots with elastic scaling
- **Progress Indicators**: Level and score display during gameplay
- **Responsive Design**: Works on phones and tablets

## 🔧 Dependencies

- `flutter`: Core Flutter framework
- `shared_preferences`: Local data persistence for high scores
- `cupertino_icons`: iOS-style icons

## 📊 Performance

- **Optimized Animations**: 60fps smooth gameplay
- **Efficient State Management**: Minimal rebuilds and memory usage
- **Fast Loading**: Quick app startup and screen transitions

## 🎮 How to Play

1. Launch the app and tap "Start Game"
2. Wait for a dot to appear on the screen
3. Tap the dot as quickly as possible
4. Continue tapping dots as they appear
5. Try to achieve the fastest reaction time
6. Beat your high scores and reach higher levels

## 🏅 Scoring System

- **Primary Metric**: Average reaction time in milliseconds
- **Secondary Metrics**: Level reached, accuracy percentage
- **High Score Criteria**: Lower reaction time is better
- **Tiebreaker**: Higher level wins in case of equal reaction times

## 🔮 Future Enhancements

- Sound effects and background music
- Multiple difficulty modes
- Global leaderboards
- Achievement system
- Custom themes and colors
- Multiplayer mode

## 📄 License

This project is open source and available under the MIT License.

---

**Enjoy playing Tap the Dot - Speed Challenge!** 🎯⚡
