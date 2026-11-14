import 'citation.dart';

sealed class RagStreamEvent {
  const RagStreamEvent();
}

class QuestionEvent extends RagStreamEvent {
  final String question;
  const QuestionEvent(this.question);
}

class StreamStatusEvent extends RagStreamEvent {
  final String stage;
  final String? detail;
  final String? stepId;
  final bool isCompleted;

  const StreamStatusEvent(
    this.stage, {
    this.detail,
    this.stepId,
    this.isCompleted = false,
  });
}

class AnswerChunkEvent extends RagStreamEvent {
  final String chunk;
  const AnswerChunkEvent(this.chunk);
}

class CitationsEvent extends RagStreamEvent {
  final List<Citation> citations;
  const CitationsEvent(this.citations);
}

class StreamDoneEvent extends RagStreamEvent {
  const StreamDoneEvent();
}

class StreamErrorEvent extends RagStreamEvent {
  final String message;
  final bool isInterrupted;
  const StreamErrorEvent(this.message, {this.isInterrupted = false});
}
