import 'package:flutter_test/flutter_test.dart';
import 'package:weightloss/data/exercise_catalog.dart';
import 'package:weightloss/data/repositories/diary_repository_impl.dart';
import 'package:weightloss/data/repositories/workout_repository_impl.dart';
import 'package:weightloss/domain/actions/action_dispatcher.dart';
import 'package:weightloss/domain/actions/plan_workout_handler.dart';
import 'package:weightloss/domain/coach/coach_models.dart';
import 'package:weightloss/domain/coach/coach_rules.dart';
import 'package:weightloss/domain/coach/coach_service.dart';
import 'package:weightloss/domain/coach/workout_builder.dart';
import 'package:weightloss/domain/context/context_assembler.dart';
import 'package:weightloss/domain/diary/diary_service.dart';
import 'package:weightloss/domain/diary/food_action.dart';
import 'package:weightloss/domain/entities/memory_fact.dart';
import 'package:weightloss/domain/memory/memory_service.dart';
import 'package:weightloss/models/workout_session.dart';
import 'package:weightloss/services/ai/reply_parser.dart';

import 'helpers.dart';

CoachInput _in({
  DateTime? now,
  int age = 30,
  double weight = 70,
  double height = 170,
  int plan = 1800,
  int tol = 100,
  int eaten = 0,
  int entries = 0,
  List<DayKcal> past = const [],
  List<WorkoutRecord> hist = const [],
  Wellbeing wb = Wellbeing.normal,
  bool joint = false,
  bool doneToday = false,
  String slot = 'evening',
  int minutes = 20,
}) =>
    CoachInput(
      now: now ?? DateTime(2026, 3, 10, 14, 0),
      age: age,
      weightKg: weight,
      heightCm: height,
      planKcal: plan,
      toleranceKcal: tol,
      eatenToday: eaten,
      entriesToday: entries,
      pastDays: past,
      history: hist,
      wellbeing: wb,
      jointIssue: joint,
      workoutDoneToday: doneToday,
      trainingSlot: slot,
      trainingMinutes: minutes,
    );

WorkoutRecord _rec(int daysAgo,
        {String status = 'completed', int skipped = 0, int? diff}) =>
    WorkoutRecord(
      date: DateTime(2026, 3, 10 - daysAgo, 19, 0),
      status: status,
      title: 'T',
      skippedExercises: skipped,
      difficulty: diff,
    );

/// Тренировки через день: 2, 4, 6… дней назад (чтобы не упереться в
/// правило «неделя заполнена»).
List<WorkoutRecord> _hist(int n) =>
    [for (var i = 0; i < n; i++) _rec(2 + i * 2, diff: 2)];

const _json = '''
{"exercises":[
 {"id":"new_one","name":"Новое","description":"d","tips":"t","muscle":"Ноги","met":4.0,"stage":"main","difficulty":3,"highImpact":true,"kcalPerMin":9,"muscles":["a","b"]},
 {"id":"squat","name":"Приседания PRO","description":"d","tips":"t","muscle":"Ноги","met":6.0},
 {"id":"no_name","description":"d","tips":"t","muscle":"x","met":4},
 {"id":"bad_met","name":"x","description":"d","tips":"t","muscle":"x","met":"много"},
 {"id":"BAD ID!","name":"x","description":"d","tips":"t","muscle":"x","met":4},
 {"id":"no_tips","name":"x","description":"d","muscle":"x","met":4},
 "строка вместо объекта",
 42,
 {"id":"weird","name":"W","description":"d","tips":"t","muscle":"m","met":3,"stage":"бред","difficulty":9,"kcalPerMin":-5}
]}''';

void main() {
  tearDown(ExerciseCatalog.reset);

  group('каталог упражнений', () {
    test('битые записи пропускаются, хорошие работают', () {
      final r = ExerciseCatalog.build(kExerciseCatalog, _json);
      expect(r.skipped, 6);
      final ids = r.items.map((e) => e.id).toList();
      expect(ids, containsAll(['new_one', 'weird', 'squat', 'plank']));
      expect(ids, isNot(contains('no_name')));
      expect(ids, isNot(contains('bad_met')));
      expect(ids, isNot(contains('BAD ID!')));
      expect(ids, isNot(contains('no_tips')));
    });

    test('одинаковый id заменяет встроенное, без дубликатов', () {
      final r = ExerciseCatalog.build(kExerciseCatalog, _json);
      expect(r.replaced, 1);
      expect(r.items.where((e) => e.id == 'squat').length, 1);
      expect(r.items.firstWhere((e) => e.id == 'squat').name, 'Приседания PRO');
      expect(r.items.firstWhere((e) => e.id == 'squat').met, 6.0);
    });

    test('необязательные поля и значения по умолчанию', () {
      final r = ExerciseCatalog.build(kExerciseCatalog, _json);
      final n = r.items.firstWhere((e) => e.id == 'new_one');
      expect(n.difficulty, 3);
      expect(n.highImpact, isTrue);
      expect(n.kcalPerMin, 9);
      expect(n.muscles, ['a', 'b']);
      final w = r.items.firstWhere((e) => e.id == 'weird');
      expect(w.stage, 'main'); // мусор в stage → main
      expect(w.difficulty, 2); // 9 вне 1..3 → 2
      expect(w.kcalPerMin, isNull);
      expect(w.highImpact, isFalse);
    });

    test('весь файл — мусор или пустой: остаётся встроенное, без падения', () {
      for (final t in ['', '   ', 'не json', '{"exercises": 5}', 'null', '[]']) {
        final r = ExerciseCatalog.build(kExerciseCatalog, t);
        expect(r.items.length, kExerciseCatalog.length, reason: t);
      }
      expect(ExerciseCatalog.build(kExerciseCatalog, '[1,2]').skipped, 2);
    });

    test('load() подключает каталог глобально, reset() возвращает', () {
      ExerciseCatalog.load(_json);
      expect(catalogById('new_one'), isNotNull);
      expect(catalogById('squat')!.name, 'Приседания PRO');
      ExerciseCatalog.reset();
      expect(catalogById('new_one'), isNull);
      expect(catalogById('squat')!.name, 'Приседания');
    });
  });

  group('решение тренера', () {
    test('обычный день: тренировка нужна, время по слоту из регистрации', () {
      final d = CoachRules.decide(_in(hist: _hist(3)));
      expect(d.needed, isTrue);
      expect(d.when, DateTime(2026, 3, 10, 19, 30));
      expect(d.minutes, 20);
      expect(d.escalated, isFalse);
    });

    test('слот прошёл: ближайшее время сегодня; поздно вечером завтра', () {
      final a = CoachRules.decide(
          _in(now: DateTime(2026, 3, 10, 20, 10), hist: _hist(3)));
      expect(a.when!.isAfter(DateTime(2026, 3, 10, 20, 10)), isTrue);
      expect(a.when!.day, 10);
      final b = CoachRules.decide(
          _in(now: DateTime(2026, 3, 10, 22, 0), hist: _hist(3)));
      expect(b.when!.day, 11);
    });

    test('съедено сверх плана сегодня: сложность растёт', () {
      final base = CoachRules.decide(_in(hist: _hist(4)));
      final over = CoachRules.decide(
          _in(hist: _hist(4), eaten: 2300, entries: 3));
      expect(over.escalated, isTrue);
      expect(over.difficulty, base.difficulty + 1);
      expect(over.minutes, greaterThan(base.minutes));
      expect(over.reasons.join(), contains('сверх нормы'));
    });

    test('в пределах допуска сложность не растёт', () {
      final d = CoachRules.decide(_in(hist: _hist(4), eaten: 1880, entries: 3));
      expect(d.escalated, isFalse);
    });

    test('сверх плана за неделю: сложность растёт', () {
      final past = [
        for (var i = 1; i <= 4; i++)
          DayKcal(DateTime(2026, 3, 10 - i), 2200),
      ];
      final d = CoachRules.decide(_in(hist: _hist(4), past: past));
      expect(d.escalated, isTrue);
      expect(d.reasons.join(), contains('за неделю'));
    });

    test('плохое самочувствие: не усложняем, при болезни отдых', () {
      final tired = CoachRules.decide(_in(
          hist: _hist(8), eaten: 2600, entries: 3, wb: Wellbeing.tired));
      expect(tired.needed, isTrue);
      expect(tired.escalated, isFalse);
      expect(tired.difficulty, 1);
      expect(tired.minutes, lessThanOrEqualTo(15));
      final sick = CoachRules.decide(
          _in(hist: _hist(8), eaten: 2600, entries: 3, wb: Wellbeing.sick));
      expect(sick.needed, isFalse);
      expect(sick.restReason, contains('самочувствие'));
    });

    test('возраст и вес ограничивают сложность и ударные упражнения', () {
      final old = CoachRules.decide(
          _in(age: 62, hist: _hist(10), eaten: 2800, entries: 3));
      expect(old.needed, isTrue);
      expect(old.maxDifficulty, 1);
      expect(old.difficulty, 1);
      expect(old.escalated, isFalse); // потолок: усложнять некуда
      expect(old.allowHighImpact, isFalse);
      final heavy = CoachRules.decide(
          _in(weight: 110, height: 170, hist: _hist(10), eaten: 2800, entries: 3));
      expect(heavy.needed, isTrue);
      expect(heavy.maxDifficulty, 1);
      expect(heavy.allowHighImpact, isFalse);
      final young = CoachRules.decide(_in(hist: _hist(10)));
      expect(young.allowHighImpact, isTrue);
      expect(CoachRules.decide(_in(joint: true, hist: _hist(10))).allowHighImpact,
          isFalse);
    });

    test('новичку сразу сложность 3 не дают', () {
      final d = CoachRules.decide(_in(eaten: 2800, entries: 3));
      expect(d.difficulty, lessThanOrEqualTo(2));
    });

    test('прервал или пропускал: следующий план легче и короче', () {
      final good = CoachRules.decide(_in(hist: _hist(6)));
      final bad = CoachRules.decide(_in(hist: [
        _rec(2, status: 'aborted', diff: 2),
        ..._hist(5).skip(1),
      ]));
      expect(good.needed && bad.needed, isTrue);
      expect(good.difficulty, 3);
      expect(bad.difficulty, lessThan(good.difficulty));
      expect(bad.minutes, lessThan(good.minutes));
      expect(bad.reasons.join(), contains('тяжело'));
    });

    test('три неудачи подряд: мягкое возвращение, без усложнения', () {
      final d = CoachRules.decide(_in(
          hist: [_rec(2, status: 'skipped'), _rec(3, status: 'aborted'), _rec(4, status: 'skipped')],
          eaten: 2600,
          entries: 3));
      expect(d.difficulty, 1);
      expect(d.escalated, isFalse);
    });

    test('отдых: уже тренировался сегодня, две подряд, неделя, тяжёлая вчера',
        () {
      expect(CoachRules.decide(_in(doneToday: true)).needed, isFalse);
      expect(
          CoachRules.decide(_in(hist: [_rec(1), _rec(2)])).restReason,
          contains('две тренировки'));
      expect(
          CoachRules.decide(
                  _in(hist: [for (var i = 0; i < 5; i++) _rec(i + 1)]))
              .needed,
          isFalse);
      final heavy = CoachRules.decide(_in(hist: [_rec(1, diff: 3)]));
      expect(heavy.needed, isFalse);
      // но при перееданиии отдых отменяется
      final over = CoachRules.decide(
          _in(hist: [_rec(1, diff: 3)], eaten: 2400, entries: 3));
      expect(over.needed, isTrue);
    });

    test('мало съедено к вечеру: не усложняем', () {
      final d = CoachRules.decide(_in(
          now: DateTime(2026, 3, 10, 18, 0),
          hist: _hist(8),
          eaten: 700,
          entries: 1,
          past: [for (var i = 1; i <= 4; i++) DayKcal(DateTime(2026, 3, 10 - i), 2400)]));
      expect(d.escalated, isFalse);
      expect(d.difficulty, lessThanOrEqualTo(2));
    });
  });

  group('сборка тренировки из выбора модели', () {
    CoachDecision dec({int diff = 2, bool impact = true, int min = 20}) =>
        CoachDecision(
            needed: true,
            difficulty: diff,
            minutes: min,
            maxDifficulty: 3,
            allowHighImpact: impact,
            when: DateTime(2026, 3, 10, 19));

    test('чужие id отбрасываются, сложность и ударные контролирует код', () {
      final w = WorkoutBuilder.build(
        decision: dec(diff: 1, impact: false),
        picks: [
          {'id': 'squat', 'durationSec': 40, 'restSec': 20},
          {'id': 'выдуманное'},
          {'id': 'burpee'}, // сложность 3 и ударное
          {'id': 'jumping_jack'}, // ударное
          {'id': 'plank'}, // сложность 2 > 1
          {'id': 'glute_bridge', 'durationSec': 9999, 'restSec': -3},
        ],
      );
      final ids = w.exercises.map((e) => e.id).toList();
      // squat (сложность 2) при уровне 1 убирается, glute_bridge (1) остаётся
      expect(ids, isNot(contains('squat')));
      expect(ids, contains('glute_bridge'));
      for (final id in ['выдуманное', 'burpee', 'jumping_jack', 'plank']) {
        expect(ids, isNot(contains(id)), reason: id);
      }
      for (final e in w.exercises) {
        expect(e.durationSec, inInclusiveRange(20, 90));
        expect(e.restSec, inInclusiveRange(0, 60));
        final t = catalogById(e.id)!;
        if (t.stage == 'main') expect(t.difficulty, lessThanOrEqualTo(1));
      }
    });

    test('есть разминка и растяжка, нет повторов подряд, длительность близка',
        () {
      final w = WorkoutBuilder.build(
        decision: dec(min: 20),
        picks: [
          {'id': 'squat'},
          {'id': 'squat'},
          {'id': 'lunge'},
        ],
      );
      expect(catalogById(w.exercises.first.id)!.stage, 'warmup');
      expect(catalogById(w.exercises.last.id)!.stage, 'cooldown');
      expect(w.exercises.last.restSec, 0);
      for (var i = 1; i < w.exercises.length; i++) {
        expect(w.exercises[i].id, isNot(w.exercises[i - 1].id));
      }
      expect(w.totalSec, inInclusiveRange(15 * 60, 25 * 60));
    });

    test('модель прислала пустой или мусорный список: план строит код', () {
      for (final picks in [
        <Map<String, dynamic>>[],
        [
          {'id': 'нет'},
          {'x': 1}
        ]
      ]) {
        final w = WorkoutBuilder.build(decision: dec(), picks: picks);
        expect(w.exercises.length, greaterThan(4));
        expect(w.totalSec, inInclusiveRange(15 * 60, 25 * 60));
      }
    });

    test('слишком длинный выбор модели подрезается под длительность', () {
      final w = WorkoutBuilder.build(
        decision: dec(min: 15),
        picks: [
          for (final t in kExerciseCatalog.where((t) => t.stage == 'main'))
            {'id': t.id, 'durationSec': 60, 'restSec': 30}
        ],
      );
      expect(w.totalSec, lessThan(15 * 60 * 1.3));
    });
  });

  group('тренер + база: результаты, контекст, диспетчер', () {
    late Env env;
    late DiaryService diary;
    late WorkoutRepositoryImpl repo;
    late CoachService coach;
    var changed = 0;

    setUp(() async {
      env = Env(DateTime(2026, 3, 10, 14, 0));
      await env.seedProfile();
      diary = DiaryService(DiaryRepositoryImpl(env.db), clock: () => env.now);
      repo = WorkoutRepositoryImpl(env.db);
      changed = 0;
      coach = CoachService(
        profiles: env.profiles,
        diary: diary,
        memory: env.memory,
        workouts: repo,
        onChanged: () async => changed++,
        clock: () => env.now,
      );
    });
    tearDown(() => env.close());

    WorkoutSession session({
      bool early = false,
      List<String> statuses = const ['completed', 'completed', 'skipped'],
      List<int> pauses = const [],
      DateTime? at,
    }) {
      final logs = [
        for (final s in statuses)
          ExerciseLog(exerciseId: 'x', name: 'X', plannedSec: 30, plannedRestSec: 10)
            ..status = s
      ];
      if (pauses.isNotEmpty) logs.first.pauses.addAll(pauses);
      return WorkoutSession(
        startedAt: at ?? env.now,
        title: 'T',
        plannedSec: 600,
        activeSec: 540,
        pausedSec: pauses.fold(0, (a, b) => a + b),
        kcal: 123.4,
        finishedEarly: early,
        logs: logs,
      );
    }

    test('результат сохраняется: выполнено, пропущено, паузы, прервано', () async {
      final w = WorkoutBuilder.build(
          decision: CoachRules.decide(_in(hist: _hist(3))), picks: const []);
      final id = await repo.savePlan(
          workout: w,
          scheduledAt: DateTime(2026, 3, 10, 19, 30),
          difficulty: 2,
          source: 'coach',
          now: env.now);
      await coach.saveResult(id, session(pauses: [15, 30]));
      await coach.saveResult(null, session(early: true, statuses: ['completed', 'stopped_early', 'not_started']));
      expect(changed, 2);

      final rows = await env.db.select(env.db.workoutResults).get();
      expect(rows.length, 2);
      final a = rows.firstWhere((r) => r.status == 'completed');
      expect(a.doneExercises, 2);
      expect(a.skippedExercises, 1);
      expect(a.pauses, 2);
      expect(a.pausedSeconds, 45);
      expect(a.durationSec, 540);
      expect(a.kcal, 123);
      expect(a.workoutId, id);
      final b = rows.firstWhere((r) => r.status == 'aborted');
      expect(b.note, contains('досрочно'));

      // план помечен выполненным
      final plan = await (env.db.select(env.db.workouts)
            ..where((x) => x.id.equals(id)))
          .getSingle();
      expect(plan.status, 'done');
      expect(await repo.nextPlanned(env.now), isNull);

      final recent = await repo.recentResults();
      expect(recent.length, 2);
      expect(recent.any((r) => r.difficulty == 2), isTrue);
    });

    test('результаты попадают в [ТРЕНИРОВКИ] контекста', () async {
      await coach.saveResult(null, session(early: true, statuses: ['completed', 'skipped']));
      final asm = ContextAssembler(
        profiles: env.profiles,
        memory: env.memory,
        conversation: env.conv,
        workouts: DbWorkoutHistorySource(repo),
        clock: () => env.now,
      );
      final c = await asm.assemble();
      expect(c.contextText, contains('[ТРЕНИРОВКИ]'));
      expect(c.contextText, contains('прервана'));
      expect(c.contextText, contains('пропущено упражнений'));
    });

    test('результат влияет на следующее решение', () async {
      for (var i = 0; i < 4; i++) {
        await coach.saveResult(
            null,
            session(
                statuses: ['completed', 'completed'],
                at: DateTime(2026, 3, 1 + i * 2, 19)));
      }
      final before = (await coach.decide())!;
      expect(before.needed, isTrue);
      await coach.saveResult(
          null,
          WorkoutSession(
            startedAt: DateTime(2026, 3, 9, 19),
            title: 'T',
            plannedSec: 600,
            activeSec: 60,
            pausedSec: 0,
            kcal: 10,
            finishedEarly: true,
            logs: [],
          ));
      final after = (await coach.decide())!;
      expect(after.needed, isTrue);
      expect(after.difficulty, lessThanOrEqualTo(before.difficulty));
      expect(after.minutes, lessThanOrEqualTo(before.minutes));
    });

    test('блок [ТРЕНЕР]: решение кода, каталог, причины', () async {
      await diary.apply(const FoodLogRequest(
          op: 'add', description: 'Пир', kcal: 3200, meal: 'lunch'));
      final b = await coach.block();
      expect(b, contains('[ТРЕНЕР]'));
      expect(b, contains('Тренировка нужна'));
      expect(b, contains('сверх нормы'));
      expect(b, contains('squat|'));
      expect(b, contains('ты его не меняешь'));
    });

    test('блок [ТРЕНЕР]: болезнь из памяти → отдых, без каталога', () async {
      await MemoryService(env.memory, clock: () => env.now).apply([
        const MemoryUpdate(
            key: 'health.wellbeing',
            fact: 'Заболел, температура',
            category: 'health'),
      ]);
      final b = await coach.block();
      expect(b, contains('не нужна'));
      expect(b, isNot(contains('squat|')));
    });

    test('самочувствие старше трёх суток не учитывается', () async {
      await MemoryService(env.memory, clock: () => DateTime(2026, 3, 1)).apply([
        const MemoryUpdate(
            key: 'health.wellbeing', fact: 'Болею', category: 'health'),
      ]);
      final d = (await coach.decide())!;
      expect(d.needed, isTrue);
    });

    test('plan_workout через диспетчер: код ставит время и сложность', () async {
      final disp = ActionDispatcher(
        memory: MemoryService(env.memory, clock: () => env.now),
        handlers: [PlanWorkoutHandler(coach)],
      );
      final r = await disp.handle(
          ReplyParser.parse('''{"reply":"Готово!","actions":[{"type":"plan_workout",
"title":"Вечерний заряд","intro":"Поехали!","difficulty":3,"scheduledAt":"2030-01-01T10:00",
"exercises":[{"id":"squat","durationSec":40,"restSec":20},{"id":"ВЫДУМАЛ"}]}]}'''),
          DispatchContext(userMessageId: 1, now: env.now));
      expect(r.footers.single, contains('Тренировка готова'));
      final p = (await repo.nextPlanned(env.now))!;
      expect(p.workout.title, 'Вечерний заряд');
      expect(p.scheduledAt, DateTime(2026, 3, 10, 19, 30)); // время — от кода
      expect(p.difficulty, isNot(3)); // сложность — от кода
      expect(p.source, 'coach');
      expect(p.workout.exercises.any((e) => e.id == 'ВЫДУМАЛ'), isFalse);
      expect(coach.revision.value, 1);
    });

    test('plan_workout, когда тренировка не нужна: игнорируется', () async {
      await coach.saveResult(null, session());
      final disp = ActionDispatcher(
        memory: MemoryService(env.memory, clock: () => env.now),
        handlers: [PlanWorkoutHandler(coach)],
      );
      final r = await disp.handle(
          ReplyParser.parse(
              '{"reply":"ок","actions":[{"type":"plan_workout","exercises":[{"id":"squat"}]}]}'),
          DispatchContext(userMessageId: 1, now: env.now));
      expect(r.footers, isEmpty);
      expect(await repo.nextPlanned(env.now), isNull);
    });

    test('переедание после записи еды усложняет сегодняшний план', () async {
      await coach.maintain();
      env.now = DateTime(2026, 3, 10, 19, 0); // близко к времени тренировки
      await coach.maintain();
      final p0 = (await repo.nextPlanned(env.now))!;
      expect(p0.source, 'local');

      // история, чтобы потолок позволял усложнение
      for (var i = 0; i < 4; i++) {
        await coach.saveResult(
            null,
            session(
                statuses: ['completed', 'completed'],
                at: DateTime(2026, 3, 1 + i * 2, 19)));
      }
      await coach.maintain();
      await diary.apply(const FoodLogRequest(
          op: 'add', description: 'Пир', kcal: 3500, meal: 'dinner'));
      final line = await coach.afterFood();
      expect(line, isNotNull);
      expect(line, contains('посложнее'));
      final p1 = (await repo.nextPlanned(env.now))!;
      expect(p1.difficulty, greaterThan(p0.difficulty));
      expect(p1.difficulty, 3);
    });

    test('пропущенный вчерашний план закрывается как «пропущено»', () async {
      final w = WorkoutBuilder.build(
          decision: CoachRules.decide(_in(hist: _hist(3))), picks: const []);
      await repo.savePlan(
          workout: w,
          scheduledAt: DateTime(2026, 3, 9, 19, 30),
          difficulty: 2,
          source: 'coach',
          now: DateTime(2026, 3, 9, 10));
      await coach.maintain();
      final rows = await env.db.select(env.db.workoutResults).get();
      expect(rows.single.status, 'skipped');
      final recent = await repo.recentResults();
      expect(recent.single.status, 'skipped');
      expect(changed, greaterThan(0));
    });

    test('новый план на тот же день заменяет прежний', () async {
      final w = WorkoutBuilder.build(
          decision: CoachRules.decide(_in(hist: _hist(3))), picks: const []);
      for (var i = 0; i < 2; i++) {
        await repo.savePlan(
            workout: w,
            scheduledAt: DateTime(2026, 3, 10, 19, 30),
            difficulty: 2,
            source: 'coach',
            now: env.now);
      }
      expect((await env.db.select(env.db.workouts).get()).length, 1);
    });
  });
}
