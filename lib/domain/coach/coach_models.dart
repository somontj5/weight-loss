/// Самочувствие по памяти (health.wellbeing), не старше трёх суток.
enum Wellbeing { normal, tired, sick }

class DayKcal {
  const DayKcal(this.date, this.kcal);
  final DateTime date;
  final int kcal;
}

/// Итог одной тренировки для правил и контекста.
class WorkoutRecord {
  const WorkoutRecord({
    required this.date,
    required this.status,
    required this.title,
    this.doneExercises = 0,
    this.skippedExercises = 0,
    this.pauses = 0,
    this.durationSec = 0,
    this.kcal = 0,
    this.difficulty,
    this.note,
  });

  final DateTime date;

  /// completed | aborted | skipped
  final String status;
  final String title;
  final int doneExercises;
  final int skippedExercises;
  final int pauses;
  final int durationSec;
  final int kcal;
  final int? difficulty;
  final String? note;

  bool get completed => status == 'completed';

  /// Тяжело пошло: прервал, пропустил или пропустил много упражнений.
  bool get struggled =>
      status == 'aborted' || status == 'skipped' || skippedExercises >= 2;
}

class CoachInput {
  const CoachInput({
    required this.now,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.planKcal,
    required this.toleranceKcal,
    required this.eatenToday,
    required this.entriesToday,
    this.pastDays = const [],
    this.trainingMinutes = 20,
    this.trainingSlot = 'evening',
    this.history = const [],
    this.workoutDoneToday = false,
    this.wellbeing = Wellbeing.normal,
    this.jointIssue = false,
  });

  final DateTime now;
  final int age;
  final double weightKg;
  final double heightCm;
  final int planKcal;
  final int toleranceKcal;
  final int eatenToday;
  final int entriesToday;

  /// Прошлые дни недели (без сегодняшнего), только с записями.
  final List<DayKcal> pastDays;
  final int trainingMinutes;

  /// morning | day | evening
  final String trainingSlot;

  /// Результаты, новые первыми.
  final List<WorkoutRecord> history;
  final bool workoutDoneToday;
  final Wellbeing wellbeing;

  /// В памяти есть проблемы с коленями, спиной, суставами.
  final bool jointIssue;

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));
}

class CoachDecision {
  const CoachDecision({
    required this.needed,
    required this.difficulty,
    required this.minutes,
    required this.maxDifficulty,
    required this.allowHighImpact,
    this.when,
    this.reasons = const [],
    this.restReason,
    this.overTodayKcal = 0,
    this.overWeekKcal = 0,
    this.escalated = false,
    this.wellbeing = Wellbeing.normal,
  });

  final bool needed;

  /// 1 (лёгкая) … 3 (тяжёлая).
  final int difficulty;
  final int minutes;
  final int maxDifficulty;
  final bool allowHighImpact;

  /// Когда делать (null, если тренировка не нужна).
  final DateTime? when;
  final List<String> reasons;

  /// Почему сегодня отдых (если needed == false).
  final String? restReason;
  final int overTodayKcal;
  final int overWeekKcal;

  /// Сложность повышена из-за съеденного сверх плана.
  final bool escalated;
  final Wellbeing wellbeing;
}
