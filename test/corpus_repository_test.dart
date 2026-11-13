import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_proj_dq/data/repositories/corpus_repository.dart';
import 'package:my_flutter_proj_dq/domain/models/corpus.dart';
import 'package:my_flutter_proj_dq/presentation/providers/corpus_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CorpusProvider.resolveDocumentsUrl', () {
    test('maps questions endpoint to /documents on the same origin', () {
      expect(
        CorpusProvider.resolveDocumentsUrl('http://localhost:8000/questions'),
        'http://localhost:8000/documents',
      );
      expect(
        CorpusProvider.resolveDocumentsUrl('https://rag.internal:8443/v1/questions?foo=bar'),
        'https://rag.internal:8443/documents',
      );
      expect(
        CorpusProvider.resolveDocumentsUrl(''),
        'http://localhost:8000/documents',
      );
    });
  });

  group('CorpusRepository.uploadDocument', () {
    test('sends multipart POST with field file, parses 201 JSON, and persists manifest', () async {
      late String capturedMethod;
      late Uri capturedUrl;
      late String capturedBody;
      String? capturedAuth;
      String? capturedContentType;

      final mockClient = MockClient.streaming((request, bodyStream) async {
        capturedMethod = request.method;
        capturedUrl = request.url;
        capturedAuth = request.headers['Authorization'];
        capturedContentType = request.headers['content-type'] ?? request.headers['Content-Type'];
        final bodyBytes = await bodyStream.toBytes();
        capturedBody = utf8.decode(bodyBytes, allowMalformed: true);

        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              jsonEncode({
                'document_id': 'doc_9876',
                'filename': 'example.pdf',
                'chunks': 12,
              }),
            ),
          ),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = CorpusRepository(client: mockClient);
      final entry = await repo.uploadDocument(
        filename: 'example.pdf',
        documentsUrl: 'http://localhost:8000/documents',
        bytes: utf8.encode('%PDF-1.4 sample content'),
      );

      expect(capturedMethod, 'POST');
      expect(capturedUrl.toString(), 'http://localhost:8000/documents');
      expect(capturedAuth, isNull);
      expect(capturedContentType, contains('multipart/form-data'));
      expect(capturedBody, contains('name="file"'));
      expect(capturedBody, contains('filename="example.pdf"'));
      expect(capturedBody, contains('%PDF-1.4 sample content'));

      expect(entry.id, 'doc_9876');
      expect(entry.filename, 'example.pdf');
      expect(entry.chunkCount, 12);
      expect(entry.status, IngestionStatus.indexed);

      // Verify manifest persists across repository instances
      final freshRepo = CorpusRepository();
      final persisted = await freshRepo.getCorpusManifest();
      expect(persisted, hasLength(1));
      expect(persisted.first.id, 'doc_9876');
      expect(persisted.first.chunkCount, 12);
    });

    test('includes Bearer Authorization header when apiKey is provided', () async {
      String? capturedAuth;

      final mockClient = MockClient.streaming((request, bodyStream) async {
        capturedAuth = request.headers['Authorization'];
        await bodyStream.drain<void>();
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              jsonEncode({
                'document_id': 'doc_auth',
                'filename': 'secured.pdf',
                'chunks': 4,
              }),
            ),
          ),
          201,
        );
      });

      final repo = CorpusRepository(client: mockClient);
      await repo.uploadDocument(
        filename: 'secured.pdf',
        documentsUrl: 'http://localhost:8000/documents',
        bytes: [1, 2, 3],
        apiKey: 'secret-token',
      );

      expect(capturedAuth, 'Bearer secret-token');
    });

    test('throws descriptive error with backend detail on 422 response', () async {
      final mockClient = MockClient.streaming((request, bodyStream) async {
        await bodyStream.drain<void>();
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              jsonEncode({'detail': 'PDF has no extractable text'}),
            ),
          ),
          422,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = CorpusRepository(client: mockClient);
      await expectLater(
        repo.uploadDocument(
          filename: 'empty.pdf',
          documentsUrl: 'http://localhost:8000/documents',
          bytes: [0],
        ),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('HTTP 422') && e.toString().contains('PDF has no extractable text'),
          ),
        ),
      );
    });
  });
}
