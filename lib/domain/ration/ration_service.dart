import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:weightloss/domain/diary/diary_service.dart';
import 'package:weightloss/domain/entities/memory_fact.dart';
import 'package:weightloss/domain/ration/meal_plan_repository.dart';
import 'package:weightloss/domain/ration/ration_models.dart';
import 'package:weightloss/domain/repositories/repositories.dart';
import 'package:weightloss/domain/settings/settings_repository.dart';

/// Отдельный запрос к модели: (системная инструкция, запрос) -> JSON-текст.
typedef RationAsk = Future<String> Function(String system, String user);

class RationResult {
  const RationResult({
    required this.ok,
    this.days = const [],
    this.marked = const [],
    this.message,
  });

  final bool ok;
  final List<DateTime> days;

  /// Дни, где сумма калорий не сошлась с нормой (показываем с пометкой).
  final List<DateTime> marked;
  final String? message;
}

/// Рацион: код собирает факты, Фитти составляет план одним запросом,
/// код проверяет технически и сохраняет. Содержание блюд решает Фитти.
class RationService {
  RationService({
    required this.repo,
    required this.profiles,
    required this.memory,
    required this.diary,
    required this.settings,
    this.ask,
    this.onChanged,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final MealPlanRepository repo;
  final ProfileRepository profiles;
  final MemoryRepository memory;
  final DiaryService diary;
  final SettingsRepository settings;
  final RationAsk? ask;
  final Future<void> Function()? onChanged;
  final DateTime Function() _clock;

  /// Счётчик изменений: на него подписан экран «Рацион».
  final ValueNotifier<int> revision = ValueNotifier<int>(0);
  bool _busy = false;
  bool get busy => _busy;

  /// Показывает на экране «Фитти составляет план…».
  final ValueNotifier<bool> working = ValueNotifier<bool>(false);

  static const horizonDays = 3;
  static const maxDays = 7;
  static const retryEveryHours = 3;

  static DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

  // ───────── когда продлевать ─────────

  /// Нужно ли дополнить рацион: будущих дней (после сегодня) меньше 2.
  static bool needsExtension(Iterable<DateTime> planDates, DateTime now) {
    final today = dayOf(now);
    final future = <DateTime>{
      for (final d in planDates)
        if (dayOf(d).isAfter(today)) dayOf(d),
    };
    return future.length < 2;
  }

  // ───────── чего не хватает в памяти ─────────

  static List<String> missingInfo(List<MemoryFact> facts) {
    bool any(bool Function(MemoryFact f) t) => facts.any(t);
    final out = <String>[];
    if (!any(
      (f) =>
          f.category == 'intolerance' ||
          f.key.startsWith('intolerance.') ||
          f.key.startsWith('allergy.'),
    )) {
      out.add('непереносимости и аллергии');
    }
    if (!any(
      (f) =>
          f.key.startsWith('food.like') ||
          f.key.startsWith('food.dislike') ||
          f.key.startsWith('food.pref') ||
          f.key.startsWith('food.favorite'),
    )) {
      out.add('любимые и нелюбимые продукты');
    }
    if (!any(
      (f) =>
          f.key.contains('product') ||
          f.key.contains('pantry') ||
          f.key.startsWith('food.home') ||
          f.key.startsWith('food.cook'),
    )) {
      out.add('какие продукты обычно есть дома');
    }
    if (!any((f) => f.category == 'budget' || f.key.startsWith('budget.'))) {
      out.add('бюджет на еду');
    }
    return out;
  }

  Future<List<String>> missing() async => missingInfo(await memory.active());

  /// Рацион считается черновиком, пока нет ответов на вопросы.
  Future<bool> isDraft() async => (await missing()).isNotEmpty;

  // ───────── обслуживание ─────────

  /// При открытии: закрыть прошедшие пункты и, если нужно, дополнить рацион.
  Future<void> maintain() async {
    try {
      final now = _clock();
      final closed = await repo.closePast(now);
      var changed = closed > 0;
      if (ask != null && await _plan() != null) {
        final dates = await repo.datesFrom(now);
        if (needsExtension(dates, now) && await _canAttempt(now)) {
          final r = await generate(
            reason: 'приложение открыто, в рационе меньше двух будущих дней',
          );
          changed = changed || r.ok;
        }
      }
      if (changed) _bump();
    } catch (_) {}
  }

  Future<bool> _canAttempt(DateTime now) async {
    final s = await settings.get(SettingKeys.rationLastAttempt);
    final t = DateTime.tryParse(s ?? '');
    return t == null || now.difference(t).inHours >= retryEveryHours;
  }

  Future<dynamic> _plan() => profiles.getDietPlan();

  void _bump() {
    revision.value++;
  }

  // ───────── связь с дневником ─────────

  /// Еда записана со ссылкой на пункт рациона: обновляем статус.
  /// [status] — eaten (по умолчанию) | replaced | skipped.
  Future<bool> linkFood(int planItemId, {String? status}) async {
    final item = await repo.byId(planItemId);
    if (item == null) return false;
    final s = PlanStatus.all.contains(status) && status != PlanStatus.planned
        ? status!
        : PlanStatus.eaten;
    final ok = await repo.setStatus(planItemId, s);
    if (ok) _bump();
    return ok;
  }

  /// Запись дневника удалена: пункт снова «по плану».
  Future<void> unlinkFood(int planItemId) async {
    if (await repo.setStatus(planItemId, PlanStatus.planned)) _bump();
  }

  Future<bool> setStatus(int id, String status) async {
    final ok = await repo.setStatus(id, status);
    if (ok) _bump();
    return ok;
  }

  // ───────── факты для запроса ─────────

  static String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static String _slotOfDiary(String meal, DateTime t) {
    switch (meal) {
      case 'breakfast':
        return MealSlot.breakfast;
      case 'lunch':
        return MealSlot.lunch;
      case 'dinner':
        return MealSlot.dinner;
      default:
        return t.hour < 14 ? MealSlot.snack : MealSlot.afternoonSnack;
    }
  }

  /// Ожидания проверки для дней. Сегодня: только оставшиеся приёмы и
  /// остаток нормы. Будущие дни: все 5 приёмов и полная норма.
  Future<List<DayExpectation>> expectations(
    List<DateTime> days,
    int kcal,
    int tolerance,
  ) async {
    final now = _clock();
    final today = dayOf(now);
    final out = <DayExpectation>[];
    for (final d in days.map(dayOf)) {
      final items = await repo.day(d);
      final kept = <String>{
        for (final i in items)
          if (i.status != PlanStatus.planned) i.meal,
      };
      if (d == today) {
        final eaten = await diary.day(d);
        for (final e in eaten) {
          kept.add(_slotOfDiary(e.meal, e.eatenAt));
        }
        final nowMin = now.hour * 60 + now.minute;
        final left = <String>[];
        for (final s in MealSlot.all) {
          if (kept.contains(s)) continue;
          final tm = items.where((i) => i.meal == s).map((i) => i.minuteOfDay);
          final m = tm.isNotEmpty
              ? tm.first
              : int.parse(MealSlot.defaultTime(s).substring(0, 2)) * 60;
          if (m + 60 >= nowMin) left.add(s);
        }
        final eatenKcal = eaten.fold<int>(0, (s, e) => s + (e.kcal ?? 0));
        final keptPlanned = items
            .where(
              (i) =>
                  i.status != PlanStatus.planned &&
                  !eaten.any((e) => e.planItemId == i.id),
            )
            .fold<int>(
              0,
              (s, i) => s + (i.status == PlanStatus.skipped ? 0 : i.kcal),
            );
        final target = (kcal - eatenKcal - keptPlanned).clamp(0, kcal);
        out.add(
          DayExpectation(
            date: d,
            targetKcal: target,
            tolerance: tolerance + 60,
            expectedSlots: left,
            keptSlots: kept,
            optional: left.isEmpty || target < 150,
          ),
        );
      } else {
        out.add(
          DayExpectation(
            date: d,
            targetKcal: kcal,
            tolerance: tolerance,
            keptSlots: kept,
            expectedSlots: [
              for (final s in MealSlot.all)
                if (!kept.contains(s)) s,
            ],
          ),
        );
      }
    }
    return out;
  }

  Future<String> _facts(
    List<DayExpectation> exp,
    String reason,
    String? userNote,
  ) async {
    final now = _clock();
    final p = await profiles.getProfile();
    final plan = await profiles.getDietPlan();
    final goal = await profiles.getGoal();
    final b = StringBuffer();
    b.writeln('Сейчас: ${RationValidator.ymd(now)} ${_hm(now)}.');
    b.writeln('Причина запроса: $reason.');
    if (userNote != null && userNote.trim().isNotEmpty) {
      b.writeln('Пожелание человека: ${userNote.trim()}');
    }
    if (p != null) {
      b.writeln(
        'Человек: ${p.name.isEmpty ? 'без имени' : p.name}, '
        '${p.female ? 'женщина' : 'мужчина'}, ${p.ageAt(now)} лет, '
        'рост ${p.heightCm.round()} см, вес ${p.weightKg.toStringAsFixed(1)} кг, '
        'цель ${p.targetWeightKg.toStringAsFixed(1)} кг'
        '${goal != null ? ', осталось ${goal.weeksLeft(now)} нед.' : ''}.',
      );
    }
    if (plan != null) {
      b.writeln(
        'Норма в день: ${plan.kcal} ккал (допуск ±${plan.toleranceKcal}), '
        'белки ${plan.proteinG} г, жиры ${plan.fatG} г, углеводы ${plan.carbsG} г.',
      );
    }
    final facts = await memory.active();
    if (facts.isEmpty) {
      b.writeln('Память о человеке: пусто.');
    } else {
      b.writeln(
        'Память о человеке (непереносимости, предпочтения, продукты, бюджет, режим дня, здоровье):',
      );
      for (final f in facts.take(40)) {
        b.writeln('- [${f.category}] ${f.fact}');
      }
    }
    final miss = missingInfo(facts);
    if (miss.isNotEmpty) {
      b.writeln(
        'Неизвестно: ${miss.join(', ')}. Составь осторожный универсальный план (черновик).',
      );
    }
    // Что ела за 7 дней.
    b.writeln(
      'Что реально ел человек за последние 7 дней (ккал против нормы):',
    );
    var anyDay = false;
    for (var i = 7; i >= 1; i--) {
      final d = dayOf(now).subtract(Duration(days: i));
      final list = await diary.day(d);
      if (list.isEmpty) continue;
      anyDay = true;
      final sum = list.fold<int>(0, (s, e) => s + (e.kcal ?? 0));
      final dev = plan == null
          ? ''
          : ' (${sum - plan.kcal >= 0 ? '+' : ''}${sum - plan.kcal})';
      b.writeln(
        '${RationValidator.ymd(d)}: ~$sum$dev: '
        '${list.take(6).map((e) => '${MealKind2.ru(e.meal)} ${e.description}').join('; ')}',
      );
    }
    final todayList = await diary.day(now);
    if (todayList.isNotEmpty) {
      final sum = todayList.fold<int>(0, (s, e) => s + (e.kcal ?? 0));
      b.writeln(
        'Сегодня уже съедено ~$sum ккал: '
        '${todayList.map((e) => e.description).take(6).join('; ')}',
      );
    }
    if (!anyDay && todayList.isEmpty) b.writeln('Записей в дневнике пока нет.');
    // Что уже в рационе.
    final existing = <String>[];
    for (final e in exp) {
      for (final i in await repo.day(e.date)) {
        existing.add(
          '${RationValidator.ymd(i.date)} ${MealSlot.ru(i.meal)} ${i.title} '
          '${i.kcal} ккал [${PlanStatus.ru(i.status)}]',
        );
      }
    }
    if (existing.isNotEmpty) {
      b.writeln('Сейчас в рационе на эти дни:');
      for (final l in existing.take(30)) {
        b.writeln('- $l');
      }
    }
    b.writeln('Нужно составить рацион на дни:');
    for (final e in exp) {
      b.writeln(
        '- ${RationValidator.ymd(e.date)}: приёмы ${e.expectedSlots.join(', ')}; '
        'сумма ккал этих приёмов должна быть ${e.targetKcal} ±${e.tolerance}'
        '${e.keptSlots.isNotEmpty ? ' (уже закрыты и заново не нужны: ${e.keptSlots.join(', ')})' : ''}.',
      );
    }
    return b.toString();
  }

  static const _system = '''
Ты — Фитти, диетолог. Составь рацион питания для человека на указанные дни. Решаешь ТЫ: блюда, порции, время, состав. Учти непереносимости, предпочтения, продукты, бюджет, режим дня и здоровье из памяти, повтори любимое, не повторяй одно и то же подряд, учти что человек реально ел и отклонения. Блюда простые, из обычных магазинов.
Ответ СТРОГО один JSON-объект без текста вокруг и без markdown:
{"days":[{"date":"ГГГГ-ММ-ДД","meals":[{"meal":"breakfast","time":"08:00","title":"Овсянка с яблоком","composition":["овсяные хлопья 50 г","яблоко 1 шт","молоко 150 мл"],"kcal":380,"protein_g":14,"fat_g":9,"carbs_g":60,"note":""}]}],"comment":"одно тёплое предложение"}
meal: breakfast | snack | lunch | afternoon_snack | dinner. time: "ЧЧ:ММ". kcal — целое число для всего приёма. Сумма kcal приёмов дня ОБЯЗАТЕЛЬНО в пределах цели дня. Калории и БЖУ должны сходиться (белок и углеводы по 4 ккал/г, жиры по 9). Включи только те дни и приёмы, которые просят.''';

  // ───────── составление ─────────

  Future<RationResult> generate({
    List<DateTime>? days,
    required String reason,
    String? userNote,
  }) async {
    if (ask == null) {
      return const RationResult(ok: false, message: 'нет связи с ИИ');
    }
    if (_busy) {
      return const RationResult(ok: false, message: 'план уже составляется');
    }
    final plan = await profiles.getDietPlan();
    if (plan == null) {
      return const RationResult(ok: false, message: 'нет нормы калорий');
    }
    _busy = true;
    working.value = true;
    try {
      final now = _clock();
      await settings.set(SettingKeys.rationLastAttempt, now.toIso8601String());
      final wanted = <DateTime>{
        for (final d
            in (days ??
                [
                  for (var i = 0; i < horizonDays; i++)
                    dayOf(now).add(Duration(days: i)),
                ]))
          dayOf(d),
      }.where((d) => !d.isBefore(dayOf(now))).toList()..sort();
      if (wanted.isEmpty) {
        return const RationResult(ok: false, message: 'нет дней для плана');
      }
      final exp = await expectations(
        wanted.take(maxDays).toList(),
        plan.kcal,
        plan.toleranceKcal,
      );
      final active = exp
          .where((e) => !(e.optional && e.expectedSlots.isEmpty))
          .toList();
      if (active.isEmpty) {
        return const RationResult(
          ok: false,
          message: 'на эти дни план уже закрыт',
        );
      }
      final facts = await _facts(active, reason, userNote);

      RationValidation? v = await _attempt(facts, active);
      if (v == null || v.big) {
        final fix = v == null
            ? 'Прошлый ответ был не JSON нужного вида. Ответь строго JSON.'
            : 'Прошлый ответ не подошёл: ${v.problems.join('; ')}. Исправь суммы калорий и недостающие приёмы.';
        final v2 = await _attempt('$facts\n$fix', active);
        if (v2 != null) v = v2;
      }
      if (v == null || v.days.isEmpty) {
        return const RationResult(
          ok: false,
          message: 'Фитти не смог составить план, попробуем позже',
        );
      }
      final today = dayOf(now);
      for (final e in v.days.entries) {
        await repo.replaceDay(
          e.key,
          e.value,
          now: now,
          clearPlanned: e.key != today,
        );
      }
      await _saveMarks(v);
      _bump();
      try {
        await onChanged?.call();
      } catch (_) {}
      return RationResult(
        ok: true,
        days: v.days.keys.toList()..sort(),
        marked: v.diffs.keys.toList()..sort(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('ration error: $e');
      return RationResult(ok: false, message: 'не получилось связаться с ИИ');
    } finally {
      _busy = false;
      working.value = false;
    }
  }

  Future<RationValidation?> _attempt(
    String facts,
    List<DayExpectation> exp,
  ) async {
    try {
      final raw = await ask!(_system, facts);
      return RationValidator.validate(RationValidator.decode(raw), exp);
    } catch (e) {
      if (e is FormatException) return null;
      rethrow;
    }
  }

  Future<void> _saveMarks(RationValidation v) async {
    final cur = await marks();
    for (final d in v.days.keys) {
      cur.remove(RationValidator.ymd(d));
    }
    v.diffs.forEach((d, diff) => cur[RationValidator.ymd(d)] = diff);
    await settings.set(SettingKeys.rationMarks, jsonEncode(cur));
  }

  /// Дни с суммой, не сошедшейся с нормой: «дата → разница ккал».
  Future<Map<String, int>> marks() async {
    try {
      final s = await settings.get(SettingKeys.rationMarks);
      if (s == null) return {};
      return (jsonDecode(s) as Map).map(
        (k, v) => MapEntry('$k', (v as num).toInt()),
      );
    } catch (_) {
      return {};
    }
  }

  // ───────── блок контекста [РАЦИОН] ─────────

  Future<String> block() async {
    final now = _clock();
    final today = dayOf(now);
    final plan = await profiles.getDietPlan();
    final items = await repo.between(today, today.add(const Duration(days: 4)));
    final miss = await missing();
    final b = StringBuffer('[РАЦИОН]');
    if (items.isEmpty) {
      b.writeln(' Плана питания пока нет. Составь его действием plan_meals.');
    } else {
      b.writeln(miss.isEmpty ? '' : ' (черновик)');
    }
    if (miss.isNotEmpty) {
      b.writeln(
        'Не хватает данных: ${miss.join(', ')}. Спроси коротко, по одному вопросу за раз.',
      );
    }
    final mk = await marks();
    DateTime? cur;
    for (final i in items) {
      if (cur != i.date) {
        cur = i.date;
        final k = RationValidator.ymd(i.date);
        final dayKcal = items
            .where((x) => x.date == i.date)
            .fold<int>(0, (s, x) => s + x.kcal);
        final rel = i.date == today
            ? 'сегодня'
            : (i.date == today.add(const Duration(days: 1)) ? 'завтра' : k);
        b.writeln(
          '$rel ($k), план ~$dayKcal ккал'
          '${mk.containsKey(k) ? ', сумма не сошлась с нормой на ${mk[k]} ккал' : ''}:',
        );
      }
      b.writeln(
        '#${i.id} ${i.time} ${MealSlot.ru(i.meal)}: ${i.title} ${i.kcal} ккал '
        '[${PlanStatus.ru(i.status)}]',
      );
    }
    if (plan != null) {
      final todayDiary = await diary.day(now);
      if (todayDiary.isNotEmpty) {
        final eaten = todayDiary.fold<int>(0, (s, e) => s + (e.kcal ?? 0));
        final dev = eaten - plan.kcal;
        if (dev.abs() > plan.toleranceKcal * 3) {
          b.writeln(
            'Отклонение сегодня: съедено ~$eaten при норме ${plan.kcal} '
            '(${dev > 0 ? '+' : ''}$dev). Реши, нужно ли поправить следующие приёмы.',
          );
        }
      }
    }
    final dates = await repo.datesFrom(now);
    if (needsExtension(dates, now) && items.isNotEmpty) {
      b.writeln('Будущих дней в плане меньше двух: можно продлить рацион.');
    }
    return b.toString().trimRight();
  }
}

class MealKind2 {
  static String ru(String meal) => switch (meal) {
    'breakfast' => 'завтрак',
    'lunch' => 'обед',
    'dinner' => 'ужин',
    _ => 'перекус',
  };
}
