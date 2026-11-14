import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/utils/citation_parser.dart';
import '../../domain/models/citation.dart';
import '../../domain/models/rag_process_step.dart';
import '../../domain/models/rag_stream_event.dart';
import '../../domain/models/profile_settings.dart';
import '../../domain/repositories/i_rag_stream_repository.dart';

class RagSessionProvider extends ChangeNotifier {
  final IRagStreamRepository _repository;
  StreamSubscription<RagStreamEvent>? _streamSubscription;

  String _currentQuery = '';
  String _streamedAnswer = '';
  List<Citation> _citations = [];
  List<AnswerSegment> _parsedSegments = [];
  List<RagProcessStep> _processSteps = [];
  bool _isStreaming = false;
  bool _isComplete = false;
  String? _errorMessage;
  String? _statusStage;
  String? _statusDetail;
  DateTime? _queryStartedAt;
  Duration? _lastDuration;

  RagSessionProvider({required IRagStreamRepository repository})
    : _repository = repository;

  String get currentQuery => _currentQuery;
  String get streamedAnswer => _streamedAnswer;
  List<Citation> get citations => List.unmodifiable(_citations);
  List<AnswerSegment> get parsedSegments => List.unmodifiable(_parsedSegments);
  List<RagProcessStep> get processSteps => List.unmodifiable(_processSteps);
  bool get isStreaming => _isStreaming;
  bool get isComplete => _isComplete;
  String? get errorMessage => _errorMessage;
  String? get statusStage => _statusStage;
  String? get statusDetail => _statusDetail;
  DateTime? get queryStartedAt => _queryStartedAt;
  Duration? get lastDuration => _lastDuration;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Citation? getCitationById(int id) {
    try {
      return _citations.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void submitQuery(
    String prompt, {
    ProfileSettings? settings,
    List<String> selectedDocumentIds = const [],
  }) {
    if (prompt.trim().isEmpty) return;

    // Cancel existing stream before starting a new one
    cancelActiveStream();

    final normalizedDocIds = selectedDocumentIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final String scopeSummary;
    if (normalizedDocIds.isEmpty) {
      scopeSummary = 'whole corpus';
    } else if (normalizedDocIds.length == 1) {
      scopeSummary = '1 selected PDF';
    } else {
      scopeSummary = '${normalizedDocIds.length} selected PDFs';
    }

    _currentQuery = prompt.trim();
    _streamedAnswer = '';
    _citations = [];
    _parsedSegments = [];
    _queryStartedAt = DateTime.now();
    _lastDuration = null;
    _processSteps = [
      RagProcessStep(
        id: 'prepare',
        title: 'Initializing query pipeline',
        detail:
            settings?.useOfflineSimulation == true
                ? 'Preparing local offline simulation ($scopeSummary)'
                : 'Target: ${settings?.sseEndpoint ?? 'http://localhost:8000/questions/stream'} · $scopeSummary',
        state: ProcessStepState.active,
      ),
    ];
    _errorMessage = null;
    _statusStage = 'Initializing query pipeline';
    _statusDetail =
        settings?.useOfflineSimulation == true
            ? 'Preparing local offline simulation...'
            : 'Connecting to ${settings?.sseEndpoint ?? 'backend'}...';
    _isStreaming = true;
    _isComplete = false;
    notifyListeners();

    _streamSubscription = _repository
        .queryStream(
          prompt,
          sseUrl: settings?.sseEndpoint,
          apiKey: settings?.apiKey,
          additionalParams: {
            'denseOnly': settings?.enableDenseOnly ?? false,
            'topK': settings?.topK ?? 5,
            'similarityThreshold': settings?.similarityThreshold ?? 0.75,
            'useOfflineSimulation': settings?.useOfflineSimulation ?? false,
            'documentIds': normalizedDocIds,
          },
        )
        .listen(
          _handleStreamEvent,
          onError: (err) {
            _isStreaming = false;
            _statusStage = null;
            _statusDetail = null;
            _errorMessage = 'Stream error: $err';
            _markActiveSteps(
              ProcessStepState.failed,
              detailOverride: _errorMessage,
            );
            _finishTiming();
            notifyListeners();
          },
          onDone: () {
            _isStreaming = false;
            _statusStage = null;
            _statusDetail = null;
            if (_errorMessage == null) {
              _isComplete = true;
              _markActiveSteps(ProcessStepState.completed);
            }
            _finishTiming();
            notifyListeners();
          },
        );
  }

  Duration _elapsedSinceStart() {
    final started = _queryStartedAt;
    if (started == null) return Duration.zero;
    return DateTime.now().difference(started);
  }

  void _finishTiming() {
    _lastDuration ??= _elapsedSinceStart();
  }

  void _markActiveSteps(
    ProcessStepState targetState, {
    String? detailOverride,
  }) {
    final elapsed = _elapsedSinceStart();
    _processSteps =
        _processSteps
            .map(
              (step) =>
                  step.state == ProcessStepState.active
                      ? step.copyWith(
                        state: targetState,
                        detail: detailOverride ?? step.detail,
                        elapsed: elapsed,
                      )
                      : step,
            )
            .toList();
  }

  void _upsertProcessStep({
    required String id,
    required String title,
    String? detail,
    required ProcessStepState state,
  }) {
    final elapsed = _elapsedSinceStart();
    final updated = <RagProcessStep>[];
    var found = false;

    for (final step in _processSteps) {
      if (step.id == id) {
        found = true;
        updated.add(
          step.copyWith(
            title: title,
            detail: detail ?? step.detail,
            state: state,
            elapsed: elapsed,
          ),
        );
      } else if (step.state == ProcessStepState.active) {
        updated.add(
          step.copyWith(state: ProcessStepState.completed, elapsed: elapsed),
        );
      } else {
        updated.add(step);
      }
    }

    if (!found) {
      updated.add(
        RagProcessStep(
          id: id,
          title: title,
          detail: detail,
          state: state,
          elapsed: elapsed,
        ),
      );
    }

    _processSteps = updated;
  }

  void _handleStreamEvent(RagStreamEvent event) {
    switch (event) {
      case QuestionEvent(question: final q):
        _currentQuery = q;
        notifyListeners();
      case StreamStatusEvent(
        stage: final stage,
        detail: final detail,
        stepId: final stepId,
        isCompleted: final isCompleted,
      ):
        _statusStage = stage;
        _statusDetail = detail;
        _upsertProcessStep(
          id: stepId ?? stage.toLowerCase().replaceAll(' ', '_'),
          title: stage,
          detail: detail,
          state:
              isCompleted
                  ? ProcessStepState.completed
                  : ProcessStepState.active,
        );
        notifyListeners();
      case AnswerChunkEvent(chunk: final delta):
        final isFirstChunk = _streamedAnswer.isEmpty;
        _statusStage = 'Streaming formatted answer';
        _statusDetail = null;
        if (isFirstChunk) {
          _upsertProcessStep(
            id: 'render',
            title: 'Formatting grounded synthesis',
            detail: 'Streaming response tokens & linking inline citations',
            state: ProcessStepState.active,
          );
        }
        _streamedAnswer += delta;
        _parsedSegments = CitationParser.parse(_streamedAnswer);
        notifyListeners();
      case CitationsEvent(citations: final list):
        _citations = list;
        _statusStage = 'Linked ${list.length} citations';
        _statusDetail = 'Formatting grounded response...';
        _upsertProcessStep(
          id: 'citations',
          title:
              'Matched ${list.length} source citation${list.length == 1 ? '' : 's'}',
          detail:
              list.isEmpty
                  ? 'No matching source spans returned'
                  : list.map((c) => c.displayTitle).take(3).join(' · '),
          state: ProcessStepState.completed,
        );
        // Re-parse segments so any citation badges correlate with the citations list
        _parsedSegments = CitationParser.parse(_streamedAnswer);
        notifyListeners();
      case StreamDoneEvent():
        _isStreaming = false;
        _isComplete = true;
        _statusStage = null;
        _statusDetail = null;
        _markActiveSteps(ProcessStepState.completed);
        _finishTiming();
        _parsedSegments = CitationParser.parse(_streamedAnswer);
        notifyListeners();
      case StreamErrorEvent(message: final msg, isInterrupted: _):
        _isStreaming = false;
        _statusStage = null;
        _statusDetail = null;
        _errorMessage = msg;
        _markActiveSteps(ProcessStepState.failed, detailOverride: msg);
        _finishTiming();
        notifyListeners();
    }
  }

  void cancelActiveStream() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _repository.cancelStream();
    if (_isStreaming) {
      _isStreaming = false;
      _statusStage = null;
      _statusDetail = null;
      _markActiveSteps(
        ProcessStepState.failed,
        detailOverride: 'Stopped by user',
      );
      _finishTiming();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    cancelActiveStream();
    super.dispose();
  }
}
