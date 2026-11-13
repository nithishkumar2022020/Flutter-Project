import '../../domain/models/citation.dart';

sealed class AnswerSegment {
  const AnswerSegment();
}

class TextSegment extends AnswerSegment {
  final String text;
  const TextSegment(this.text);
}

class CitationSegment extends AnswerSegment {
  final int citationId;
  final String rawMatch;
  const CitationSegment({
    required this.citationId,
    required this.rawMatch,
  });
}

class CitationParser {
  // Matches [1], [2], [1, 2], [Source 1], [Ref 1], [Citation 1]
  static final RegExp _citationRegex = RegExp(
    r'\[(?:(?:Source|Ref|Citation)\s+)?(\d+(?:\s*,\s*(?:(?:Source|Ref|Citation)\s+)?\d+)*)\]',
    caseSensitive: false,
  );

  /// Parses text into text and citation segments for rich rendering.
  static List<AnswerSegment> parse(String text) {
    if (text.isEmpty) return const [];

    final segments = <AnswerSegment>[];
    int lastMatchEnd = 0;

    for (final match in _citationRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        segments.add(TextSegment(text.substring(lastMatchEnd, match.start)));
      }

      final fullPattern = match.group(0)!;
      final numbersPart = match.group(1)!;
      final ids = numbersPart
          .split(',')
          .map((s) => s.replaceFirst(RegExp(r'^(?:Source|Ref|Citation)\s+', caseSensitive: false), '').trim())
          .map(int.tryParse)
          .whereType<int>()
          .toList();

      if (ids.isEmpty) {
        segments.add(TextSegment(fullPattern));
      } else {
        for (final id in ids) {
          segments.add(CitationSegment(
            citationId: id,
            rawMatch: '[$id]',
          ));
        }
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      segments.add(TextSegment(text.substring(lastMatchEnd)));
    }

    return segments;
  }

  /// Normalizes inline source references like `[paper.pdf, p. 3]` or `(paper.pdf, page 3)`
  /// into `[id]` markers when they match known [citations], then runs [parse].
  static List<AnswerSegment> parseWithCitations(String text, List<Citation> citations) {
    if (text.isEmpty || citations.isEmpty) return parse(text);

    var normalized = text;
    for (final c in citations) {
      final escapedFile = RegExp.escape(c.cleanFilename);
      if (escapedFile.isEmpty) continue;
      final inlineRefPattern = RegExp(
        r'[\[\(]\s*' + escapedFile + r'(?:\s*[,—\-]\s*(?:p\.?|page)\s*\d+|\s*\(p\.\s*\d+\))?\s*[\]\)]',
        caseSensitive: false,
      );
      normalized = normalized.replaceAll(inlineRefPattern, '[${c.id}]');
    }

    return parse(normalized);
  }

  /// Extracts all unique referenced citation IDs from a text.
  static Set<int> extractCitationIds(String text) {
    final ids = <int>{};
    for (final match in _citationRegex.allMatches(text)) {
      final numbersPart = match.group(1)!;
      final parsed = numbersPart
          .split(',')
          .map((s) => s.replaceFirst(RegExp(r'^(?:Source|Ref|Citation)\s+', caseSensitive: false), '').trim())
          .map(int.tryParse)
          .whereType<int>();
      ids.addAll(parsed);
    }
    return ids;
  }
}
