import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/corpus_repository.dart';
import 'data/repositories/mock_telemetry_repository.dart';
import 'data/repositories/profile_settings_repository.dart';
import 'data/repositories/rag_stream_repository.dart';
import 'domain/repositories/i_corpus_repository.dart';
import 'domain/repositories/i_profile_settings_repository.dart';
import 'domain/repositories/i_rag_stream_repository.dart';
import 'domain/repositories/i_telemetry_repository.dart';
import 'firebase_options.dart';
import 'presentation/providers/corpus_provider.dart';
import 'presentation/providers/rag_session_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/telemetry_provider.dart';
import 'presentation/screens/archival_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Graceful initialization fallback for local/offline testing
  }

  final IRagStreamRepository ragStreamRepo = RagStreamRepository();
  final ICorpusRepository corpusRepo = CorpusRepository();
  final ITelemetryRepository telemetryRepo = MockTelemetryRepository();
  final IProfileSettingsRepository settingsRepo = ProfileSettingsRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(repository: settingsRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => RagSessionProvider(repository: ragStreamRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => CorpusProvider(repository: corpusRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => TelemetryProvider(repository: telemetryRepo),
        ),
      ],
      child: const RagApplication(),
    ),
  );
}

class RagApplication extends StatelessWidget {
  const RagApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProv, _) {
        final isDark = settingsProv.isNocturneMode;
        return MaterialApp(
          title: 'Archival RAG Shell',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.buildTheme(isDark),
          home: const ArchivalSplashScreen(),
        );
      },
    );
  }
}
