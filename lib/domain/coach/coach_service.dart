import 'package:flutter/foundation.dart';
import 'package:weightloss/data/exercise_catalog.dart';
import 'package:weightloss/domain/coach/coach_models.dart';
import 'package:weightloss/domain/coach/offline_coach.dart';
import 'package:weightloss/domain/coach/offline_workout_builder.dart';
import 'package:weightloss/domain/coach/plan_validator.dart';
import 'package:weightloss/domain/coach/workout_repository.dart';
import 'package:weightloss/domain/diary/diary_service.dart';
import 'package:weightloss/domain/entities/part2_entities.dart';
import 'package:weightloss/domain/repositories/repositories.dart';
import 'package:weightloss/models/workout_session.dart';

/// Тренер: собирает ФАКТЫ для модели (блок [ДАННЫЕ ДЛЯ ТРЕНЕРА]), проверяет
/// технически и сохраняет планы Фитти и результаты. Решает Фитти, не код.
/// Запасной офлайн-тренер работает только без сети.
class CoachService {
  CoachService({
    required this.profiles,
    required this.diary,
    required this.memory,
    required this.workouts,
    this.onChanged,
    this.quietRange,
    this.onlineProbe,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final ProfileRepository profiles;
  final DiaryService diary;
  final MemoryRepository memory;
  final WorkoutRepository workouts;

  /// Что-то изменилось (план или результат): пересоздать напоминания.
  final Future<void> Function()? onChanged;
  final DateTime Function() _clock;

  /// Тихие часы (минуты от полуночи): from, to.
  final Future<(int, int)?> Function()? quietRange;

  /// Проверка, доступен ли ИИ, когда ещё не было ни одного ответа.
  final Future<bool> Function()? onlineProbe;

  /// Последний известный статус ИИ (ставит чат): true — отвечает,
  /// false — нет сети или ключа, null — пока неизвестно.
  bool? aiOnline;

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

  /// Запасное решение офлайн-тренера (используется ТОЛЬКО без сети).
  Future<CoachDecision?> _offlineDecision() async {
    final i = await buildInput();
    return i == null ? null : OfflineCoach.decide(i);
  }

  static String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static String _ymd(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

  String _whenRu(DateTime when, DateTime now) {
    final d = DateTime(
      when.year,
      when.month,
      when.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;
    final day = switch (d) {
      0 => 'сегодня',
      1 => 'завтра',
      _ => 'послезавтра',
    };
    return '$day в ${_hm(when)}';
  }

  static const _memPrefixes = ['health.', 'fitness.', 'feeling.'];

  /// Блок [ДАННЫЕ ДЛЯ ТРЕНЕРА]: ТОЛЬКО факты, без решений. Нужна ли
  /// тренировка, сложность, время и состав решает Фитти.
  Future<String> block() async {
    final now = _clock();
    final b = StringBuffer('[ДАННЫЕ ДЛЯ ТРЕНЕРА] (только факты)\n');
    final i = await buildInput();
    if (i == null) {
      b.writeln('Данных профиля нет.');
      return b.toString().trimRight();
    }
    b.writeln('Сейчас: ${_ymd(now)} ${_hm(now)}.');
    b.writeln(
      'Возраст: ${i.age}, вес: ${i.weightKg.toStringAsFixed(1)} кг, '
      'рост: ${i.heightCm.round()} см.',
    );
    b.writeln(
      'Время на тренировки: ${i.trainingMinutes} мин, '
      'удобное время: ${switch (i.trainingSlot) {
        'morning' => 'утро',
        'day' => 'день',
        _ => 'вечер',
      }}.',
    );
    if (i.entriesToday > 0) {
      b.writeln(
        'Съедено сегодня: ~${i.eatenToday} ккал из плана ${i.planKcal} '
        '(записей: ${i.entriesToday}).',
      );
    } else {
      b.writeln('Сегодня еды в дневнике ещё нет (план ${i.planKcal} ккал).');
    }
    if (i.pastDays.isNotEmpty) {
      final eaten = i.pastDays.fold<int>(0, (s, d) => s + d.kcal);
      b.writeln(
        'За прошлые дни недели (${i.pastDays.length} дн. с записями): '
        'съедено ~$eaten ккал против плана ${i.planKcal * i.pastDays.length}.',
      );
    }
    // дни без тренировок
    final done = i.history.where((r) => r.status != 'skipped').toList();
    if (done.isEmpty) {
      b.writeln('Тренировок в приложении ещё не было.');
    } else {
      final d0 = DateTime(now.year, now.month, now.day);
      final last = DateTime(
        done.first.date.year,
        done.first.date.month,
        done.first.date.day,
      );
      b.writeln('Дней без тренировок: ${d0.difference(last).inDays}.');
    }
    if (i.history.isNotEmpty) {
      b.writeln('Последние тренировки (новые первыми):');
      for (final r in i.history.take(5)) {
        final st = switch (r.status) {
          'completed' => 'выполнена',
          'aborted' => 'прервана',
          _ => 'пропущена',
        };
        b.writeln(
          '- ${_ymd(r.date)} «${r.title}»: $st, упражнений выполнено '
          '${r.doneExercises}, пропущено ${r.skippedExercises}, паузы ${r.pauses}, '
          '${(r.durationSec / 60).round()} мин'
          '${r.difficulty != null ? ', сложность ${r.difficulty}' : ''}.',
        );
      }
    }
    final planned = await workouts.nextPlanned(now);
    if (planned != null && planned.scheduledAt != null) {
      b.writeln(
        'Уже запланировано: «${planned.workout.title}» '
        '${_whenRu(planned.scheduledAt!, now)}, сложность ${planned.difficulty}'
        '${planned.source == 'offline' ? ' (офлайн-план)' : ''}.',
      );
    } else {
      b.writeln('Запланированных тренировок нет.');
    }
    // память
    final mem = <String>[];
    var hasBase = false;
    for (final f in await memory.active()) {
      if (!_memPrefixes.any(f.key.startsWith)) continue;
      if (f.key == 'fitness.level' ||
          f.key == 'fitness.limits' ||
          f.key.startsWith('health.')) {
        hasBase = true;
      }
      mem.add('- ${f.key}: ${f.fact} (${_ymd(f.updatedAt)})');
    }
    if (mem.isEmpty) {
      b.writeln('Память о здоровье и опыте (health.*, fitness.*): пусто.');
    } else {
      b.writeln('Память (дата обновления в скобках):');
      for (final m in mem) {
        b.writeln(m);
      }
    }
    if (!hasBase) {
      b.writeln(
        'Про опыт, травмы и здоровье данных нет (fitness.level, fitness.limits, health.*).',
      );
    }
    b.writeln(
      'Каталог упражнений для plan_workout '
      '(id|название|мышцы|этап|сложность|ударное):',
    );
    for (final t in ExerciseCatalog.all) {
      b.writeln(
        '${t.id}|${t.name}|${t.muscle}|${t.stage}|${t.difficulty}|'
        '${t.highImpact ? 'ударное' : 'без удара'}',
      );
    }
    return b.toString().trimRight();
  }

  /// Сохраняет план от Фитти (действие plan_workout). Код проверяет только
  /// технически (PlanValidator). Возвращает строку-подвал или null.
  Future<String?> savePlanFromModel({
    required String? title,
    required String? intro,
    required List<Map<String, dynamic>> picks,
    Object? difficulty,
    Object? scheduledFor,
  }) async {
    final now = _clock();
    var qf = 22 * 60 + 30, qt = 7 * 60 + 30;
    try {
      final q = await quietRange?.call();
      if (q != null) (qf, qt) = q;
    } catch (_) {}
    final v = PlanValidator.validate(
      picks: picks,
      now: now,
      title: title,
      intro: intro,
      difficulty: difficulty,
      scheduledFor: scheduledFor,
      quietFromMin: qf,
      quietToMin: qt,
    );
    if (v == null) {
      return 'Не получилось подготовить тренировку: в плане не нашлось '
          'упражнений из каталога.';
    }
    await workouts.savePlan(
      workout: v.workout,
      scheduledAt: v.scheduledAt,
      difficulty: v.difficulty,
      source: 'coach',
      now: now,
    );
    await _changed();
    final notes = <String>[
      if (v.timeMoved) 'время перенесено на ближайшее удобное',
      if (v.trimmed) 'план укорочен до 60 минут',
    ];
    return 'Тренировка готова: ${_whenRu(v.scheduledAt, now)}, '
        '~${(PlanValidator.total(v.workout.exercises) / 60).ceil()} мин, '
        'сложность ${v.difficulty}. Она во вкладке «Тренировка».'
        '${notes.isEmpty ? '' : ' (${notes.join(', ')})'}';
  }

  Future<void> _changed() async {
    revision.value++;
    try {
      await onChanged?.call();
    } catch (_) {}
  }

  /// Фоновая работа при старте и возвращении в приложение: закрыть
  /// пропущенные планы. Если ИИ недоступен (нет сети или ключа), а пора
  /// тренироваться и плана нет, старый локальный тренер составляет
  /// «офлайн-план». При доступном ИИ код планов не создаёт.
  Future<void> maintain() async {
    try {
      final now = _clock();
      final closed = await workouts.closeOverdue(now);
      var created = false;
      if (!await _aiOnline()) {
        final d = await _offlineDecision();
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
              final w = OfflineWorkoutBuilder.build(
                decision: d,
                picks: const [],
                intro:
                    'Офлайн-план: связи с ИИ нет, поэтому это простой '
                    'запасной вариант на ~${d.minutes} мин. Я рядом!',
                seed: now.day,
              );
              await workouts.savePlan(
                workout: w,
                scheduledAt: d.when!,
                difficulty: d.difficulty,
                source: 'offline',
                now: now,
              );
              created = true;
            }
          }
        }
      }
      if (closed > 0 || created) await _changed();
    } catch (_) {}
  }

  Future<bool> _aiOnline() async {
    if (aiOnline != null) return aiOnline!;
    try {
      return await onlineProbe?.call() ?? false;
    } catch (_) {
      return false;
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
