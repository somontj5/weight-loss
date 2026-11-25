import 'package:drift/drift.dart';

import 'package:weightloss/domain/entities/memory_fact.dart';
import 'package:weightloss/domain/repositories/repositories.dart';
import 'package:weightloss/data/db/app_database.dart';

class MemoryRepositoryImpl implements MemoryRepository {
  MemoryRepositoryImpl(this._db);
  final AppDatabase _db;

  MemoryFact _map(MemoryFactsRow r) => MemoryFact(
        id: r.id,
        key: r.key,
        fact: r.fact,
        category: r.category,
        confidence: r.confidence,
        active: r.status == 'active',
        supersededBy: r.supersededBy,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  @override
  Future<List<MemoryFact>> active() async => (await (_db.select(_db.memoryFacts)
            ..where((t) => t.status.equals('active'))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get())
      .map(_map)
      .toList();

  @override
  Future<List<MemoryFact>> all() async => (await (_db.select(_db.memoryFacts)
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get())
      .map(_map)
      .toList();

  @override
  Future<MemoryFact?> activeByKey(String key) async {
    final r = await (_db.select(_db.memoryFacts)
          ..where((t) => t.key.equals(key) & t.status.equals('active'))
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
    return r == null ? null : _map(r);
  }

  @override
  Future<int> insert({
    required String key,
    required String fact,
    required String category,
    required double confidence,
    required DateTime now,
    int? sourceMessageId,
  }) =>
      _db.into(_db.memoryFacts).insert(MemoryFactsCompanion.insert(
            key: key,
            fact: fact,
            category: Value(category),
            confidence: Value(confidence),
            sourceMessageId: Value(sourceMessageId),
            createdAt: now,
            updatedAt: now,
          ));

  @override
  Future<void> touch(int id,
          {required double confidence, required DateTime now}) =>
      (_db.update(_db.memoryFacts)..where((t) => t.id.equals(id))).write(
          MemoryFactsCompanion(
              confidence: Value(confidence), updatedAt: Value(now)));

  @override
  Future<void> supersede(int id, {int? by, required DateTime now}) =>
      (_db.update(_db.memoryFacts)..where((t) => t.id.equals(id))).write(
          MemoryFactsCompanion(
              status: const Value('superseded'),
              supersededBy: Value(by),
              updatedAt: Value(now)));
}
