import 'package:flutter/foundation.dart';
import 'package:weightloss/data/exercise_catalog.dart';
import 'package:weightloss/domain/coach/coach_models.dart';
import 'package:weightloss/domain/coach/coach_rules.dart';
import 'package:weightloss/domain/coach/workout_builder.dart';
import 'package:weightloss/domain/coach/workout_repository.dart';
import 'package:weightloss/domain/diary/diary_service.dart';
import 'package:weightloss/domain/entities/part2_entities.dart';
import 'package:weightloss/domain/repositories/repositories.dart';
import 'package:weightloss/models/workout_session.dart';

/// Тренер: собирает данные, зовёт правила (CoachRules), формирует блок
/// [ТРЕНЕР] для модели и сохраняет планы и результаты.
class CoachService {
  CoachService({
    required this.profiles,
    required this.diary,
    required this.memory,
    required this.workouts,
    this.onChanged,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final ProfileRepository profiles;
  final DiaryService diary;
  final MemoryRepository memory;
  final WorkoutRepository workouts;

  /// Что-то изменилось (план или результат): пересоздать напоминания.
  final Future<void> Function()? onChanged;
  final DateTime Function() _clock;

  /// Счётчик изменений планов: на него подписан экран «Тренировка».
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static final _sickRe = RegExp(
    r'болею|заболел|болен|больна|температур|простуд|грипп|орви|тошнит|плохо себя|отравил|не могу вставать',
  );
  static final _tiredRe = RegExp(
    r'устал|не выспал|недосып|слабост|нет сил|вялый|вялая|разбит|плохо спал',
  );
  static final _jointRe = RegExp(
    r'колен|спин|сустав|грыж|поясниц|протрузи|лодыжк|плеч',
  );

  static Wellbeing parseWellbeing(String? fact) {
    final f = (fact ?? '').toLowerCase();
    if (_sickRe.hasMatch(f)) return Wellbeing.sick;
    if (_tiredRe.hasMatch(f)) return Wellbeing.tired;
    return Wellbeing.normal;
  }

  Future<CoachInput?> buildInput() async {
    final now = _clock();
    final p = await profiles.getProfile();
    final plan = await profiles.getDietPlan();
    if (p == null || plan == null) return null;
    final today = await diary.day(now);
    final eaten = today.fold<int>(0, (s, e) => s + (e.kcal ?? 0));
    final past = <DayKcal>[];
    for (var i = 1; i <= 7; i++) {
      final d = DiaryService.dayStart(now).subtract(Duration(days: i));
      final list = await diary.day(d);
      if (list.isEmpty) continue;
      past.add(DayKcal(d, list.fold<int>(0, (s, e) => s + (e.kcal ?? 0))));
    }
    final hist = await workouts.recentResults(limit: 20);
    final ds = DiaryService.dayStart(now);
    final doneToday = hist.any(
      (r) => r.status != 'skipped' && !r.date.isBefore(ds),
    );

    var wellbeing = Wellbeing.normal;
    var joint = false;
    final facts = await memory.active();
    for (final f in facts) {
      if (f.category != 'health' && !f.key.startsWith('health.')) continue;
      if (f.key.contains('wellbeing') ||
          f.key.contains('feeling') ||
          f.key.contains('state')) {
        // самочувствие актуально ~3 суток
        if (now.difference(f.updatedAt).inHours <= 72) {
          final w = parseWellbeing(f.fact);
          if (w.index > wellbeing.index) wellbeing = w;
        }
      } else if (_jointRe.hasMatch(f.fact.toLowerCase())) {
        joint = true;
      }
    }

    return CoachInput(
      now: now,
      age: p.ageAt(now),
      weightKg: p.weightKg,
      heightCm: p.heightCm,
      planKcal: plan.kcal,
      toleranceKcal: plan.toleranceKcal,
      eatenToday: eaten,
      entriesToday: today.length,
      pastDays: past,
      trainingMinutes: p.trainingMinutes,
      trainingSlot: p.trainingSlot,
      history: hist,
      workoutDoneToday: doneToday,
      wellbeing: wellbeing,
      jointIssue: joint,
    );
  }

  Future<CoachDecision?> decide() async {
    final i = await buildInput();
    return i == null ? null : CoachRules.decide(i);
  }

  static String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _whenRu(DateTime when, DateTime now) {
    final d = DateTime(
      when.year,
      when.month,
      when.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;
    return '${d == 0 ? 'сегодня' : 'завтра'} в ${_hm(when)}';
  }

  /// Блок [ТРЕНЕР] для системного промта.
  Future<String> block() async {
    final now = _clock();
    final d = await decide();
    final b = StringBuffer(
      '[ТРЕНЕР] (решение принял код, ты его не меняешь, а только объясняешь по-человечески)\n',
    );
    if (d == null) {
      b.writeln('Данных профиля нет: про тренировки не говори.');
      return b.toString().trimRight();
    }
    if (!d.needed) {
      b.writeln(
        'Тренировка сегодня не нужна: ${d.restReason}. '
        'Не назначай тренировку, поддержи и объясни, почему отдых тоже часть пути.',
      );
    } else {
      b.writeln(
        'Тренировка нужна: ${_whenRu(d.when!, now)}, '
        '~${d.minutes} мин, сложность ${d.difficulty} из 3'
        '${d.maxDifficulty < 3 ? ' (потолок для этого человека: ${d.maxDifficulty})' : ''}.',
      );
      if (d.reasons.isNotEmpty) b.writeln('Причины: ${d.reasons.join('; ')}.');
      if (d.escalated) {
        b.writeln(
          'Сложность ПОВЫШЕНА из-за съеденного сверх плана. Скажи об этом '
          'по-доброму, без стыда: «Сегодня съедено больше плана, я сделаю '
          'тренировку посложнее вечером».',
        );
      }
      if (!d.allowHighImpact) {
        b.writeln(
          'Ударные и прыжковые упражнения запрещены (возраст, вес или суставы).',
        );
      }
    }
    if (d.wellbeing != Wellbeing.normal) {
      b.writeln(
        'Самочувствие по памяти: '
        '${d.wellbeing == Wellbeing.sick ? 'плохое' : 'уставший'}: '
        'не усложняй и не дави.',
      );
    }
    final planned = await workouts.nextPlanned(now);
    final hasForDay =
        planned != null &&
        planned.scheduledAt != null &&
        d.when != null &&
        DiaryService.dayStart(planned.scheduledAt!) ==
            DiaryService.dayStart(d.when!);
    if (d.needed) {
      if (hasForDay) {
        b.writeln(
          'План на этот день уже есть («${planned.workout.title}», '
          '${planned.source == 'coach' ? 'твой' : 'составлен кодом'}). '
          'Новый plan_workout отправляй только если человек просит изменить.',
        );
      } else {
        b.writeln(
          'Плана на этот день ещё нет. Когда это уместно по разговору, '
          'отправь действие plan_workout (формат в инструкции) и в ответе '
          'коротко расскажи, что подготовил.',
        );
      }
      b.writeln(
        'Каталог для plan_workout (id|название|мышцы|этап|сложность). '
        'Выбирай ТОЛЬКО эти id, основные упражнения не тяжелее ${d.difficulty}:',
      );
      for (final t in ExerciseCatalog.all) {
        if (t.stage == 'main' &&
            (t.difficulty > d.difficulty ||
                (!d.allowHighImpact && t.highImpact))) {
          continue;
        }
        b.writeln('${t.id}|${t.name}|${t.muscle}|${t.stage}|${t.difficulty}');
      }
    }
    return b.toString().trimRight();
  }

  /// Сохраняет план от модели (действие plan_workout). Время и сложность
  /// ставит код. Возвращает строку-подвал или null.
  Future<String?> savePlanFromModel({
    required String? title,
    required String? intro,
    required List<Map<String, dynamic>> picks,
  }) async {
    final d = await decide();
    if (d == null || !d.needed || d.when == null) return null;
    final now = _clock();
    final w = WorkoutBuilder.build(
      decision: d,
      picks: picks,
      title: title,
      intro: intro,
      seed: now.day,
    );
    await workouts.savePlan(
      workout: w,
      scheduledAt: d.when!,
      difficulty: d.difficulty,
      source: 'coach',
      now: now,
    );
    await _changed();
    return 'Тренировка готова: ${_whenRu(d.when!, now)}, ~${(w.totalSec / 60).ceil()} мин, '
        'сложность ${d.difficulty}. Она во вкладке «Тренировка».';
  }

  Future<void> _changed() async {
    revision.value++;
    try {
      await onChanged?.call();
    } catch (_) {}
  }

  /// Фоновая работа при старте и возвращении в приложение: закрыть
  /// пропущенные планы; если пора тренироваться, а плана нет, код
  /// составляет его сам (запасной вариант без модели).
  Future<void> maintain() async {
    try {
      final now = _clock();
      final closed = await workouts.closeOverdue(now);
      final d = await decide();
      var created = false;
      if (d != null && d.needed && d.when != null) {
        final soon = d.when!.difference(now) <= const Duration(minutes: 60);
        if (soon) {
          final planned = await workouts.nextPlanned(now);
          final has =
              planned != null &&
              planned.scheduledAt != null &&
              DiaryService.dayStart(planned.scheduledAt!) ==
                  DiaryService.dayStart(d.when!);
          if (!has) {
            final w = WorkoutBuilder.build(
              decision: d,
              picks: const [],
              intro: localIntro(d),
              seed: now.day,
            );
            await workouts.savePlan(
              workout: w,
              scheduledAt: d.when!,
              difficulty: d.difficulty,
              source: 'local',
              now: now,
            );
            created = true;
          }
        }
      }
      if (closed > 0 || created) await _changed();
    } catch (_) {}
  }

  static String localIntro(CoachDecision d) {
    final b = StringBuffer('Небольшая тренировка на ~${d.minutes} мин. ');
    if (d.escalated) {
      b.write('Сегодня съедено больше плана, поэтому нагрузка чуть выше. ');
    } else if (d.difficulty == 1) {
      b.write('Начнём мягко, в твоём темпе. ');
    }
    b.write('Я рядом!');
    return b.toString();
  }

  /// После записи еды: если съедено сверх плана и решение стало
  /// сложнее, пересобираем сегодняшний план. Возвращает строку-подвал.
  Future<String?> afterFood() async {
    try {
      final now = _clock();
      final d = await decide();
      if (d == null || !d.needed || !d.escalated || d.when == null) return null;
      final planned = await workouts.nextPlanned(now);
      final sameDay =
          planned != null &&
          planned.scheduledAt != null &&
          DiaryService.dayStart(planned.scheduledAt!) ==
              DiaryService.dayStart(d.when!);
      if (sameDay && planned.difficulty >= d.difficulty) return null;
      final picks = sameDay
          ? [
              for (final e in planned.workout.exercises) {'id': e.id},
            ]
          : <Map<String, dynamic>>[];
      final w = WorkoutBuilder.build(
        decision: d,
        picks: picks,
        title: sameDay ? planned.workout.title : null,
        intro: sameDay ? planned.workout.intro : localIntro(d),
        seed: now.day,
      );
      await workouts.savePlan(
        workout: w,
        scheduledAt: d.when!,
        difficulty: d.difficulty,
        source: sameDay ? planned.source : 'local',
        now: now,
      );
      await _changed();
      return 'Съедено больше плана, поэтому тренировка ${_whenRu(d.when!, now)} '
          'будет посложнее (уровень ${d.difficulty} из 3).';
    } catch (_) {
      return null;
    }
  }

  Future<void> saveResult(int? workoutId, WorkoutSession s) async {
    await workouts.saveResult(workoutId: workoutId, session: s, now: _clock());
    await _changed();
  }
}

/// Реальный источник блока [ТРЕНИРОВКИ] (таблицы workouts / workout_results).
class DbWorkoutHistorySource implements WorkoutHistorySource {
  DbWorkoutHistorySource(this._repo);
  final WorkoutRepository _repo;

  @override
  Future<List<WorkoutBrief>> recent(DateTime now, {int limit = 5}) async {
    final list = await _repo.recentResults(limit: limit);
    return [
      for (final r in list)
        WorkoutBrief(
          date: r.date,
          title: r.title,
          status: switch (r.status) {
            'completed' => 'выполнена',
            'aborted' => 'прервана',
            _ => 'пропущена',
          },
          minutes: (r.durationSec / 60).round(),
          kcal: r.kcal,
          note:
              [
                if (r.note != null) r.note!,
                if (r.difficulty != null) 'сложность ${r.difficulty}',
              ].join(', ').isEmpty
              ? null
              : [
                  if (r.note != null) r.note!,
                  if (r.difficulty != null) 'сложность ${r.difficulty}',
                ].join(', '),
        ),
    ];
  }
}
