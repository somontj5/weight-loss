// Сущности для слотов части 2 (дневник, тренировки). В части 1 источники
// возвращают пустые данные, но формат и бюджет уже заложены.

class DiaryItem {
  const DiaryItem({
    required this.time,
    required this.meal,
    required this.description,
    this.kcal,
    this.proteinG,
    this.fatG,
    this.carbsG,
  });

  final DateTime time;
  final String meal;
  final String description;
  final int? kcal;
  final double? proteinG;
  final double? fatG;
  final double? carbsG;
}

class DiaryDay {
  const DiaryDay({required this.date, required this.items});
  final DateTime date;
  final List<DiaryItem> items;

  int get kcal => items.fold(0, (s, e) => s + (e.kcal ?? 0));
  double get protein => items.fold(0.0, (s, e) => s + (e.proteinG ?? 0));
  double get fat => items.fold(0.0, (s, e) => s + (e.fatG ?? 0));
  double get carbs => items.fold(0.0, (s, e) => s + (e.carbsG ?? 0));
}

class WorkoutBrief {
  const WorkoutBrief({
    required this.date,
    required this.title,
    required this.status,
    this.minutes = 0,
    this.kcal = 0,
    this.note,
  });

  final DateTime date;
  final String title;

  /// completed | aborted | skipped
  final String status;
  final int minutes;
  final int kcal;
  final String? note;
}
