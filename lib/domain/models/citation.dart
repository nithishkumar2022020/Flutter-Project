/// Represents a single source citation retrieved during RAG generation.
class Citation {
  final int id;
  final String chunkId;
  final String textSpan;
  final String sourceDoc;
  final double score;
  final String? documentId;
  final int? page;

  const Citation({
    required this.id,
    required this.chunkId,
    required this.textSpan,
    required this.sourceDoc,
    required this.score,
    this.documentId,
    this.page,
  });

  /// Clean basename without directory path or trailing ` (p.N)` suffix.
  String get cleanFilename {
    var base = sourceDoc.replaceAll(RegExp(r'\s*\(p\.\s*\d+\)\s*$'), '').trim();
    if (base.contains('/')) {
      base = base.split('/').last;
    }
    if (base.contains('\\')) {
      base = base.split('\\').last;
    }
    return base.isEmpty ? sourceDoc : base;
  }

  /// Human-friendly title with storage prefixes (UUID/timestamp) and extension stripped.
  String get displayTitle {
    var name = cleanFilename;
    // Strip common `<uuid>_` or `<timestamp>_` storage prefixes.
    name = name.replaceFirst(
      RegExp(r'^(?:[0-9a-fA-F]{8}-[0-9a-fA-F-]{27}|\d{10,13})[_-]+'),
      '',
    );
    name = name.replaceFirst(RegExp(r'\.[a-zA-Z0-9]{2,5}$'), '');
    name = name.replaceAll(RegExp(r'[_-]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    return name.isEmpty ? cleanFilename : name;
  }

  factory Citation.fromJson(Map<String, dynamic> json, {int fallbackId = 1}) {
    final docId = json['document_id']?.toString() ?? json['documentId']?.toString();
    final filename = json['filename']?.toString() ??
        json['sourceDoc']?.toString() ??
        json['source_doc']?.toString() ??
        'Document';

    final rawPage = json['page'];
    final parsedPage = rawPage is int ? rawPage : int.tryParse(rawPage?.toString() ?? '');
    final pageSuffix = parsedPage != null ? ' (p.$parsedPage)' : '';

    final resolvedChunkId = json['chunkId']?.toString() ??
        json['chunk_id']?.toString() ??
        (docId != null && docId.isNotEmpty
            ? '${docId}_p${parsedPage ?? fallbackId}'
            : 'chk_$fallbackId');

    final resolvedSpan = json['textSpan']?.toString() ??
        json['text_span']?.toString() ??
        json['excerpt']?.toString() ??
        'Cited from $filename${parsedPage != null ? ' — Page $parsedPage' : ''}.';

    final resolvedId = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '') ?? fallbackId;

    final resolvedScore = (json['score'] is num)
        ? (json['score'] as num).toDouble()
        : double.tryParse(json['score']?.toString() ?? '') ?? 1.0;

    return Citation(
      id: resolvedId,
      chunkId: resolvedChunkId,
      textSpan: resolvedSpan,
      sourceDoc: filename.contains('(p.') ? filename : '$filename$pageSuffix',
      score: resolvedScore,
      documentId: docId,
      page: parsedPage,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chunkId': chunkId,
        'textSpan': textSpan,
        'sourceDoc': sourceDoc,
        'score': score,
        if (documentId != null) 'document_id': documentId,
        if (page != null) 'page': page,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Citation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          chunkId == other.chunkId;

  @override
  int get hashCode => id.hashCode ^ chunkId.hashCode;
}
