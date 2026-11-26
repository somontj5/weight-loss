import 'dart:convert';

import 'package:weightloss/domain/coach/coach_models.dart';
import 'package:weightloss/models/workout.dart';
import 'package:weightloss/models/workout_session.dart';

class PlannedWorkout {
  const PlannedWorkout({
    required this.id,
    required this.workout,
    required this.scheduledAt,
    required this.difficulty,
    required this.source,
  });

  final int id;
  final Workout workout;
  final DateTime? scheduledAt;
  final int difficulty;

  /// coach (составил Фитти) | local (составил код)
  final String source;
}

abstract class WorkoutRepository {
  /// Сохраняет план. Прежние невыполненные планы на этот же день
  /// помечаются как заменённые (удаляются).
  Future<int> savePlan({
    required Workout workout,
    required DateTime scheduledAt,
    required int difficulty,
    required String source,
    required DateTime now,
  });

  /// Ближайший невыполненный план (не старше сегодняшнего дня).
  Future<PlannedWorkout?> nextPlanned(DateTime now);

  Future<List<DateTime>> plannedTimes(DateTime now);

  /// Прошедшие невыполненные планы → «пропущено» (с записью результата).
  Future<int> closeOverdue(DateTime now);

  Future<void> saveResult({
    int? workoutId,
    required WorkoutSession session,
    required DateTime now,
  });

  /// Результаты, новые первыми.
  Future<List<WorkoutRecord>> recentResults({int limit = 20});
}

Map<String, dynamic> planToJson(Workout w, int difficulty) => {
  ...w.toJson(),
  'difficulty': difficulty,
};

String planJsonString(Workout w, int difficulty) =>
    jsonEncode(planToJson(w, difficulty));
