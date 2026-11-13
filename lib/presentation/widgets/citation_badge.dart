import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CitationBadge extends StatelessWidget {
  final int citationId;
  final VoidCallback onTap;
  final bool hasSourceData;
  final String? tooltip;

  const CitationBadge({
    super.key,
    required this.citationId,
    required this.onTap,
    this.hasSourceData = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vermilion = isDark ? AppTheme.nocturneVermilion : AppTheme.parchmentVermilion;
    final borderColor = isDark ? AppTheme.nocturneBorder : AppTheme.parchmentBorder;
    final surface = isDark ? AppTheme.nocturneSurface : AppTheme.parchmentSurface;

    final bgColor = hasSourceData
        ? Color.alphaBlend(vermilion.withValues(alpha: 0.12), surface)
        : surface;
    final accentColor = hasSourceData ? vermilion : borderColor.withValues(alpha: 0.65);

    final badge = MouseRegion(
      cursor: hasSourceData ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              top: BorderSide(color: accentColor, width: 1),
              left: BorderSide(color: accentColor, width: 1),
              right: BorderSide(color: accentColor, width: 1),
              bottom: BorderSide(color: accentColor, width: 2),
            ),
          ),
          child: Text(
            '[$citationId]',
            style: AppTheme.monospace(
              color: accentColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ).copyWith(
              decoration: hasSourceData ? TextDecoration.underline : TextDecoration.none,
              decorationColor: accentColor,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(
        message: tooltip!,
        child: badge,
      );
    }
    return badge;
  }
}
