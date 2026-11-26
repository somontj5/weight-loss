import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:weightloss/data/db/app_database.dart';
import 'package:weightloss/domain/diary/diary_repository.dart';
import 'package:weightloss/domain/entities/diary_entry.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  DiaryRepositoryImpl(this._db);
  final AppDatabase _db;

  DiaryEntry _map(DiaryEntriesRow r) => DiaryEntry(
        id: r.id,
        eatenAt: r.eatenAt,
        meal: r.meal,
        description: r.description,
        kcal: r.kcal,
        proteinG: r.proteinG,
        fatG: r.fatG,
        carbsG: r.carbsG,
        photos: (jsonDecode(r.photoPathsJson) as List).cast<String>(),
        source: r.source,
        messageId: r.messageId,
        createdAt: r.createdAt,
        offPlan: r.offPlan,
        note: r.note,
        planItemId: r.planItemId,
      );

  DiaryEntriesCompanion _companion(DiaryEntry e, {bool withId = false}) =>
      DiaryEntriesCompanion(
        id: withId ? Value(e.id) : const Value.absent(),
        eatenAt: Value(e.eatenAt),
        meal: Value(e.meal),
        description: Value(e.description),
        kcal: Value(e.kcal),
        proteinG: Value(e.proteinG),
        fatG: Value(e.fatG),
        carbsG: Value(e.carbsG),
        photoPathsJson: Value(jsonEncode(e.photos)),
        source: Value(e.source),
        messageId: Value(e.messageId),
        createdAt: Value(e.createdAt),
        offPlan: Value(e.offPlan),
        note: Value(e.note),
        planItemId: Value(e.planItemId),
      );

  @override
  Future<int> insert(DiaryEntry e) =>
      _db.into(_db.diaryEntries).insert(_companion(e));

  @override
  Future<DiaryEntry?> byId(int id) async {
    final r = await (_db.select(_db.diaryEntries)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return r == null ? null : _map(r);
  }

  @override
  Future<DiaryEntry?> byMessageId(int messageId) async {
    final r = await (_db.select(_db.diaryEntries)
          ..where((t) => t.messageId.equals(messageId))
          ..limit(1))
        .getSingleOrNull();
    return r == null ? null : _map(r);
  }

  @override
  Future<void> update(DiaryEntry e) async {
    await (_db.update(_db.diaryEntries)..where((t) => t.id.equals(e.id)))
        .write(_companion(e));
  }

  @override
  Future<bool> delete(int id) async =>
      await (_db.delete(_db.diaryEntries)..where((t) => t.id.equals(id)))
          .go() >
      0;

  @override
  Future<List<DiaryEntry>> between(DateTime from, DateTime to) async {
    final rows = await (_db.select(_db.diaryEntries)
          ..where((t) =>
              t.eatenAt.isBiggerOrEqualValue(from) &
              t.eatenAt.isSmallerThanValue(to))
          ..orderBy([
            (t) => OrderingTerm.asc(t.eatenAt),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
    return rows.map(_map).toList();
  }

  @override
  Future<DiaryEntry?> latest() async {
    final r = await (_db.select(_db.diaryEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
    return r == null ? null : _map(r);
  }
}
