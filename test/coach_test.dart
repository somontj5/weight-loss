import 'package:flutter_test/flutter_test.dart';
import 'package:weightloss/data/exercise_catalog.dart';
import 'package:weightloss/data/repositories/diary_repository_impl.dart';
import 'package:weightloss/data/repositories/workout_repository_impl.dart';
import 'package:weightloss/domain/actions/action_dispatcher.dart';
import 'package:weightloss/domain/actions/plan_workout_handler.dart';
import 'package:weightloss/domain/coach/coach_models.dart';
import 'package:weightloss/domain/coach/offline_coach.dart';
import 'package:weightloss/domain/coach/coach_service.dart';
import 'package:weightloss/domain/coach/offline_workout_builder.dart';
import 'package:weightloss/domain/coach/plan_validator.dart';
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

  group('проверка плана Фитти (только техническая)', () {
    final now = DateTime(2026, 3, 10, 14, 0);
    ValidatedPlan? v(List<Map<String, dynamic>> picks,
            {Object? when, Object? diff, int qf = 22 * 60 + 30, int qt = 7 * 60 + 30}) =>
        PlanValidator.validate(
            picks: picks, now: now, scheduledFor: when, difficulty: diff,
            quietFromMin: qf, quietToMin: qt);

    test('чужие id отбрасываются, остальное принимается как есть', () {
      final r = v([
        {'id': 'squat', 'durationSec': 40, 'restSec': 20},
        {'id': 'ВЫДУМАЛ'},
        {'id': 'plank'},
      ], when: '2026-03-10T19:30', diff: 3)!;
      expect(r.droppedUnknown, 1);
      expect(r.workout.exercises.map((e) => e.id), ['squat', 'plank']);
      expect(r.difficulty, 3);
      expect(r.scheduledAt, DateTime(2026, 3, 10, 19, 30));
      expect(r.timeMoved, isFalse);
    });

    test('код не добавляет и не подрезает упражнения по своим правилам', () {
      final r = v([for (final i in ['squat', 'squat', 'plank']) {'id': i, 'durationSec': 30, 'restSec': 10}],
          when: '2026-03-10T19:30')!;
      expect(r.workout.exercises.length, 3);
      expect(r.trimmed, isFalse);
      final hard = catalogHard();
      final r2 = v([{'id': hard}], when: '2026-03-10T19:30', diff: 1)!;
      expect(r2.workout.exercises.single.id, hard);
    });

    test('границы: упражнение 20-90 сек, отдых 0-60 сек', () {
      final r = v([
        {'id': 'squat', 'durationSec': 5, 'restSec': -3},
        {'id': 'plank', 'durationSec': 500, 'restSec': 999},
        {'id': 'lunge', 'durationSec': '45', 'restSec': 'мусор'},
      ], when: '2026-03-10T19:30')!;
      final e = r.workout.exercises;
      expect(e[0].durationSec, 20);
      expect(e[0].restSec, 0);
      expect(e[1].durationSec, 90);
      expect(e[1].restSec, 60);
      expect(e[2].durationSec, 45);
      expect(e[2].restSec, 20);
    });

    test('общая длительность не больше 60 минут', () {
      final r = v([for (var i = 0; i < 60; i++) {'id': i.isEven ? 'squat' : 'plank', 'durationSec': 90, 'restSec': 60}],
          when: '2026-03-10T19:30')!;
      expect(PlanValidator.total(r.workout.exercises), lessThanOrEqualTo(3600));
      expect(r.trimmed, isTrue);
    });

    test('все id чужие: плана нет', () {
      expect(v([{'id': 'нет'}, {'id': 'тоже нет'}]), isNull);
      expect(v([]), isNull);
    });

    test('время: тихие часы переносятся на конец тишины', () {
      final r = v([{'id': 'squat'}], when: '2026-03-10T23:30')!;
      expect(r.timeMoved, isTrue);
      expect(r.scheduledAt, DateTime(2026, 3, 11, 7, 30));
      final r2 = v([{'id': 'squat'}], when: '2026-03-11T03:00')!;
      expect(r2.scheduledAt, DateTime(2026, 3, 11, 7, 30));
      final r3 = v([{'id': 'squat'}], when: '2026-03-11T08:00', qf: 23 * 60, qt: 9 * 60)!;
      expect(r3.scheduledAt, DateTime(2026, 3, 11, 9, 0));
    });

    test('время: прошлое, дальше 48 часов или мусор — ближайшее разумное', () {
      for (final w in ['2026-03-09T10:00', '2030-01-01T10:00', 'когда-нибудь', null]) {
        final r = v([{'id': 'squat'}], when: w)!;
        expect(r.timeMoved, isTrue, reason: '$w');
        expect(r.scheduledAt, DateTime(2026, 3, 10, 14, 30));
      }
      final ok = v([{'id': 'squat'}], when: '2026-03-12T10:00')!;
      expect(ok.scheduledAt, DateTime(2026, 3, 12, 10, 0));
      final night = PlanValidator.nearestReasonable(
          DateTime(2026, 3, 10, 23, 50), 22 * 60 + 30, 7 * 60 + 30);
      expect(night, DateTime(2026, 3, 11, 7, 30));
    });

    test('сложность вне 1-3 приводится к границам', () {
      expect(v([{'id': 'squat'}], when: '2026-03-10T19:30', diff: 9)!.difficulty, 3);
      expect(v([{'id': 'squat'}], when: '2026-03-10T19:30', diff: 0)!.difficulty, 1);
    });
  });

  group('запасной офлайн-тренер', () {
    test('офлайн-план собирается и помечен «Офлайн-план»', () {
      final d = OfflineCoach.decide(_in(hist: _hist(3)));
      expect(d.needed, isTrue);
      final w = OfflineWorkoutBuilder.build(decision: d, picks: const []);
      expect(w.title, contains('Офлайн-план'));
      expect(w.exercises, isNotEmpty);
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

    Future<int> savePlan() async {
      final w = OfflineWorkoutBuilder.build(
          decision: OfflineCoach.decide(_in(hist: _hist(3))), picks: const []);
      return repo.savePlan(
          workout: w,
          scheduledAt: DateTime(2026, 3, 10, 19, 30),
          difficulty: 2,
          source: 'coach',
          now: env.now);
    }

    ActionDispatcher disp() => ActionDispatcher(
          memory: MemoryService(env.memory, clock: () => env.now),
          handlers: [PlanWorkoutHandler(coach)],
        );

    test('результат сохраняется: выполнено, пропущено, паузы, прервано', () async {
      final id = await savePlan();
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
      final plan = await (env.db.select(env.db.workouts)..where((x) => x.id.equals(id))).getSingle();
      expect(plan.status, 'done');
      expect(await repo.nextPlanned(env.now), isNull);
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

    test('блок [ДАННЫЕ ДЛЯ ТРЕНЕРА]: только факты, без решений', () async {
      await diary.apply(const FoodLogRequest(op: 'add', description: 'Пир', kcal: 3200, meal: 'lunch'));
      await coach.saveResult(null, session(at: DateTime(2026, 3, 8, 19)));
      final b = await coach.block();
      expect(b, contains('[ДАННЫЕ ДЛЯ ТРЕНЕРА]'));
      expect(b, isNot(contains('[ТРЕНЕР]')));
      expect(b, contains('Съедено сегодня: ~3200'));
      expect(b, contains('Дней без тренировок: 2'));
      expect(b, contains('Возраст: 30'));
      expect(b, contains('Время на тренировки: 30 мин'));
      expect(b, contains('squat|'));
      expect(b, contains('|main|'));
      expect(b, contains('|warmup|'));
      expect(b, contains('|cooldown|'));
      expect(b, contains('ударное'));
      expect(b, contains('Последние тренировки'));
      expect(b, contains('упражнений выполнено 2, пропущено 1'));
      for (final bad in [
        'ты его не меняешь', 'Тренировка нужна', 'не нужна', 'ПОВЫШЕНА',
        'запрещены', 'Причины', 'потолок', 'решение принял',
      ]) {
        expect(b, isNot(contains(bad)), reason: bad);
      }
    });

    test('блок: память health.*, fitness.*, feeling.* как факты, без решения', () async {
      await MemoryService(env.memory, clock: () => env.now).apply([
        const MemoryUpdate(key: 'health.wellbeing', fact: 'Заболел, температура', category: 'health'),
        const MemoryUpdate(key: 'fitness.level', fact: 'Новичок', category: 'habit'),
        const MemoryUpdate(key: 'fitness.limits', fact: 'Болит колено', category: 'health'),
        const MemoryUpdate(key: 'feeling.today', fact: 'Устал', category: 'other'),
        const MemoryUpdate(key: 'food.dislikes', fact: 'Не любит рыбу', category: 'food'),
      ]);
      final b = await coach.block();
      expect(b, contains('health.wellbeing: Заболел, температура'));
      expect(b, contains('fitness.level: Новичок'));
      expect(b, contains('fitness.limits: Болит колено'));
      expect(b, contains('feeling.today: Устал'));
      expect(b, isNot(contains('food.dislikes')));
      expect(b, isNot(contains('не нужна')));
      expect(b, contains('squat|'));
      expect(b, isNot(contains('данных нет (fitness.level')));
    });

    test('блок: нет данных про опыт и здоровье — сказано фактом', () async {
      final b = await coach.block();
      expect(b, contains('Тренировок в приложении ещё не было'));
      expect(b, contains('fitness.level, fitness.limits, health.*'));
      expect(b, contains('Запланированных тренировок нет'));
    });

    test('результаты влияют на контекст', () async {
      expect(await coach.block(), contains('ещё не было'));
      await coach.saveResult(null, session(at: DateTime(2026, 3, 9, 19)));
      expect(await coach.block(), contains('Дней без тренировок: 1'));
      await coach.saveResult(null, session(early: true, statuses: ['completed'], at: DateTime(2026, 3, 10, 9)));
      final after = await coach.block();
      expect(after, contains('Дней без тренировок: 0'));
      expect(after, contains('прервана'));
    });

    test('plan_workout через диспетчер: время, сложность и состав у Фитти', () async {
      final r = await disp().handle(
          ReplyParser.parse('{"reply":"Готово!","actions":[{"type":"plan_workout","title":"Вечерний заряд","intro":"Поехали!","difficulty":3,"scheduledFor":"2026-03-10T20:15","exercises":[{"id":"squat","durationSec":40,"restSec":20},{"id":"ВЫДУМАЛ"}]}]}'),
          DispatchContext(userMessageId: 1, now: env.now));
      expect(r.footers.single, contains('Тренировка готова'));
      final p = (await repo.nextPlanned(env.now))!;
      expect(p.workout.title, 'Вечерний заряд');
      expect(p.scheduledAt, DateTime(2026, 3, 10, 20, 15));
      expect(p.difficulty, 3);
      expect(p.source, 'coach');
      expect(p.workout.exercises.map((e) => e.id), ['squat']);
      expect(coach.revision.value, 1);
    });

    test('plan_workout в тихие часы переносится; болезнь код не блокирует', () async {
      await MemoryService(env.memory, clock: () => env.now).apply([
        const MemoryUpdate(key: 'health.wellbeing', fact: 'Болею', category: 'health'),
      ]);
      final r = await disp().handle(
          ReplyParser.parse('{"reply":"ок","actions":[{"type":"plan_workout","difficulty":1,"scheduledFor":"2026-03-10T23:45","exercises":[{"id":"squat"}]}]}'),
          DispatchContext(userMessageId: 1, now: env.now));
      expect(r.footers.single, contains('перенесено'));
      final p = (await repo.nextPlanned(env.now))!;
      expect(p.scheduledAt, DateTime(2026, 3, 11, 7, 30));
    });

    test('plan_workout без годных упражнений: честное сообщение, плана нет', () async {
      final r = await disp().handle(
          ReplyParser.parse('{"reply":"ок","actions":[{"type":"plan_workout","exercises":[{"id":"нет"}]}]}'),
          DispatchContext(userMessageId: 1, now: env.now));
      expect(r.footers.single, contains('Не получилось'));
      expect(await repo.nextPlanned(env.now), isNull);
    });

    test('съели много: код сам план не создаёт и не усложняет', () async {
      env.now = DateTime(2026, 3, 10, 19, 0);
      coach.aiOnline = true;
      await coach.maintain();
      expect(await repo.nextPlanned(env.now), isNull);
      await diary.apply(const FoodLogRequest(op: 'add', description: 'Пир', kcal: 3500, meal: 'dinner'));
      expect(await repo.nextPlanned(env.now), isNull);
    });

    test('без сети: запасной план, помечен «офлайн-план»', () async {
      env.now = DateTime(2026, 3, 10, 19, 0);
      coach.aiOnline = false;
      await coach.maintain();
      final p = (await repo.nextPlanned(env.now))!;
      expect(p.source, 'offline');
      expect(p.workout.title, contains('Офлайн-план'));
      expect(p.workout.intro, contains('Офлайн-план'));
      expect(await coach.block(), contains('офлайн-план'));
    });

    test('пропущенный вчерашний план закрывается как «пропущено»', () async {
      final w = OfflineWorkoutBuilder.build(
          decision: OfflineCoach.decide(_in(hist: _hist(3))), picks: const []);
      await repo.savePlan(
          workout: w,
          scheduledAt: DateTime(2026, 3, 9, 19, 30),
          difficulty: 2,
          source: 'coach',
          now: DateTime(2026, 3, 9, 10));
      coach.aiOnline = true;
      await coach.maintain();
      final rows = await env.db.select(env.db.workoutResults).get();
      expect(rows.single.status, 'skipped');
      expect(changed, greaterThan(0));
    });

    test('новый план на тот же день заменяет прежний', () async {
      await savePlan();
      await savePlan();
      expect((await env.db.select(env.db.workouts).get()).length, 1);
    });
  });
}

String catalogHard() =>
    ExerciseCatalog.all.firstWhere((t) => t.stage == 'main' && t.difficulty == 3).id;
