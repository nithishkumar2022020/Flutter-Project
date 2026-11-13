import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_proj_dq/data/repositories/mock_corpus_repository.dart';
import 'package:my_flutter_proj_dq/data/repositories/mock_graph_repository.dart';
import 'package:my_flutter_proj_dq/data/repositories/mock_telemetry_repository.dart';
import 'package:my_flutter_proj_dq/data/repositories/mock_vector_inspector_repository.dart';
import 'package:my_flutter_proj_dq/domain/models/corpus.dart';

void main() {
  group('Secondary Mock Repositories Contract Tests', () {
    test('MockTelemetryRepository returns valid non-null metrics', () async {
      final repo = MockTelemetryRepository();
      final data = await repo.getTelemetryForQuery();

      expect(data.totalLatencyMs, greaterThan(0));
      expect(data.denseRetrievalScore, inInclusiveRange(0.0, 1.0));
      expect(data.sparseBM25Score, greaterThan(0.0));
      expect(data.rerankScore, inInclusiveRange(0.0, 1.0));
      expect(data.rerankerModel.isNotEmpty, true);
    });

    test(
      'MockCorpusRepository loads manifest and simulates upload cleanly',
      () async {
        final repo = MockCorpusRepository();
        final manifest = await repo.getCorpusManifest();

        expect(manifest.isNotEmpty, true);
        expect(manifest.first.title.isNotEmpty, true);
        expect(manifest.first.status, IngestionStatus.indexed);

        final uploaded = await repo.simulateUpload(
          filename: 'new_evidence_corpus.pdf',
          byteLength: 500000,
        );
        expect(uploaded.filename, 'new_evidence_corpus.pdf');
        expect(uploaded.chunkCount, greaterThan(0));

        final updatedManifest = await repo.getCorpusManifest();
        expect(updatedManifest.any((d) => d.id == uploaded.id), true);
      },
    );

    test(
      'MockVectorInspectorRepository returns 1536-D embedding stats and BM25 weights',
      () async {
        final repo = MockVectorInspectorRepository();
        final data = await repo.getChunkInspection('chk_test_123');

        expect(data.chunkId, 'chk_test_123');
        expect(data.dimension, 1536);
        expect(data.previewEmbedding.length, 64);
        expect(data.bm25TokenWeights.isNotEmpty, true);
        expect(data.rawChunkText.isNotEmpty, true);
      },
    );

    test(
      'MockGraphRepository returns static node and edge sets cleanly',
      () async {
        final repo = MockGraphRepository();
        final graph = await repo.getKnowledgeGraph();

        expect(graph.nodes.isNotEmpty, true);
        expect(graph.edges.isNotEmpty, true);
        expect(graph.nodes.any((n) => n.category == 'Concept'), true);
        expect(graph.edges.any((e) => e.relation == 'routes_to'), true);
      },
    );
  });
}
