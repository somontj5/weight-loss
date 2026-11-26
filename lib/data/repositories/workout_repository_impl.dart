import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:weightloss/data/db/app_database.dart';
import 'package:weightloss/domain/coach/coach_models.dart';
import 'package:weightloss/domain/coach/workout_repository.dart';
import 'package:weightloss/models/workout.dart';
import 'package:weightloss/models/workout_session.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  WorkoutRepositoryImpl(this._db);
  final AppDatabase _db;

  static DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

  @override
  Future<int> savePlan({
    required Workout workout,
    required DateTime scheduledAt,
    required int difficulty,
    required String source,
    required DateTime now,
  }) async {
    final d0 = _day(scheduledAt);
    final d1 = d0.add(const Duration(days: 1));
    return _db.transaction(() async {
      await (_db.delete(_db.workouts)..where(
            (w) =>
                w.status.equals('planned') &
                w.scheduledAt.isBiggerOrEqualValue(d0) &
                w.scheduledAt.isSmallerThanValue(d1),
          ))
          .go();
      return _db
          .into(_db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              createdAt: now,
              scheduledAt: Value(scheduledAt),
              title: workout.title,
              planJson: Value(planJsonString(workout, difficulty)),
              source: Value(source),
              status: const Value('planned'),
            ),
          );
    });
  }

  PlannedWorkout? _planned(WorkoutsRow r) {
    try {
      final j = jsonDecode(r.planJson) as Map<String, dynamic>;
      return PlannedWorkout(
        id: r.id,
        workout: Workout.fromJson(j, source: WorkoutSource.ai),
        scheduledAt: r.scheduledAt,
        difficulty: (j['difficulty'] as num?)?.toInt() ?? 1,
        source: r.source,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PlannedWorkout?> nextPlanned(DateTime now) async {
    final rows =
        await (_db.select(_db.workouts)
              ..where(
                (w) =>
                    w.status.equals('planned') &
                    w.scheduledAt.isBiggerOrEqualValue(_day(now)),
              )
              ..orderBy([(w) => OrderingTerm.asc(w.scheduledAt)]))
            .get();
    for (final r in rows) {
      final p = _planned(r);
      if (p != null) return p;
    }
    return null;
  }

  @override
  Future<List<DateTime>> plannedTimes(DateTime now) async {
    final rows =
        await (_db.select(_db.workouts)..where(
              (w) =>
                  w.status.equals('planned') &
                  w.scheduledAt.isBiggerOrEqualValue(now),
            ))
            .get();
    return [
      for (final r in rows)
        if (r.scheduledAt != null) r.scheduledAt!,
    ];
  }

  @override
  Future<int> closeOverdue(DateTime now) async {
    final rows =
        await (_db.select(_db.workouts)..where(
              (w) =>
                  w.status.equals('planned') &
                  w.scheduledAt.isSmallerThanValue(_day(now)),
            ))
            .get();
    for (final r in rows) {
      await _db.transaction(() async {
        await (_db.update(_db.workouts)..where((w) => w.id.equals(r.id))).write(
          const WorkoutsCompanion(status: Value('skipped')),
        );
        await _db
            .into(_db.workoutResults)
            .insert(
              WorkoutResultsCompanion.insert(
                workoutId: Value(r.id),
                startedAt: r.scheduledAt ?? now,
                status: 'skipped',
                note: const Value('не начата'),
              ),
            );
      });
    }
    return rows.length;
  }

  @override
  Future<void> saveResult({
    int? workoutId,
    required WorkoutSession session,
    required DateTime now,
  }) async {
    final status = session.finishedEarly ? 'aborted' : 'completed';
    final skipped = session.logs
        .where((l) => l.status == 'skipped' || l.status == 'stopped_early')
        .length;
    final done = session.completedCount;
    final notes = <String>[
      if (skipped > 0) 'пропущено упражнений: $skipped',
      if (session.pausesCount > 0) 'пауз: ${session.pausesCount}',
      if (session.finishedEarly) 'остановил досрочно',
    ];
    await _db.transaction(() async {
      await _db
          .into(_db.workoutResults)
          .insert(
            WorkoutResultsCompanion.insert(
              workoutId: Value(workoutId),
              startedAt: session.startedAt,
              finishedAt: Value(now),
              status: status,
              doneExercises: Value(done),
              skippedExercises: Value(skipped),
              pauses: Value(session.pausesCount),
              pausedSeconds: Value(session.pausedSec),
              durationSec: Value(session.activeSec),
              kcal: Value(session.kcal.round()),
              note: Value(notes.isEmpty ? null : notes.join(', ')),
            ),
          );
      if (workoutId != null) {
        await (_db.update(_db.workouts)..where((w) => w.id.equals(workoutId)))
            .write(const WorkoutsCompanion(status: Value('done')));
      }
    });
  }

  @override
  Future<List<WorkoutRecord>> recentResults({int limit = 20}) async {
    final results =
        await (_db.select(_db.workoutResults)
              ..orderBy([(r) => OrderingTerm.desc(r.startedAt)])
              ..limit(limit))
            .get();
    final out = <WorkoutRecord>[];
    for (final r in results) {
      var title = 'Тренировка';
      int? diff;
      if (r.workoutId != null) {
        final w = await (_db.select(
          _db.workouts,
        )..where((x) => x.id.equals(r.workoutId!))).getSingleOrNull();
        if (w != null) {
          title = w.title;
          try {
            diff = ((jsonDecode(w.planJson) as Map)['difficulty'] as num?)
                ?.toInt();
          } catch (_) {}
        }
      }
      out.add(
        WorkoutRecord(
          date: r.startedAt,
          status: r.status,
          title: title,
          doneExercises: r.doneExercises,
          skippedExercises: r.skippedExercises,
          pauses: r.pauses,
          durationSec: r.durationSec,
          kcal: r.kcal,
          difficulty: diff,
          note: r.note,
        ),
      );
    }
    return out;
  }
}
