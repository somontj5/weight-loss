import 'package:weightloss/domain/coach/coach_models.dart';

/// ЗАПАСНОЙ офлайн-тренер: работает только без сети. Когда сеть есть, решает Фитти.
class OfflineCoach {
  static const maxPerWeek = 5;
  static const lateHour = 21; // после 21:30 назначаем на завтра

  static int _round5(num v) => (v / 5).round() * 5;

  static CoachDecision decide(CoachInput i) {
    final now = i.now;
    final bmi = i.bmi;

    // Ограничения по возрасту и весу.
    var maxDiff = 3;
    if (i.age >= 60 || bmi >= 35) {
      maxDiff = 1;
    } else if (i.age >= 50 || bmi >= 30) {
      maxDiff = 2;
    }
    final allowImpact = i.age < 50 && bmi < 32 && !i.jointIssue;

    final hist = i.history;
    final doneLast14 = hist
        .where((r) => r.completed && now.difference(r.date).inDays < 14)
        .length;
    if (hist.where((r) => r.completed).length < 3 && maxDiff > 2) {
      maxDiff = 2; // новичку сразу «три» не даём
    }

    // Съедено сверх плана.
    final tol = i.toleranceKcal;
    final overToday = i.entriesToday > 0 ? i.eatenToday - i.planKcal : 0;
    var weekOver = 0;
    for (final d in i.pastDays) {
      final diff = d.kcal - i.planKcal;
      if (diff > 0) weekOver += diff;
    }
    if (overToday > 0) weekOver += overToday;
    final overTodayFlag = overToday > tol;
    final overWeekFlag = weekOver > tol * 2;

    final reasons = <String>[];
    if (overTodayFlag) {
      reasons.add('сегодня съедено сверх нормы ~${_r10(overToday)} ккал');
    }
    if (overWeekFlag) {
      reasons.add('за неделю сверх нормы набралось ~${_r10(weekOver)} ккал');
    }

    // Самочувствие.
    if (i.wellbeing == Wellbeing.sick) {
      return CoachDecision(
        needed: false,
        difficulty: 1,
        minutes: 0,
        maxDifficulty: maxDiff,
        allowHighImpact: allowImpact,
        restReason: 'плохое самочувствие, сегодня отдых',
        reasons: reasons,
        overTodayKcal: overToday > 0 ? overToday : 0,
        overWeekKcal: weekOver,
        wellbeing: i.wellbeing,
      );
    }

    // Нужна ли тренировка сегодня.
    String? rest;
    final trainedIn = {
      for (final r in hist.where((r) => r.status != 'skipped'))
        DateTime(r.date.year, r.date.month, r.date.day),
    };
    final today = DateTime(now.year, now.month, now.day);
    final yday = today.subtract(const Duration(days: 1));
    final dayBefore = today.subtract(const Duration(days: 2));
    final weekCount = trainedIn
        .where((d) => today.difference(d).inDays < 7)
        .length;
    final overAny = overTodayFlag || overWeekFlag;

    if (i.workoutDoneToday) {
      rest = 'сегодня тренировка уже была';
    } else if (weekCount >= maxPerWeek) {
      rest = 'на этой неделе тренировок уже достаточно, нужен отдых';
    } else if (trainedIn.contains(yday) &&
        trainedIn.contains(dayBefore) &&
        !overTodayFlag) {
      rest = 'две тренировки подряд позади, сегодня отдых';
    } else if (trainedIn.contains(yday) &&
        hist.isNotEmpty &&
        hist.first.completed &&
        (hist.first.difficulty ?? 1) >= 3 &&
        !overAny) {
      rest = 'вчера была тяжёлая тренировка, телу нужен отдых';
    }
    if (rest != null) {
      return CoachDecision(
        needed: false,
        difficulty: 1,
        minutes: 0,
        maxDifficulty: maxDiff,
        allowHighImpact: allowImpact,
        restReason: rest,
        reasons: reasons,
        overTodayKcal: overToday > 0 ? overToday : 0,
        overWeekKcal: weekOver,
        wellbeing: i.wellbeing,
      );
    }

    // Базовая сложность по опыту и последним результатам.
    var base = doneLast14 >= 6 ? 3 : (doneLast14 >= 2 ? 2 : 1);
    final last = hist.isEmpty ? null : hist.first;
    final recent3 = hist.take(3).toList();
    final struggledRecently = last != null && last.struggled;
    final softReturn = recent3.length == 3 && recent3.every((r) => r.struggled);
    if (struggledRecently) {
      base = (base - 1).clamp(1, 3);
      reasons.add('в прошлый раз было тяжело (пропуски или остановка)');
    }

    // Мало съели к вечеру: сил может не быть, не усложняем.
    final lowEnergy =
        i.entriesToday > 0 && now.hour >= 17 && i.eatenToday < i.planKcal * 0.5;

    // Усложнение за съеденное сверх плана (но не при плохом самочувствии).
    final tired = i.wellbeing == Wellbeing.tired;
    var bump = 0;
    if (overTodayFlag) bump++;
    if (overWeekFlag) bump++;
    if (bump > 1) bump = 1; // не больше +1 за раз
    final baseC = base.clamp(1, maxDiff);
    var diff = baseC;
    var escalate = false;
    if (bump > 0 && !tired && !lowEnergy && !softReturn && baseC < maxDiff) {
      diff = baseC + 1; // усложняем, только если есть куда (потолок не трогаем)
      escalate = true;
    }
    if (tired) {
      diff = 1;
      reasons.add('самочувствие не очень, нагрузка лёгкая');
    }
    if (lowEnergy && !tired) {
      diff = diff > 2 ? 2 : diff;
      reasons.add('сегодня съедено мало, силы берегём');
    }
    if (softReturn) {
      diff = 1;
      reasons.add(
        'несколько тренировок подряд не получились, возвращаемся мягко',
      );
    }

    // Длительность.
    var minutes = i.trainingMinutes.clamp(10, 60);
    if (escalate) minutes += 5;
    if (struggledRecently) minutes = (minutes * 0.75).round();
    if (tired || softReturn) minutes = minutes > 15 ? 15 : minutes;
    final cap = (i.age >= 60 || bmi >= 35) ? 30 : 60;
    minutes = _round5(minutes).clamp(10, cap);

    return CoachDecision(
      needed: true,
      difficulty: diff,
      minutes: minutes,
      maxDifficulty: maxDiff,
      allowHighImpact: allowImpact,
      when: _when(now, i.trainingSlot),
      reasons: reasons,
      overTodayKcal: overToday > 0 ? overToday : 0,
      overWeekKcal: weekOver,
      escalated: escalate,
      wellbeing: i.wellbeing,
    );
  }

  static int _r10(num v) => (v / 10).round() * 10;

  /// Время тренировки: слот из регистрации; если он прошёл, то ближайшее
  /// разумное время сегодня, а поздно вечером завтра.
  static DateTime _when(DateTime now, String slot) {
    final h = switch (slot) {
      'morning' => 8,
      'day' => 14,
      _ => 19,
    };
    final m = slot == 'evening' ? 30 : (slot == 'morning' ? 30 : 0);
    final today = DateTime(now.year, now.month, now.day);
    final slotTime = today.add(Duration(hours: h, minutes: m));
    if (slotTime.isAfter(now.add(const Duration(minutes: 5)))) return slotTime;
    final late =
        now.hour > lateHour || (now.hour == lateHour && now.minute >= 30);
    if (late) {
      return today.add(Duration(days: 1, hours: h, minutes: m));
    }
    final soon = now.add(const Duration(minutes: 30));
    final mm = (soon.minute / 5).ceil() * 5;
    return DateTime(
      soon.year,
      soon.month,
      soon.day,
      soon.hour,
    ).add(Duration(minutes: mm));
  }
}
