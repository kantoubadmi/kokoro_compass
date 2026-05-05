import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kokoro_compass/screens/home_screen.dart';
import 'package:kokoro_compass/providers/gratitude_provider.dart';
import 'package:kokoro_compass/providers/meditation_provider.dart';
import 'package:kokoro_compass/providers/happiness_provider.dart';

void main() {
  group('HomeScreen Tests', () {
    testWidgets('HomeScreen displays app title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GratitudeProvider()),
            ChangeNotifierProvider(create: (_) => MeditationProvider()),
            ChangeNotifierProvider(create: (_) => HappinessProvider()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('こころコンパス'), findsOneWidget);
    });

    testWidgets('HomeScreen displays welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GratitudeProvider()),
            ChangeNotifierProvider(create: (_) => MeditationProvider()),
            ChangeNotifierProvider(create: (_) => HappinessProvider()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('今日のあなたへ'), findsOneWidget);
    });

    testWidgets('HomeScreen displays all feature cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GratitudeProvider()),
            ChangeNotifierProvider(create: (_) => MeditationProvider()),
            ChangeNotifierProvider(create: (_) => HappinessProvider()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('感謝日記'), findsOneWidget);
      expect(find.text('瞑想ガイド'), findsOneWidget);
      expect(find.text('幸福度チェック'), findsOneWidget);
      expect(find.text('統計・分析'), findsOneWidget);
    });

    testWidgets('Feature cards have correct descriptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GratitudeProvider()),
            ChangeNotifierProvider(create: (_) => MeditationProvider()),
            ChangeNotifierProvider(create: (_) => HappinessProvider()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('今日の感謝を記録'), findsOneWidget);
      expect(find.text('心を落ち着ける'), findsOneWidget);
      expect(find.text('今の気持ちを記録'), findsOneWidget);
      expect(find.text('心の変化を確認'), findsOneWidget);
    });

    testWidgets('Feature cards display correct icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GratitudeProvider()),
            ChangeNotifierProvider(create: (_) => MeditationProvider()),
            ChangeNotifierProvider(create: (_) => HappinessProvider()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.byIcon(Icons.self_improvement), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.insights), findsOneWidget);
    });
  });
}
