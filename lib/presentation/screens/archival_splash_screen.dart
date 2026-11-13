import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import 'clearance_auth_screen.dart';
import 'root_shell_screen.dart';

/// Neo-Brutalist Archival Initialization Screen with typewriter text animation,
/// terminal cursor telemetry, and segmented progress bar.
class ArchivalSplashScreen extends StatefulWidget {
  final Duration duration;
  final Widget? destinationOverride;
  final VoidCallback? onAnimationComplete;

  const ArchivalSplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 2100),
    this.destinationOverride,
    this.onAnimationComplete,
  });

  @override
  State<ArchivalSplashScreen> createState() => _ArchivalSplashScreenState();
}

class _ArchivalSplashScreenState extends State<ArchivalSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progressController;
  late final AnimationController _blinkController;
  bool _hasNavigated = false;

  static const String _fullTitle = 'SYNQRA';
  static const String _fullSubtitle = 'NEURAL RETRIEVAL & ATTRIBUTION CANVAS';

  static const List<_BootStep> _bootSteps = [
    _BootStep(threshold: 0.05, label: 'MOUNTING LATENT MANIFOLD (1536-D)...', code: 'VEC_INIT'),
    _BootStep(threshold: 0.32, label: 'CALIBRATING HNSW GRAPH & BM25 INDICES...', code: 'HNSW_CALIB'),
    _BootStep(threshold: 0.62, label: 'ESTABLISHING GROUNDED SSE PIPELINE...', code: 'SSE_LINK'),
    _BootStep(threshold: 0.88, label: 'SYNQRA CORE ONLINE // CLEARANCE VERIFIED', code: 'SYS_READY'),
  ];

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _progressController.addListener(() {
      if (mounted) setState(() {});
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateForward();
      }
    });

    _progressController.forward();
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _navigateForward() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    if (widget.onAnimationComplete != null) {
      widget.onAnimationComplete!();
      return;
    }

    final destination = widget.destinationOverride ??
        (context.read<SettingsProvider>().isAuthenticated
            ? const RootShellScreen()
            : const ClearanceAuthScreen());

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
      ),
    );
  }

  String _getTypedTitle(double progress) {
    if (progress <= 0.02) return '';
    if (progress >= 0.40) return _fullTitle;
    final fraction = ((progress - 0.02) / 0.38).clamp(0.0, 1.0);
    final count = (fraction * _fullTitle.length).ceil().clamp(0, _fullTitle.length);
    return _fullTitle.substring(0, count);
  }

  String _getTypedSubtitle(double progress) {
    if (progress <= 0.38) return '';
    if (progress >= 0.82) return _fullSubtitle;
    final fraction = ((progress - 0.38) / 0.44).clamp(0.0, 1.0);
    final count = (fraction * _fullSubtitle.length).ceil().clamp(0, _fullSubtitle.length);
    return _fullSubtitle.substring(0, count);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.nocturneBg : AppTheme.parchmentBg;
    final surfaceColor = isDark ? AppTheme.nocturneSurface : AppTheme.parchmentSurface;
    final textColor = isDark ? AppTheme.nocturneText : AppTheme.parchmentText;
    final mutedText = isDark ? AppTheme.nocturneMutedText : AppTheme.parchmentMutedText;
    final vermilion = isDark ? AppTheme.nocturneVermilion : AppTheme.parchmentVermilion;
    final borderColor = isDark ? AppTheme.nocturneBorder : AppTheme.parchmentBorder;

    final progress = _progressController.value;
    final percent = (progress * 100).toInt().clamp(0, 100);

    final typedTitle = _getTypedTitle(progress);
    final typedSubtitle = _getTypedSubtitle(progress);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            _navigateForward();
          },
          child: Stack(
            children: [
              // Subtle background technical grid
              Positioned.fill(
                child: CustomPaint(
                  painter: _TechGridPainter(
                    gridColor: borderColor.withValues(alpha: isDark ? 0.05 : 0.07),
                  ),
                ),
              ),

              // Corner Crosshair Markers
              Positioned(
                top: 16,
                left: 16,
                child: _buildCrosshair(borderColor, mutedText, '[00, 00]'),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Row(
                  children: [
                    _buildSkipButton(vermilion, borderColor),
                    const SizedBox(width: 8),
                    _buildCrosshair(borderColor, mutedText, '[99, 00]'),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: _buildCrosshair(borderColor, mutedText, '[00, 99]'),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: _buildCrosshair(borderColor, mutedText, '[99, 99]'),
              ),

              // Main Centered Content
              Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Meta Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: vermilion.withValues(alpha: 0.12),
                            border: Border.all(color: vermilion, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: vermilion,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'ARCHIVAL RAG CORE // DAEMON BOOT',
                                style: AppTheme.monospace(
                                  color: vermilion,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Crisp Typewriter Terminal Hero Box
                        _buildTerminalHero(
                          typedTitle: typedTitle,
                          typedSubtitle: typedSubtitle,
                          progress: progress,
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          mutedText: mutedText,
                          vermilion: vermilion,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),

                        // Neo-Brutalist Segmented Progress Bar
                        _buildSegmentedProgressBar(
                          progress: progress,
                          percent: percent,
                          vermilion: vermilion,
                          borderColor: borderColor,
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                        ),
                        const SizedBox(height: 18),

                        // Live Telemetry Boot Log Terminal
                        _buildTelemetryTerminal(
                          progress: progress,
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          mutedText: mutedText,
                          vermilion: vermilion,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerminalHero({
    required String typedTitle,
    required String typedSubtitle,
    required double progress,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color mutedText,
    required Color vermilion,
    required bool isDark,
  }) {
    final isTitleDone = progress >= 0.40;
    final showTitleCursor = !isTitleDone;
    final showSubtitleCursor = isTitleDone;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Terminal Window Status Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: vermilion,
                ),
                child: Text(
                  'TERM://SYNQRA',
                  style: AppTheme.monospace(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: borderColor.withValues(alpha: 0.08),
                  border: Border.all(color: borderColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Text(
                  'SYS_PROMPT_INIT',
                  style: AppTheme.monospace(
                    color: mutedText,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'ONLINE',
                style: AppTheme.monospace(
                  color: vermilion,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Hero Typewriter Title Line
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '> ',
                style: AppTheme.slabHeader(
                  color: vermilion,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                typedTitle,
                style: AppTheme.slabHeader(
                  color: textColor,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 5.0,
                ),
              ),
              if (showTitleCursor)
                AnimatedBuilder(
                  animation: _blinkController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _blinkController.value < 0.5 ? 1.0 : 0.0,
                      child: Text(
                        '▌',
                        style: AppTheme.slabHeader(
                          color: vermilion,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Typewriter Subtitle Line
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  typedSubtitle.isEmpty ? ' ' : '> $typedSubtitle',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.monospace(
                    color: isDark ? AppTheme.nocturneMutedText : AppTheme.parchmentText,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              if (showSubtitleCursor)
                AnimatedBuilder(
                  animation: _blinkController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _blinkController.value < 0.5 ? 1.0 : 0.0,
                      child: Text(
                        '▌',
                        style: AppTheme.monospace(
                          color: vermilion,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton(Color vermilion, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: vermilion.withValues(alpha: 0.1),
        border: Border.all(color: vermilion.withValues(alpha: 0.6), width: 1),
      ),
      child: Text(
        'SKIP >>',
        style: AppTheme.monospace(
          color: vermilion,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCrosshair(Color borderColor, Color mutedColor, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '+',
          style: AppTheme.monospace(
            color: borderColor.withValues(alpha: 0.45),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.monospace(
            color: mutedColor.withValues(alpha: 0.5),
            fontSize: 8,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedProgressBar({
    required double progress,
    required int percent,
    required Color vermilion,
    required Color borderColor,
    required Color surfaceColor,
    required Color textColor,
  }) {
    const totalSegments = 16;
    final activeSegments = (progress * totalSegments).floor();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor,
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BOOT SEQUENCE',
                style: AppTheme.monospace(
                  color: textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '$percent% [OK]',
                style: AppTheme.monospace(
                  color: vermilion,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(totalSegments, (index) {
              final isFilled = index <= activeSegments;
              return Expanded(
                child: Container(
                  height: 10,
                  margin: EdgeInsets.only(right: index == totalSegments - 1 ? 0 : 3),
                  decoration: BoxDecoration(
                    color: isFilled ? vermilion : borderColor.withValues(alpha: 0.12),
                    border: Border.all(
                      color: isFilled ? borderColor : borderColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryTerminal({
    required double progress,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color mutedText,
    required Color vermilion,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final step in _bootSteps)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text(
                    progress >= step.threshold ? '✓' : '›',
                    style: AppTheme.monospace(
                      color: progress >= step.threshold ? vermilion : mutedText.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step.label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.monospace(
                        color: progress >= step.threshold ? textColor : mutedText.withValues(alpha: 0.4),
                        fontSize: 9.5,
                        fontWeight: progress >= step.threshold ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  Text(
                    step.code,
                    style: AppTheme.monospace(
                      color: progress >= step.threshold ? vermilion : mutedText.withValues(alpha: 0.3),
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BootStep {
  final double threshold;
  final String label;
  final String code;

  const _BootStep({
    required this.threshold,
    required this.label,
    required this.code,
  });
}

/// Subtle blueprint/schematic grid painter
class _TechGridPainter extends CustomPainter {
  final Color gridColor;

  const _TechGridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8;

    const step = 28.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TechGridPainter oldDelegate) =>
      oldDelegate.gridColor != gridColor;
}
