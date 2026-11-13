import '../models/vector_inspection.dart';

abstract class IVectorInspectorRepository {
  Future<VectorInspectionData> getChunkInspection(String chunkId);
}
