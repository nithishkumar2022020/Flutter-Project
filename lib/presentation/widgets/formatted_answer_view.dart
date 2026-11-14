import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/citation_parser.dart';
import '../../domain/models/citation.dart';
import 'citation_badge.dart';

/// Renders a synthesized RAG answer with Markdown structure, inline formatting,
/// and interactive hyperlinked [CitationBadge] markers.
class FormattedAnswerView extends StatelessWidget {
  final String text;
  final List<Citation> citations;
  final ValueChanged<Citation> onCitationTap;

  const FormattedAnswerView({
    super.key,
    required this.text,
    required this.citations,
    required this.onCitationTap,
  });

  Citation? _findCitation(int id) {
    for (final c in citations) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.nocturneText : AppTheme.parchmentText;
    final mutedText =
        isDark ? AppTheme.nocturneMutedText : AppTheme.parchmentMutedText;
    final vermilion =
        isDark ? AppTheme.nocturneVermilion : AppTheme.parchmentVermilion;
    final borderColor =
        isDark ? AppTheme.nocturneBorder : AppTheme.parchmentBorder;
    final bgColor = isDark ? AppTheme.nocturneBg : AppTheme.parchmentBg;

    final blocks = _parseBlocks(text);
    if (blocks.isEmpty) {
      return Text(
        text,
        style: AppTheme.readingSerif(
          color: textColor,
          fontSize: 15,
          height: 1.6,
        ),
      );
    }

    final children = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      if (i > 0) {
        final prev = blocks[i - 1];
        final curr = blocks[i];
        final gap =
            (prev is _ListItemBlock && curr is _ListItemBlock)
                ? 6.0
                : (curr is _HeadingBlock ? 16.0 : 11.0);
        children.add(SizedBox(height: gap));
      }
      children.add(
        _buildBlock(
          context,
          blocks[i],
          textColor: textColor,
          mutedText: mutedText,
          vermilion: vermilion,
          borderColor: borderColor,
          codeBg: bgColor,
        ),
      );
    }

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildBlock(
    BuildContext context,
    _MdBlock block, {
    required Color textColor,
    required Color mutedText,
    required Color vermilion,
    required Color borderColor,
    required Color codeBg,
  }) {
    switch (block) {
      case _HeadingBlock(:final level, :final content):
        final size = switch (level) {
          1 => 19.0,
          2 => 17.0,
          3 => 15.5,
          _ => 14.5,
        };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInlineRichText(
              content,
              baseStyle: AppTheme.slabHeader(
                color: textColor,
                fontSize: size,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
              textColor: textColor,
              vermilion: vermilion,
              codeBg: codeBg,
            ),
            if (level <= 2) ...[
              const SizedBox(height: 4),
              Container(width: 36, height: 2, color: vermilion),
            ],
          ],
        );

      case _ListItemBlock(:final orderedIndex, :final content, :final indent):
        return Padding(
          padding: EdgeInsets.only(left: indent * 14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: orderedIndex != null ? 24 : 16,
                child: Padding(
                  padding: EdgeInsets.only(top: orderedIndex != null ? 3 : 8),
                  child:
                      orderedIndex != null
                          ? Text(
                            '$orderedIndex.',
                            style: AppTheme.monospace(
                              color: vermilion,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 6,
                              height: 6,
                              color: vermilion,
                            ),
                          ),
                ),
              ),
              Expanded(
                child: _buildInlineRichText(
                  content,
                  baseStyle: AppTheme.readingSerif(
                    color: textColor,
                    fontSize: 15,
                    height: 1.58,
                  ),
                  textColor: textColor,
                  vermilion: vermilion,
                  codeBg: codeBg,
                ),
              ),
            ],
          ),
        );

      case _QuoteBlock(:final content):
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(
            color: codeBg,
            border: Border(left: BorderSide(color: vermilion, width: 3)),
          ),
          child: _buildInlineRichText(
            content,
            baseStyle: AppTheme.readingSerif(
              color: mutedText,
              fontSize: 14.5,
              height: 1.55,
            ).copyWith(fontStyle: FontStyle.italic),
            textColor: textColor,
            vermilion: vermilion,
            codeBg: codeBg,
          ),
        );

      case _CodeBlock(:final language, :final code):
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: codeBg,
            border: Border.all(
              color: borderColor.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (language.isNotEmpty) ...[
                Text(
                  language.toUpperCase(),
                  style: AppTheme.monospace(
                    color: vermilion,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  code,
                  style: AppTheme.monospace(
                    color: textColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );

      case _DividerBlock():
        return Divider(
          height: 8,
          thickness: 1.5,
          color: borderColor.withValues(alpha: 0.25),
        );

      case _ParagraphBlock(:final content):
        return _buildInlineRichText(
          content,
          baseStyle: AppTheme.readingSerif(
            color: textColor,
            fontSize: 15,
            height: 1.62,
          ),
          textColor: textColor,
          vermilion: vermilion,
          codeBg: codeBg,
        );
    }
  }

  Widget _buildInlineRichText(
    String rawText, {
    required TextStyle baseStyle,
    required Color textColor,
    required Color vermilion,
    required Color codeBg,
  }) {
    final segments = CitationParser.parseWithCitations(rawText, citations);
    final spans = <InlineSpan>[];

    for (final segment in segments) {
      if (segment is TextSegment) {
        spans.addAll(
          _parseInlineMarkdown(
            segment.text,
            baseStyle: baseStyle,
            textColor: textColor,
            vermilion: vermilion,
            codeBg: codeBg,
          ),
        );
      } else if (segment is CitationSegment) {
        final citation = _findCitation(segment.citationId);
        final tooltip =
            citation == null
                ? null
                : '${citation.displayTitle}${citation.page != null ? ' • p.${citation.page}' : ''}';
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: CitationBadge(
              citationId: segment.citationId,
              hasSourceData: citation != null,
              tooltip: tooltip,
              onTap: () {
                if (citation != null) {
                  onCitationTap(citation);
                }
              },
            ),
          ),
        );
      }
    }

    return Text.rich(TextSpan(children: spans));
  }

  List<InlineSpan> _parseInlineMarkdown(
    String input, {
    required TextStyle baseStyle,
    required Color textColor,
    required Color vermilion,
    required Color codeBg,
  }) {
    if (input.isEmpty) return const [];

    final pattern = RegExp(
      r'(`[^`\n]+`)'
      r'|(\*\*[^*\n]+?\*\*|__[^_\n]+?__)'
      r'|(\*[^*\n]+?\*|_[^_\n]+?_)'
      r'|(\[([^\]\n]+)\]\((https?://[^)\s]+)\))',
    );

    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final match in pattern.allMatches(input)) {
      if (match.start > cursor) {
        spans.add(
          TextSpan(
            text: input.substring(cursor, match.start),
            style: baseStyle,
          ),
        );
      }

      if (match.group(1) != null) {
        final codeText = match
            .group(1)!
            .substring(1, match.group(1)!.length - 1);
        spans.add(
          TextSpan(
            text: ' $codeText ',
            style: AppTheme.monospace(
              color: textColor,
              fontSize: (baseStyle.fontSize ?? 15) - 2,
              fontWeight: FontWeight.w600,
            ).copyWith(backgroundColor: codeBg),
          ),
        );
      } else if (match.group(2) != null) {
        final raw = match.group(2)!;
        final boldText = raw.substring(2, raw.length - 2);
        spans.add(
          TextSpan(
            text: boldText,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        );
      } else if (match.group(3) != null) {
        final raw = match.group(3)!;
        final italicText = raw.substring(1, raw.length - 1);
        spans.add(
          TextSpan(
            text: italicText,
            style: baseStyle.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else if (match.group(4) != null) {
        final label = match.group(5) ?? match.group(4)!;
        spans.add(
          TextSpan(
            text: label,
            style: baseStyle.copyWith(
              color: vermilion,
              decoration: TextDecoration.underline,
              decorationColor: vermilion,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }

      cursor = match.end;
    }

    if (cursor < input.length) {
      spans.add(TextSpan(text: input.substring(cursor), style: baseStyle));
    }

    return spans;
  }

  List<_MdBlock> _parseBlocks(String raw) {
    final normalized = raw.replaceAll('\r\n', '\n').trim();
    if (normalized.isEmpty) return const [];

    final lines = normalized.split('\n');
    final blocks = <_MdBlock>[];
    final paragraphBuffer = <String>[];

    void flushParagraph() {
      if (paragraphBuffer.isEmpty) return;
      blocks.add(_ParagraphBlock(paragraphBuffer.join(' ').trim()));
      paragraphBuffer.clear();
    }

    var i = 0;
    while (i < lines.length) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        flushParagraph();
        i++;
        continue;
      }

      // Fenced code block
      if (trimmed.startsWith('```')) {
        flushParagraph();
        final language = trimmed.substring(3).trim();
        final codeLines = <String>[];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        if (i < lines.length && lines[i].trim().startsWith('```')) {
          i++;
        }
        blocks.add(_CodeBlock(language: language, code: codeLines.join('\n')));
        continue;
      }

      // Horizontal rule
      if (RegExp(r'^([-*_])\1{2,}$').hasMatch(trimmed)) {
        flushParagraph();
        blocks.add(const _DividerBlock());
        i++;
        continue;
      }

      // Heading (# .. ####)
      final headingMatch = RegExp(r'^(#{1,4})\s+(.+)$').firstMatch(trimmed);
      if (headingMatch != null) {
        flushParagraph();
        blocks.add(
          _HeadingBlock(
            level: headingMatch.group(1)!.length,
            content: headingMatch.group(2)!.trim(),
          ),
        );
        i++;
        continue;
      }

      // Blockquote
      if (trimmed.startsWith('>')) {
        flushParagraph();
        final quoteLines = <String>[];
        while (i < lines.length && lines[i].trim().startsWith('>')) {
          quoteLines.add(lines[i].trim().replaceFirst(RegExp(r'^>\s?'), ''));
          i++;
        }
        blocks.add(_QuoteBlock(quoteLines.join(' ').trim()));
        continue;
      }

      // Unordered list item
      final bulletMatch = RegExp(r'^(\s*)[-*•]\s+(.+)$').firstMatch(line);
      if (bulletMatch != null) {
        flushParagraph();
        final indent = (bulletMatch.group(1)?.length ?? 0) ~/ 2;
        blocks.add(
          _ListItemBlock(content: bulletMatch.group(2)!.trim(), indent: indent),
        );
        i++;
        continue;
      }

      // Ordered list item
      final orderedMatch = RegExp(r'^(\s*)(\d+)\.\s+(.+)$').firstMatch(line);
      if (orderedMatch != null) {
        flushParagraph();
        final indent = (orderedMatch.group(1)?.length ?? 0) ~/ 2;
        blocks.add(
          _ListItemBlock(
            orderedIndex: int.tryParse(orderedMatch.group(2)!),
            content: orderedMatch.group(3)!.trim(),
            indent: indent,
          ),
        );
        i++;
        continue;
      }

      paragraphBuffer.add(trimmed);
      i++;
    }

    flushParagraph();
    return blocks;
  }
}

sealed class _MdBlock {
  const _MdBlock();
}

class _HeadingBlock extends _MdBlock {
  final int level;
  final String content;
  const _HeadingBlock({required this.level, required this.content});
}

class _ListItemBlock extends _MdBlock {
  final int? orderedIndex;
  final String content;
  final int indent;
  const _ListItemBlock({
    this.orderedIndex,
    required this.content,
    this.indent = 0,
  });
}

class _QuoteBlock extends _MdBlock {
  final String content;
  const _QuoteBlock(this.content);
}

class _CodeBlock extends _MdBlock {
  final String language;
  final String code;
  const _CodeBlock({required this.language, required this.code});
}

class _DividerBlock extends _MdBlock {
  const _DividerBlock();
}

class _ParagraphBlock extends _MdBlock {
  final String content;
  const _ParagraphBlock(this.content);
}
