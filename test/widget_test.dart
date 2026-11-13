import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_proj_dq/data/repositories/mock_corpus_repository.dart';
import 'package:my_flutter_proj_dq/data/repositories/mock_telemetry_repository.dart';
import 'package:my_flutter_proj_dq/data/repositories/profile_settings_repository.dart';
import 'package:my_flutter_proj_dq/data/repositories/rag_stream_repository.dart';
import 'package:my_flutter_proj_dq/presentation/providers/corpus_provider.dart';
import 'package:my_flutter_proj_dq/presentation/providers/rag_session_provider.dart';
import 'package:my_flutter_proj_dq/presentation/providers/settings_provider.dart';
import 'package:my_flutter_proj_dq/presentation/providers/telemetry_provider.dart';
import 'package:my_flutter_proj_dq/presentation/screens/chunk_inspector_screen.dart';
import 'package:my_flutter_proj_dq/presentation/screens/clearance_auth_screen.dart';
import 'package:my_flutter_proj_dq/presentation/screens/root_shell_screen.dart';
import 'package:my_flutter_proj_dq/presentation/screens/user_profile_screen.dart';
import 'package:my_flutter_proj_dq/presentation/widgets/citation_badge.dart';

Widget createTestApp({
  Widget? home,
  bool startAuthenticated = true,
  http.Client? httpClient,
}) {
  final settingsRepo = ProfileSettingsRepository();
  final settingsProv = SettingsProvider(repository: settingsRepo);
  if (startAuthenticated) {
    settingsProv.signIn(callSign: 'ARCH-9942', passkey: 'secret');
  }

  final mockHttpClient =
      httpClient ??
      MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 80));
        return http.Response(
          jsonEncode({
            'answer':
                'Neural retrieval uses dense vectors [1] and cross-encoder reranking [2] with sliding context [3].',
            'citations': [
              {'document_id': 'doc_1', 'filename': 'neural_ir.pdf', 'page': 1},
              {'document_id': 'doc_2', 'filename': 'reranking.pdf', 'page': 3},
              {'document_id': 'doc_3', 'filename': 'context.pdf', 'page': 7},
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settingsProv),
      ChangeNotifierProvider(
        create:
            (_) => RagSessionProvider(
              repository: RagStreamRepository(client: mockHttpClient),
            ),
      ),
      ChangeNotifierProvider(
        create: (_) => CorpusProvider(repository: MockCorpusRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => TelemetryProvider(repository: MockTelemetryRepository()),
      ),
    ],
    child: MaterialApp(
      home:
          home ??
          (startAuthenticated
              ? const RootShellScreen()
              : const ClearanceAuthScreen()),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 3 Verification Gateway Tests', () {
    testWidgets(
      '1 & 2: Submitting prompt streams tokens and renders citation badges reactively',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // We start on QueryCanvasView (Page 1)
        expect(find.text('CANVAS STANDBY'), findsOneWidget);

        // Enter query in the prompt text field
        final textField = find.byKey(const Key('query_prompt_input'));
        expect(textField, findsOneWidget);
        await tester.enterText(textField, 'Explain neural retrieval');
        await tester.tap(find.byKey(const Key('query_submit_btn')));

        // Re-pump to start stream
        await tester.pump();
        expect(find.text('STREAMING ACTIVE'), findsOneWidget);
        expect(find.text('ACTIVE PROMPT'), findsOneWidget);
        expect(find.text('Explain neural retrieval'), findsOneWidget);

        // Pump time to receive citations and first token batch
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.text('3 SOURCES'), findsOneWidget);

        // Pump remaining tokens until stream completes
        await tester.pump(const Duration(milliseconds: 1400));
        await tester.pumpAndSettle();

        expect(find.text('SYNTHESIS COMPLETE'), findsOneWidget);
        // Citation badges [1], [2], [3] must render reactively
        expect(find.byType(CitationBadge), findsWidgets);
      },
    );

    testWidgets(
      '3: Tapping citation badge opens evidence bottom sheet with deep inspection',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Submit prompt to generate response and citations
        await tester.enterText(
          find.byKey(const Key('query_prompt_input')),
          'Test query',
        );
        await tester.tap(find.byKey(const Key('query_submit_btn')));
        await tester.pump(const Duration(milliseconds: 1500));
        await tester.pumpAndSettle();

        // Find citation badges
        final badgeFinder = find.byType(CitationBadge);
        expect(badgeFinder, findsWidgets);

        // Scroll to ensure badge is within viewport bounds
        await tester.ensureVisible(badgeFinder.first);
        await tester.pumpAndSettle();

        // Tap the first citation badge
        await tester.tap(badgeFinder.first);
        await tester.pumpAndSettle();

        // Evidence bottom sheet must be open
        expect(find.text('CITATION [1]'), findsOneWidget);

        final inspectAction = find.text('INSPECT CHUNK IN MATRIX');
        expect(inspectAction, findsOneWidget);

        // Tap "Inspect Chunk in Matrix" action
        await tester.tap(inspectAction);
        await tester.pumpAndSettle();

        // Must push ChunkInspectorScreen
        expect(find.byType(ChunkInspectorScreen), findsOneWidget);
        expect(find.text('VECTOR MATRIX INSPECTOR'), findsOneWidget);
      },
    );

    testWidgets(
      '4: Swipe and mini-dock navigation work smoothly across views',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Tap CORPUS tab on mini-dock
        await tester.tap(find.byKey(const Key('minidock_corpus')));
        await tester.pumpAndSettle();
        expect(find.text('CORPUS REPOSITORY'), findsOneWidget);

        // Tap MATRIX tab
        await tester.tap(find.byKey(const Key('minidock_matrix')));
        await tester.pumpAndSettle();
        expect(find.text('VECTOR MATRIX REPOSITORY'), findsOneWidget);

        // Tap DIAG tab
        await tester.tap(find.byKey(const Key('minidock_diag')));
        await tester.pumpAndSettle();
        expect(find.text('TELEMETRY & GRAPH DIAGNOSTICS'), findsOneWidget);

        // Fling back left to MATRIX
        await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
        await tester.pumpAndSettle();
        expect(find.text('VECTOR MATRIX REPOSITORY'), findsOneWidget);
      },
    );

    testWidgets(
      '5: Secondary screens load static mock data cleanly without null-check exceptions',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        final element = tester.element(find.byType(RootShellScreen));
        final settingsProv = Provider.of<SettingsProvider>(
          element,
          listen: false,
        );
        await settingsProv.updateSettings(
          settingsProv.settings.copyWith(useOfflineSimulation: true),
        );
        await tester.pumpAndSettle();

        // Navigate to Corpus screen
        await tester.tap(find.byKey(const Key('minidock_corpus')));
        await tester.pumpAndSettle();
        expect(find.text('Neural IR Foundations'), findsOneWidget);

        // Test Ingestion upload action
        await tester.tap(find.byKey(const Key('corpus_ingest_btn')));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Simulated ingest "demo_corpus_'),
          findsOneWidget,
        );

        // Navigate to Diagnostics screen
        await tester.tap(find.byKey(const Key('minidock_diag')));
        await tester.pumpAndSettle();
        expect(find.text('REAL-TIME RETRIEVAL TELEMETRY'), findsOneWidget);
        expect(find.text('KNOWLEDGE GRAPH TOPOLOGY'), findsOneWidget);

        // Drag to reveal configuration section
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(find.text('PERSIST CONFIGURATION'), findsOneWidget);
      },
    );

    testWidgets(
      '6: Query canvas displays agentic process timeline while loading and failed step on 503',
      (WidgetTester tester) async {
        final failingClient = MockClient((request) async {
          await Future.delayed(const Duration(milliseconds: 120));
          return http.Response(
            jsonEncode({'detail': 'Backend vector index warming up'}),
            503,
            reasonPhrase: 'Service Unavailable',
            headers: {'content-type': 'application/json'},
          );
        });

        await tester.pumpWidget(createTestApp(httpClient: failingClient));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('query_prompt_input')),
          'What is the status?',
        );
        await tester.tap(find.byKey(const Key('query_submit_btn')));
        await tester.pump(const Duration(milliseconds: 20));

        // Live agentic step timeline must be expanded & visible while waiting for backend response
        expect(find.byKey(const Key('process_timeline_card')), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.text('Query parameters prepared'), findsOneWidget);
        expect(find.text('Searching corpus & synthesizing'), findsOneWidget);

        // Let 503 response arrive
        await tester.pumpAndSettle();

        // Timeline marks failure and actionable error card is shown cleanly
        expect(find.text('REQUEST FAILED'), findsOneWidget);
        expect(find.textContaining('PIPELINE HALTED AT'), findsOneWidget);
        expect(find.text('BACKEND REQUEST ERROR'), findsOneWidget);
        expect(find.textContaining('503'), findsWidgets);
        expect(
          find.textContaining('Backend vector index warming up'),
          findsWidgets,
        );
        expect(find.byKey(const Key('query_retry_btn')), findsOneWidget);
      },
    );
  });

  group('Archival Auth & User Profile Tests', () {
    testWidgets(
      'Auth screen toggles Sign In and Sign Up tabs and displays appropriate fields',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(startAuthenticated: false));
        await tester.pumpAndSettle();

        expect(
          find.text('ARCHIVAL CLEARANCE //\nIDENTITY VERIFICATION'),
          findsOneWidget,
        );
        expect(find.byKey(const Key('input_call_sign')), findsOneWidget);
        expect(find.byKey(const Key('input_passkey')), findsOneWidget);
        expect(find.byKey(const Key('input_researcher_name')), findsNothing);

        // Switch to Sign Up tab
        await tester.tap(find.byKey(const Key('auth_tab_signup')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('input_researcher_name')), findsOneWidget);
        expect(
          find.byKey(const Key('dropdown_clearance_level')),
          findsOneWidget,
        );

        // Switch back to Sign In
        await tester.tap(find.byKey(const Key('auth_tab_signin')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('input_researcher_name')), findsNothing);
      },
    );

    testWidgets(
      'Guest bypass logs in observer and routes smoothly to RootShellScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(startAuthenticated: false));
        await tester.pumpAndSettle();

        // Ensure button is visible then tap
        final guestBtn = find.byKey(const Key('auth_guest_btn'));
        await tester.ensureVisible(guestBtn);
        await tester.pumpAndSettle();
        await tester.tap(guestBtn);
        await tester.pumpAndSettle();

        // Should land in workspace RootShellScreen
        expect(find.byType(RootShellScreen), findsOneWidget);
        expect(find.text('CANVAS STANDBY'), findsOneWidget);
      },
    );

    testWidgets(
      'Navigating to UserProfileScreen displays dossier card, quota, and signs out',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(startAuthenticated: true));
        await tester.pumpAndSettle();

        // Tap operator badge in header
        final profileBadge = find.byKey(const Key('header_profile_badge'));
        expect(profileBadge, findsOneWidget);
        await tester.tap(profileBadge);
        await tester.pumpAndSettle();

        // UserProfileScreen is shown
        expect(find.byType(UserProfileScreen), findsOneWidget);
        expect(find.text('FIELD DOSSIER // OPERATOR PROFILE'), findsOneWidget);
        expect(find.text('VECTOR RETRIEVAL QUOTA METER'), findsOneWidget);
        expect(find.text('14,208 / 50,000 Chunks'), findsOneWidget);
        expect(find.text('ASSIGNED LLM ENDPOINT'), findsOneWidget);

        // Scroll to sign out button and tap
        final signOutBtn = find.byKey(const Key('profile_revoke_session_btn'));
        await tester.ensureVisible(signOutBtn);
        await tester.pumpAndSettle();
        await tester.tap(signOutBtn);
        await tester.pumpAndSettle();

        // Routes back to ClearanceAuthScreen
        expect(find.byType(ClearanceAuthScreen), findsOneWidget);
        expect(
          find.text('ARCHIVAL CLEARANCE //\nIDENTITY VERIFICATION'),
          findsOneWidget,
        );
      },
    );
  });
}
