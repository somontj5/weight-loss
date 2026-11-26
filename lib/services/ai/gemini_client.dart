import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:weightloss/config/ai_config.dart';
import 'package:weightloss/domain/context/context_assembler.dart';
import 'package:weightloss/services/ai/ai_exceptions.dart';
import 'package:weightloss/services/ai/media_preparer.dart';

/// Низкоуровневый вызов модели. Абстракция нужна для тестов.
abstract class ModelTransport {
  /// Возвращает сырой текст ответа модели (ожидается JSON).
  Future<String> generate({
    required String model,
    required String system,
    required List<ChatTurn> turns,
    List<Attachment> attachments = const [],
  });
}

/// Клиент Gemini API (generateContent). Ключ — только из AiConfig
/// (то есть из --dart-define).
class GeminiClient implements ModelTransport {
  GeminiClient(this._config, {http.Client? client})
      : _http = client ?? http.Client();

  final AiConfig _config;
  final http.Client _http;

  @override
  Future<String> generate({
    required String model,
    required String system,
    required List<ChatTurn> turns,
    List<Attachment> attachments = const [],
  }) async {
    if (!_config.hasKey) throw const AiNoKey();

    final uri = Uri.parse('${_config.baseUrl}/models/$model:generateContent');
    final body = jsonEncode(buildBody(system, turns, attachments));


    http.Response res;
    try {
      res = await _http
          .post(uri,
              headers: {
                'Content-Type': 'application/json',
                'x-goog-api-key': _config.apiKey,
              },
              body: body)
          .timeout(_config.timeout);
    } on TimeoutException {
      throw const AiUnavailable('timeout');
    } on SocketException {
      throw const AiOffline();
    } on http.ClientException {
      throw const AiOffline();
    }

    return parseHttp(res.statusCode, utf8.decode(res.bodyBytes), model: model);
  }

  /// Тело запроса. Вложения прикрепляются к ПОСЛЕДНЕМУ сообщению пользователя.
  Map<String, dynamic> buildBody(
      String system, List<ChatTurn> turns, List<Attachment> attachments) {
    var lastUser = -1;
    for (var i = 0; i < turns.length; i++) {
      if (turns[i].role == 'user') lastUser = i;
    }
    final contents = <Map<String, dynamic>>[];
    for (var i = 0; i < turns.length; i++) {
      final parts = <Map<String, dynamic>>[];
      if (i == lastUser) parts.addAll(attachments.map((a) => a.toPart()));
      parts.add({'text': turns[i].text});
      contents.add({'role': turns[i].role, 'parts': parts});
    }
    return {
      'systemInstruction': {
        'parts': [
          {'text': system}
        ]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': _config.temperature,
        'maxOutputTokens': _config.maxOutputTokens,
        'responseMimeType': 'application/json',
      },
    };
  }

  /// Разбор HTTP-ответа (вынесен для тестов).
  static String parseHttp(int status, String body, {String model = ''}) {
    if (status == 200) return _extractText(body);
    if (isModelNotFound(status, body)) throw AiModelNotFound([model]);
    if (status == 429) {
      throw AiRateLimited(daily: body.contains('PerDay'));
    }
    if (status == 401 || status == 403) throw const AiBadKey();
    if (status == 400) {
      if (body.contains('API key') || body.contains('API_KEY')) {
        throw const AiBadKey();
      }
      throw const AiUnavailable('bad request');
    }
    throw AiUnavailable('http $status');
  }

  /// 404, либо 400 с текстом «модель не найдена / не поддерживается».
  static bool isModelNotFound(int status, String body) {
    if (status == 404) return true;
    if (status != 400) return false;
    final b = body.toLowerCase();
    if (b.contains('api key') || b.contains('api_key')) return false;
    return b.contains('model') &&
        (b.contains('not found') ||
            b.contains('is not supported') ||
            b.contains('does not exist') ||
            b.contains('invalid model'));
  }

  static String _extractText(String body) {
    final Object? j;
    try {
      j = jsonDecode(body);
    } catch (_) {
      throw const AiUnavailable('invalid json');
    }
    if (j is! Map<String, dynamic>) throw const AiUnavailable('shape');
    final cands = j['candidates'];
    if (cands is! List || cands.isEmpty) {
      final block = (j['promptFeedback'] as Map?)?['blockReason'];
      if (block != null) throw const AiBlocked();
      throw const AiUnavailable('no candidates');
    }
    final c = cands.first as Map<String, dynamic>;
    final parts = ((c['content'] as Map?)?['parts'] as List?) ?? const [];
    final text = parts
        .whereType<Map>()
        .where((p) => p['thought'] != true && p['text'] is String)
        .map((p) => p['text'] as String)
        .join();
    if (text.trim().isEmpty) {
      if (c['finishReason'] == 'SAFETY') throw const AiBlocked();
      throw const AiUnavailable('empty');
    }
    return text;
  }

  void close() => _http.close();
}
