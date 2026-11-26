import 'dart:convert';

import 'package:weightloss/domain/entities/diet_plan.dart';
import 'package:weightloss/domain/entities/profile.dart';
import 'package:weightloss/domain/profile_service.dart';
import 'package:weightloss/domain/repositories/repositories.dart';
import 'package:weightloss/domain/settings/settings_repository.dart';

class WeightFacts {
  const WeightFacts({
    required this.points,
    this.weekDelta,
    this.monthDelta,
    this.leftKg,
    this.paceOk,
    this.needKgPerWeek,
    this.actualKgPerWeek,
    this.lastAt,
    this.daysSince,
    this.timeToWeigh = false,
  });

  final List<WeightPoint> points;
  final double? weekDelta;
  final double? monthDelta;
  final double? leftKg;
  final bool? paceOk;
  final double? needKgPerWeek;
  final double? actualKgPerWeek;
  final DateTime? lastAt;
  final int? daysSince;
  final bool timeToWeigh;
}

class WeightOutcome {
  const WeightOutcome({
    required this.saved,
    this.message,
    this.needConfirm = false,
    this.oldKcal,
    this.newKcal,
    this.normChanged = false,
    this.weightKg,
  });

  final bool saved;
  final String? message;

  /// Скачок слишком большой: запись ждёт подтверждения человека.
  final bool needConfirm;
  final int? oldKcal;
  final int? newKcal;
  final bool normChanged;
  final double? weightKg;
}

/// Вес: факты для Фитти, техническая проверка и запись взвешиваний.
class WeightService {
  WeightService({
    required this.profiles,
    required this.profileService,
    required this.settings,
    this.onNormChanged,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final ProfileRepository profiles;
  final ProfileService profileService;
  final SettingsRepository settings;

  /// Норма изменилась: Фитти должен поправить будущие дни рациона.
  final Future<void> Function()? onNormChanged;
  final DateTime Function() _clock;

  static const minWeight = 30.0;
  static const maxWeight = 300.0;

  /// Скачок больше этого за 7 дней — вернуть Фитти на уточнение.
  static const maxJumpPerWeekKg = 3.0;
  static const remindAfterDays = 7;
  static const askEveryDays = 5;

  /// Разумное значение обхвата, см.
  static bool girthOk(double? v) => v == null || (v >= 30 && v <= 250);

  static DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

  /// Скачок относительно ближайшего прошлого взвешивания, приведённый к
  /// неделе. Если прошлое взвешивание в тот же день, считаем за сутки.
  static double jumpPerWeek(WeightPoint last, DateTime at, double weight) {
    final days = (at.difference(last.at).inHours / 24).abs();
    final d = days < 1 ? 1.0 : days;
    return (weight - last.weightKg).abs() / d * 7;
  }

  Future<WeightFacts> facts() async {
    final now = _clock();
    final pts = await profiles.weightHistory(limit: 40);
    final goal = await profiles.getGoal();
    final p = await profiles.getProfile();
    if (pts.isEmpty) return const WeightFacts(points: []);
    final last = pts.last;
    double? delta(int days) {
      final from = now.subtract(Duration(days: days));
      final older = pts.where((w) => !w.at.isAfter(from)).toList();
      if (older.isEmpty) {
        // нет точки «неделю назад»: берём самую раннюю, если она старше 3 дней
        final first = pts.first;
        if (pts.length > 1 &&
            now.difference(first.at).inDays >= 3 &&
            days <= 7) {
          return last.weightKg - first.weightKg;
        }
        return null;
      }
      return last.weightKg - older.last.weightKg;
    }

    final week = delta(7);
    final month = delta(30);
    final daysSince = dayOf(now).difference(dayOf(last.at)).inDays;
    double? left;
    bool? paceOk;
    double? need;
    double? actual;
    if (p != null) left = last.weightKg - p.targetWeightKg;
    if (goal != null && left != null) {
      final weeksLeft = goal.weeksLeft(now);
      need = left > 0 ? left / weeksLeft : 0;
      final elapsedDays = now.difference(goal.startDate).inDays;
      final since = pts.where((w) => !w.at.isBefore(goal.startDate)).toList();
      if (elapsedDays >= 10 && since.length >= 2) {
        final lost = since.first.weightKg - last.weightKg;
        actual = lost / (elapsedDays / 7);
        paceOk = left <= 0 || actual >= need * 0.8;
      }
    }
    return WeightFacts(
      points: pts,
      weekDelta: week,
      monthDelta: month,
      leftKg: left,
      paceOk: paceOk,
      needKgPerWeek: need,
      actualKgPerWeek: actual,
      lastAt: last.at,
      daysSince: daysSince,
      timeToWeigh: daysSince >= remindAfterDays,
    );
  }

  static String _n(double v) =>
      v.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
  static String _sgn(double v) => '${v >= 0 ? '+' : ''}${_n(v)}';

  /// Блок [ВЕС] для контекста (~220 токенов).
  Future<String> block() async {
    final now = _clock();
    final f = await facts();
    final b = StringBuffer('[ВЕС]\n');
    if (f.points.isEmpty) {
      b.write('Взвешиваний нет.');
      return b.toString();
    }
    final tail = f.points.length > 5
        ? f.points.sublist(f.points.length - 5)
        : f.points;
    b.writeln(
      'Последние взвешивания: ${tail.map((w) => '${w.at.day.toString().padLeft(2, '0')}.${w.at.month.toString().padLeft(2, '0')}=${_n(w.weightKg)}').join(', ')}.',
    );
    final tr = <String>[
      if (f.weekDelta != null) 'за неделю ${_sgn(f.weekDelta!)} кг',
      if (f.monthDelta != null) 'за месяц ${_sgn(f.monthDelta!)} кг',
    ];
    if (tr.isNotEmpty) b.writeln('Тренд: ${tr.join(', ')}.');
    if (f.leftKg != null) {
      b.writeln(
        f.leftKg! > 0
            ? 'До цели осталось ${_n(f.leftKg!)} кг.'
            : 'Цель по весу достигнута.',
      );
    }
    if (f.needKgPerWeek != null && f.leftKg! > 0) {
      b.write('Нужный темп ~${_n(f.needKgPerWeek!)} кг/нед');
      if (f.actualKgPerWeek != null) {
        b.write(', фактический ~${_n(f.actualKgPerWeek!)} кг/нед');
      }
      b.writeln(
        f.paceOk == null
            ? '.'
            : (f.paceOk! ? ': идёт по сроку.' : ': отстаёт от срока.'),
      );
      if (f.paceOk == false) {
        b.writeln('Можно мягко предложить пересмотреть срок: решает человек.');
      }
    }
    b.writeln(
      'Последнее взвешивание: ${f.lastAt!.day.toString().padLeft(2, '0')}.${f.lastAt!.month.toString().padLeft(2, '0')} '
      '(${f.daysSince} дн. назад).',
    );
    if (f.timeToWeigh) {
      final asked = DateTime.tryParse(
        await settings.get(SettingKeys.weightLastAsked) ?? '',
      );
      final canAsk =
          asked == null || now.difference(asked).inDays >= askEveryDays;
      if (canAsk) _shown = true;
      b.writeln(
        canAsk
            ? 'ПОРА ВЗВЕСИТЬ: прошло ${f.daysSince} дн. Естественно попроси вес '
                  '(иногда и обхваты: талия, грудь, бёдра).'
            : 'Пора взвешивать, но недавно уже просил: не напоминай.',
      );
    }
    final pend = await pending();
    if (pend != null) {
      b.writeln(
        'ЖДЁТ ПОДТВЕРЖДЕНИЯ: ${_n(pend['weight_kg'] as double)} кг '
        '(скачок слишком большой). Уточни у человека, не ошибка ли.',
      );
    }
    return b.toString().trimRight();
  }

  bool _shown = false;

  /// Вызывается после ответа Фитти: если просьба о весе была в контексте,
  /// считаем, что он попросил, и не просим снова 5 дней.
  Future<void> commitAsked() async {
    if (!_shown) return;
    _shown = false;
    await markAsked();
  }

  /// Фитти попросил вес в этом ответе: отмечаем, чтобы не просить чаще.
  Future<void> markAsked() =>
      settings.set(SettingKeys.weightLastAsked, _clock().toIso8601String());

  Future<Map<String, dynamic>?> pending() async {
    try {
      final s = await settings.get(SettingKeys.weightPending);
      if (s == null || s.isEmpty) return null;
      final m = jsonDecode(s) as Map<String, dynamic>;
      m['weight_kg'] = (m['weight_kg'] as num).toDouble();
      return m;
    } catch (_) {
      return null;
    }
  }

  /// update_weight. [confirmed] — человек подтвердил большой скачок.
  Future<WeightOutcome> apply({
    required double? weightKg,
    double? waistCm,
    double? chestCm,
    double? hipsCm,
    DateTime? date,
    bool confirmed = false,
  }) async {
    final now = _clock();
    final p = await profiles.getProfile();
    if (p == null) {
      return const WeightOutcome(saved: false, message: 'нет профиля');
    }
    var w = weightKg;
    var at = date ?? now;
    if (at.isAfter(now)) at = now;
    if (now.difference(at).inDays > 60) {
      return const WeightOutcome(saved: false, message: 'дата слишком старая');
    }
    if (date != null && dayOf(at) == dayOf(now)) at = now;
    if (w == null && (waistCm != null || chestCm != null || hipsCm != null)) {
      w = p.weightKg; // только замеры
    }
    if (w == null) {
      return const WeightOutcome(saved: false, message: 'нет значения веса');
    }
    if (w < minWeight || w > maxWeight) {
      return WeightOutcome(
        saved: false,
        needConfirm: true,
        message:
            'вес ${_n(w)} кг выглядит неправдоподобно: уточни у человека, '
            'нет ли ошибки',
      );
    }
    if (!girthOk(waistCm) || !girthOk(chestCm) || !girthOk(hipsCm)) {
      return const WeightOutcome(
        saved: false,
        needConfirm: true,
        message: 'обхват выглядит неправдоподобно: уточни у человека',
      );
    }

    // Скачок: сравниваем с последним взвешиванием.
    final hist = await profiles.weightHistory(limit: 1);
    final pend = await pending();
    final confirmedNow =
        confirmed ||
        (pend != null && ((pend['weight_kg'] as double) - w).abs() < 0.05);
    if (hist.isNotEmpty && weightKg != null && !confirmedNow) {
      final j = jumpPerWeek(hist.last, at, w);
      if (j > maxJumpPerWeekKg) {
        await settings.set(
          SettingKeys.weightPending,
          jsonEncode({
            'weight_kg': w,
            'waist_cm': waistCm,
            'chest_cm': chestCm,
            'hips_cm': hipsCm,
            'at': at.toIso8601String(),
          }),
        );
        return WeightOutcome(
          saved: false,
          needConfirm: true,
          weightKg: w,
          message:
              'скачок с ${_n(hist.last.weightKg)} до ${_n(w)} кг слишком '
              'резкий для такого срока: уточни у человека, всё ли верно. '
              'Запись не сохранена; когда человек подтвердит, отправь то же '
              'значение ещё раз',
        );
      }
    }

    final old = await profiles.getDietPlan();
    final goal = await profiles.getGoal();
    final updated = p.copyWith(
      weightKg: w,
      waistCm: waistCm ?? p.waistCm,
      chestCm: chestCm ?? p.chestCm,
      hipsCm: hipsCm ?? p.hipsCm,
    );
    await profiles.recordMeasurement(updated, at: at, source: 'chat');
    await settings.remove(SettingKeys.weightPending);
    if (waistCm != null || chestCm != null || hipsCm != null) {
      await settings.set(SettingKeys.weightGirthsAt, now.toIso8601String());
    }

    // Новая норма (только норма; история цифр сохраняется).
    DietPlanData? plan = old;
    var changed = false;
    final latest = await profiles.weightHistory(limit: 1);
    if (latest.isNotEmpty && !at.isBefore(latest.last.at)) {
      final level = await settings.get(SettingKeys.activityLevel);
      final norm = profileService.calculate(
        updated,
        goal?.weeks ?? 12,
        activityLevel: level,
      );
      final newPlan = ProfileService.planFrom(norm);
      if (old == null ||
          old.kcal != newPlan.kcal ||
          old.proteinG != newPlan.proteinG) {
        await profiles.replaceDietPlan(newPlan);
        plan = newPlan;
        changed = old == null ? false : old.kcal != newPlan.kcal;
      }
    }
    if (changed) {
      try {
        await onNormChanged?.call();
      } catch (_) {}
    }
    return WeightOutcome(
      saved: true,
      weightKg: w,
      normChanged: changed,
      oldKcal: old?.kcal,
      newKcal: plan?.kcal,
    );
  }
}

/// Разбор дат вида 2026-03-10.
DateTime? parseWeightDate(Object? v) {
  final m = RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch('${v ?? ''}');
  if (m == null) return null;
  return DateTime(
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    int.parse(m.group(3)!),
    12,
  );
}

double? parseWeightNum(Object? v) {
  if (v is num) return v.toDouble();
  return double.tryParse('${v ?? ''}'.replaceAll(',', '.'));
}

/// Текст для пользователя о выполненной записи (подвал под ответом).
String weightFooter(Profile? p, WeightOutcome o) {
  if (!o.saved) return '';
  final b = StringBuffer('Записал вес ${o.weightKg!.toStringAsFixed(1)} кг.');
  if (o.normChanged && o.newKcal != null) {
    b.write(' Новая норма: ${o.newKcal} ккал в день (было ${o.oldKcal}).');
  }
  return b.toString();
}
