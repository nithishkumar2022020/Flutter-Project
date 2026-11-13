import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_proj_dq/core/utils/citation_parser.dart';
import 'package:my_flutter_proj_dq/data/repositories/rag_stream_repository.dart';
import 'package:my_flutter_proj_dq/presentation/providers/rag_session_provider.dart';

void main() {
  group('RagSessionProvider State & Streaming Tests', () {
    late RagSessionProvider provider;

    setUp(() {
      provider = RagSessionProvider(repository: RagStreamRepository());
    });

    tearDown(() {
      provider.dispose();
    });

    test('submitQuery streams tokens and parses citation badges in real time', () async {
      expect(provider.isStreaming, false);
      expect(provider.streamedAnswer, isEmpty);

      provider.submitQuery('What is RAG?');

      expect(provider.isStreaming, true);
      expect(provider.currentQuery, 'What is RAG?');

      // Wait for stream events to accumulate
      await Future.delayed(const Duration(milliseconds: 700));

      expect(provider.streamedAnswer.isNotEmpty, true);
      expect(provider.citations.isNotEmpty, true);
      expect(provider.parsedSegments.any((s) => s is CitationSegment), true);

      final citation1 = provider.getCitationById(1);
      expect(citation1, isNotNull);
      expect(citation1!.score, greaterThan(0.8));

      // Wait for completion
      await Future.delayed(const Duration(milliseconds: 600));
      expect(provider.isComplete, true);
      expect(provider.isStreaming, false);
    });

    test('cancelActiveStream stops generation immediately', () async {
      provider.submitQuery('Test query');
      expect(provider.isStreaming, true);

      await Future.delayed(const Duration(milliseconds: 200));
      provider.cancelActiveStream();

      expect(provider.isStreaming, false);
    });
  });
}
