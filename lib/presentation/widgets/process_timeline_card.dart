import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/rag_process_step.dart';
import 'brutalist_container.dart';

/// Claude / Agentic-IDE style expandable pipeline trace showing real-time
/// query preparation, backend retrieval/synthesis, citation linking, and timing.
class ProcessTimelineCard extends StatefulWidget {
  final List<RagProcessStep> steps;
  final bool isStreaming;
  final bool isComplete;
  final bool hasError;
  final DateTime? startedAt;
  final Duration? totalDuration;

  const ProcessTimelineCard({
    super.key,
    required this.steps,
    required this.isStreaming,
    required this.isComplete,
    required this.hasError,
    this.startedAt,
    this.totalDuration,
  });

  @override
  State<ProcessTimelineCard> createState() => _ProcessTimelineCardState();
}

class _ProcessTimelineCardState extends State<ProcessTimelineCard> {
  Timer? _ticker;
  bool? _userExpandedOverride;

  bool get _isExpanded {
    if (_userExpandedOverride != null) return _userExpandedOverride!;
    if (widget.isStreaming || widget.hasError) return true;
    return false;
  }

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant ProcessTimelineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStreaming && !oldWidget.isStreaming) {
      // Reset manual override on a brand-new query stream
      _userExpandedOverride = null;
    }
    _syncTicker();
  }

  void _syncTicker() {
    if (widget.isStreaming) {
      _ticker ??= Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (mounted) setState(() {});
      });
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final ms = duration.inMilliseconds;
    if (ms < 1000) return '0.${(ms ~/ 100)}s';
    return '${(ms / 1000).toStringAsFixed(1)}s';
  }

  Duration get _currentElapsed {
    if (!widget.isStreaming && widget.totalDuration != null) {
      return widget.totalDuration!;
    }
    if (widget.startedAt != null) {
      return DateTime.now().difference(widget.startedAt!);
    }
    return Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.nocturneText : AppTheme.parchmentText;
    final mutedText =
        isDark ? AppTheme.nocturneMutedText : AppTheme.parchmentMutedText;
    final vermilion =
        isDark ? AppTheme.nocturneVermilion : AppTheme.parchmentVermilion;
    final sage = isDark ? AppTheme.nocturneSage : AppTheme.parchmentSage;
    final borderColor =
        isDark ? AppTheme.nocturneBorder : AppTheme.parchmentBorder;
    final surfaceColor =
        isDark ? AppTheme.nocturneSurface : AppTheme.parchmentSurface;

    final elapsedText = _formatDuration(_currentElapsed);
    final activeStep =
        widget.steps
            .where((s) => s.state == ProcessStepState.active)
            .lastOrNull;

    final String headerTitle;
    if (widget.isStreaming) {
      headerTitle = (activeStep?.title ?? 'PROCESSING PIPELINE').toUpperCase();
    } else if (widget.hasError) {
      headerTitle = 'PIPELINE HALTED AT $elapsedText';
    } else {
      headerTitle = 'PROCESSED IN $elapsedText · ${widget.steps.length} STEPS';
    }

    final accentColor =
        widget.hasError ? vermilion : (widget.isStreaming ? vermilion : sage);

    return BrutalistContainer(
      key: const Key('process_timeline_card'),
      backgroundColor: surfaceColor,
      borderColor: widget.hasError ? vermilion : borderColor,
      borderWidth: 1.5,
      shadowOffset: const Offset(2, 2),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: const Key('process_timeline_toggle'),
            onTap: () {
              setState(() {
                _userExpandedOverride = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  if (widget.isStreaming)
                    SizedBox(
                      width: 13,
                      height: 13,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: vermilion,
                      ),
                    )
                  else
                    Icon(
                      widget.hasError
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      size: 15,
                      color: accentColor,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      headerTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.monospace(
                        color: widget.hasError ? vermilion : textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.45),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      elapsedText,
                      style: AppTheme.monospace(
                        color: accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: mutedText,
                  ),
                ],
              ),
            ),
          ),
          if (widget.isStreaming)
            LinearProgressIndicator(
              minHeight: 2.5,
              color: vermilion,
              backgroundColor: borderColor.withValues(alpha: 0.12),
            ),
          if (_isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: borderColor.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < widget.steps.length; i++)
                    _buildStepRow(
                      widget.steps[i],
                      isLast: i == widget.steps.length - 1,
                      textColor: textColor,
                      mutedText: mutedText,
                      vermilion: vermilion,
                      sage: sage,
                      borderColor: borderColor,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepRow(
    RagProcessStep step, {
    required bool isLast,
    required Color textColor,
    required Color mutedText,
    required Color vermilion,
    required Color sage,
    required Color borderColor,
  }) {
    final Color nodeColor;
    final Widget nodeWidget;

    switch (step.state) {
      case ProcessStepState.completed:
        nodeColor = sage;
        nodeWidget = Icon(Icons.check, size: 11, color: Colors.white);
      case ProcessStepState.active:
        nodeColor = vermilion;
        nodeWidget = Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        );
      case ProcessStepState.failed:
        nodeColor = vermilion;
        nodeWidget = const Icon(Icons.close, size: 11, color: Colors.white);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: nodeColor,
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Center(child: nodeWidget),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: borderColor.withValues(alpha: 0.25),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: AppTheme.monospace(
                            color:
                                step.state == ProcessStepState.failed
                                    ? vermilion
                                    : textColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+${_formatDuration(step.elapsed)}',
                        style: AppTheme.monospace(
                          color: mutedText,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (step.detail != null && step.detail!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.detail!,
                      style: AppTheme.readingSerif(
                        color: mutedText,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
