import '../models/knowledge_graph.dart';

abstract class IGraphRepository {
  Future<KnowledgeGraphData> getKnowledgeGraph({String? focusChunkId});
}
