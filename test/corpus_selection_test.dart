import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_proj_dq/data/repositories/mock_corpus_repository.dart';
import 'package:my_flutter_proj_dq/data/repositories/rag_stream_repository.dart';
import 'package:my_flutter_proj_dq/presentation/providers/corpus_provider.dart';
import 'package:my_flutter_proj_dq/presentation/providers/rag_session_provider.dart';
import 'package:my_flutter_proj_dq/presentation/providers/settings_provider.dart';
import 'package:my_flutter_proj_dq/data/repositories/profile_settings_repository.dart';
import 'package:my_flutter_proj_dq/presentation/screens/ingestion_screen.dart';
import 'package:my_flutter_proj_dq/presentation/screens/query_canvas_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CorpusProvider document selection', () {
    test('supports single toggle, drag range selection, selectAll, and clearSelection', () async {
      final provider = CorpusProvider(repository: MockCorpusRepository());
      await provider.loadManifest();
      expect(provider.documents.length, greaterThanOrEqualTo(3));

      final firstId = provider.documents[0].id;
      final secondId = provider.documents[1].id;
      final thirdId = provider.documents[2].id;

      // Single toggle
      provider.toggleSelection(firstId);
      expect(provider.selectedDocumentIds, {firstId});
      expect(provider.isSelected(firstId), true);

      // Drag across index 0 -> 2 selects all 3 items
      provider.applyDragRangeSelection(
        anchorIndex: 0,
        targetIndex: 2,
        baseSelection: const {},
      );
      expect(provider.selectedDocumentIds, {firstId, secondId, thirdId});

      // Reverse drag preserves existing baseSelection
      provider.clearSelection();
      provider.toggleSelection(firstId);
      provider.applyDragRangeSelection(
        anchorIndex: 2,
        targetIndex: 1,
        baseSelection: {firstId},
      );
      expect(provider.selectedDocumentIds, {firstId, secondId, thirdId});

      // Removing a document clears its selection
      await provider.removeDocument(secondId);
      expect(provider.isSelected(secondId), false);
      expect(provider.selectedDocumentIds, {firstId, thirdId});

      provider.clearSelection();
      expect(provider.selectedDocumentIds, isEmpty);
    });
  });

  group('RagStreamRepository document scoping payload', () {
    test('sends no filter for whole DB, document_id for 1 PDF, and document_ids for multiple PDFs', () async {
      final capturedBodies = <Map<String, dynamic>>[];
      final mockClient = MockClient((request) async {
        capturedBodies.add(jsonDecode(request.body) as Map<String, dynamic>);
        return http.Response(
          jsonEncode({'answer': 'Scoped answer.', 'citations': []}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = RagStreamRepository(client: mockClient);

      await repo
          .queryStream('Q1', sseUrl: 'http://localhost:8000/questions', additionalParams: {'documentIds': []})
          .drain<void>();
      await repo
          .queryStream('Q2', sseUrl: 'http://localhost:8000/questions', additionalParams: {'documentIds': ['doc_single']})
          .drain<void>();
      await repo
          .queryStream('Q3', sseUrl: 'http://localhost:8000/questions', additionalParams: {'documentIds': ['doc_a', 'doc_b']})
          .drain<void>();

      expect(capturedBodies[0], {'question': 'Q1'});
      expect(capturedBodies[1], {'question': 'Q2', 'document_id': 'doc_single'});
      expect(capturedBodies[2], {'question': 'Q3', 'document_ids': ['doc_a', 'doc_b']});
    });
  });

  group('Tap and long-press slide selection UI', () {
    testWidgets(
      'tap selects 1 PDF and long-press slide selects range across cards',
      (tester) async {
        final settingsProv = SettingsProvider(repository: ProfileSettingsRepository());
        final corpusProv = CorpusProvider(repository: MockCorpusRepository());

        final capturedBodies = <Map<String, dynamic>>[];
        final mockClient = MockClient((request) async {
          capturedBodies.add(jsonDecode(request.body) as Map<String, dynamic>);
          return http.Response(
            jsonEncode({'answer': 'Answer', 'citations': []}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        var showQuery = false;
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: settingsProv),
              ChangeNotifierProvider.value(value: corpusProv),
              ChangeNotifierProvider(
                create: (_) => RagSessionProvider(repository: RagStreamRepository(client: mockClient)),
              ),
            ],
            child: MaterialApp(
              home: StatefulBuilder(
                builder: (context, setState) {
                  return showQuery
                      ? QueryCanvasScreen(onNavigateToCorpus: () => setState(() => showQuery = false))
                      : IngestionScreen(onNavigateToQuery: () => setState(() => showQuery = true));
                },
              ),
            ),
          ),
        );
        // Pump time to let MockCorpusRepository loadManifest complete
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        final docs = corpusProv.documents;
        expect(docs.length, greaterThanOrEqualTo(3));

        // Single tap selects 1st PDF
        final firstCard = find.byKey(Key('corpus_doc_card_${docs[0].id}'));
        await tester.ensureVisible(firstCard);
        await tester.pumpAndSettle();
        await tester.tap(firstCard);
        await tester.pump();
        expect(corpusProv.selectedDocumentIds, {docs[0].id});
        expect(find.text('RAG SCOPE: 1 PDF SELECTED'), findsOneWidget);

        // Clear, then long-press on 1st card and slide down onto 3rd card
        await tester.tap(find.byKey(const Key('corpus_clear_selection_btn')));
        await tester.pump();
        expect(corpusProv.selectedDocumentIds, isEmpty);

        final thirdCard = find.byKey(Key('corpus_doc_card_${docs[2].id}'));
        await tester.ensureVisible(thirdCard);
        await tester.pumpAndSettle();

        final startPos = tester.getCenter(firstCard);
        final endPos = tester.getCenter(thirdCard);
        final gesture = await tester.startGesture(startPos);
        await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
        await gesture.moveTo(endPos);
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        expect(corpusProv.selectedDocumentIds, {docs[0].id, docs[1].id, docs[2].id});
        expect(find.text('RAG SCOPE: 3 PDFS SELECTED'), findsOneWidget);

        // Navigate to query screen via QUERY button and submit
        await tester.tap(find.byKey(const Key('corpus_ask_selected_btn')));
        await tester.pumpAndSettle();

        expect(find.textContaining('SCOPE: 3 PDFS'), findsOneWidget);
        await tester.enterText(find.byKey(const Key('query_prompt_input')), 'Summarize selected');
        await tester.tap(find.byKey(const Key('query_submit_btn')));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();

        expect(capturedBodies.last['document_ids'], [docs[0].id, docs[1].id, docs[2].id]);

        // Clear scope on Query screen -> resets to whole database
        await tester.tap(find.byKey(const Key('query_scope_clear_btn')));
        await tester.pump();
        expect(find.text('SCOPE: ALL DATABASE'), findsOneWidget);
      },
    );
  });
}
