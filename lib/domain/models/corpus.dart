enum IngestionStatus {
  indexed,
  indexing,
  failed,
  pending,
}

class DocumentEntry {
  final String id;
  final String title;
  final String filename;
  final int chunkCount;
  final int sizeBytes;
  final DateTime updatedAt;
  final IngestionStatus status;
  final double indexingProgress; // 0.0 to 1.0

  const DocumentEntry({
    required this.id,
    required this.title,
    required this.filename,
    required this.chunkCount,
    required this.sizeBytes,
    required this.updatedAt,
    required this.status,
    this.indexingProgress = 1.0,
  });

  static String titleFromFilename(String filename) {
    return filename
        .replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '')
        .replaceAll('_', ' ');
  }

  factory DocumentEntry.fromJson(Map<String, dynamic> json) {
    final filename = json['filename']?.toString() ?? 'document.pdf';
    final statusName = json['status']?.toString() ?? IngestionStatus.indexed.name;
    final parsedStatus = IngestionStatus.values.firstWhere(
      (s) => s.name == statusName,
      orElse: () => IngestionStatus.indexed,
    );

    return DocumentEntry(
      id: json['id']?.toString() ?? json['document_id']?.toString() ?? '',
      title: json['title']?.toString() ?? titleFromFilename(filename),
      filename: filename,
      chunkCount: json['chunkCount'] is int
          ? json['chunkCount'] as int
          : int.tryParse(json['chunks']?.toString() ?? '0') ?? 0,
      sizeBytes: json['sizeBytes'] is int
          ? json['sizeBytes'] as int
          : int.tryParse(json['sizeBytes']?.toString() ?? '0') ?? 0,
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      status: parsedStatus,
      indexingProgress: (json['indexingProgress'] is num)
          ? (json['indexingProgress'] as num).toDouble()
          : 1.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'filename': filename,
        'chunkCount': chunkCount,
        'sizeBytes': sizeBytes,
        'updatedAt': updatedAt.toIso8601String(),
        'status': status.name,
        'indexingProgress': indexingProgress,
      };

  DocumentEntry copyWith({
    String? id,
    String? title,
    String? filename,
    int? chunkCount,
    int? sizeBytes,
    DateTime? updatedAt,
    IngestionStatus? status,
    double? indexingProgress,
  }) {
    return DocumentEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      filename: filename ?? this.filename,
      chunkCount: chunkCount ?? this.chunkCount,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      indexingProgress: indexingProgress ?? this.indexingProgress,
    );
  }
}
