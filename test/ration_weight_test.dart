import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import 'package:weightloss/config/context_config.dart';
import 'package:weightloss/data/db/app_database.dart';
import 'package:weightloss/data/repositories/diary_repository_impl.dart';
import 'package:weightloss/data/repositories/meal_plan_repository_impl.dart';
import 'package:weightloss/data/repositories/settings_repository_impl.dart';
import 'package:weightloss/domain/actions/action_dispatcher.dart';
import 'package:weightloss/domain/actions/plan_meals_handler.dart';
import 'package:weightloss/domain/context/context_assembler.dart';
import 'package:weightloss/domain/diary/diary_service.dart';
import 'package:weightloss/domain/diary/food_action.dart';
import 'package:weightloss/domain/memory/memory_service.dart';
import 'package:weightloss/domain/ration/ration_models.dart';
import 'package:weightloss/domain/ration/ration_service.dart';
import 'package:weightloss/domain/weight/weight_service.dart';
import 'package:weightloss/services/ai/reply_parser.dart';

import 'helpers.dart';

final _now = DateTime(2026, 3, 10, 9, 0);

Map<String, dynamic> _meal(String m, int kcal, {String? time}) => {
  'meal': m,
  'time': time ?? MealSlot.defaultTime(m),
  'title': 'Блюдо $m',
  'composition': ['а 100 г', 'б 50 г'],
  'kcal': kcal,
  'protein_g': kcal * 0.2 / 4,
  'fat_g': kcal * 0.3 / 9,
  'carbs_g': kcal * 0.5 / 4,
};

String _day(DateTime d, List<int> kcals) => jsonEncode({
  'date': RationValidator.ymd(d),
  'meals': [
    for (var i = 0; i < MealSlot.all.length; i++)
      _meal(MealSlot.all[i], kcals[i]),
  ],
});

String _plan(List<DateTime> days, {int total = 1700}) {
  final k = [
    (total * .22).round(),
    (total * .1).round(),
    (total * .3).round(),
    (total * .1).round(),
    total -
        (total * .22).round() -
        (total * .1).round() * 2 -
        (total * .3).round(),
  ];
  return '{"days":[${days.map((d) => _day(d, k)).join(',')}],"comment":"ok"}';
}

class _Env extends Env {
  _Env() : super(_now) {
    settings = SettingsRepositoryImpl(db);
    diary = DiaryService(DiaryRepositoryImpl(db), clock: () => now);
    plans = MealPlanRepositoryImpl(db);
  }
  late final SettingsRepositoryImpl settings;
  late final DiaryService diary;
  late final MealPlanRepositoryImpl plans;
  final asked = <String>[];
  List<String> answers = [];

  late final RationService ration = RationService(
    repo: plans,
    profiles: profiles,
    memory: memory,
    diary: diary,
    settings: settings,
    clock: () => now,
    ask: (s, u) async {
      asked.add(u);
      return answers.isEmpty ? '' : answers.removeAt(0);
    },
  );
}

void main() {
  late _Env e;
  late List<DateTime> days;
  setUp(() async {
    e = _Env();
    await e.seedProfile();
    days = [for (var i = 0; i < 3; i++) DateTime(2026, 3, 10 + i)];
  });
  tearDown(() => e.close());

  group('plan_meals: разбор и проверка сумм', () {
    test('нормальный ответ принимается, пункты сохраняются', () async {
      final kcal = (await e.profiles.getDietPlan())!.kcal;
      e.answers = [_plan(days, total: kcal)];
      final r = await e.ration.generate(days: days, reason: 'тест');
      expect(r.ok, isTrue);
      expect(r.marked, isEmpty);
      expect(e.asked.length, 1);
      final tomorrow = await e.plans.day(days[1]);
      expect(tomorrow.length, 5);
      expect(tomorrow.map((i) => i.meal), MealSlot.all);
      expect(tomorrow.every((i) => i.status == 'planned'), isTrue);
    });

    test('сильное расхождение: один повтор, потом показ с пометкой', () async {
      final kcal = (await e.profiles.getDietPlan())!.kcal;
      e.answers = [
        _plan(days, total: kcal + 900),
        _plan(days, total: kcal + 500),
      ];
      final r = await e.ration.generate(days: days, reason: 'тест');
      expect(e.asked.length, 2, reason: 'ровно один повторный запрос');
      expect(r.ok, isTrue);
      expect(r.marked, isNotEmpty);
      expect((await e.ration.marks()).isNotEmpty, isTrue);
    });

    test('повтор исправил суммы: пометок нет', () async {
      final kcal = (await e.profiles.getDietPlan())!.kcal;
      e.answers = [_plan(days, total: kcal + 900), _plan(days, total: kcal)];
      final r = await e.ration.generate(days: days, reason: 'тест');
      expect(r.ok, isTrue);
      expect(r.marked, isEmpty);
    });

    test(
      'мусор вместо JSON: повтор и честная неудача, база не тронута',
      () async {
        e.answers = ['не json', 'снова не json'];
        final r = await e.ration.generate(days: days, reason: 'тест');
        expect(e.asked.length, 2);
        expect(r.ok, isFalse);
        expect(
          (await e.plans.between(
            days.first,
            days.last.add(const Duration(days: 1)),
          )),
          isEmpty,
        );
      },
    );

    test('валидатор: потерянный день и приём, ```json``` ограждение', () {
      final exp = [
        DayExpectation(date: days[0], targetKcal: 1000, tolerance: 100),
        DayExpectation(date: days[1], targetKcal: 1000, tolerance: 100),
      ];
      final raw =
          '```json\n{"days":[{"date":"2026-03-10","meals":['
          '${jsonEncode(_meal('breakfast', 500))},${jsonEncode(_meal('lunch', 500))}]}]}\n```';
      final v = RationValidator.validate(RationValidator.decode(raw), exp)!;
      expect(v.big, isTrue);
      expect(v.problems.any((p) => p.contains('нет дня 2026-03-11')), isTrue);
      expect(v.problems.any((p) => p.contains('нет приёма')), isTrue);
      expect(RationValidator.validate(null, exp), isNull);
    });

    test(
      'валидатор: неверные числа отбрасываются, БЖУ не из калорий обнуляются',
      () {
        final exp = [
          DayExpectation(
            date: days[0],
            targetKcal: 500,
            tolerance: 100,
            expectedSlots: const ['breakfast'],
          ),
        ];
        final bad = _meal('breakfast', 500)
          ..['protein_g'] = 250
          ..['fat_g'] = 250
          ..['carbs_g'] = 250;
        final v = RationValidator.validate({
          'days': [
            {
              'date': '2026-03-10',
              'meals': [bad],
            },
          ],
        }, exp)!;
        final it = v.days[days[0]]!.single;
        expect(it.proteinG, 0);
        final v2 = RationValidator.validate({
          'days': [
            {
              'date': '2026-03-10',
              'meals': [_meal('breakfast', 99999)],
            },
          ],
        }, exp)!;
        expect(v2.days, isEmpty);
      },
    );

    test('обработчик plan_meals принимает действие из ответа модели', () async {
      final kcal = (await e.profiles.getDietPlan())!.kcal;
      e.answers = [_plan(days, total: kcal)];
      final d = ActionDispatcher(
        memory: MemoryService(e.memory),
        handlers: [PlanMealsHandler(e.ration)],
      );
      final parsed = ReplyParser.parse(
        jsonEncode({
          'reply': 'Готово',
          'actions': [
            {
              'type': 'plan_meals',
              'op': 'create',
              'days': ['2026-03-10', '2026-03-11', '2026-03-12'],
            },
          ],
        }),
      );
      final res = await d.handle(
        parsed,
        DispatchContext(userMessageId: 1, now: _now),
      );
      expect(res.footers.single, contains('Рацион составлен на 3 дн.'));
      expect(
        res.footers.single,
        contains('черновик'),
        reason:
            'в памяти нет непереносимостей, предпочтений, продуктов, бюджета',
      );
    });
  });

  group('когда продлевать рацион', () {
    test('меньше двух будущих дней: нужно', () {
      expect(RationService.needsExtension([], _now), isTrue);
      expect(RationService.needsExtension([days[0], days[1]], _now), isTrue);
      expect(RationService.needsExtension(days, _now), isFalse);
      expect(
        RationService.needsExtension([
          days[1],
          days[2],
          DateTime(2026, 3, 13),
        ], _now),
        isFalse,
      );
    });

    test('maintain: при полном плане запроса к ИИ нет', () async {
      final kcal = (await e.profiles.getDietPlan())!.kcal;
      e.answers = [_plan(days, total: kcal)];
      await e.ration.generate(days: days, reason: 'тест');
      e.asked.clear();
      e.answers = [_plan(days, total: kcal)];
      await e.ration.maintain();
      expect(e.asked, isEmpty, reason: 'не пересоздавать без причины');
    });

    test(
      'maintain: пустой рацион запрашивается, повтор не чаще чем раз в 3 часа',
      () async {
        e.answers = ['мусор', 'мусор'];
        await e.ration.maintain();
        expect(e.asked.length, 2);
        e.answers = ['мусор'];
        await e.ration.maintain();
        expect(e.asked.length, 2, reason: 'антиспам повторных попыток');
      },
    );
  });

  group('что неизвестно о человеке', () {
    test('пустая память: четыре пробела, статус черновик', () async {
      expect((await e.ration.missing()).length, 4);
      expect(await e.ration.isDraft(), isTrue);
    });

    test('после ответов черновик снимается', () async {
      for (final f in [
        ['intolerance.lactose', 'без лактозы', 'intolerance'],
        ['food.dislikes', 'не любит рыбу', 'food'],
        ['food.home_products', 'крупы, курица', 'food'],
        ['budget.weekly', '5000', 'budget'],
      ]) {
        await e.memory.insert(
          key: f[0],
          fact: f[1],
          category: f[2],
          confidence: 0.9,
          now: _now,
        );
      }
      expect(await e.ration.missing(), isEmpty);
      expect(await e.ration.isDraft(), isFalse);
    });
  });

  group('log_food связан с plan_item_id', () {
    test('парсер читает plan_item_id и мусор отбрасывает', () {
      final r = FoodActionParser.parse({
        'op': 'add',
        'description': 'Овсянка',
        'kcal': 300,
        'plan_item_id': 7,
      }, _now)!;
      expect(r.planItemId, 7);
      expect(
        FoodActionParser.parse({
          'op': 'add',
          'description': 'x',
          'kcal': 300,
          'plan_item_id': 'abc',
        }, _now)!.planItemId,
        isNull,
      );
      expect(
        FoodActionParser.parse({
          'op': 'add',
          'description': 'x',
          'kcal': 300,
          'plan_item_id': -3,
        }, _now)!.planItemId,
        isNull,
      );
    });

    test(
      'еда со ссылкой меняет статус пункта, удаление возвращает planned',
      () async {
        final kcal = (await e.profiles.getDietPlan())!.kcal;
        e.answers = [_plan(days, total: kcal)];
        await e.ration.generate(days: days, reason: 'тест');
        final item = (await e.plans.day(days[0])).first;
        final d = ActionDispatcher(
          memory: MemoryService(e.memory),
          diary: e.diary,
          ration: e.ration,
        );
        ParsedReply reply(Map<String, dynamic> a) => ReplyParser.parse(
          jsonEncode({
            'reply': 'ok',
            'actions': [a],
          }),
        );
        var res = await d.handle(
          reply({
            'type': 'log_food',
            'op': 'add',
            'meal': 'breakfast',
            'time': '08:10',
            'description': 'Овсянка',
            'kcal': 350,
            'plan_item_id': item.id,
          }),
          DispatchContext(userMessageId: 1, now: _now),
        );
        expect(res.food!.entry!.planItemId, item.id);
        expect((await e.plans.byId(item.id))!.status, 'eaten');

        // замена: другая еда вместо пункта
        final item2 = (await e.plans.day(days[0]))[2];
        await d.handle(
          reply({
            'type': 'log_food',
            'op': 'add',
            'meal': 'lunch',
            'time': '13:00',
            'description': 'Пицца',
            'kcal': 700,
            'plan_item_id': item2.id,
            'plan_status': 'replaced',
          }),
          DispatchContext(userMessageId: 2, now: _now),
        );
        expect((await e.plans.byId(item2.id))!.status, 'replaced');

        // несуществующая ссылка ничего не ломает
        res = await d.handle(
          reply({
            'type': 'log_food',
            'op': 'add',
            'meal': 'dinner',
            'time': '19:00',
            'description': 'Суп',
            'kcal': 300,
            'plan_item_id': 99999,
          }),
          DispatchContext(userMessageId: 3, now: _now),
        );
        expect(res.food!.kind, FoodOutcomeKind.added);

        // удаление записи: пункт снова по плану
        final id = (await e.diary.day(
          _now,
        )).firstWhere((x) => x.planItemId == item.id).id;
        await d.handle(
          reply({'type': 'log_food', 'op': 'delete', 'entry_id': id}),
          DispatchContext(userMessageId: 4, now: _now),
        );
        expect((await e.plans.byId(item.id))!.status, 'planned');
      },
    );

    test('закрытые пункты не затираются при обновлении дня', () async {
      final kcal = (await e.profiles.getDietPlan())!.kcal;
      e.answers = [_plan(days, total: kcal), _plan(days, total: kcal)];
      await e.ration.generate(days: days, reason: 'тест');
      final item = (await e.plans.day(days[1])).first;
      await e.plans.setStatus(item.id, 'eaten');
      await e.ration.generate(days: [days[1]], reason: 'тест');
      expect((await e.plans.byId(item.id))!.status, 'eaten');
      final all = await e.plans.day(days[1]);
      expect(
        all.where((i) => i.meal == item.meal).length,
        1,
        reason: 'закрытый приём заново не создаётся',
      );
    });
  });

  group('update_weight', () {
    late WeightService w;
    var normChanges = 0;
    setUp(() {
      normChanges = 0;
      w = WeightService(
        profiles: e.profiles,
        profileService: e.service,
        settings: e.settings,
        clock: () => e.now,
        onNormChanged: () async => normChanges++,
      );
    });

    test(
      'обычное взвешивание: история растёт, норма пересчитана, старая цифра цела',
      () async {
        final before = (await e.profiles.getDietPlan())!;
        e.now = _now.add(const Duration(days: 7));
        final o = await w.apply(weightKg: 78, waistCm: 88);
        expect(o.saved, isTrue);
        final hist = await e.profiles.weightHistory();
        expect(hist.map((p) => p.weightKg), [
          80,
          78,
        ], reason: 'история сохранена');
        expect((await e.profiles.getProfile())!.weightKg, 78);
        expect((await e.profiles.getProfile())!.waistCm, 88);
        final after = (await e.profiles.getDietPlan())!;
        expect(after.kcal, lessThan(before.kcal));
        expect(o.normChanged, isTrue);
        expect(normChanges, 1, reason: 'Фитти должен поправить будущие дни');
      },
    );

    test(
      'скачок больше 3 кг в неделю не сохраняется, пока не подтвердят',
      () async {
        e.now = _now.add(const Duration(days: 7));
        final o = await w.apply(weightKg: 73);
        expect(o.saved, isFalse);
        expect(o.needConfirm, isTrue);
        expect(o.message, contains('уточни у человека'));
        expect((await e.profiles.weightHistory()).length, 1);
        expect(await w.block(), contains('ЖДЁТ ПОДТВЕРЖДЕНИЯ'));
        // подтверждение тем же значением
        final ok = await w.apply(weightKg: 73);
        expect(ok.saved, isTrue);
        expect((await e.profiles.weightHistory()).last.weightKg, 73);
        expect(await e.settings.get('weight.pending'), isNull);
      },
    );

    test('неправдоподобные значения не пишутся', () async {
      expect((await w.apply(weightKg: 12)).saved, isFalse);
      expect((await w.apply(weightKg: 500)).saved, isFalse);
      expect((await w.apply(weightKg: 79, waistCm: 5)).saved, isFalse);
      expect((await e.profiles.weightHistory()).length, 1);
    });

    test(
      'блок [ВЕС]: тренд, остаток, пора взвесить, антиспам просьбы',
      () async {
        e.now = _now.add(const Duration(days: 8));
        var b = await w.block();
        expect(b, contains('До цели осталось 10'));
        expect(b, contains('ПОРА ВЗВЕСИТЬ'));
        await w.commitAsked();
        e.now = e.now.add(const Duration(days: 2));
        b = await w.block();
        expect(b, contains('недавно уже просил'));
        e.now = e.now.add(const Duration(days: 4));
        expect(await w.block(), contains('ПОРА ВЗВЕСИТЬ'));
      },
    );
  });

  group('контекст с новыми блоками', () {
    test('влезает в потолок 5000 токенов, блоки на месте', () async {
      expect(ContextConfig.defaults.totalBudget, 5000);
      final kcal = (await e.profiles.getDietPlan())!.kcal;
      e.answers = [_plan(days, total: kcal)];
      await e.ration.generate(days: days, reason: 'тест');
      final w = WeightService(
        profiles: e.profiles,
        profileService: e.service,
        settings: e.settings,
        clock: () => e.now,
      );
      for (var i = 0; i < 60; i++) {
        await e.conv.addMessage(
          role: i.isEven ? 'user' : 'fitty',
          body: 'Длинное сообщение номер $i ' * 20,
        );
      }
      final a = ContextAssembler(
        profiles: e.profiles,
        memory: e.memory,
        conversation: e.conv,
        rationBlock: e.ration.block,
        weightBlock: w.block,
        clock: () => e.now,
      );
      final ctx = await a.assemble();
      expect(ctx.tokens, lessThanOrEqualTo(5000));
      expect(ctx.contextText, contains('[РАЦИОН]'));
      expect(ctx.contextText, contains('[ВЕС]'));
      expect(ctx.contextText, contains('черновик'));
      expect(
        ctx.sections['ration']!,
        lessThanOrEqualTo(ContextConfig.defaults.rationBudget),
      );
    });
  });

  test('миграция v2 → v3 сохраняет данные и добавляет рацион', () async {
    final raw = sql.sqlite3.openInMemory();
    // создаём базу текущей схемы, затем откатываем её до вида v2
    final tmp = AppDatabase(NativeDatabase.opened(raw));
    await tmp.customSelect('select 1').get();
    await tmp.customStatement('DROP TABLE meal_plan_items');
    await tmp.customStatement(
      'ALTER TABLE diary_entries DROP COLUMN plan_item_id',
    );
    await tmp.customStatement(
      "INSERT INTO diary_entries (eaten_at, meal, description, kcal, created_at) VALUES (1700000000, 'lunch', 'Борщ', 320, 1700000000)",
    );
    await tmp.customStatement('PRAGMA user_version = 2');
    // не закрываем raw: открываем заново как «старую» базу v2
    final db = AppDatabase(NativeDatabase.opened(raw));
    addTearDown(db.close);
    final d = await db.select(db.diaryEntries).getSingle();
    expect(d.description, 'Борщ');
    expect(d.planItemId, isNull);
    await db
        .into(db.mealPlanItems)
        .insert(
          MealPlanItemsCompanion.insert(
            date: DateTime(2026, 3, 10),
            meal: 'lunch',
            title: 'Суп',
            kcal: 300,
            createdAt: DateTime(2026, 3, 10),
          ),
        );
    final row = await db.select(db.mealPlanItems).getSingle();
    expect(row.status, 'planned');
    expect(AppDatabase.dbSchemaVersion, 3);
  });
}
