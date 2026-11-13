import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_proj_dq/core/utils/citation_parser.dart';
import 'package:my_flutter_proj_dq/domain/models/citation.dart';
import 'package:my_flutter_proj_dq/presentation/widgets/citation_badge.dart';
import 'package:my_flutter_proj_dq/presentation/widgets/formatted_answer_view.dart';

void main() {
  group('Citation displayTitle and CitationParser', () {
    test('strips storage prefixes, directories, extensions, and page suffixes for displayTitle', () {
      const c1 = Citation(
        id: 1,
        chunkId: 'chk_1',
        textSpan: 'Span',
        sourceDoc: 'uploads/1762958400_annual_report_2025.pdf (p.3)',
        score: 0.9,
        page: 3,
      );
      expect(c1.cleanFilename, '1762958400_annual_report_2025.pdf');
      expect(c1.displayTitle, 'annual report 2025');

      final c2 = Citation.fromJson({
        'document_id': 'doc_2',
        'filename': '550e8400-e29b-41d4-a716-446655440000_retrieval-guide.pdf',
        'page': 7,
      }, fallbackId: 2);
      expect(c2.displayTitle, 'retrieval guide');
      expect(c2.page, 7);
    });

    test('parseWithCitations turns filename/page and Source markers into CitationSegments', () {
      const citations = [
        Citation(
          id: 1,
          chunkId: 'chk_1',
          textSpan: 'Span 1',
          sourceDoc: 'annual_report.pdf (p.3)',
          score: 1.0,
          page: 3,
        ),
        Citation(
          id: 2,
          chunkId: 'chk_2',
          textSpan: 'Span 2',
          sourceDoc: 'appendix.pdf (p.9)',
          score: 1.0,
          page: 9,
        ),
      ];

      final segments = CitationParser.parseWithCitations(
        'Summary from [annual_report.pdf, p. 3] and [Source 2].',
        citations,
      );

      final ids = segments.whereType<CitationSegment>().map((s) => s.citationId).toList();
      expect(ids, [1, 2]);
    });
  });

  group('FormattedAnswerView', () {
    testWidgets('renders markdown structure without raw markers and links inline citations', (tester) async {
      Citation? tapped;
      const citations = [
        Citation(
          id: 1,
          chunkId: 'chk_1',
          textSpan: 'Dense vectors speed up lookup.',
          sourceDoc: 'neural_ir.pdf (p.4)',
          score: 0.95,
          page: 4,
        ),
      ];

      const md = '''
## Key Takeaways

Here is the **core conclusion** with `BM25` comparison [1]:

- Fast retrieval [neural_ir.pdf, p. 4]
- Clean formatting
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FormattedAnswerView(
                text: md,
                citations: citations,
                onCitationTap: (c) => tapped = c,
              ),
            ),
          ),
        ),
      );

      // Raw markdown syntax must not be visible
      expect(find.textContaining('##'), findsNothing);
      expect(find.textContaining('**'), findsNothing);
      expect(find.textContaining('neural_ir.pdf'), findsNothing);

      // Formatted headings and content must be visible
      expect(find.text('Key Takeaways', findRichText: true), findsOneWidget);
      expect(find.textContaining('core conclusion', findRichText: true), findsOneWidget);
      expect(find.textContaining('Fast retrieval', findRichText: true), findsOneWidget);

      // Both [1] and normalized [neural_ir.pdf, p. 4] become interactive CitationBadges
      final badges = find.byType(CitationBadge);
      expect(badges, findsNWidgets(2));

      await tester.tap(badges.first);
      await tester.pump();
      expect(tapped?.id, 1);
    });
  });
}
