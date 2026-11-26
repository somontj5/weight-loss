import 'package:weightloss/domain/ration/ration_models.dart';

abstract class MealPlanRepository {
  /// Пункты дня (по времени).
  Future<List<MealPlanItem>> day(DateTime date);

  /// Пункты с [from] включительно по [to] не включительно.
  Future<List<MealPlanItem>> between(DateTime from, DateTime to);
  Future<MealPlanItem?> byId(int id);

  /// Заменяет пункты дня. [clearPlanned] — сначала удалить все пункты со
  /// статусом planned; иначе заменяются только приёмы из [drafts]. Пункты
  /// со статусом eaten/skipped/replaced не трогаются никогда.
  Future<void> replaceDay(
    DateTime date,
    List<MealPlanDraft> drafts, {
    required DateTime now,
    bool clearPlanned = false,
  });

  Future<bool> setStatus(int id, String status, {String? note});

  /// Дни (начала суток) от [from], в которых есть пункты.
  Future<List<DateTime>> datesFrom(DateTime from);

  /// Все planned-пункты до [before] становятся skipped. Возвращает число.
  Future<int> closePast(DateTime before);
}
