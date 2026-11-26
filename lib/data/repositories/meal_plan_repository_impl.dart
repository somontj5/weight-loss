import 'package:drift/drift.dart';

import 'package:weightloss/data/db/app_database.dart';
import 'package:weightloss/domain/ration/meal_plan_repository.dart';
import 'package:weightloss/domain/ration/ration_models.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  MealPlanRepositoryImpl(this._db);
  final AppDatabase _db;

  static DateTime _d(DateTime t) => DateTime(t.year, t.month, t.day);

  MealPlanItem _map(MealPlanItemsRow r) => MealPlanItem(
    id: r.id,
    date: r.date,
    meal: r.meal,
    time: r.time,
    title: r.title,
    composition: MealPlanItem.decodeComposition(r.compositionJson),
    kcal: r.kcal,
    proteinG: r.proteinG,
    fatG: r.fatG,
    carbsG: r.carbsG,
    status: r.status,
    note: r.note,
  );

  @override
  Future<List<MealPlanItem>> day(DateTime date) =>
      between(_d(date), _d(date).add(const Duration(days: 1)));

  @override
  Future<List<MealPlanItem>> between(DateTime from, DateTime to) async {
    final rows =
        await (_db.select(_db.mealPlanItems)
              ..where(
                (t) =>
                    t.date.isBiggerOrEqualValue(from) &
                    t.date.isSmallerThanValue(to),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.date),
                (t) => OrderingTerm.asc(t.time),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return rows.map(_map).toList();
  }

  @override
  Future<MealPlanItem?> byId(int id) async {
    final r = await (_db.select(
      _db.mealPlanItems,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return r == null ? null : _map(r);
  }

  @override
  Future<void> replaceDay(
    DateTime date,
    List<MealPlanDraft> drafts, {
    required DateTime now,
    bool clearPlanned = false,
  }) async {
    final day = _d(date);
    await _db.transaction(() async {
      final del = _db.delete(_db.mealPlanItems)
        ..where((t) => t.date.equals(day) & t.status.equals('planned'));
      if (!clearPlanned) {
        final meals = drafts.map((d) => d.meal).toList();
        del.where((t) => t.meal.isIn(meals));
      }
      await del.go();
      for (final d in drafts) {
        await _db
            .into(_db.mealPlanItems)
            .insert(
              MealPlanItemsCompanion.insert(
                date: day,
                meal: d.meal,
                time: Value(d.time),
                title: d.title,
                compositionJson: Value(
                  MealPlanItem.encodeComposition(d.composition),
                ),
                kcal: d.kcal,
                proteinG: Value(d.proteinG),
                fatG: Value(d.fatG),
                carbsG: Value(d.carbsG),
                note: Value(d.note),
                createdAt: now,
              ),
            );
      }
    });
  }

  @override
  Future<bool> setStatus(int id, String status, {String? note}) async {
    if (!PlanStatus.all.contains(status)) return false;
    final n =
        await (_db.update(
          _db.mealPlanItems,
        )..where((t) => t.id.equals(id))).write(
          MealPlanItemsCompanion(
            status: Value(status),
            note: note == null ? const Value.absent() : Value(note),
          ),
        );
    return n > 0;
  }

  @override
  Future<List<DateTime>> datesFrom(DateTime from) async {
    final rows = await (_db.select(
      _db.mealPlanItems,
    )..where((t) => t.date.isBiggerOrEqualValue(_d(from)))).get();
    final set = <DateTime>{for (final r in rows) _d(r.date)};
    return set.toList()..sort();
  }

  @override
  Future<int> closePast(DateTime before) =>
      (_db.update(_db.mealPlanItems)..where(
            (t) =>
                t.date.isSmallerThanValue(_d(before)) &
                t.status.equals('planned'),
          ))
          .write(const MealPlanItemsCompanion(status: Value('skipped')));
}
