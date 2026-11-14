import '../models/corpus.dart';

abstract class ICorpusRepository {
  Future<List<DocumentEntry>> getCorpusManifest();

  Future<DocumentEntry> uploadDocument({
    required String filename,
    required String documentsUrl,
    String? filePath,
    List<int>? bytes,
    String? apiKey,
  });

  Future<DocumentEntry> simulateUpload({
    required String filename,
    required int byteLength,
  });

  Future<void> deleteDocument(String documentId);
}
