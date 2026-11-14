import 'dart:math';
import '../../domain/models/telemetry.dart';
import '../../domain/repositories/i_telemetry_repository.dart';

class MockTelemetryRepository implements ITelemetryRepository {
  final Random _rnd = Random();

  @override
  Future<TelemetryData> getTelemetryForQuery({String? queryId}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final embedMs = 20 + _rnd.nextInt(15);
    final searchMs = 35 + _rnd.nextInt(25);
    final rerankMs = 55 + _rnd.nextInt(35);
    final totalMs = embedMs + searchMs + rerankMs;

    return TelemetryData(
      totalLatencyMs: totalMs,
      embeddingLatencyMs: embedMs,
      vectorSearchLatencyMs: searchMs,
      rerankLatencyMs: rerankMs,
      denseRetrievalScore: 0.88 + (_rnd.nextDouble() * 0.08),
      sparseBM25Score: 12.4 + (_rnd.nextDouble() * 4.2),
      rerankScore: 0.92 + (_rnd.nextDouble() * 0.06),
      totalCandidates: 128,
      prunedCandidates: 16,
      rerankerModel: 'bge-reranker-v2-m3',
    );
  }
}
