import '../models/rag_stream_event.dart';

abstract class IRagStreamRepository {
  /// Connects to the SSE endpoint or fallback simulation and yields stream events.
  Stream<RagStreamEvent> queryStream(
    String prompt, {
    String? sseUrl,
    String? apiKey,
    Map<String, dynamic>? additionalParams,
  });

  /// Cancels any currently ongoing stream.
  void cancelStream();
}
