import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/citation.dart';
import '../../domain/models/rag_stream_event.dart';
import '../../domain/repositories/i_rag_stream_repository.dart';

class RagStreamRepository implements IRagStreamRepository {
  final http.Client? _injectedClient;
  http.Client? _ownedClient;
  bool _isCancelled = false;

  RagStreamRepository({http.Client? client}) : _injectedClient = client;

  @override
  void cancelStream() {
    _isCancelled = true;
    _ownedClient?.close();
    _ownedClient = null;
  }

  @override
  Stream<RagStreamEvent> queryStream(
    String prompt, {
    String? sseUrl,
    String? apiKey,
    Map<String, dynamic>? additionalParams,
  }) async* {
    _isCancelled = false;
    final targetUrl = sseUrl?.trim() ?? '';
    final useOfflineSim = additionalParams?['useOfflineSimulation'] == true;

    yield QuestionEvent(prompt);

    final topK = additionalParams?['topK'] ?? 5;
    final denseOnly = additionalParams?['denseOnly'] == true;
    final docIds = (additionalParams?['documentIds'] as List?)
            ?.whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList() ??
        const <String>[];

    final String scopeLabel;
    if (docIds.isEmpty) {
      scopeLabel = 'scope=whole database';
    } else if (docIds.length == 1) {
      scopeLabel = 'scope=single PDF (${docIds.first})';
    } else {
      scopeLabel = 'scope=${docIds.length} selected PDFs';
    }

    yield StreamStatusEvent(
      'Query parameters prepared',
      stepId: 'prepare',
      isCompleted: true,
      detail: '$scopeLabel · top_k=$topK · ${denseOnly ? 'dense vector' : 'hybrid'} retrieval',
    );

    if (useOfflineSim || targetUrl.isEmpty) {
      yield const StreamStatusEvent(
        'Searching local vector fixtures',
        stepId: 'backend_rag',
        detail: 'Running offline RAG retrieval & synthesis simulation...',
      );
      yield* _generateSimulatedStream(prompt);
      return;
    }

    final isHttpUrl = targetUrl.startsWith('http://') || targetUrl.startsWith('https://');
    if (!isHttpUrl) {
      yield StreamErrorEvent('Invalid backend URL: "$targetUrl"');
      return;
    }

    var activeUrl = targetUrl;
    var triedJsonFallback = false;
    int attempts = 0;
    const maxRetries = 1;

    while (attempts <= maxRetries && !_isCancelled) {
      attempts++;
      yield StreamStatusEvent(
        attempts > 1 && !triedJsonFallback
            ? 'Retrying backend connection'
            : 'Searching corpus & synthesizing',
        stepId: 'backend_rag',
        detail: attempts > 1 && !triedJsonFallback
            ? 'Attempt $attempts of ${maxRetries + 1} · POST $activeUrl'
            : 'POST $activeUrl · awaiting embedding, vector search & LLM response',
      );

      final http.Client client;
      if (_injectedClient != null) {
        client = _injectedClient;
      } else {
        _ownedClient = http.Client();
        client = _ownedClient!;
      }

      try {
        final request = http.Request('POST', Uri.parse(activeUrl));
        request.headers['Content-Type'] = 'application/json';
        request.headers['Accept'] = activeUrl.endsWith('/stream')
            ? 'text/event-stream, application/json'
            : 'application/json, text/event-stream';
        if (apiKey != null && apiKey.trim().isNotEmpty) {
          request.headers['Authorization'] = 'Bearer ${apiKey.trim()}';
        }

        final payload = <String, dynamic>{'question': prompt};
        if (docIds.length == 1) {
          payload['document_id'] = docIds.first;
        } else if (docIds.length > 1) {
          payload['document_ids'] = docIds;
        }
        request.body = jsonEncode(payload);

        final response = await client.send(request).timeout(const Duration(seconds: 30));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final contentType = response.headers['content-type']?.toLowerCase() ?? '';

          if (contentType.contains('text/event-stream')) {
            yield const StreamStatusEvent(
              'Streaming SSE response',
              stepId: 'stream',
              detail: 'Connected to live event stream...',
            );
            yield* _consumeSseStream(response.stream);
            return;
          } else {
            yield StreamStatusEvent(
              'Parsing grounded payload',
              stepId: 'parse',
              detail: 'HTTP ${response.statusCode} received · extracting citations & answer',
            );
            final bodyBytes = await response.stream.toBytes();
            if (_isCancelled) return;
            final bodyStr = utf8.decode(bodyBytes);
            yield* _consumeJsonResponse(bodyStr);
            return;
          }
        } else if ((response.statusCode == 404 || response.statusCode == 405) &&
            !triedJsonFallback &&
            activeUrl.endsWith('/questions/stream')) {
          await response.stream.drain<void>();
          triedJsonFallback = true;
          activeUrl = activeUrl.substring(0, activeUrl.length - '/stream'.length);
          attempts = 0; // Allow clean request on fallback endpoint
          yield StreamStatusEvent(
            'Falling back to JSON endpoint',
            stepId: 'fallback',
            isCompleted: true,
            detail: 'SSE endpoint returned HTTP ${response.statusCode} · switching to $activeUrl',
          );
          continue;
        } else {
          final errBytes = await response.stream.toBytes();
          final rawBody = utf8.decode(errBytes, allowMalformed: true).trim();
          final detail = _extractErrorDetail(rawBody);
          final reason = (response.reasonPhrase?.trim().isNotEmpty ?? false)
              ? ' (${response.reasonPhrase!.trim()})'
              : '';
          yield StreamErrorEvent(
            'HTTP ${response.statusCode}$reason from $activeUrl'
            '${detail.isNotEmpty ? ': $detail' : ' — Backend unavailable or failed to process the query.'}',
          );
          return;
        }
      } catch (e) {
        if (_isCancelled) {
          yield const StreamErrorEvent('Stream cancelled by user.', isInterrupted: true);
          return;
        }
        if (attempts <= maxRetries) {
          await Future.delayed(const Duration(milliseconds: 300));
          continue;
        }
        yield StreamErrorEvent(
          'Cannot reach $activeUrl ($e). Ensure backend is running & `adb reverse tcp:8000 tcp:8000` is active.',
        );
        return;
      } finally {
        _ownedClient?.close();
        _ownedClient = null;
      }
    }
  }

  String _extractErrorDetail(String rawBody) {
    if (rawBody.isEmpty) return '';
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map) {
        final detail = decoded['detail'] ?? decoded['message'] ?? decoded['error'];
        if (detail != null && detail.toString().trim().isNotEmpty) {
          return detail.toString().trim();
        }
      }
    } catch (_) {}
    return rawBody;
  }

  Stream<RagStreamEvent> _consumeJsonResponse(String bodyStr) async* {
    final decoded = jsonDecode(bodyStr);
    if (decoded is! Map<String, dynamic>) {
      yield const StreamErrorEvent('Unexpected JSON response format from backend.');
      return;
    }

    final rawCitations = decoded['citations'];
    if (rawCitations is List) {
      final parsedCitations = <Citation>[];
      for (var i = 0; i < rawCitations.length; i++) {
        final item = rawCitations[i];
        if (item is Map<String, dynamic>) {
          parsedCitations.add(Citation.fromJson(item, fallbackId: i + 1));
        }
      }
      if (parsedCitations.isNotEmpty) {
        yield CitationsEvent(parsedCitations);
      }
    }

    final answer = decoded['answer']?.toString() ?? '';
    if (answer.isEmpty) {
      yield const StreamDoneEvent();
      return;
    }

    // Stream answer progressively in lightweight word chunks to preserve smooth UI rendering
    final tokens = _tokenizeForSmoothStream(answer);
    for (final token in tokens) {
      if (_isCancelled) return;
      yield AnswerChunkEvent(token);
      await Future.delayed(const Duration(milliseconds: 12));
    }

    yield const StreamDoneEvent();
  }

  List<String> _tokenizeForSmoothStream(String text) {
    final matches = RegExp(r'\S+\s*|\n+').allMatches(text);
    final chunks = <String>[];
    final buffer = StringBuffer();
    int count = 0;

    for (final m in matches) {
      buffer.write(m.group(0));
      count++;
      if (count >= 3) {
        chunks.add(buffer.toString());
        buffer.clear();
        count = 0;
      }
    }
    if (buffer.isNotEmpty) {
      chunks.add(buffer.toString());
    }
    return chunks.isEmpty ? [text] : chunks;
  }

  Stream<RagStreamEvent> _consumeSseStream(http.ByteStream byteStream) async* {
    String buffer = '';
    await for (final chunk in byteStream.transform(utf8.decoder)) {
      if (_isCancelled) break;
      buffer += chunk.replaceAll('\r\n', '\n');

      while (buffer.contains('\n\n')) {
        final index = buffer.indexOf('\n\n');
        final messageBlock = buffer.substring(0, index);
        buffer = buffer.substring(index + 2);

        final event = _parseSseBlock(messageBlock);
        if (event != null) {
          yield event;
          if (event is StreamDoneEvent || event is StreamErrorEvent) return;
        }
      }
    }
    if (!_isCancelled && buffer.trim().isNotEmpty) {
      final trailingEvent = _parseSseBlock(buffer);
      if (trailingEvent != null) {
        yield trailingEvent;
        if (trailingEvent is StreamDoneEvent || trailingEvent is StreamErrorEvent) {
          return;
        }
      }
    }
    yield const StreamDoneEvent();
  }

  RagStreamEvent? _parseSseBlock(String block) {
    final lines = block.split('\n');
    String? currentEvent;
    final dataLines = <String>[];

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      if (line.isEmpty || line.startsWith(':')) continue;
      if (line.startsWith('event:')) {
        currentEvent = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        var val = line.substring(5);
        if (val.startsWith(' ')) {
          val = val.substring(1);
        }
        dataLines.add(val);
      }
    }

    final data = dataLines.join('\n').trim();
    if (data.isEmpty) return null;
    if (data == '[DONE]' || currentEvent == 'done') return const StreamDoneEvent();

    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        if (currentEvent == 'error' ||
            decoded.containsKey('detail') ||
            decoded.containsKey('error')) {
          final detail = (decoded['detail'] ??
                  decoded['error'] ??
                  decoded['message'] ??
                  'Streaming error')
              .toString();
          return StreamErrorEvent(detail);
        }
        if (decoded.containsKey('question')) {
          return QuestionEvent(decoded['question'].toString());
        }
        if (decoded.containsKey('status') || decoded.containsKey('step')) {
          final stage = (decoded['step'] ?? decoded['status']).toString();
          return StreamStatusEvent(
            stage,
            stepId: decoded['step_id']?.toString() ?? 'sse_${stage.hashCode}',
            detail: decoded['detail']?.toString(),
            isCompleted: decoded['done'] == true,
          );
        }
        if (currentEvent == 'answer_chunk' ||
            decoded.containsKey('text') ||
            decoded.containsKey('answer_chunk') ||
            decoded.containsKey('chunk')) {
          final text = decoded['text'] ?? decoded['answer_chunk'] ?? decoded['chunk'];
          if (text != null) {
            return AnswerChunkEvent(text.toString());
          }
        }
        if (currentEvent == 'citations' || decoded.containsKey('citations')) {
          final rawList = decoded['citations'];
          if (rawList is List) {
            final list = <Citation>[];
            for (var i = 0; i < rawList.length; i++) {
              final item = rawList[i];
              if (item is Map<String, dynamic>) {
                list.add(Citation.fromJson(item, fallbackId: i + 1));
              }
            }
            return CitationsEvent(list);
          }
        }
      }
    } catch (_) {
      if (currentEvent == 'citations') return null;
      if (currentEvent == 'error') return StreamErrorEvent(data);
      return AnswerChunkEvent(data);
    }
    return null;
  }

  /// Offline simulation fallback for tests and demo mode.
  Stream<RagStreamEvent> _generateSimulatedStream(String prompt) async* {
    final mockCitations = [
      const Citation(
        id: 1,
        chunkId: 'chk_784f_neural',
        textSpan: 'Dense vector retrieval projects tokens into a unified 1536-D latent manifold, bypassing vocabulary mismatch.',
        sourceDoc: 'Foundations of Neural Information Retrieval (2024)',
        score: 0.948,
      ),
      const Citation(
        id: 2,
        chunkId: 'chk_993b_rerank',
        textSpan: 'Cross-attention rerankers compute full pairwise query-document interactions, suppressing false positives by 42%.',
        sourceDoc: 'Hierarchical Reranking in Production RAG (v2.1)',
        score: 0.912,
      ),
      const Citation(
        id: 3,
        chunkId: 'chk_410a_context',
        textSpan: 'Context compression and sliding-window chunking prevent attention dilution across 32k token windows.',
        sourceDoc: 'Large Language Model Context Architectures',
        score: 0.876,
      ),
    ];

    await Future.delayed(const Duration(milliseconds: 120));
    yield CitationsEvent(mockCitations);

    final responseTokens = [
      'Retrieval-Augmented ',
      'Generation (RAG) ',
      'combines neural ',
      'vector representations ',
      'with sparse lexical matching [1]. ',
      '\n\n',
      'By projecting document chunks ',
      'into high-dimensional latent space, ',
      'the system identifies semantic relevance ',
      'even when surface vocabulary differs.\n\n',
      'Next, a cross-encoder ',
      'reranking stage filters ',
      'candidate passages [2], ',
      'reordering them by relevance ',
      'and filtering false positives.\n\n',
      'Finally, context pruning ',
      'and sliding-window chunking [3] ',
      'deliver focused evidence spans ',
      'to the generative model, ',
      'guaranteeing verifiable attribution ',
      'with near-zero hallucination.'
    ];

    for (final token in responseTokens) {
      if (_isCancelled) {
        yield const StreamErrorEvent('Stream aborted.', isInterrupted: true);
        return;
      }
      await Future.delayed(const Duration(milliseconds: 35));
      yield AnswerChunkEvent(token);
    }

    await Future.delayed(const Duration(milliseconds: 60));
    yield const StreamDoneEvent();
  }
}
