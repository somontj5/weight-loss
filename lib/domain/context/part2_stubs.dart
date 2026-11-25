import 'package:weightloss/domain/entities/part2_entities.dart';
import 'package:weightloss/domain/repositories/repositories.dart';

/// ЗАГЛУШКА под часть 2: дневник питания. Реализация на таблице
/// diary_entries появится в части 2; ContextAssembler менять не придётся.
class EmptyDiarySource implements DiarySource {
  const EmptyDiarySource();

  @override
  bool get available => false;

  @override
  Future<DiaryDay> today(DateTime now) async =>
      DiaryDay(date: now, items: const []);

  @override
  Future<List<DiaryDay>> lastDays(DateTime now, int days) async => const [];
}

/// ЗАГЛУШКА под часть 2: история тренировок (таблица workout_results).
class EmptyWorkoutHistorySource implements WorkoutHistorySource {
  const EmptyWorkoutHistorySource();

  @override
  Future<List<WorkoutBrief>> recent(DateTime now, {int limit = 5}) async =>
      const [];
}
