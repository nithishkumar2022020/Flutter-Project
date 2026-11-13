import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/smooth_page_route.dart';
import '../providers/corpus_provider.dart';
import '../providers/rag_session_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/brutalist_container.dart';
import '../widgets/evidence_bottom_sheet.dart';
import '../widgets/formatted_answer_view.dart';
import '../widgets/process_timeline_card.dart';
import 'user_profile_screen.dart';

class QueryCanvasScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCorpus;

  const QueryCanvasScreen({super.key, this.onNavigateToCorpus});

  @override
  State<QueryCanvasScreen> createState() => _QueryCanvasScreenState();
}

class _QueryCanvasScreenState extends State<QueryCanvasScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend() {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    final ragSession = context.read<RagSessionProvider>();
    final settings = context.read<SettingsProvider>().settings;
    final selectedDocIds = context.read<CorpusProvider>().selectedDocumentIds.toList();

    ragSession.submitQuery(
      text,
      settings: settings,
      selectedDocumentIds: selectedDocIds,
    );
    _promptController.clear();
    FocusScope.of(context).unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _showDocumentScopeSheet(BuildContext context) {
    final corpus = context.read<CorpusProvider>();
    if (corpus.documents.isEmpty) {
      widget.onNavigateToCorpus?.call();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DocumentScopePickerSheet(
        onOpenCorpus: () {
          Navigator.of(context).pop();
          widget.onNavigateToCorpus?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.nocturneText : AppTheme.parchmentText;
    final mutedText = isDark ? AppTheme.nocturneMutedText : AppTheme.parchmentMutedText;
    final vermilion = isDark ? AppTheme.nocturneVermilion : AppTheme.parchmentVermilion;
    final borderColor = isDark ? AppTheme.nocturneBorder : AppTheme.parchmentBorder;
    final surfaceColor = isDark ? AppTheme.nocturneSurface : AppTheme.parchmentSurface;

    return Consumer<RagSessionProvider>(
      builder: (context, session, _) {
        if (session.isStreaming) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Minimal Top Stream Status Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: borderColor, width: 2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: session.isStreaming
                                  ? vermilion
                                  : (session.errorMessage != null
                                      ? vermilion
                                      : (session.isComplete ? AppTheme.parchmentSage : mutedText)),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            session.isStreaming
                                ? 'STREAMING ACTIVE'
                                : (session.errorMessage != null
                                    ? 'REQUEST FAILED'
                                    : (session.isComplete ? 'SYNTHESIS COMPLETE' : 'CANVAS STANDBY')),
                            style: AppTheme.monospace(
                              color: session.errorMessage != null && !session.isStreaming ? vermilion : textColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (session.citations.isNotEmpty) ...[
                            Text(
                              '${session.citations.length} SOURCES',
                              style: AppTheme.monospace(
                                color: vermilion,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Consumer<SettingsProvider>(
                            builder: (context, settingsProv, _) => GestureDetector(
                              key: const Key('header_profile_badge'),
                              onTap: () {
                                Navigator.of(context).push(
                                  SmoothPageRoute(page: const UserProfileScreen()),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: vermilion.withValues(alpha: 0.15),
                                  border: Border.all(color: vermilion, width: 1.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person_outline, size: 12, color: vermilion),
                                    const SizedBox(width: 4),
                                    Text(
                                      settingsProv.callSign,
                                      style: AppTheme.monospace(color: vermilion, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Scrollable Area using CustomScrollView to prevent keyboard overflow
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Query Card (if submitted)
                            if (session.currentQuery.isNotEmpty) ...[
                              Text(
                                'ACTIVE PROMPT',
                                style: AppTheme.monospace(color: mutedText, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              BrutalistContainer(
                                backgroundColor: surfaceColor,
                                child: Text(
                                  session.currentQuery,
                                  style: AppTheme.slabHeader(color: textColor, fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Expandable Agentic Pipeline Trace (steps & live timing)
                            if (session.processSteps.isNotEmpty) ...[
                              ProcessTimelineCard(
                                steps: session.processSteps,
                                isStreaming: session.isStreaming,
                                isComplete: session.isComplete,
                                hasError: session.errorMessage != null,
                                startedAt: session.queryStartedAt,
                                totalDuration: session.lastDuration,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Answer Canvas (shown once tokens/response begin arriving)
                            if (session.streamedAnswer.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'SYNTHESIZED GROUNDED RESPONSE',
                                    style: AppTheme.monospace(color: mutedText, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  if (session.isStreaming)
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: vermilion),
                                    )
                                  else if (session.streamedAnswer.isNotEmpty)
                                    GestureDetector(
                                      key: const Key('copy_answer_btn'),
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: session.streamedAnswer));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Response copied to clipboard.',
                                              style: AppTheme.monospace(color: Colors.white, fontSize: 12),
                                            ),
                                            duration: const Duration(seconds: 2),
                                            backgroundColor: borderColor,
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.copy_outlined, size: 12, color: mutedText),
                                          const SizedBox(width: 4),
                                          Text(
                                            'COPY',
                                            style: AppTheme.monospace(
                                              color: mutedText,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              BrutalistContainer(
                                backgroundColor: surfaceColor,
                                padding: const EdgeInsets.all(18),
                                child: _buildAnswerContent(context, session),
                              ),
                              if (session.citations.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Text(
                                  'SOURCES (${session.citations.length})',
                                  style: AppTheme.monospace(color: mutedText, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                BrutalistContainer(
                                  backgroundColor: surfaceColor,
                                  padding: EdgeInsets.zero,
                                  shadowOffset: const Offset(2, 2),
                                  child: Column(
                                    children: [
                                      for (var i = 0; i < session.citations.length; i++) ...[
                                        if (i > 0)
                                          Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: borderColor.withValues(alpha: 0.15),
                                          ),
                                        InkWell(
                                          onTap: () => showEvidenceBottomSheet(context, session.citations[i]),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Color.alphaBlend(
                                                      vermilion.withValues(alpha: 0.12),
                                                      surfaceColor,
                                                    ),
                                                    border: Border.all(color: vermilion, width: 1),
                                                  ),
                                                  child: Text(
                                                    '[${session.citations[i].id}]',
                                                    style: AppTheme.monospace(
                                                      color: vermilion,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    session.citations[i].displayTitle,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: AppTheme.readingSerif(
                                                      color: textColor,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.2,
                                                    ).copyWith(
                                                      decoration: TextDecoration.underline,
                                                      decorationColor: vermilion.withValues(alpha: 0.6),
                                                    ),
                                                  ),
                                                ),
                                                if (session.citations[i].page != null) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: borderColor.withValues(alpha: 0.3),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'p.${session.citations[i].page}',
                                                      style: AppTheme.monospace(
                                                        color: mutedText,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(width: 8),
                                                Icon(Icons.open_in_new, size: 14, color: vermilion),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                            ],

                            // Empty state guidance
                            if (session.currentQuery.isEmpty && !session.isStreaming) ...[
                              const SizedBox(height: 40),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'ARCHIVAL RAG CANVASES',
                                      style: AppTheme.slabHeader(color: textColor, fontSize: 22),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Submit a query below to initiate low-latency SSE token streaming with reactive citation badges.',
                                      textAlign: TextAlign.center,
                                      style: AppTheme.readingSerif(color: mutedText, fontSize: 14),
                                    ),
                                    const SizedBox(height: 24),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        _buildPromptChip('What is dense neural IR?'),
                                        _buildPromptChip('How does cross-encoder reranking work?'),
                                        _buildPromptChip('Explain 1536-D embedding projections'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Error Display
                            if (session.errorMessage != null) ...[
                              const SizedBox(height: 12),
                              BrutalistContainer(
                                backgroundColor: vermilion.withValues(alpha: 0.08),
                                borderColor: vermilion,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.error_outline, size: 16, color: vermilion),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'BACKEND REQUEST ERROR',
                                            style: AppTheme.monospace(
                                              color: vermilion,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          key: const Key('query_error_dismiss_btn'),
                                          onTap: session.clearError,
                                          child: Icon(Icons.close, size: 16, color: mutedText),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      session.errorMessage!,
                                      style: AppTheme.monospace(
                                        color: textColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (session.currentQuery.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      GestureDetector(
                                        key: const Key('query_retry_btn'),
                                        onTap: () {
                                          final settings = context.read<SettingsProvider>().settings;
                                          final selectedIds = context.read<CorpusProvider>().selectedDocumentIds.toList();
                                          session.submitQuery(
                                            session.currentQuery,
                                            settings: settings,
                                            selectedDocumentIds: selectedIds,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: vermilion,
                                            border: Border.all(color: borderColor, width: 1.5),
                                          ),
                                          child: Text(
                                            'RETRY QUERY',
                                            style: AppTheme.monospace(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 32),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),

                // Active RAG Document Scope Strip
                Consumer<CorpusProvider>(
                  builder: (context, corpus, _) {
                    final selected = corpus.selectedDocuments;
                    final String label;
                    if (selected.isEmpty) {
                      label = 'SCOPE: ALL DATABASE';
                    } else if (selected.length == 1) {
                      label = 'SCOPE: ${selected.first.title}';
                    } else {
                      label = 'SCOPE: ${selected.length} PDFS (${selected.first.title} +${selected.length - 1})';
                    }

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected.isNotEmpty
                            ? Color.alphaBlend(vermilion.withValues(alpha: 0.08), surfaceColor)
                            : surfaceColor,
                        border: Border(top: BorderSide(color: borderColor.withValues(alpha: 0.35), width: 1)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected.isEmpty ? Icons.storage_outlined : Icons.description_outlined,
                            size: 13,
                            color: selected.isNotEmpty ? vermilion : mutedText,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GestureDetector(
                              key: const Key('query_scope_picker_btn'),
                              onTap: () => _showDocumentScopeSheet(context),
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.monospace(
                                  color: selected.isNotEmpty ? vermilion : mutedText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showDocumentScopeSheet(context),
                            child: Text(
                              selected.isEmpty ? 'FILTER DOCS' : 'CHANGE',
                              style: AppTheme.monospace(
                                color: textColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (selected.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              key: const Key('query_scope_clear_btn'),
                              onTap: corpus.clearSelection,
                              child: Icon(Icons.close, size: 14, color: vermilion),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),

                // Prompt Input Bar with Neo-Brutalist Border
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border(top: BorderSide(color: borderColor, width: 2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('query_prompt_input'),
                          controller: _promptController,
                          style: AppTheme.readingSerif(color: textColor, fontSize: 15),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _handleSend(),
                          decoration: InputDecoration(
                            hintText: 'Enter inquiry to stream grounded synthesis...',
                            hintStyle: AppTheme.readingSerif(color: mutedText, fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        key: const Key('query_submit_btn'),
                        onTap: session.isStreaming ? session.cancelActiveStream : _handleSend,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: AppTheme.brutalistDecoration(
                            bgColor: session.isStreaming ? (isDark ? AppTheme.nocturneAmber : AppTheme.parchmentAmber) : vermilion,
                            borderColor: borderColor,
                            borderWidth: 1.5,
                            shadowOffset: const Offset(2, 2),
                          ),
                          child: Text(
                            session.isStreaming ? 'STOP' : 'QUERY',
                            style: AppTheme.monospace(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPromptChip(String prompt) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppTheme.nocturneBorder : AppTheme.parchmentBorder;
    final textColor = isDark ? AppTheme.nocturneText : AppTheme.parchmentText;

    return GestureDetector(
      onTap: () {
        _promptController.text = prompt;
        _handleSend();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          prompt,
          style: AppTheme.monospace(color: textColor, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildAnswerContent(BuildContext context, RagSessionProvider session) {
    return FormattedAnswerView(
      text: session.streamedAnswer,
      citations: session.citations,
      onCitationTap: (citation) => showEvidenceBottomSheet(context, citation),
    );
  }
}

class _DocumentScopePickerSheet extends StatefulWidget {
  final VoidCallback onOpenCorpus;

  const _DocumentScopePickerSheet({required this.onOpenCorpus});

  @override
  State<_DocumentScopePickerSheet> createState() => _DocumentScopePickerSheetState();
}

class _DocumentScopePickerSheetState extends State<_DocumentScopePickerSheet> {
  final Map<int, GlobalKey> _rowKeys = {};
  int? _dragAnchorIndex;
  int? _dragLastIndex;
  Set<String> _dragBaseSelection = {};
  bool _dragSelectMode = true;

  GlobalKey _keyFor(int index) => _rowKeys.putIfAbsent(index, () => GlobalKey());

  void _startDrag(int index, CorpusProvider corpus) {
    if (index < 0 || index >= corpus.documents.length) return;
    HapticFeedback.mediumImpact();
    _dragAnchorIndex = index;
    _dragLastIndex = index;
    _dragBaseSelection = Set<String>.from(corpus.selectedDocumentIds);
    _dragSelectMode = !corpus.isSelected(corpus.documents[index].id);
    corpus.applyDragRangeSelection(
      anchorIndex: index,
      targetIndex: index,
      baseSelection: _dragBaseSelection,
      selectRange: _dragSelectMode,
    );
  }

  void _updateDrag(Offset globalPosition, CorpusProvider corpus) {
    final anchor = _dragAnchorIndex;
    if (anchor == null) return;
    for (final entry in _rowKeys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final topLeft = box.localToGlobal(Offset.zero);
      final bottom = topLeft.dy + box.size.height;
      if (globalPosition.dy >= topLeft.dy - 4 && globalPosition.dy <= bottom + 4) {
        if (entry.key != _dragLastIndex) {
          _dragLastIndex = entry.key;
          HapticFeedback.selectionClick();
          corpus.applyDragRangeSelection(
            anchorIndex: anchor,
            targetIndex: entry.key,
            baseSelection: _dragBaseSelection,
            selectRange: _dragSelectMode,
          );
        }
        break;
      }
    }
  }

  void _endDrag() {
    _dragAnchorIndex = null;
    _dragLastIndex = null;
    _dragBaseSelection = {};
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.nocturneSurface : AppTheme.parchmentSurface;
    final textColor = isDark ? AppTheme.nocturneText : AppTheme.parchmentText;
    final mutedText = isDark ? AppTheme.nocturneMutedText : AppTheme.parchmentMutedText;
    final vermilion = isDark ? AppTheme.nocturneVermilion : AppTheme.parchmentVermilion;
    final borderColor = isDark ? AppTheme.nocturneBorder : AppTheme.parchmentBorder;

    return Consumer<CorpusProvider>(
      builder: (context, corpus, _) {
        final count = corpus.selectedDocumentIds.length;
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.72,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              top: BorderSide(color: borderColor, width: 3),
              left: BorderSide(color: borderColor, width: 2),
              right: BorderSide(color: borderColor, width: 2),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SELECT RAG DOCUMENTS',
                              style: AppTheme.slabHeader(color: textColor, fontSize: 17),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap 1 PDF or hold & slide across multiple files',
                              style: AppTheme.monospace(color: mutedText, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onOpenCorpus,
                        child: Text(
                          'CORPUS',
                          style: AppTheme.monospace(
                            color: vermilion,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: corpus.clearSelection,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: count == 0 ? vermilion : Colors.transparent,
                            border: Border.all(
                              color: count == 0 ? vermilion : borderColor,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'ALL DATABASE',
                            style: AppTheme.monospace(
                              color: count == 0 ? Colors.white : textColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: corpus.selectAll,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: Text(
                            'SELECT ALL (${corpus.documents.length})',
                            style: AppTheme.monospace(
                              color: textColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          color: borderColor,
                          child: Text(
                            'DONE',
                            style: AppTheme.monospace(
                              color: bgColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Divider(height: 1, color: borderColor.withValues(alpha: 0.25)),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: corpus.documents.length,
                    itemBuilder: (context, index) {
                      final doc = corpus.documents[index];
                      final isSelected = corpus.isSelected(doc.id);
                      return Padding(
                        key: _keyFor(index),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => corpus.toggleSelection(doc.id),
                          onLongPressStart: (_) => _startDrag(index, corpus),
                          onLongPressMoveUpdate: (d) => _updateDrag(d.globalPosition, corpus),
                          onLongPressEnd: (_) => _endDrag(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color.alphaBlend(vermilion.withValues(alpha: 0.1), bgColor)
                                  : bgColor,
                              border: Border.all(
                                color: isSelected ? vermilion : borderColor.withValues(alpha: 0.45),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: isSelected ? vermilion : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? vermilion : borderColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTheme.readingSerif(
                                          color: textColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${doc.filename} · ${doc.chunkCount} chunks',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTheme.monospace(color: mutedText, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
