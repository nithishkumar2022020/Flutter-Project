import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_proj_dq/core/utils/citation_parser.dart';

void main() {
  group('CitationParser Unit Tests', () {
    test('parses plain text with no citations', () {
      final segments = CitationParser.parse('This is a simple answer without citations.');
      expect(segments.length, 1);
      expect(segments.first, isA<TextSegment>());
      expect((segments.first as TextSegment).text, 'This is a simple answer without citations.');
    });

    test('parses single citation badge [1]', () {
      final segments = CitationParser.parse('Dense vectors project into 1536-D space [1].');
      expect(segments.length, 3);
      expect((segments[0] as TextSegment).text, 'Dense vectors project into 1536-D space ');
      expect(segments[1], isA<CitationSegment>());
      expect((segments[1] as CitationSegment).citationId, 1);
      expect((segments[2] as TextSegment).text, '.');
    });

    test('parses compound citations [1, 2]', () {
      final segments = CitationParser.parse('Rerankers filter false positives [1, 2] efficiently.');
      expect(segments.length, 4);
      expect((segments[0] as TextSegment).text, 'Rerankers filter false positives ');
      expect((segments[1] as CitationSegment).citationId, 1);
      expect((segments[2] as CitationSegment).citationId, 2);
      expect((segments[3] as TextSegment).text, ' efficiently.');
    });

    test('extracts unique citation IDs accurately', () {
      final ids = CitationParser.extractCitationIds('Text [1] more text [2] and again [1, 3].');
      expect(ids, {1, 2, 3});
    });
  });
}
