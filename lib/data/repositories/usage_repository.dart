import 'package:drift/drift.dart';

import 'package:weightloss/data/db/app_database.dart';

/// Счётчик запросов к модели по дням.
class UsageRepository {
  UsageRepository(this._db);
  final AppDatabase _db;

  Future<int> count(String day, String model) async {
    final r = await (_db.select(_db.apiUsage)
          ..where((t) => t.day.equals(day) & t.model.equals(model)))
        .getSingleOrNull();
    return r?.count ?? 0;
  }

  Future<void> increment(String day, String model) async {
    final c = await count(day, model);
    await _db.into(_db.apiUsage).insertOnConflictUpdate(
        ApiUsageCompanion.insert(day: day, model: model, count: Value(c + 1)));
  }

  /// Запрос отклонён сервером по лимиту: считаем день исчерпанным.
  Future<void> setAtLeast(String day, String model, int value) async {
    final c = await count(day, model);
    if (c >= value) return;
    await _db.into(_db.apiUsage).insertOnConflictUpdate(
        ApiUsageCompanion.insert(day: day, model: model, count: Value(value)));
  }
}
