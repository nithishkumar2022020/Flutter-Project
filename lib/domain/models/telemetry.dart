class TelemetryData {
  final int totalLatencyMs;
  final int embeddingLatencyMs;
  final int vectorSearchLatencyMs;
  final int rerankLatencyMs;
  final double denseRetrievalScore;
  final double sparseBM25Score;
  final double rerankScore;
  final int totalCandidates;
  final int prunedCandidates;
  final String rerankerModel;

  const TelemetryData({
    required this.totalLatencyMs,
    required this.embeddingLatencyMs,
    required this.vectorSearchLatencyMs,
    required this.rerankLatencyMs,
    required this.denseRetrievalScore,
    required this.sparseBM25Score,
    required this.rerankScore,
    required this.totalCandidates,
    required this.prunedCandidates,
    required this.rerankerModel,
  });

  factory TelemetryData.mock() {
    return const TelemetryData(
      totalLatencyMs: 142,
      embeddingLatencyMs: 28,
      vectorSearchLatencyMs: 44,
      rerankLatencyMs: 70,
      denseRetrievalScore: 0.892,
      sparseBM25Score: 14.85,
      rerankScore: 0.941,
      totalCandidates: 100,
      prunedCandidates: 10,
      rerankerModel: 'bge-reranker-large-v2',
    );
  }
}
