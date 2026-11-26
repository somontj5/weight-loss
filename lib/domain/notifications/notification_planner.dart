import 'package:weightloss/domain/notifications/notification_models.dart';

/// Выбор времени и антиспам. Чистая логика без плагинов: легко тестировать.
/// Тексты подставляет вызывающий код (через [TextPicker]).
typedef TextPicker =
    ({String title, String body}) Function(
      String slot,
      DateTime at,
      int? customId,
      String? customText,
    );

class NotificationPlanner {
  /// Сдвиг напоминания о еде относительно времени приёма пищи:
  /// спрашиваем «вы уже поели?», когда обычно уже поели.
  static const mealOffsetMin = 30;

  /// Не чаще, чем раз в столько минут (из двух близких остаётся важнее).
  static const minGapMin = 45;

  /// Абсолютная ночь: в это время не будим никогда.
  static const hardNightEndMin = 7 * 60;

  static const defaultBreakfast = 8 * 60;
  static const defaultLunch = 13 * 60;
  static const defaultDinner = 19 * 60;
  static const defaultSummary = 21 * 60 + 30;

  /// Парсит «07:30», «7.30», «в 8:15» в минуты от полуночи.
  static int? parseTime(String? s) {
    if (s == null) return null;
    final m = RegExp(r'(\d{1,2})\s*[:.]\s*(\d{2})').firstMatch(s);
    if (m == null) return null;
    final h = int.parse(m.group(1)!);
    final mm = int.parse(m.group(2)!);
    if (h > 23 || mm > 59) return null;
    return h * 60 + mm;
  }

  /// Время суток для слота тренировки из онбординга.
  static int workoutMinuteForSlot(String? slot) => switch (slot) {
    'morning' => 8 * 60 + 30,
    'day' => 14 * 60,
    _ => 19 * 60 + 30,
  };

  /// Базовое время напоминания слота (минуты от полуночи) или null.
  static int? baseMinute(String slot, PlanInput i) {
    switch (slot) {
      case NotifSlot.breakfast:
        final m =
            i.breakfastMin ??
            (i.wakeUpMin != null ? i.wakeUpMin! + 60 : defaultBreakfast);
        return m + mealOffsetMin;
      case NotifSlot.lunch:
        return (i.lunchMin ?? defaultLunch) + mealOffsetMin;
      case NotifSlot.dinner:
        return (i.dinnerMin ?? defaultDinner) + mealOffsetMin;
      case NotifSlot.summary:
        if (i.bedtimeMin != null) {
          // за полтора часа до сна (отбой после полуночи учитываем)
          final b = i.bedtimeMin! < 4 * 60
              ? i.bedtimeMin! + 24 * 60
              : i.bedtimeMin!;
          return (b - 90) % (24 * 60);
        }
        return defaultSummary;
      default:
        return null;
    }
  }

  /// Тихие часы с учётом режима дня: от отбоя до подъёма, если известны.
  static (int from, int to) quietRange(PlanInput i) {
    final from = i.bedtimeMin != null && i.bedtimeMin! >= 20 * 60
        ? i.bedtimeMin!
        : i.prefs.quietFromMin;
    final to = i.wakeUpMin ?? i.prefs.quietToMin;
    return (from, to);
  }

  static bool _quiet(int minute, int from, int to) {
    if (minute < hardNightEndMin) return true;
    if (from == to) return false;
    if (from > to) return minute >= from || minute < to;
    return minute >= from && minute < to;
  }

  static List<PlannedNotif> plan(PlanInput i, TextPicker pick) {
    if (!i.prefs.enabled) return const [];
    final out = <PlannedNotif>[];
    final (qFrom, qTo) = quietRange(i);
    final today = DateTime(i.now.year, i.now.month, i.now.day);

    for (var d = 0; d < i.days; d++) {
      final day = today.add(Duration(days: d));
      final cands = <_Cand>[];

      // 1) Слоты по режиму дня (с учётом ручных настроек).
      for (final slot in NotifSlot.named) {
        final ov = _overrideFor(i.overrides, slot);
        if (ov != null && (!ov.enabled || !ov.runsOn(day))) continue;
        if (d == 0 &&
            NotifSlot.meals.contains(slot) &&
            i.loggedMealsToday.contains(slot)) {
          continue; // уже записал: не напоминаем
        }
        final fixed = (ov != null && ov.minuteOfDay >= 0)
            ? ov.minuteOfDay
            : null;
        final fromPlan = i.planTimes[PlanInput.dayKey(day)]?[slot];
        var m =
            fixed ??
            (fromPlan != null ? fromPlan + mealOffsetMin : baseMinute(slot, i)!);
        if (_quiet(m, qFrom, qTo)) {
          if (slot == NotifSlot.summary && fixed == null) {
            m = (qFrom - 30) % (24 * 60); // итог сдвигаем до тихих часов
            if (_quiet(m, qFrom, qTo)) continue;
          } else {
            continue;
          }
        }
        cands.add(_Cand(slot, m, null, null));
      }

      // 1б) «Пора взвеситься»: один раз, в первый подходящий день,
      // мягко, утром; потом не повторяется, пока не будет взвешивания.
      if (i.lastWeighAt != null) {
        final lw = DateTime(
          i.lastWeighAt!.year,
          i.lastWeighAt!.month,
          i.lastWeighAt!.day,
        );
        final due = lw.add(const Duration(days: 7));
        var first = due;
        if (due.isBefore(today)) {
          // просрочено: напоминаем раз в неделю от даты «срока»
          final late = today.difference(due).inDays;
          first = due.add(Duration(days: ((late + 6) ~/ 7) * 7));
        }
        if (day == first) {
          final base = (i.wakeUpMin ?? defaultBreakfast) + 20;
          var m = base < 9 * 60 ? 9 * 60 : base;
          if (!_quiet(m, qFrom, qTo)) cands.add(_Cand(NotifSlot.weigh, m, null, null));
        }
      }

      // 1в) «План на завтра готов»: вечером, если рацион на завтра есть.
      if (i.planDays.contains(PlanInput.dayKey(day.add(const Duration(days: 1))))) {
        var m = defaultSummary - 90;
        if (i.bedtimeMin != null) {
          final b = i.bedtimeMin! < 4 * 60 ? i.bedtimeMin! + 24 * 60 : i.bedtimeMin!;
          m = ((b - 150) % (24 * 60));
        }
        if (!_quiet(m, qFrom, qTo)) cands.add(_Cand(NotifSlot.planReady, m, null, null));
      }

      // 2) Пользовательские напоминания.
      for (final o in i.overrides.where((o) => o.slot == NotifSlot.custom)) {
        if (!o.enabled || !o.runsOn(day)) continue;
        if (_quiet(o.minuteOfDay, qFrom, qTo)) continue;
        cands.add(_Cand(NotifSlot.custom, o.minuteOfDay, o.id, o.text));
      }

      // 3) Тренировки, назначенные тренером на этот день.
      for (final w in i.workouts) {
        if (w.year != day.year || w.month != day.month || w.day != day.day) {
          continue;
        }
        final m = w.hour * 60 + w.minute;
        if (_quiet(m, qFrom, qTo)) continue;
        cands.add(_Cand(NotifSlot.workout, m, null, null));
      }

      // Прошедшее время сегодня не планируем.
      final nowMin = i.now.hour * 60 + i.now.minute;
      cands.removeWhere((c) => d == 0 && c.minute <= nowMin + 1);

      // Антиспам: минимальный интервал, затем дневной лимит по важности.
      final byTime = [...cands]..sort((a, b) => a.minute.compareTo(b.minute));
      final spaced = <_Cand>[];
      for (final c in byTime) {
        final clash = spaced.where(
          (s) => (s.minute - c.minute).abs() < minGapMin,
        );
        if (clash.isEmpty) {
          spaced.add(c);
          continue;
        }
        final other = clash.first;
        if (NotifSlot.priority(c.slot) < NotifSlot.priority(other.slot)) {
          spaced
            ..remove(other)
            ..add(c);
        }
      }
      final byPriority = [...spaced]
        ..sort(
          (a, b) =>
              NotifSlot.priority(a.slot).compareTo(NotifSlot.priority(b.slot)),
        );
      final kept = byPriority.take(i.prefs.maxPerDay).toList()
        ..sort((a, b) => a.minute.compareTo(b.minute));

      for (final c in kept) {
        final at = day.add(Duration(minutes: c.minute));
        final t = pick(c.slot, at, c.customId, c.text);
        out.add(
          PlannedNotif(
            id: notifId(day, c.slot, c.customId),
            slot: c.slot,
            at: at,
            title: t.title,
            body: t.body,
            payload:
                '${c.slot}|${day.year}-${day.month}-${day.day}|${c.customId ?? 0}',
          ),
        );
      }
    }
    return out;
  }

  static NotifOverride? _overrideFor(List<NotifOverride> list, String slot) {
    for (final o in list) {
      if (o.slot == slot) return o;
    }
    return null;
  }

  /// Стабильный id: день × 100 + слот × 10 + (id custom % 10).
  static int notifId(DateTime day, String slot, int? customId) {
    final dayNum = day.year % 100 * 10000 + day.month * 100 + day.day;
    return (dayNum * 100 + NotifSlot.code(slot) * 10 + (customId ?? 0) % 10) %
        2147483647;
  }
}

class _Cand {
  _Cand(this.slot, this.minute, this.customId, this.text);
  final String slot;
  final int minute;
  final int? customId;
  final String? text;
}
