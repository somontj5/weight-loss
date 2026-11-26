import 'package:weightloss/domain/diary/food_action.dart';
import 'package:weightloss/domain/entities/part2_entities.dart';

/// Отклонение дня от нормы.
class DayDeviation {
  const DayDeviation(this.date, this.kcal, this.diff, this.withinTolerance);
  final DateTime date;
  final int kcal;

  /// съедено − норма (плюс = перебор).
  final int diff;
  final bool withinTolerance;
}

class NextMeal {
  const NextMeal(this.meal, this.kcal);

  /// breakfast | lunch | dinner | snack
  final String meal;

  /// Ориентир в ккал; null — норма уже выбрана.
  final int? kcal;
}

/// Все числа считает КОД, не модель.
class DiaryMath {
  static const mains = ['breakfast', 'lunch', 'dinner'];

  static int round10(num v) => (v / 10).round() * 10;

  static int remaining(int norm, int eaten) => norm - eaten;

  /// Последние [limit] прошлых дней с записями (от свежих к старым).
  static List<DayDeviation> deviations(
      List<DiaryDay> pastDays, int norm, int tolerance,
      {int limit = 3}) {
    final days = pastDays.where((d) => d.items.isNotEmpty).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return [
      for (final d in days.take(limit))
        DayDeviation(
            d.date, d.kcal, d.kcal - norm, (d.kcal - norm).abs() <= tolerance)
    ];
  }

  /// Какой приём пищи следующий и сколько ккал на него остаётся.
  /// Остаток делится поровну между ещё не записанными основными приёмами
  /// (начиная со следующего).
  static NextMeal nextMeal({
    required DateTime now,
    required Set<String> logged,
    required int remaining,
  }) {
    var next = MealKind.byTime(now);
    if (next != 'snack') {
      var i = mains.indexOf(next);
      while (i < mains.length && logged.contains(mains[i])) {
        i++;
      }
      next = i < mains.length ? mains[i] : 'snack';
    }
    if (remaining <= 0) return NextMeal(next, null);
    if (next == 'snack') {
      return NextMeal('snack', round10(remaining < 200 ? remaining : 200));
    }
    final idx = mains.indexOf(next);
    final left = mains.skip(idx).where((m) => !logged.contains(m)).length;
    final share = remaining / (left < 1 ? 1 : left);
    return NextMeal(next, round10(share));
  }
}
