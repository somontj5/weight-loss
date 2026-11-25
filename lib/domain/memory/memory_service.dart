import 'package:weightloss/domain/entities/memory_fact.dart';
import 'package:weightloss/domain/repositories/repositories.dart';

class MemoryApplyResult {
  const MemoryApplyResult({
    this.added = 0,
    this.replaced = 0,
    this.confirmed = 0,
    this.forgotten = 0,
    this.ignored = 0,
  });

  final int added;
  final int replaced;
  final int confirmed;
  final int forgotten;
  final int ignored;
}

/// Применяет факты от модели. Один ключ — один актуальный факт: новое
/// высказывание заменяет старое (старое помечается «заменён»), противоречия
/// не копятся.
class MemoryService {
  MemoryService(this._repo, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final MemoryRepository _repo;
  final DateTime Function() _clock;

  static const maxUpdatesPerReply = 8;
  static const maxFactChars = 220;
  static const maxKeyChars = 60;

  /// Новое сомнительное высказывание не вытесняет уверенный старый факт.
  static const weakConfidence = 0.4;
  static const strongConfidence = 0.7;

  static String normalizeKey(String raw) {
    var k = raw.trim().toLowerCase();
    k = k.replaceAll(RegExp(r'[\s\-/]+'), '_');
    k = k.replaceAll(RegExp(r'[^a-z0-9а-яё_.]'), '');
    if (k.length > maxKeyChars) k = k.substring(0, maxKeyChars);
    return k;
  }

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-zа-яё0-9]+'), ' ').trim();

  Future<MemoryApplyResult> apply(List<MemoryUpdate> updates,
      {int? sourceMessageId}) async {
    final now = _clock();

    // Внутри одного ответа последний по ключу выигрывает.
    final byKey = <String, MemoryUpdate>{};
    for (final u in updates.take(maxUpdatesPerReply)) {
      final k = normalizeKey(u.key);
      if (k.isEmpty) continue;
      byKey[k] = u;
    }

    var added = 0, replaced = 0, confirmed = 0, forgotten = 0, ignored = 0;
    for (final e in byKey.entries) {
      final u = e.value;
      final key = e.key;
      final conf = u.confidence.clamp(0.0, 1.0).toDouble();
      final old = await _repo.activeByKey(key);

      if (u.forget) {
        if (old != null) {
          await _repo.supersede(old.id, now: now);
          forgotten++;
        } else {
          ignored++;
        }
        continue;
      }

      var text = u.fact.trim();
      if (text.isEmpty) {
        ignored++;
        continue;
      }
      if (text.length > maxFactChars) text = text.substring(0, maxFactChars);

      if (old == null) {
        await _repo.insert(
          key: key,
          fact: text,
          category: MemoryCategory.normalize(u.category),
          confidence: conf,
          now: now,
          sourceMessageId: sourceMessageId,
        );
        added++;
        continue;
      }

      if (_norm(old.fact) == _norm(text)) {
        // То же самое сказано снова: подтверждаем, дубль не создаём.
        await _repo.touch(old.id,
            confidence: conf > old.confidence ? conf : old.confidence,
            now: now);
        confirmed++;
        continue;
      }

      if (conf < weakConfidence && old.confidence >= strongConfidence) {
        ignored++; // догадка модели не перебивает уверенный факт
        continue;
      }

      final id = await _repo.insert(
        key: key,
        fact: text,
        category: MemoryCategory.normalize(u.category),
        confidence: conf,
        now: now,
        sourceMessageId: sourceMessageId,
      );
      await _repo.supersede(old.id, by: id, now: now);
      replaced++;
    }

    return MemoryApplyResult(
        added: added,
        replaced: replaced,
        confirmed: confirmed,
        forgotten: forgotten,
        ignored: ignored);
  }
}
