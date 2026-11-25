/// Итоги одного упражнения во время тренировки. Всё, что делал пользователь
/// (пропуски, паузы, досрочный выход), попадает сюда — и уходит ИИ-тренеру.
class ExerciseLog {
  ExerciseLog({
    required this.exerciseId,
    required this.name,
    required this.plannedSec,
    required this.plannedRestSec,
  });

  final String exerciseId;
  final String name;
  final int plannedSec;
  final int plannedRestSec;

  /// completed | skipped | stopped_early | not_started
  String status = 'not_started';
  double actualSec = 0;

  /// completed | skipped | omitted (упражнение пропущено — отдыха не было) | none
  String restOutcome = 'none';
  double restActualSec = 0;

  /// Фактическая длительность каждой паузы (сек).
  final List<int> pauses = [];
  double kcal = 0;

  Map<String, dynamic> toJson() => {
        'exercise': name,
        'status': status,
        'plannedSec': plannedSec,
        'actualSec': actualSec.round(),
        'plannedRestSec': plannedRestSec,
        'restActualSec': restActualSec.round(),
        'restOutcome': restOutcome,
        if (pauses.isNotEmpty) 'pausesSec': pauses,
        'kcal': double.parse(kcal.toStringAsFixed(1)),
      };

  factory ExerciseLog.fromJson(Map<String, dynamic> j) {
    final l = ExerciseLog(
      exerciseId: '',
      name: j['exercise']?.toString() ?? '',
      plannedSec: (j['plannedSec'] as num?)?.toInt() ?? 0,
      plannedRestSec: (j['plannedRestSec'] as num?)?.toInt() ?? 0,
    );
    l.status = j['status']?.toString() ?? 'not_started';
    l.actualSec = (j['actualSec'] as num?)?.toDouble() ?? 0;
    l.restOutcome = j['restOutcome']?.toString() ?? 'none';
    l.restActualSec = (j['restActualSec'] as num?)?.toDouble() ?? 0;
    l.kcal = (j['kcal'] as num?)?.toDouble() ?? 0;
    final p = j['pausesSec'];
    if (p is List) l.pauses.addAll(p.whereType<num>().map((e) => e.toInt()));
    return l;
  }
}

class WorkoutSession {
  WorkoutSession({
    required this.startedAt,
    required this.title,
    required this.plannedSec,
    required this.activeSec,
    required this.pausedSec,
    required this.kcal,
    required this.finishedEarly,
    required this.logs,
  });

  final DateTime startedAt;
  final String title;
  final int plannedSec;
  final int activeSec;
  final int pausedSec;
  final double kcal;
  final bool finishedEarly;
  final List<ExerciseLog> logs;

  int get completedCount => logs.where((l) => l.status == 'completed').length;
  int get skippedCount => logs.where((l) => l.status == 'skipped').length;
  int get pausesCount => logs.fold(0, (a, l) => a + l.pauses.length);

  Map<String, dynamic> toJson() => {
        'startedAt': startedAt.toIso8601String(),
        'workout': title,
        'plannedTotalSec': plannedSec,
        'activeSec': activeSec,
        'pausedSec': pausedSec,
        'kcalBurned': double.parse(kcal.toStringAsFixed(1)),
        'finishedEarly': finishedEarly,
        'exercisesCompleted': completedCount,
        'exercisesTotal': logs.length,
        'exercisesSkipped': skippedCount,
        'exercises': logs.map((l) => l.toJson()).toList(),
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> j) => WorkoutSession(
        startedAt: DateTime.tryParse(j['startedAt']?.toString() ?? '') ??
            DateTime.now(),
        title: j['workout']?.toString() ?? '',
        plannedSec: (j['plannedTotalSec'] as num?)?.toInt() ?? 0,
        activeSec: (j['activeSec'] as num?)?.toInt() ?? 0,
        pausedSec: (j['pausedSec'] as num?)?.toInt() ?? 0,
        kcal: (j['kcalBurned'] as num?)?.toDouble() ?? 0,
        finishedEarly: j['finishedEarly'] == true,
        logs: [
          for (final e in (j['exercises'] as List? ?? const []))
            if (e is Map) ExerciseLog.fromJson(Map<String, dynamic>.from(e)),
        ],
      );
}
