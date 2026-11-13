import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Parchment Mode Palette
  static const Color parchmentBg = Color(0xFFF5EFE6);
  static const Color parchmentSurface = Color(0xFFFAF7F2);
  static const Color parchmentText = Color(0xFF1A1614);
  static const Color parchmentMutedText = Color(0xFF5A524C);
  static const Color parchmentBorder = Color(0xFF1A1614);
  static const Color parchmentVermilion = Color(0xFFC83228);
  static const Color parchmentAmber = Color(0xFFE89A3C);
  static const Color parchmentSage = Color(0xFF4C785B);

  // Nocturne Mode Palette
  static const Color nocturneBg = Color(0xFF121110);
  static const Color nocturneSurface = Color(0xFF1C1A18);
  static const Color nocturneText = Color(0xFFE6DFD5);
  static const Color nocturneMutedText = Color(0xFFA69C90);
  static const Color nocturneBorder = Color(0xFFE6DFD5);
  static const Color nocturneVermilion = Color(0xFFE04838);
  static const Color nocturneAmber = Color(0xFFF0A855);
  static const Color nocturneSage = Color(0xFF689B77);

  // Neo-Brutalist Box Shadow specification
  static List<BoxShadow> brutalistShadow(Color shadowColor, {Offset offset = const Offset(4, 4)}) {
    return [
      BoxShadow(
        color: shadowColor,
        offset: offset,
        blurRadius: 0,
        spreadRadius: 0,
      ),
    ];
  }

  // Neo-Brutalist Container Decoration
  static BoxDecoration brutalistDecoration({
    required Color bgColor,
    required Color borderColor,
    double borderWidth = 2.0,
    BorderRadius? borderRadius,
    Offset shadowOffset = const Offset(4, 4),
  }) {
    return BoxDecoration(
      color: bgColor,
      borderRadius: borderRadius ?? BorderRadius.zero,
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: brutalistShadow(borderColor, offset: shadowOffset),
    );
  }

  // Typography Styles
  static TextStyle slabHeader({
    required Color color,
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w800,
    double? height,
    double? letterSpacing,
  }) {
    try {
      return GoogleFonts.fraunces(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
      ).copyWith(fontFamilyFallback: const ['serif', 'Times New Roman']);
    } catch (_) {
      return TextStyle(
        fontFamily: 'serif',
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
      );
    }
  }

  static TextStyle readingSerif({
    required Color color,
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.normal,
    double height = 1.55,
    double? letterSpacing,
  }) {
    try {
      return GoogleFonts.newsreader(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
      ).copyWith(fontFamilyFallback: const ['serif', 'Times New Roman']);
    } catch (_) {
      return TextStyle(
        fontFamily: 'serif',
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
      );
    }
  }

  static TextStyle monospace({
    required Color color,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    double? letterSpacing,
  }) {
    try {
      return GoogleFonts.jetBrainsMono(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      ).copyWith(fontFamilyFallback: const ['monospace', 'Courier New']);
    } catch (_) {
      return TextStyle(
        fontFamily: 'monospace',
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      );
    }
  }

  static ThemeData buildTheme(bool isNocturne) {
    final bg = isNocturne ? nocturneBg : parchmentBg;
    final surface = isNocturne ? nocturneSurface : parchmentSurface;
    final text = isNocturne ? nocturneText : parchmentText;
    final border = isNocturne ? nocturneBorder : parchmentBorder;
    final vermilion = isNocturne ? nocturneVermilion : parchmentVermilion;

    return ThemeData(
      useMaterial3: true,
      brightness: isNocturne ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      primaryColor: vermilion,
      canvasColor: surface,
      colorScheme: ColorScheme(
        brightness: isNocturne ? Brightness.dark : Brightness.light,
        primary: vermilion,
        onPrimary: Colors.white,
        secondary: isNocturne ? nocturneAmber : parchmentAmber,
        onSecondary: Colors.black,
        error: vermilion,
        onError: Colors.white,
        surface: surface,
        onSurface: text,
      ),
      dividerColor: border,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: border, width: 2),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
      ),
    );
  }
}
