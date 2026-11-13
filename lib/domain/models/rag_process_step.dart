enum ProcessStepState { active, completed, failed }

/// Represents a single observable stage in the RAG query pipeline.
class RagProcessStep {
  final String id;
  final String title;
  final String? detail;
  final ProcessStepState state;
  final Duration elapsed;

  const RagProcessStep({
    required this.id,
    required this.title,
    this.detail,
    required this.state,
    this.elapsed = Duration.zero,
  });

  RagProcessStep copyWith({
    String? title,
    String? detail,
    ProcessStepState? state,
    Duration? elapsed,
  }) {
    return RagProcessStep(
      id: id,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      state: state ?? this.state,
      elapsed: elapsed ?? this.elapsed,
    );
  }
}
