class VectorInspectionData {
  final String chunkId;
  final String documentTitle;
  final int dimension;
  final List<double> previewEmbedding; // sample dimensions from 1536-D
  final double vectorMagnitude;
  final double vectorMean;
  final double vectorMin;
  final double vectorMax;
  final Map<String, double> bm25TokenWeights;
  final String rawChunkText;

  const VectorInspectionData({
    required this.chunkId,
    required this.documentTitle,
    required this.dimension,
    required this.previewEmbedding,
    required this.vectorMagnitude,
    required this.vectorMean,
    required this.vectorMin,
    required this.vectorMax,
    required this.bm25TokenWeights,
    required this.rawChunkText,
  });
}
