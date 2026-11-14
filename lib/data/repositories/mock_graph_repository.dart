import '../../domain/models/knowledge_graph.dart';
import '../../domain/repositories/i_graph_repository.dart';

class MockGraphRepository implements IGraphRepository {
  @override
  Future<KnowledgeGraphData> getKnowledgeGraph({String? focusChunkId}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final nodes = [
      const GraphNode(
        id: 'n_rag',
        label: 'RAG Pipeline',
        category: 'Concept',
        centrality: 0.98,
      ),
      const GraphNode(
        id: 'n_dense',
        label: 'Dense Embedder (1536-D)',
        category: 'Component',
        centrality: 0.85,
      ),
      const GraphNode(
        id: 'n_bm25',
        label: 'BM25 Lexical Index',
        category: 'Component',
        centrality: 0.78,
      ),
      const GraphNode(
        id: 'n_rerank',
        label: 'BGE Cross-Encoder',
        category: 'Component',
        centrality: 0.88,
      ),
      const GraphNode(
        id: 'n_hnsw',
        label: 'HNSW Graph Index',
        category: 'Storage',
        centrality: 0.74,
      ),
      const GraphNode(
        id: 'n_doc1',
        label: 'Neural IR Foundations',
        category: 'Document',
        centrality: 0.65,
      ),
      const GraphNode(
        id: 'n_doc2',
        label: 'Hierarchical Reranking',
        category: 'Document',
        centrality: 0.61,
      ),
      const GraphNode(
        id: 'n_llm',
        label: 'Synthesis Generator',
        category: 'Model',
        centrality: 0.92,
      ),
    ];

    final edges = [
      const GraphEdge(
        sourceId: 'n_rag',
        targetId: 'n_dense',
        relation: 'routes_to',
        weight: 0.95,
      ),
      const GraphEdge(
        sourceId: 'n_rag',
        targetId: 'n_bm25',
        relation: 'parallel_searches',
        weight: 0.80,
      ),
      const GraphEdge(
        sourceId: 'n_dense',
        targetId: 'n_hnsw',
        relation: 'indexes_via',
        weight: 0.90,
      ),
      const GraphEdge(
        sourceId: 'n_hnsw',
        targetId: 'n_rerank',
        relation: 'feeds_candidates',
        weight: 0.88,
      ),
      const GraphEdge(
        sourceId: 'n_bm25',
        targetId: 'n_rerank',
        relation: 'feeds_sparse_candidates',
        weight: 0.75,
      ),
      const GraphEdge(
        sourceId: 'n_rerank',
        targetId: 'n_llm',
        relation: 'injects_context',
        weight: 0.96,
      ),
      const GraphEdge(
        sourceId: 'n_doc1',
        targetId: 'n_dense',
        relation: 'tokenized_by',
        weight: 0.70,
      ),
      const GraphEdge(
        sourceId: 'n_doc2',
        targetId: 'n_rerank',
        relation: 'grounding_data',
        weight: 0.72,
      ),
    ];

    return KnowledgeGraphData(nodes: nodes, edges: edges);
  }
}
