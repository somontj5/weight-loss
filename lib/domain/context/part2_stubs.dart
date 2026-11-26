import 'package:weightloss/domain/diary/diary_service.dart';
import 'package:weightloss/domain/diary/food_action.dart';
import 'package:weightloss/domain/entities/diary_entry.dart';
import 'package:weightloss/domain/entities/part2_entities.dart';
import 'package:weightloss/domain/repositories/repositories.dart';

/// Реальный источник дневника для ContextAssembler (читает diary_entries).
/// У каждой записи в описании стоит её номер («#12»): так модель может
/// править именно нужную запись.
class DbDiarySource implements DiarySource {
  DbDiarySource(this._diary);
  final DiaryService _diary;

  @override
  bool get available => true;

  static String describe(DiaryEntry e) =>
      '#${e.id} ${e.description}${e.offPlan ? ' [вне плана]' : ''}';

  DiaryItem _item(DiaryEntry e) => DiaryItem(
        time: e.eatenAt,
        meal: MealKind.ru(e.meal),
        description: describe(e),
        kcal: e.kcal,
        proteinG: e.proteinG,
        fatG: e.fatG,
        carbsG: e.carbsG,
      );

  @override
  Future<DiaryDay> today(DateTime now) async {
    final list = await _diary.day(now);
    return DiaryDay(date: now, items: list.map(_item).toList());
  }

  /// Прошлые [days] дней БЕЗ сегодняшнего (он идёт отдельным блоком),
  /// только дни, где есть записи; от старых к новым.
  @override
  Future<List<DiaryDay>> lastDays(DateTime now, int days) async {
    final start = DiaryService.dayStart(now);
    final out = <DiaryDay>[];
    for (var i = days; i >= 1; i--) {
      final d = start.subtract(Duration(days: i));
      final list = await _diary.day(d);
      if (list.isEmpty) continue;
      out.add(DiaryDay(date: d, items: list.map(_item).toList()));
    }
    return out;
  }
}

/// ЗАГЛУШКА под часть 2Б: история тренировок (таблица workout_results).
class EmptyWorkoutHistorySource implements WorkoutHistorySource {
  const EmptyWorkoutHistorySource();

  @override
  Future<List<WorkoutBrief>> recent(DateTime now, {int limit = 5}) async =>
      const [];
}
