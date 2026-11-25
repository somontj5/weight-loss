import 'dart:convert';

import 'package:weightloss/domain/entities/memory_fact.dart';

/// Действие из блока actions.
class AiAction {
  const AiAction(this.type, this.data);
  final String type;
  final Map<String, dynamic> data;
}

/// Единый формат ответа модели: текст + необязательные действия.
class ParsedReply {
  const ParsedReply({
    required this.text,
    this.actions = const [],
    this.summary,
    this.wellFormed = true,
  });

  final String text;
  final List<AiAction> actions;
  final String? summary;

  /// false — модель вернула не JSON, весь текст принят как ответ.
  final bool wellFormed;

  /// Только save_memory обрабатывается; остальные принимаются и игнорируются
  /// (заготовка под часть 2).
  List<MemoryUpdate> get memoryUpdates {
    final out = <MemoryUpdate>[];
    for (final a in actions) {
      if (a.type != 'save_memory') continue;
      final facts = a.data['facts'];
      if (facts is! List) continue;
      for (final f in facts) {
        if (f is! Map) continue;
        final key = f['key']?.toString() ?? '';
        final forget = f['forget'] == true;
        final fact = f['fact']?.toString() ?? '';
        if (key.trim().isEmpty) continue;
        if (!forget && fact.trim().isEmpty) continue;
        out.add(MemoryUpdate(
          key: key,
          fact: fact,
          category: f['category']?.toString() ?? 'other',
          confidence: (f['confidence'] as num?)?.toDouble() ?? 0.7,
          forget: forget,
        ));
      }
    }
    return out;
  }

  /// Действия, которые пока игнорируются (для логов/части 2).
  List<AiAction> get deferredActions =>
      actions.where((a) => a.type != 'save_memory').toList();
}

class ReplyParser {
  static ParsedReply parse(String raw) {
    final cleaned = _stripFences(raw.trim());
    Object? j;
    try {
      j = jsonDecode(cleaned);
    } catch (_) {
      final s = cleaned.indexOf('{');
      final e = cleaned.lastIndexOf('}');
      if (s >= 0 && e > s) {
        try {
          j = jsonDecode(cleaned.substring(s, e + 1));
        } catch (_) {}
      }
    }
    if (j is! Map<String, dynamic>) {
      return ParsedReply(
          text: cleaned.isEmpty ? '…' : cleaned, wellFormed: false);
    }

    final actions = <AiAction>[];
    final rawActions = j['actions'];
    if (rawActions is List) {
      for (final a in rawActions) {
        if (a is Map && a['type'] is String) {
          actions.add(AiAction(
              a['type'] as String, Map<String, dynamic>.from(a)));
        }
      }
    }
    var text = (j['reply'] ?? j['text'] ?? '').toString().trim();
    if (text.isEmpty) text = actions.isEmpty ? '…' : 'Запомнил!';
    final summary = j['summary']?.toString().trim();
    return ParsedReply(
      text: text,
      actions: actions,
      summary: (summary == null || summary.isEmpty) ? null : summary,
    );
  }

  static String _stripFences(String s) {
    if (!s.startsWith('```')) return s;
    final firstNl = s.indexOf('\n');
    var body = firstNl < 0 ? s.substring(3) : s.substring(firstNl + 1);
    if (body.trimRight().endsWith('```')) {
      body = body.trimRight();
      body = body.substring(0, body.length - 3);
    }
    return body.trim();
  }
}
