import 'package:weightloss/domain/diary/diary_repository.dart';
import 'package:weightloss/domain/diary/food_action.dart';
import 'package:weightloss/domain/entities/diary_entry.dart';

/// Добавление, ПРАВКА и удаление записей. Правка меняет существующую
/// запись, а не создаёт вторую.
class DiaryService {
  DiaryService(this._repo, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final DiaryRepository _repo;
  final DateTime Function() _clock;

  /// Фото и текст об одном приёме пищи, присланные в этом окне, — одна запись.
  static const mergeWindow = Duration(minutes: 10);
  static const maxEntriesPerDay = 20;

  DiaryRepository get repo => _repo;

  static DateTime dayStart(DateTime t) => DateTime(t.year, t.month, t.day);

  Future<List<DiaryEntry>> day(DateTime t) =>
      _repo.between(dayStart(t), dayStart(t).add(const Duration(days: 1)));

  Future<FoodLogOutcome> apply(
    FoodLogRequest r, {
    int? messageId,
    String source = 'chat_text',
    List<String> photos = const [],
  }) async {
    switch (r.op) {
      case 'delete':
        return _delete(r);
      case 'update':
        return _update(r, photos: photos);
      default:
        return _add(r, messageId: messageId, source: source, photos: photos);
    }
  }

  // ───────────── добавление ─────────────

  Future<FoodLogOutcome> _add(FoodLogRequest r,
      {int? messageId,
      required String source,
      required List<String> photos}) async {
    final now = _clock();
    if (r.description == null) {
      return const FoodLogOutcome(FoodOutcomeKind.rejected,
          reason: 'нет описания');
    }
    if (r.kcal == null) {
      return const FoodLogOutcome(FoodOutcomeKind.rejected,
          reason: 'нет правдоподобной калорийности');
    }
    final eatenAt = r.time ?? now;
    final meal = r.meal ?? MealKind.byTime(eatenAt);

    // 1) Это же сообщение уже породило запись: правим её, не дублируем.
    if (messageId != null) {
      final same = await _repo.byMessageId(messageId);
      if (same != null) {
        return _write(_merged(same, r, photos: photos), merged: true);
      }
    }

    // 2) Фото и текст об одном приёме пищи в течение нескольких минут.
    final last = await _repo.latest();
    if (last != null &&
        now.difference(last.createdAt) <= mergeWindow &&
        !now.isBefore(last.createdAt) &&
        last.meal == meal &&
        (last.source == 'chat_photo') != (source == 'chat_photo') &&
        last.messageId != messageId) {
      return _write(_merged(last, r, photos: photos), merged: true);
    }

    // 3) Защита от лавины записей.
    final today = await day(eatenAt);
    if (today.length >= maxEntriesPerDay) {
      return const FoodLogOutcome(FoodOutcomeKind.rejected,
          reason: 'слишком много записей за день');
    }

    final entry = DiaryEntry(
      id: 0,
      eatenAt: eatenAt,
      meal: meal,
      description: r.description!,
      kcal: r.kcal,
      proteinG: r.proteinG,
      fatG: r.fatG,
      carbsG: r.carbsG,
      photos: photos,
      source: source,
      messageId: messageId,
      createdAt: now,
      offPlan: r.offPlan ?? false,
      note: r.note,
    );
    final id = await _repo.insert(entry);
    final saved = await _repo.byId(id);
    return FoodLogOutcome(FoodOutcomeKind.added, entry: saved);
  }

  // ───────────── правка ─────────────

  Future<FoodLogOutcome> _update(FoodLogRequest r,
      {required List<String> photos}) async {
    final old = await _repo.byId(r.entryId!);
    if (old == null) {
      return const FoodLogOutcome(FoodOutcomeKind.rejected,
          reason: 'нет записи с таким номером');
    }
    return _write(_merged(old, r, photos: photos));
  }

  /// Накладывает поля запроса на существующую запись; чего нет — остаётся.
  DiaryEntry _merged(DiaryEntry old, FoodLogRequest r,
      {required List<String> photos}) {
    final newKcal = r.kcal ?? old.kcal;
    var p = r.proteinG ?? old.proteinG;
    var f = r.fatG ?? old.fatG;
    var c = r.carbsG ?? old.carbsG;

    // Калории поменялись, а БЖУ нет: пересчитываем пропорционально.
    final noMacros = r.proteinG == null && r.fatG == null && r.carbsG == null;
    if (r.kcal != null &&
        noMacros &&
        old.kcal != null &&
        old.kcal! > 0 &&
        r.kcal != old.kcal) {
      final k = r.kcal! / old.kcal!;
      p = old.proteinG == null ? null : _r1(old.proteinG! * k);
      f = old.fatG == null ? null : _r1(old.fatG! * k);
      c = old.carbsG == null ? null : _r1(old.carbsG! * k);
    }

    final allPhotos = <String>{...old.photos, ...photos}.toList();
    return DiaryEntry(
      id: old.id,
      eatenAt: r.time ?? old.eatenAt,
      meal: r.meal ?? old.meal,
      description: r.description ?? old.description,
      kcal: newKcal,
      proteinG: p,
      fatG: f,
      carbsG: c,
      photos: allPhotos,
      source: old.source,
      messageId: old.messageId,
      createdAt: old.createdAt,
      offPlan: r.offPlan ?? old.offPlan,
      note: r.note ?? old.note,
    );
  }

  Future<FoodLogOutcome> _write(DiaryEntry e, {bool merged = false}) async {
    await _repo.update(e);
    return FoodLogOutcome(FoodOutcomeKind.updated, entry: e, merged: merged);
  }

  // ───────────── удаление ─────────────

  Future<FoodLogOutcome> _delete(FoodLogRequest r) async {
    final old = await _repo.byId(r.entryId!);
    if (old == null) {
      return const FoodLogOutcome(FoodOutcomeKind.rejected,
          reason: 'нет записи с таким номером');
    }
    await _repo.delete(old.id);
    return FoodLogOutcome(FoodOutcomeKind.deleted, entry: old);
  }

  static double _r1(double v) => double.parse(v.toStringAsFixed(1));
}
