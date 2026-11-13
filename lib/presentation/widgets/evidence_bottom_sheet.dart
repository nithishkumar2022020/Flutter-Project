import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/smooth_page_route.dart';
import '../../domain/models/citation.dart';
import '../screens/chunk_inspector_screen.dart';
import 'brutalist_container.dart';

void showEvidenceBottomSheet(BuildContext context, Citation citation) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final bgColor = isDark ? AppTheme.nocturneSurface : AppTheme.parchmentSurface;
      final textColor = isDark ? AppTheme.nocturneText : AppTheme.parchmentText;
      final mutedText = isDark ? AppTheme.nocturneMutedText : AppTheme.parchmentMutedText;
      final vermilion = isDark ? AppTheme.nocturneVermilion : AppTheme.parchmentVermilion;
      final borderColor = isDark ? AppTheme.nocturneBorder : AppTheme.parchmentBorder;

      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: bgColor,
              border: Border(
                top: BorderSide(color: borderColor, width: 3),
                left: BorderSide(color: borderColor, width: 2),
                right: BorderSide(color: borderColor, width: 2),
              ),
              boxShadow: [
                BoxShadow(
                  color: borderColor,
                  offset: const Offset(0, -4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: vermilion,
                          child: Text(
                            'CITATION [${citation.id}]',
                            style: AppTheme.monospace(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SIMILARITY: ${(citation.score * 100).toStringAsFixed(1)}%',
                          style: AppTheme.monospace(color: vermilion, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Source Document
                Text(
                  'SOURCE ARTIFACT',
                  style: AppTheme.monospace(color: mutedText, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  citation.displayTitle,
                  style: AppTheme.slabHeader(color: textColor, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(
                      citation.cleanFilename,
                      style: AppTheme.monospace(color: mutedText, fontSize: 11),
                    ),
                    if (citation.page != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          border: Border.all(color: vermilion, width: 1),
                        ),
                        child: Text(
                          'PAGE ${citation.page}',
                          style: AppTheme.monospace(
                            color: vermilion,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Chunk Text Span
                Text(
                  'GROUNDED PASSAGE SPAN',
                  style: AppTheme.monospace(color: mutedText, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                BrutalistContainer(
                  backgroundColor: isDark ? AppTheme.nocturneBg : AppTheme.parchmentBg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${citation.textSpan}"',
                        style: AppTheme.readingSerif(
                          color: textColor,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'CHUNK REF: ${citation.chunkId}',
                        style: AppTheme.monospace(color: mutedText, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Deep Inspection Action
                BrutalistContainer(
                  backgroundColor: vermilion,
                  borderColor: borderColor,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      SmoothPageRoute(
                        page: ChunkInspectorScreen(chunkId: citation.chunkId),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hub_outlined, color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'INSPECT CHUNK IN MATRIX',
                        style: AppTheme.monospace(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
}
