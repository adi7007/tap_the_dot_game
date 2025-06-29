// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:tap_the_dot_game/main.dart';

void main() {
  testWidgets('Tap the Dot game smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TapTheDotGame());

    // Verify that the start screen is displayed
    expect(find.text('Tap the Dot'), findsOneWidget);
    expect(find.text('Speed Challenge'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
    expect(find.text('High Scores'), findsOneWidget);
  });
}
