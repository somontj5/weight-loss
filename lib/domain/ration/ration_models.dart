import 'dart:convert';

/// Приёмы пищи рациона (в порядке дня).
class MealSlot {
  static const breakfast = 'breakfast';
  static const snack = 'snack';
  static const lunch = 'lunch';
  static const afternoonSnack = 'afternoon_snack';
  static const dinner = 'dinner';

  static const all = [breakfast, snack, lunch, afternoonSnack, dinner];

  static const _aliases = {
    'завтрак': breakfast,
    'перекус': snack,
    'второй завтрак': snack,
    'обед': lunch,
    'полдник': afternoonSnack,
    'ужин': dinner,
    'afternoon': afternoonSnack,
  };

  static String? normalize(Object? raw) {
    final s = (raw ?? '').toString().trim().toLowerCase();
    if (all.contains(s)) return s;
    return _aliases[s];
  }

  static String ru(String slot) => switch (slot) {
    breakfast => 'завтрак',
    snack => 'перекус',
    lunch => 'обед',
    afternoonSnack => 'полдник',
    dinner => 'ужин',
    _ => slot,
  };

  static String emoji(String slot) => switch (slot) {
    breakfast => '🍳',
    snack => '🍎',
    lunch => '🍲',
    afternoonSnack => '🥛',
    dinner => '🥗',
    _ => '🍽️',
  };

  static String defaultTime(String slot) => switch (slot) {
    breakfast => '08:00',
    snack => '10:30',
    lunch => '13:00',
    afternoonSnack => '16:00',
    _ => '19:00',
  };
}

class PlanStatus {
  static const planned = 'planned';
  static const eaten = 'eaten';
  static const skipped = 'skipped';
  static const replaced = 'replaced';
  static const all = [planned, eaten, skipped, replaced];

  static String ru(String s) => switch (s) {
    eaten => 'съедено',
    skipped => 'пропущено',
    replaced => 'заменено',
    _ => 'по плану',
  };
}

/// Пункт рациона, как он лежит в базе.
class MealPlanItem {
  const MealPlanItem({
    required this.id,
    required this.date,
    required this.meal,
    required this.time,
    required this.title,
    required this.composition,
    required this.kcal,
    this.proteinG = 0,
    this.fatG = 0,
    this.carbsG = 0,
    this.status = PlanStatus.planned,
    this.note,
  });

  final int id;
  final DateTime date;
  final String meal;
  final String time;
  final String title;
  final List<String> composition;
  final int kcal;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final String status;
  final String? note;

  static String encodeComposition(List<String> c) => jsonEncode(c);
  static List<String> decodeComposition(String s) {
    try {
      return (jsonDecode(s) as List).map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }

  int get minuteOfDay {
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(time);
    if (m == null) return 12 * 60;
    return int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
  }
}

/// Пункт до сохранения (после проверки кодом).
class MealPlanDraft {
  const MealPlanDraft({
    required this.meal,
    required this.time,
    required this.title,
    required this.composition,
    required this.kcal,
    this.proteinG = 0,
    this.fatG = 0,
    this.carbsG = 0,
    this.note,
  });

  final String meal;
  final String time;
  final String title;
  final List<String> composition;
  final int kcal;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final String? note;
}

/// Что должен содержать план одного дня (факты для проверки).
class DayExpectation {
  const DayExpectation({
    required this.date,
    required this.targetKcal,
    required this.tolerance,
    this.expectedSlots = MealSlot.all,
    this.keptSlots = const {},
    this.optional = false,
  });

  final DateTime date;

  /// Сколько ккал должны дать НОВЫЕ пункты этого дня.
  final int targetKcal;
  final int tolerance;

  /// Приёмы, которые обязаны быть.
  final List<String> expectedSlots;

  /// Приёмы, уже закрытые (съедено/заменено/пропущено): заново не создаём.
  final Set<String> keptSlots;

  /// Сегодня, когда почти всё уже съедено: пустой день допустим.
  final bool optional;
}

class RationValidation {
  const RationValidation({
    required this.days,
    required this.problems,
    required this.diffs,
    required this.big,
  });

  /// Проверенные пункты по дням.
  final Map<DateTime, List<MealPlanDraft>> days;
  final List<String> problems;

  /// Сумма минус цель, по дням (только дни, где вышли за допуск).
  final Map<DateTime, int> diffs;

  /// Есть сильное расхождение или потерян день/приём: стоит повторить запрос.
  final bool big;

  bool get ok => problems.isEmpty && diffs.isEmpty;
}

/// Техническая проверка ответа Фитти: JSON, даты, приёмы, суммы.
/// Содержание блюд код не оценивает.
class RationValidator {
  static const minKcal = 20;
  static const maxKcal = 1500;

  static String ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime? parseDate(Object? v) {
    final m = RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch('${v ?? ''}');
    if (m == null) return null;
    final d = DateTime(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    );
    return d;
  }

  /// Достаёт JSON-объект из ответа (допускает ```json ограждения).
  static Map<String, dynamic>? decode(String raw) {
    var s = raw.trim();
    final a = s.indexOf('{');
    final b = s.lastIndexOf('}');
    if (a < 0 || b <= a) return null;
    s = s.substring(a, b + 1);
    try {
      final j = jsonDecode(s);
      return j is Map<String, dynamic> ? j : null;
    } catch (_) {
      return null;
    }
  }

  static String _normTime(Object? v, String slot) {
    final m = RegExp(r'(\d{1,2})\s*[:.]\s*(\d{2})').firstMatch('${v ?? ''}');
    if (m != null) {
      final h = int.parse(m.group(1)!);
      final mm = int.parse(m.group(2)!);
      if (h <= 23 && mm <= 59) {
        return '${h.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
      }
    }
    return MealSlot.defaultTime(slot);
  }

  static double? _macro(Object? v) {
    final n = v is num ? v.toDouble() : double.tryParse('${v ?? ''}');
    if (n == null || n < 0 || n > 300) return null;
    return double.parse(n.toStringAsFixed(1));
  }

  static RationValidation? validate(
    Map<String, dynamic>? json,
    List<DayExpectation> expect,
  ) {
    if (json == null) return null;
    final rawDays = json['days'];
    if (rawDays is! List) return null;

    final byDate = <DateTime, List<dynamic>>{};
    for (final d in rawDays) {
      if (d is! Map) continue;
      final date = parseDate(d['date']);
      final meals = d['meals'];
      if (date == null || meals is! List) continue;
      byDate.putIfAbsent(date, () => []).addAll(meals);
    }

    final problems = <String>[];
    final diffs = <DateTime, int>{};
    final out = <DateTime, List<MealPlanDraft>>{};
    var big = false;

    for (final e in expect) {
      final raw = byDate[e.date];
      if (raw == null) {
        if (!e.optional) {
          problems.add('нет дня ${ymd(e.date)}');
          big = true;
        }
        continue;
      }
      final seen = <String>{};
      final items = <MealPlanDraft>[];
      for (final m in raw) {
        if (m is! Map) continue;
        final slot = MealSlot.normalize(m['meal']);
        if (slot == null || seen.contains(slot) || e.keptSlots.contains(slot)) {
          continue;
        }
        final title = (m['title'] ?? '').toString().trim();
        final kcalRaw = m['kcal'];
        final kcal = kcalRaw is num
            ? kcalRaw.round()
            : int.tryParse('${kcalRaw ?? ''}');
        if (title.isEmpty || kcal == null || kcal < minKcal || kcal > maxKcal) {
          problems.add('${ymd(e.date)} ${MealSlot.ru(slot)}: неверные данные');
          continue;
        }
        var p = _macro(m['protein_g']);
        var f = _macro(m['fat_g']);
        var c = _macro(m['carbs_g']);
        if (p == null || f == null || c == null) {
          p = f = c = 0;
        } else {
          final fromMacros = p * 4 + f * 9 + c * 4;
          // БЖУ, не сходящиеся с калориями, лучше не показывать.
          if (fromMacros > kcal * 1.5 + 60 || fromMacros < kcal * 0.5 - 60) {
            p = f = c = 0;
          }
        }
        final comp = m['composition'] is List
            ? (m['composition'] as List)
                  .map((x) => x.toString().trim())
                  .where((x) => x.isNotEmpty)
                  .take(8)
                  .toList()
            : <String>[];
        final note = (m['note'] ?? '').toString().trim();
        seen.add(slot);
        items.add(
          MealPlanDraft(
            meal: slot,
            time: _normTime(m['time'], slot),
            title: title.length > 80 ? title.substring(0, 80) : title,
            composition: comp,
            kcal: kcal,
            proteinG: p,
            fatG: f,
            carbsG: c,
            note: note.isEmpty ? null : note,
          ),
        );
      }
      for (final s in e.expectedSlots) {
        if (!seen.contains(s) && !e.keptSlots.contains(s)) {
          problems.add('${ymd(e.date)}: нет приёма «${MealSlot.ru(s)}»');
          big = true;
        }
      }
      if (items.isEmpty) {
        if (!e.optional) big = true;
        continue;
      }
      items.sort(
        (a, b) => MealSlot.all
            .indexOf(a.meal)
            .compareTo(MealSlot.all.indexOf(b.meal)),
      );
      final sum = items.fold<int>(0, (s, i) => s + i.kcal);
      final diff = sum - e.targetKcal;
      if (diff.abs() > e.tolerance) {
        diffs[e.date] = diff;
        problems.add('${ymd(e.date)}: сумма $sum ккал, цель ${e.targetKcal}');
        if (diff.abs() > e.tolerance * 2) big = true;
      }
      out[e.date] = items;
    }
    return RationValidation(
      days: out,
      problems: problems,
      diffs: diffs,
      big: big,
    );
  }
}
