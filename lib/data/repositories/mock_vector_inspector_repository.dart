import 'dart:math';
import '../../domain/models/vector_inspection.dart';
import '../../domain/repositories/i_vector_inspector_repository.dart';

class MockVectorInspectorRepository implements IVectorInspectorRepository {
  final Random _rnd = Random();

  @override
  Future<VectorInspectionData> getChunkInspection(String chunkId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Generate deterministic pseudo-random 64 preview values representing the 1536-D embedding
    final seed = chunkId.hashCode;
    final prng = Random(seed);
    final preview = List.generate(64, (_) => (prng.nextDouble() * 2 - 1.0));

    final tokenWeights = <String, double>{
      'retrieval': 4.38 + (_rnd.nextDouble() * 0.4),
      'vector': 3.91 + (_rnd.nextDouble() * 0.3),
      'neural': 3.42 + (_rnd.nextDouble() * 0.2),
      'reranking': 2.95 + (_rnd.nextDouble() * 0.3),
      'manifold': 2.71 + (_rnd.nextDouble() * 0.2),
      'compression': 2.15 + (_rnd.nextDouble() * 0.2),
      'token': 1.84 + (_rnd.nextDouble() * 0.1),
      'attention': 1.62 + (_rnd.nextDouble() * 0.1),
    };

    return VectorInspectionData(
      chunkId: chunkId,
      documentTitle: 'Neural IR & Vector Indexing Architecture (Chunk #${chunkId.hashCode % 500})',
      dimension: 1536,
      previewEmbedding: preview,
      vectorMagnitude: 1.002,
      vectorMean: 0.0014,
      vectorMin: -0.0984,
      vectorMax: 0.1142,
      bm25TokenWeights: tokenWeights,
      rawChunkText:
          'Dense vector retrieval projects tokens into a unified 1536-D latent manifold, bypassing vocabulary mismatch. '
          'Tokens are embedded using contextual transformers, and cosine similarity over an HNSW index produces top-K candidate spans.',
    );
  }
}
