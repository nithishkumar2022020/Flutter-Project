import 'package:flutter/foundation.dart';
import '../../domain/models/corpus.dart';
import '../../domain/repositories/i_corpus_repository.dart';

class CorpusProvider extends ChangeNotifier {
  final ICorpusRepository _repository;
  List<DocumentEntry> _documents = [];
  final Set<String> _selectedDocumentIds = {};
  bool _isLoading = false;
  bool _isUploading = false;
  String? _error;

  CorpusProvider({required ICorpusRepository repository})
      : _repository = repository {
    loadManifest();
  }

  List<DocumentEntry> get documents => List.unmodifiable(_documents);
  Set<String> get selectedDocumentIds => Set.unmodifiable(_selectedDocumentIds);
  List<DocumentEntry> get selectedDocuments =>
      _documents.where((d) => _selectedDocumentIds.contains(d.id)).toList(growable: false);
  bool isSelected(String documentId) => _selectedDocumentIds.contains(documentId);
  bool get hasSelection => _selectedDocumentIds.isNotEmpty;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get error => _error;

  void toggleSelection(String documentId) {
    if (_selectedDocumentIds.contains(documentId)) {
      _selectedDocumentIds.remove(documentId);
    } else {
      _selectedDocumentIds.add(documentId);
    }
    notifyListeners();
  }

  void setSelected(String documentId, bool selected) {
    final changed = selected
        ? _selectedDocumentIds.add(documentId)
        : _selectedDocumentIds.remove(documentId);
    if (changed) notifyListeners();
  }

  void applyDragRangeSelection({
    required int anchorIndex,
    required int targetIndex,
    required Set<String> baseSelection,
    bool selectRange = true,
  }) {
    if (_documents.isEmpty) return;
    final start = (anchorIndex < targetIndex ? anchorIndex : targetIndex).clamp(0, _documents.length - 1);
    final end = (anchorIndex > targetIndex ? anchorIndex : targetIndex).clamp(0, _documents.length - 1);

    final next = <String>{...baseSelection};
    for (var i = start; i <= end; i++) {
      final id = _documents[i].id;
      if (selectRange) {
        next.add(id);
      } else {
        next.remove(id);
      }
    }

    if (next.length == _selectedDocumentIds.length && next.containsAll(_selectedDocumentIds)) {
      return;
    }
    _selectedDocumentIds
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  void selectAll() {
    final allIds = _documents.map((d) => d.id).toSet();
    if (_selectedDocumentIds.length == allIds.length && _selectedDocumentIds.containsAll(allIds)) {
      return;
    }
    _selectedDocumentIds
      ..clear()
      ..addAll(allIds);
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedDocumentIds.isEmpty) return;
    _selectedDocumentIds.clear();
    notifyListeners();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  static String resolveDocumentsUrl(String questionEndpoint) {
    final trimmed = questionEndpoint.trim();
    if (trimmed.isEmpty) return 'http://localhost:8000/documents';
    try {
      final uri = Uri.parse(trimmed);
      if (uri.hasScheme && uri.host.isNotEmpty) {
        return Uri(
          scheme: uri.scheme,
          userInfo: uri.userInfo.isNotEmpty ? uri.userInfo : null,
          host: uri.host,
          port: uri.hasPort ? uri.port : null,
          path: '/documents',
        ).toString();
      }
    } catch (_) {}
    return 'http://localhost:8000/documents';
  }

  Future<void> loadManifest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _documents = await _repository.getCorpusManifest();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DocumentEntry?> uploadPdf({
    required String filename,
    required String endpointUrl,
    String? filePath,
    List<int>? bytes,
    String? apiKey,
    bool useOfflineSimulation = false,
  }) async {
    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      final DocumentEntry doc;
      if (useOfflineSimulation) {
        doc = await _repository.simulateUpload(
          filename: filename,
          byteLength: bytes?.length ?? 1850400,
        );
      } else {
        final documentsUrl = resolveDocumentsUrl(endpointUrl);
        doc = await _repository.uploadDocument(
          filename: filename,
          documentsUrl: documentsUrl,
          filePath: filePath,
          bytes: bytes,
          apiKey: apiKey,
        );
      }
      _documents = [doc, ..._documents.where((d) => d.id != doc.id)];
      return doc;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> simulateUploadDocument(String filename, int bytes) async {
    try {
      final doc = await _repository.simulateUpload(
        filename: filename,
        byteLength: bytes,
      );
      _documents = [doc, ..._documents];
      notifyListeners();
    } catch (e) {
      _error = 'Upload failed: $e';
      notifyListeners();
    }
  }

  Future<void> removeDocument(String id) async {
    try {
      await _repository.deleteDocument(id);
      _documents = _documents.where((d) => d.id != id).toList();
      _selectedDocumentIds.remove(id);
      notifyListeners();
    } catch (e) {
      _error = 'Delete failed: $e';
      notifyListeners();
    }
  }
}
