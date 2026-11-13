import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BrutalistContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final Offset shadowOffset;
  final VoidCallback? onTap;

  const BrutalistContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.shadowOffset = const Offset(4, 4),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bColor = borderColor ?? (isDark ? AppTheme.nocturneBorder : AppTheme.parchmentBorder);
    final defaultSurface = isDark ? AppTheme.nocturneSurface : AppTheme.parchmentSurface;
    final rawBgColor = backgroundColor ?? defaultSurface;
    // Composite translucent backgrounds onto surface so hard BoxShadow never bleeds through.
    final bgColor = rawBgColor.a < 1.0 ? Color.alphaBlend(rawBgColor, defaultSurface) : rawBgColor;

    Widget content = Container(
      margin: margin,
      padding: padding,
      decoration: AppTheme.brutalistDecoration(
        bgColor: bgColor,
        borderColor: bColor,
        borderWidth: borderWidth,
        shadowOffset: shadowOffset,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
