import 'package:flutter_test/flutter_test.dart';
import 'package:weightloss/data/repositories/diary_repository_impl.dart';
import 'package:weightloss/data/repositories/settings_repository_impl.dart';
import 'package:weightloss/domain/actions/action_dispatcher.dart';
import 'package:weightloss/domain/context/part2_stubs.dart';
import 'package:weightloss/domain/diary/diary_calc.dart';
import 'package:weightloss/domain/diary/diary_math.dart';
import 'package:weightloss/domain/diary/diary_service.dart';
import 'package:weightloss/domain/diary/food_action.dart';
import 'package:weightloss/domain/entities/part2_entities.dart';
import 'package:weightloss/domain/memory/memory_service.dart';
import 'package:weightloss/services/ai/reply_parser.dart';

import 'helpers.dart';

void main() {
  final now = DateTime(2026, 3, 10, 13, 30);

  group('разбор log_food', () {
    FoodLogRequest? p(Map<String, dynamic> m) => FoodActionParser.parse(m, now);

    test('нормальное добавление', () {
      final r = p({
        'op': 'add',
        'meal': 'lunch',
        'time': '13:05',
        'description': 'Курица с гречкой',
        'kcal': 520,
        'protein_g': 40,
        'fat_g': 14,
        'carbs_g': 55,
      })!;
      expect(r.isAdd, isTrue);
      expect(r.meal, 'lunch');
      expect(r.time, DateTime(2026, 3, 10, 13, 5));
      expect(r.kcal, 520);
      expect(r.proteinG, 40);
      expect(r.problems, isEmpty);
    });

    test('op по умолчанию add; русские названия приёмов', () {
      final r = p({'meal': 'Обед', 'description': 'суп', 'kcal': '300 ккал'})!;
      expect(r.op, 'add');
      expect(r.meal, 'lunch');
      expect(r.kcal, 300);
    });

    test('нереальные калории и БЖУ отбрасываются', () {
      final r = p({'description': 'x', 'kcal': 99999, 'protein_g': -5})!;
      expect(r.kcal, isNull);
      expect(r.proteinG, isNull);
      expect(r.problems, isNotEmpty);
    });

    test('БЖУ, не сходящиеся с калориями, выбрасываются', () {
      final r = p({
        'description': 'x',
        'kcal': 200,
        'protein_g': 100,
        'fat_g': 100,
        'carbs_g': 100
      })!;
      expect(r.kcal, 200);
      expect(r.proteinG, isNull);
      expect(r.fatG, isNull);
    });

    test('update/delete без номера и неизвестная операция — мусор', () {
      expect(p({'op': 'update', 'kcal': 100}), isNull);
      expect(p({'op': 'delete'}), isNull);
      expect(p({'op': 'explode', 'entry_id': 1}), isNull);
      expect(p({'op': 'delete', 'entry_id': 12})!.entryId, 12);
    });

    test('время: будущее и древнее игнорируется, мусор тоже', () {
      expect(p({'description': 'x', 'kcal': 1, 'time': '23:50'})!.time, isNull);
      expect(p({'description': 'x', 'kcal': 1, 'time': '99:99'})!.time, isNull);
      expect(p({'description': 'x', 'kcal': 1, 'time': 'вчера'})!.time, isNull);
      expect(
          p({'description': 'x', 'kcal': 1, 'time': '2020-01-01 10:00'})!.time,
          isNull);
    });

    test('описание чистится: «#12» в начале и длина', () {
      final r = p({'description': '#12  ${'а' * 400}', 'kcal': 1})!;
      expect(r.description!.startsWith('#'), isFalse);
      expect(r.description!.length, lessThanOrEqualTo(160));
    });
  });

  group('дневник: правка без дубля', () {
    late Env env;
    late DiaryService diary;
    setUp(() {
      env = Env(now);
      diary = DiaryService(DiaryRepositoryImpl(env.db), clock: () => env.now);
    });
    tearDown(() => env.close());

    FoodLogRequest add(String d, int kcal,
            {String? meal, double? p, double? f, double? c}) =>
        FoodLogRequest(
            op: 'add',
            description: d,
            kcal: kcal,
            meal: meal,
            proteinG: p,
            fatG: f,
            carbsG: c);

    test('update меняет ту же запись и пропорционально пересчитывает БЖУ',
        () async {
      final a = await diary.apply(
          add('Паста', 400, meal: 'lunch', p: 15, f: 10, c: 60),
          messageId: 1);
      final id = a.entry!.id;
      final u = await diary.apply(FoodLogRequest(
          op: 'update', entryId: id, kcal: 800, description: 'Две порции пасты'));
      expect(u.kind, FoodOutcomeKind.updated);
      final list = await diary.day(now);
      expect(list, hasLength(1)); // дубля нет
      expect(list.single.id, id);
      expect(list.single.kcal, 800);
      expect(list.single.description, 'Две порции пасты');
      expect(list.single.proteinG, 30);
      expect(list.single.carbsG, 120);
    });

    test('update несуществующей записи отклоняется, ничего не создаёт',
        () async {
      final u = await diary
          .apply(const FoodLogRequest(op: 'update', entryId: 999, kcal: 100));
      expect(u.kind, FoodOutcomeKind.rejected);
      expect(await diary.day(now), isEmpty);
    });

    test('повторный add из того же сообщения правит запись, а не дублирует',
        () async {
      await diary.apply(add('Омлет', 300, meal: 'breakfast'), messageId: 5);
      final again = await diary.apply(add('Омлет с сыром', 380, meal: 'breakfast'),
          messageId: 5);
      expect(again.kind, FoodOutcomeKind.updated);
      final list = await diary.day(now);
      expect(list, hasLength(1));
      expect(list.single.kcal, 380);
    });

    test('фото и текст об одном приёме пищи сливаются в одну запись', () async {
      final a = await diary.apply(add('Салат (по фото)', 250, meal: 'lunch'),
          messageId: 10, source: 'chat_photo', photos: ['/p/1.jpg']);
      env.now = now.add(const Duration(minutes: 2));
      final b = await diary.apply(
          add('Салат с оливковым маслом', 330, meal: 'lunch'),
          messageId: 11,
          source: 'chat_text');
      expect(b.merged, isTrue);
      expect(b.entry!.id, a.entry!.id);
      final list = await diary.day(now);
      expect(list, hasLength(1));
      expect(list.single.kcal, 330);
      expect(list.single.photos, ['/p/1.jpg']);
    });

    test('два разных приёма пищи — две записи', () async {
      await diary.apply(add('Овсянка', 300, meal: 'breakfast'), messageId: 1);
      env.now = now.add(const Duration(minutes: 1));
      await diary.apply(add('Яблоко', 80, meal: 'snack'), messageId: 2);
      expect(await diary.day(now), hasLength(2));
    });

    test('delete убирает запись', () async {
      final a = await diary.apply(add('Торт', 450, meal: 'snack'), messageId: 1);
      final d = await diary
          .apply(FoodLogRequest(op: 'delete', entryId: a.entry!.id));
      expect(d.kind, FoodOutcomeKind.deleted);
      expect(await diary.day(now), isEmpty);
    });

    test('без калорий или описания запись не создаётся', () async {
      final a = await diary.apply(
          const FoodLogRequest(op: 'add', description: 'что-то'));
      final b = await diary.apply(const FoodLogRequest(op: 'add', kcal: 100));
      expect(a.ok, isFalse);
      expect(b.ok, isFalse);
      expect(await diary.day(now), isEmpty);
    });
  });

  group('остаток, отклонения, ориентир — считает код', () {
    test('остаток и округление', () {
      expect(DiaryMath.remaining(1700, 1180), 520);
      expect(DiaryMath.round10(523), 520);
    });

    test('отклонения от плана по прошлым дням', () {
      DiaryDay day(int d, int kcal) => DiaryDay(date: DateTime(2026, 3, d), items: [
            DiaryItem(time: DateTime(2026, 3, d, 12), meal: 'x', description: 'y', kcal: kcal)
          ]);
      final dev = DiaryMath.deviations(
          [day(5, 1750), day(6, 2100), day(7, 1500)], 1700, 100);
      expect(dev.map((d) => d.diff), [-200, 400, 50]); // свежие первыми
      expect(dev.map((d) => d.withinTolerance), [false, false, true]);
    });

    test('ориентир на следующий приём пищи', () {
      // 13:30, обед не записан: делим остаток на обед и ужин
      final n = DiaryMath.nextMeal(
          now: now, logged: {'breakfast'}, remaining: 1400);
      expect(n.meal, 'lunch');
      expect(n.kcal, 700);
      // обед уже записан → ужин получает всё
      final n2 = DiaryMath.nextMeal(
          now: now, logged: {'breakfast', 'lunch'}, remaining: 800);
      expect(n2.meal, 'dinner');
      expect(n2.kcal, 800);
      // норма выбрана
      expect(
          DiaryMath.nextMeal(now: now, logged: {}, remaining: -50).kcal, isNull);
    });
  });

  group('ActionDispatcher + подвал', () {
    late Env env;
    late DiaryService diary;
    late DiaryCalc calc;
    late ActionDispatcher disp;

    setUp(() async {
      env = Env(now);
      await env.seedProfile(); // норма посчитается кодом
      diary = DiaryService(DiaryRepositoryImpl(env.db), clock: () => env.now);
      calc = DiaryCalc(
        diary: diary,
        source: DbDiarySource(diary),
        profiles: env.profiles,
        settings: SettingsRepositoryImpl(env.db, clock: () => env.now),
        clock: () => env.now,
      );
      disp = ActionDispatcher(
          memory: MemoryService(env.memory, clock: () => env.now),
          diary: diary,
          calc: calc);
    });
    tearDown(() => env.close());

    DispatchContext ctx(int id) => DispatchContext(userMessageId: id, now: env.now);

    test('одно сообщение — одна запись, подвал с числами кода', () async {
      final parsed = ReplyParser.parse('''
{"reply":"Вкусно!","actions":[
 {"type":"log_food","op":"add","meal":"lunch","description":"Борщ","kcal":520},
 {"type":"log_food","op":"add","meal":"lunch","description":"Вторая запись","kcal":300}]}''');
      final r = await disp.handle(parsed, ctx(1));
      expect(await diary.day(now), hasLength(1));
      final plan = (await env.profiles.getDietPlan())!;
      final left = DiaryMath.round10(plan.kcal - 520);
      expect(r.footers.single, 'Записал: обед, примерно 520 ккал. Осталось ~$left ккал');
    });

    test('clarify: еда не записывается, счётчик вопросов растёт и сбрасывается',
        () async {
      final ask = ReplyParser.parse(
          '{"reply":"Это жареное?","clarify":true,"actions":[{"type":"log_food","description":"Картошка","kcal":300}]}');
      await disp.handle(ask, ctx(1));
      expect(await diary.day(now), isEmpty);
      expect(await calc.clarifyStreak(), 1);
      await disp.handle(ask, ctx(2));
      await disp.handle(ask, ctx(3));
      expect(await calc.clarifyStreak(), DiaryCalc.maxClarify); // потолок
      final done = ReplyParser.parse(
          '{"reply":"Записал","actions":[{"type":"log_food","description":"Картошка","kcal":300,"meal":"lunch"}]}');
      await disp.handle(done, ctx(4));
      expect(await calc.clarifyStreak(), 0);
      expect(await diary.day(now), hasLength(1));
    });

    test('тренерские и уведомочные действия принимаются и игнорируются',
        () async {
      final parsed = ReplyParser.parse(
          '{"reply":"ок","actions":[{"type":"plan_workout"},{"type":"schedule_notification"},{"type":"something_new"}]}');
      final r = await disp.handle(parsed, ctx(1));
      expect(r.ignored, ['plan_workout', 'schedule_notification', 'something_new']);
      expect(r.footers, isEmpty);
    });

    test('[ДНЕВНИК-КОД]: пусто — остаток не называем; с записями — числа',
        () async {
      var b = await calc.codeBlock();
      expect(b, contains('Записей сегодня: 0'));
      expect(b, contains('Остаток калорий не называй'));
      await diary.apply(
          const FoodLogRequest(
              op: 'add', description: 'Борщ', kcal: 520, meal: 'lunch'),
          messageId: 1);
      b = await calc.codeBlock();
      expect(b, contains('Съедено ~520'));
      expect(b, contains('Ориентир на ужин'));
      expect(b.length, lessThan(900)); // короткий блок
    });

    test('номер записи (#id) виден модели в дневнике сегодня', () async {
      final a = await diary.apply(
          const FoodLogRequest(op: 'add', description: 'Борщ', kcal: 520),
          messageId: 1);
      final today = await DbDiarySource(diary).today(now);
      expect(today.items.single.description, startsWith('#${a.entry!.id} '));
    });
  });
}
