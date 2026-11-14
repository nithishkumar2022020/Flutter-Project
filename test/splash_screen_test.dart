import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_proj_dq/data/repositories/profile_settings_repository.dart';
import 'package:my_flutter_proj_dq/presentation/providers/settings_provider.dart';
import 'package:my_flutter_proj_dq/presentation/screens/archival_splash_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestSplash({
    required SettingsProvider settingsProvider,
    VoidCallback? onComplete,
    Widget? destinationOverride,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return ChangeNotifierProvider.value(
      value: settingsProvider,
      child: MaterialApp(
        home: ArchivalSplashScreen(
          duration: duration,
          destinationOverride: destinationOverride,
          onAnimationComplete: onComplete,
        ),
      ),
    );
  }

  group('ArchivalSplashScreen Typewriter Tests', () {
    testWidgets('renders typewriter terminal and types out SYNQRA and subtitle', (
      tester,
    ) async {
      final settingsProv = SettingsProvider(
        repository: ProfileSettingsRepository(),
      );

      await tester.pumpWidget(
        buildTestSplash(
          settingsProvider: settingsProv,
          duration: const Duration(milliseconds: 2000),
        ),
      );

      // Initial state at 50ms - UI chrome is present
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('ARCHIVAL RAG CORE // DAEMON BOOT'), findsOneWidget);
      expect(find.text('TERM://SYNQRA'), findsOneWidget);
      expect(find.text('BOOT SEQUENCE'), findsOneWidget);
      expect(find.text('SKIP >>'), findsOneWidget);

      // Advance through animation where SYNQRA (0.02 - 0.40) and subtitle (0.38 - 0.82) are fully typed
      await tester.pump(const Duration(milliseconds: 1700));

      expect(find.text('SYNQRA'), findsOneWidget);
      expect(
        find.textContaining('NEURAL RETRIEVAL & ATTRIBUTION CANVAS'),
        findsOneWidget,
      );
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('advancing past duration completes animation callback', (
      tester,
    ) async {
      var completed = false;
      final settingsProv = SettingsProvider(
        repository: ProfileSettingsRepository(),
      );

      await tester.pumpWidget(
        buildTestSplash(
          settingsProvider: settingsProv,
          duration: const Duration(milliseconds: 500),
          onComplete: () => completed = true,
        ),
      );

      // Initially at 50ms
      await tester.pump(const Duration(milliseconds: 50));
      expect(completed, false);

      // Advance past duration to complete
      await tester.pump(const Duration(milliseconds: 600));
      expect(completed, true);
    });

    testWidgets('tapping screen skips animation immediately', (tester) async {
      var completed = false;
      final settingsProv = SettingsProvider(
        repository: ProfileSettingsRepository(),
      );

      await tester.pumpWidget(
        buildTestSplash(
          settingsProvider: settingsProv,
          duration: const Duration(milliseconds: 3000),
          onComplete: () => completed = true,
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(completed, false);

      // Tap screen to skip
      await tester.tap(find.byType(ArchivalSplashScreen));
      await tester.pump();
      expect(completed, true);
    });
  });
}
