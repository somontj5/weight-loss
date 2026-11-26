import 'package:weightloss/domain/diary/diary_math.dart';
import 'package:weightloss/domain/diary/food_action.dart';
import 'package:weightloss/domain/diary/diary_service.dart';
import 'package:weightloss/domain/repositories/repositories.dart';
import 'package:weightloss/domain/settings/settings_repository.dart';

/// Короткий блок [ДНЕВНИК-КОД] для системного промта и строка-подвал под
/// ответом Фитти. Модель эти числа не считает, а только пересказывает.
class DiaryCalc {
  DiaryCalc({
    required this.diary,
    required this.source,
    required this.profiles,
    required this.settings,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final DiaryService diary;
  final DiarySource source;
  final ProfileRepository profiles;
  final SettingsRepository settings;
  final DateTime Function() _clock;

  static const maxClarify = 2;

  Future<int> clarifyStreak() async =>
      int.tryParse(await settings.get(SettingKeys.clarifyStreak) ?? '') ?? 0;

  Future<void> setClarifyStreak(int n) =>
      settings.set(SettingKeys.clarifyStreak, '$n');

  Future<String> codeBlock() async {
    final now = _clock();
    final plan = await profiles.getDietPlan();
    final today = await source.today(now);
    final streak = await clarifyStreak();
    final activity = await settings.get(SettingKeys.activityLevel);

    final b = StringBuffer('[ДНЕВНИК-КОД] (числа посчитал код, не пересчитывай)\n');
    if (today.items.isEmpty) {
      b.writeln('Записей сегодня: 0. Остаток калорий не называй.');
    } else if (plan != null) {
      final left = DiaryMath.remaining(plan.kcal, today.kcal);
      b.writeln('Записей сегодня: ${today.items.length}. Съедено ~${today.kcal} '
          'из ${plan.kcal} ккал, '
          '${left >= 0 ? 'осталось ~${DiaryMath.round10(left)}' : 'выше нормы на ~${DiaryMath.round10(-left)}'}'
          ' (допуск ±${plan.toleranceKcal}).');
    } else {
      b.writeln('Записей сегодня: ${today.items.length}, съедено ~${today.kcal} ккал. Нормы нет.');
    }

    if (plan != null) {
      final past = await source.lastDays(now, 7);
      final dev = DiaryMath.deviations(past, plan.kcal, plan.toleranceKcal);
      if (dev.isNotEmpty) {
        final inTol = dev.where((d) => d.withinTolerance).length;
        b.writeln('Прошлые дни к норме: '
            '${dev.map((d) => '${d.diff >= 0 ? '+' : ''}${d.diff}').join(', ')} ккал; '
            'в допуске $inTol из ${dev.length}.');
      }
      final logged = <String>{
        for (final e in await diary.day(now)) e.meal,
      };
      final left = DiaryMath.remaining(plan.kcal, today.kcal);
      final next = DiaryMath.nextMeal(now: now, logged: logged, remaining: left);
      b.writeln(next.kcal == null
          ? 'Ориентир на ${MealKind.ru(next.meal)}: норма дня уже выбрана, '
              'только лёгкое (овощи, белок).'
          : 'Ориентир на ${MealKind.ru(next.meal)}: ~${next.kcal} ккал.');
    }

    b.writeln('Активность: ${activity ?? 'не задана'}. '
        'Уточняющих вопросов подряд: $streak из $maxClarify.'
        '${streak >= maxClarify ? ' Больше не спрашивай: оцени сам и записывай.' : ''}');
    return b.toString().trimRight();
  }

  /// «Записал: обед, примерно 520 ккал. Осталось ~X ккал» — числа считает код.
  Future<String?> footer(FoodLogOutcome o) async {
    if (!o.ok || o.entry == null) return null;
    final e = o.entry!;
    final now = _clock();
    final plan = await profiles.getDietPlan();
    final meal = MealKind.ru(e.meal);
    final kcal = e.kcal;
    final head = switch (o.kind) {
      FoodOutcomeKind.deleted => 'Убрал запись: $meal'
          '${kcal != null ? ', примерно $kcal ккал' : ''}.',
      _ => 'Записал: $meal${kcal != null ? ', примерно $kcal ккал' : ''}.',
    };

    final sameDay = DiaryService.dayStart(e.eatenAt) == DiaryService.dayStart(now);
    if (plan == null || !sameDay) return head;
    final eaten = (await diary.day(now)).fold<int>(0, (s, x) => s + (x.kcal ?? 0));
    final left = DiaryMath.remaining(plan.kcal, eaten);
    final tail = left >= 0
        ? 'Осталось ~${DiaryMath.round10(left)} ккал'
        : 'Выше нормы на ~${DiaryMath.round10(-left)} ккал';
    return '$head $tail';
  }
}
