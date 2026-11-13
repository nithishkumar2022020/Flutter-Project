import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_flutter_proj_dq/data/repositories/rag_stream_repository.dart';
import 'package:my_flutter_proj_dq/domain/models/rag_stream_event.dart';

void main() {
  group('RagStreamRepository Tests', () {
    test('yields QuestionEvent, CitationsEvent, AnswerChunks and DoneEvent in simulation', () async {
      final repository = RagStreamRepository();
      final events = <RagStreamEvent>[];
      await for (final event in repository.queryStream('Test prompt')) {
        events.add(event);
      }

      expect(events.isNotEmpty, true);
      expect(events.first, isA<QuestionEvent>());
      expect((events.first as QuestionEvent).question, 'Test prompt');

      final citationsEvent = events.whereType<CitationsEvent>().firstOrNull;
      expect(citationsEvent, isNotNull);
      expect(citationsEvent!.citations.isNotEmpty, true);
      expect(citationsEvent.citations.first.id, 1);

      final chunks = events.whereType<AnswerChunkEvent>().toList();
      expect(chunks.length, greaterThan(5));

      expect(events.last, isA<StreamDoneEvent>());
    });

    test('POST /questions JSON contract parses answer and document_id/filename/page citations without auth header', () async {
      late http.Request capturedRequest;
      final mockClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'answer': 'The main conclusion is clear [1].',
            'citations': [
              {
                'document_id': 'doc_99',
                'filename': 'annual_report.pdf',
                'page': 3,
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repository = RagStreamRepository(client: mockClient);
      final events = <RagStreamEvent>[];
      await for (final event in repository.queryStream(
        'What is the main conclusion?',
        sseUrl: 'http://localhost:8000/questions',
      )) {
        events.add(event);
      }

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.toString(), 'http://localhost:8000/questions');
      expect(capturedRequest.headers.containsKey('Authorization'), false);
      expect(jsonDecode(capturedRequest.body), {'question': 'What is the main conclusion?'});

      final citationsEvent = events.whereType<CitationsEvent>().first;
      expect(citationsEvent.citations.length, 1);
      final c = citationsEvent.citations.first;
      expect(c.id, 1);
      expect(c.documentId, 'doc_99');
      expect(c.page, 3);
      expect(c.sourceDoc, 'annual_report.pdf (p.3)');

      final fullAnswer = events.whereType<AnswerChunkEvent>().map((e) => e.chunk).join();
      expect(fullAnswer, 'The main conclusion is clear [1].');
      expect(events.last, isA<StreamDoneEvent>());
    });

    test('HTTP error yields StreamErrorEvent with status details', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal error', 500);
      });

      final repository = RagStreamRepository(client: mockClient);
      final events = <RagStreamEvent>[];
      await for (final event in repository.queryStream(
        'Test',
        sseUrl: 'http://localhost:8000/questions',
      )) {
        events.add(event);
      }

      final errorEvent = events.whereType<StreamErrorEvent>().firstOrNull;
      expect(errorEvent, isNotNull);
      expect(errorEvent!.message, contains('500'));
    });

    test('HTTP 503 extracts FastAPI JSON detail and emits status + error events', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'detail': 'Vector store index unavailable'}),
          503,
          reasonPhrase: 'Service Unavailable',
          headers: {'content-type': 'application/json'},
        );
      });

      final repository = RagStreamRepository(client: mockClient);
      final events = <RagStreamEvent>[];
      await for (final event in repository.queryStream(
        'Test',
        sseUrl: 'http://localhost:8000/questions',
      )) {
        events.add(event);
      }

      expect(events.whereType<StreamStatusEvent>(), isNotEmpty);
      final errorEvent = events.whereType<StreamErrorEvent>().firstOrNull;
      expect(errorEvent, isNotNull);
      expect(errorEvent!.message, contains('503'));
      expect(errorEvent.message, contains('Service Unavailable'));
      expect(errorEvent.message, contains('Vector store index unavailable'));
    });

    test('cancelStream stops incoming events', () async {
      final repository = RagStreamRepository();
      final events = <RagStreamEvent>[];
      final subscription = repository.queryStream('Test prompt').listen((event) {
        events.add(event);
        if (events.length == 3) {
          repository.cancelStream();
        }
      });

      await Future.delayed(const Duration(milliseconds: 300));
      await subscription.cancel();

      expect(events.any((e) => e is StreamDoneEvent), false);
    });

    test('POST /questions/stream parses SSE answer_chunk and citations events', () async {
      late http.BaseRequest capturedRequest;
      final mockClient = MockClient.streaming((request, bodyStream) async {
        capturedRequest = request;
        await bodyStream.drain<void>();
        final ssePayload = [
          'event: answer_chunk\ndata: {"text":"Hello "}\n\n',
          'event: answer_chunk\ndata: {"text":"world [1]."}\n\n',
          'event: citations\ndata: {"citations":[{"document_id":"doc_1","filename":"paper.pdf","page":2}]}\n\n',
        ];
        return http.StreamedResponse(
          Stream.fromIterable(ssePayload.map(utf8.encode)),
          200,
          headers: {'content-type': 'text/event-stream; charset=utf-8'},
        );
      });

      final repository = RagStreamRepository(client: mockClient);
      final events = await repository
          .queryStream('Hello?', sseUrl: 'http://localhost:8000/questions/stream')
          .toList();

      expect(capturedRequest.url.toString(), 'http://localhost:8000/questions/stream');
      expect(events.whereType<AnswerChunkEvent>().map((e) => e.chunk).toList(), ['Hello ', 'world [1].']);
      final citations = events.whereType<CitationsEvent>().single.citations;
      expect(citations.length, 1);
      expect(citations.first.documentId, 'doc_1');
      expect(citations.first.page, 2);
      expect(events.last, isA<StreamDoneEvent>());
    });

    test('POST /questions/stream parses SSE error event and stops without StreamDoneEvent', () async {
      final mockClient = MockClient.streaming((request, bodyStream) async {
        await bodyStream.drain<void>();
        const sseError = 'event: error\ndata: {"detail":"Gemini API quota exhausted"}\n\n';
        return http.StreamedResponse(
          Stream.value(utf8.encode(sseError)),
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      });

      final repository = RagStreamRepository(client: mockClient);
      final events = await repository
          .queryStream('Hello?', sseUrl: 'http://localhost:8000/questions/stream')
          .toList();

      final err = events.whereType<StreamErrorEvent>().single;
      expect(err.message, 'Gemini API quota exhausted');
      expect(events.any((e) => e is StreamDoneEvent), false);
    });

    test('falls back from /questions/stream 404 to /questions JSON endpoint', () async {
      final requestedUrls = <String>[];
      final mockClient = MockClient((request) async {
        requestedUrls.add(request.url.toString());
        if (request.url.path.endsWith('/stream')) {
          return http.Response('Not Found', 404);
        }
        return http.Response(
          jsonEncode({'answer': 'Fallback answer.', 'citations': []}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repository = RagStreamRepository(client: mockClient);
      final events = await repository
          .queryStream('Hello?', sseUrl: 'http://localhost:8000/questions/stream')
          .toList();

      expect(requestedUrls, [
        'http://localhost:8000/questions/stream',
        'http://localhost:8000/questions',
      ]);
      expect(events.whereType<AnswerChunkEvent>().map((e) => e.chunk).join(), 'Fallback answer.');
      expect(events.last, isA<StreamDoneEvent>());
    });
  });
}
