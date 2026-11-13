class GraphNode {
  final String id;
  final String label;
  final String category; // 'Entity', 'Concept', 'Document', 'Chunk'
  final double centrality;

  const GraphNode({
    required this.id,
    required this.label,
    required this.category,
    required this.centrality,
  });
}

class GraphEdge {
  final String sourceId;
  final String targetId;
  final String relation;
  final double weight;

  const GraphEdge({
    required this.sourceId,
    required this.targetId,
    required this.relation,
    required this.weight,
  });
}

class KnowledgeGraphData {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  const KnowledgeGraphData({
    required this.nodes,
    required this.edges,
  });
}
