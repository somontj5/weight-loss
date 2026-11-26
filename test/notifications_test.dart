import 'package:flutter_test/flutter_test.dart';
import 'package:weightloss/data/repositories/diary_repository_impl.dart';
import 'package:weightloss/data/repositories/notification_schedule_repository_impl.dart';
import 'package:weightloss/data/repositories/settings_repository_impl.dart';
import 'package:weightloss/domain/actions/action_dispatcher.dart';
import 'package:weightloss/domain/actions/notification_handlers.dart';
import 'package:weightloss/domain/diary/diary_service.dart';
import 'package:weightloss/domain/diary/food_action.dart';
import 'package:weightloss/domain/entities/memory_fact.dart';
import 'package:weightloss/domain/memory/memory_service.dart';
import 'package:weightloss/domain/notifications/notification_schedule_repository.dart';
import 'package:weightloss/domain/notifications/notification_gateway.dart';
import 'package:weightloss/domain/notifications/notification_models.dart';
import 'package:weightloss/domain/notifications/notification_planner.dart';
import 'package:weightloss/domain/notifications/notification_service.dart';
import 'package:weightloss/domain/notifications/notification_texts.dart';
import 'package:weightloss/services/ai/reply_parser.dart';

import 'helpers.dart';

class FakeGateway implements NotificationGateway {
  List<PlannedNotif> last = [];
  bool exactFlag = false;
  bool permission = true;
  int replaced = 0;
  @override
  Future<void> init({required void Function(String payload) onTap}) async {}
  @override
  Future<bool> requestPermission() async => permission;
  @override
  Future<bool> hasPermission() async => permission;
  @override
  Future<bool> canScheduleExact() async => exactFlag;
  @override
  Future<void> replaceAll(List<PlannedNotif> items,
      {required bool exact}) async {
    last = items;
    exactFlag = exact;
    replaced++;
  }

  @override
  Future<String?> launchPayload() async => null;
}

({String title, String body}) _t(String s, DateTime a, int? i, String? t) =>
    (title: s, body: t ?? s);

PlanInput _in({
  DateTime? now,
  NotifPrefs prefs = const NotifPrefs(),
  int? wake,
  int? bed,
  int? b,
  int? l,
  int? d,
  List<NotifOverride> ov = const [],
  Set<String> logged = const {},
  List<DateTime> workouts = const [],
  int days = 1,
}) =>
    PlanInput(
      now: now ?? DateTime(2026, 3, 10, 6, 0),
      prefs: prefs,
      wakeUpMin: wake,
      bedtimeMin: bed,
      breakfastMin: b,
      lunchMin: l,
      dinnerMin: d,
      overrides: ov,
      loggedMealsToday: logged,
      workouts: workouts,
      days: days,
    );

int _min(PlannedNotif n) => n.at.hour * 60 + n.at.minute;

void main() {
  group('выбор времени', () {
    test('парсинг времени из памяти', () {
      expect(NotificationPlanner.parseTime('07:30'), 450);
      expect(NotificationPlanner.parseTime('встаю в 7.45'), 465);
      expect(NotificationPlanner.parseTime('25:00'), isNull);
      expect(NotificationPlanner.parseTime('утром'), isNull);
      expect(NotificationPlanner.parseTime(null), isNull);
    });

    test('без данных: разумные значения по умолчанию', () {
      final p = NotificationPlanner.plan(_in(), _t);
      final slots = {for (final n in p) n.slot: _min(n)};
      expect(slots['breakfast'], 8 * 60 + 30);
      expect(slots['lunch'], 13 * 60 + 30);
      expect(slots['dinner'], 19 * 60 + 30);
      expect(slots['summary'], 21 * 60 + 30);
    });

    test('время берётся из режима дня (память)', () {
      final p = NotificationPlanner.plan(
          _in(b: 9 * 60, l: 12 * 60, d: 18 * 60, bed: 23 * 60 + 30), _t);
      final slots = {for (final n in p) n.slot: _min(n)};
      expect(slots['breakfast'], 9 * 60 + 30);
      expect(slots['lunch'], 12 * 60 + 30);
      expect(slots['dinner'], 18 * 60 + 30);
      // итог за 1,5 часа до сна
      expect(slots['summary'], 22 * 60);
    });

    test('подъём без времени завтрака: завтрак через час после подъёма', () {
      final p = NotificationPlanner.plan(_in(wake: 6 * 60 + 30), _t);
      expect(_min(p.firstWhere((n) => n.slot == 'breakfast')), 8 * 60);
    });

    test('ручное время слота важнее вычисленного', () {
      final p = NotificationPlanner.plan(
          _in(l: 12 * 60, ov: const [
            NotifOverride(
                id: 1,
                slot: 'lunch',
                minuteOfDay: 14 * 60,
                weekdaysMask: 127,
                enabled: true)
          ]),
          _t);
      expect(_min(p.firstWhere((n) => n.slot == 'lunch')), 14 * 60);
    });
  });

  group('антиспам', () {
    test('дневной лимит: остаются самые важные', () {
      final p = NotificationPlanner.plan(
          _in(prefs: const NotifPrefs(maxPerDay: 2)), _t);
      expect(p.length, 2);
      expect(p.map((n) => n.slot), containsAll(['lunch', 'dinner']));
    });

    test('сегодня уже записан обед: про обед не напоминаем, завтра напомним',
        () {
      final p = NotificationPlanner.plan(
          _in(logged: {'lunch'}, days: 2), _t);
      final day0 = p.where((n) => n.at.day == 10).map((n) => n.slot);
      final day1 = p.where((n) => n.at.day == 11).map((n) => n.slot);
      expect(day0, isNot(contains('lunch')));
      expect(day1, contains('lunch'));
    });

    test('не ночью: ничего раньше 7:00 и в тихие часы', () {
      final p = NotificationPlanner.plan(
          _in(b: 5 * 60, l: 23 * 60, d: 2 * 60), _t);
      for (final n in p) {
        expect(_min(n), greaterThanOrEqualTo(7 * 60));
        expect(NotificationPlanner.quietRange(_in()).$1, 22 * 60 + 30);
        expect(_min(n) < 22 * 60 + 30, isTrue);
      }
      expect(p.map((n) => n.slot), isNot(contains('breakfast')));
    });

    test('«не беспокоить»: свои тихие часы уважаются', () {
      final p = NotificationPlanner.plan(
          _in(
              prefs: const NotifPrefs(
                  quietFromMin: 13 * 60, quietToMin: 15 * 60)),
          _t);
      expect(p.map((n) => n.slot), isNot(contains('lunch')));
      expect(p.map((n) => n.slot), contains('dinner'));
    });

    test('две близкие напоминалки: остаётся более важная', () {
      // завтрак и обед в одно время
      final p = NotificationPlanner.plan(_in(b: 12 * 60, l: 12 * 60 + 10), _t);
      final near = p.where((n) => _min(n) > 12 * 60 && _min(n) < 13 * 60);
      expect(near.length, 1);
      expect(near.first.slot, 'lunch');
    });

    test('выключено: ничего не планируем', () {
      expect(
          NotificationPlanner.plan(
              _in(prefs: const NotifPrefs(enabled: false)), _t),
          isEmpty);
    });

    test('прошедшее сегодня время не планируется', () {
      final p = NotificationPlanner.plan(
          _in(now: DateTime(2026, 3, 10, 15, 0)), _t);
      expect(p.map((n) => n.slot), isNot(contains('lunch')));
      expect(p.map((n) => n.slot), contains('dinner'));
    });

    test('тренировка от тренера попадает в расписание', () {
      final p = NotificationPlanner.plan(
          _in(workouts: [DateTime(2026, 3, 10, 17, 0)]), _t);
      expect(p.where((n) => n.slot == 'workout').length, 1);
    });

    test('дни недели для ручной настройки', () {
      // 10 марта 2026 — вторник; маска только понедельник
      final p = NotificationPlanner.plan(
          _in(ov: const [
            NotifOverride(
                id: 1,
                slot: 'lunch',
                minuteOfDay: 13 * 60,
                weekdaysMask: 1,
                enabled: true)
          ]),
          _t);
      expect(p.map((n) => n.slot), isNot(contains('lunch')));
      expect(parseWeekdays('weekdays'), 31);
      expect(parseWeekdays(['mon', 'wed']), 5);
      expect(parseWeekdays('мусор'), isNull);
    });
  });

  group('ротация текстов', () {
    test('в каждом слоте и тоне достаточно вариантов (5-10)', () {
      for (final tone in NotifTone.all) {
        for (final s in [...NotifSlot.named, NotifSlot.workout]) {
          final n = NotificationTexts.bodies[tone]![s]!.length;
          expect(n, inInclusiveRange(5, 10), reason: '$tone/$s');
        }
      }
    });

    test('подряд идущие дни: текст не повторяется', () {
      for (final tone in NotifTone.all) {
        for (final s in [...NotifSlot.named, NotifSlot.workout]) {
          final list = NotificationTexts.bodies[tone]![s]!;
          int? prev;
          for (var d = 0; d < 60; d++) {
            final i = TextRotator.forDay(
                count: list.length,
                day: DateTime(2026, 3, 1).add(Duration(days: d)),
                seed: NotifSlot.code(s));
            expect(i, isNot(prev), reason: '$tone/$s день $d');
            prev = i;
          }
        }
      }
    });

    test('все варианты рано или поздно показываются', () {
      final list = NotificationTexts.bodies[NotifTone.caring]!['lunch']!;
      final seen = {
        for (var d = 0; d < 30; d++)
          TextRotator.forDay(
              count: list.length, day: DateTime(2026, 3, 1).add(Duration(days: d)))
      };
      expect(seen.length, list.length);
    });

    test('один вариант: не падаем', () {
      expect(TextRotator.forDay(count: 1, day: DateTime(2026, 3, 1)), 0);
    });
  });

  group('сервис уведомлений', () {
    late Env env;
    late FakeGateway gw;
    late NotificationService svc;
    late DiaryService diary;
    late NotificationScheduleRepositoryImpl sched;

    setUp(() async {
      env = Env(DateTime(2026, 3, 10, 6, 0));
      await env.seedProfile();
      gw = FakeGateway();
      diary = DiaryService(DiaryRepositoryImpl(env.db), clock: () => env.now);
      sched = NotificationScheduleRepositoryImpl(env.db, clock: () => env.now);
      svc = NotificationService(
        gateway: gw,
        settings: SettingsRepositoryImpl(env.db, clock: () => env.now),
        schedule: sched,
        memory: env.memory,
        profiles: env.profiles,
        diary: diary,
        clock: () => env.now,
      );
    });
    tearDown(() => env.close());

    test('режим дня из памяти меняет расписание', () async {
      await MemoryService(env.memory, clock: () => env.now).apply([
        const MemoryUpdate(
            key: 'schedule.lunch', fact: '12:00', category: 'schedule'),
      ]);
      await svc.reschedule();
      final lunch = gw.last.firstWhere((n) => n.slot == 'lunch');
      expect(lunch.at.hour * 60 + lunch.at.minute, 12 * 60 + 30);
    });

    test('запись еды убирает сегодняшнее напоминание', () async {
      await svc.reschedule();
      expect(gw.last.any((n) => n.slot == 'lunch' && n.at.day == 10), isTrue);
      await diary.apply(const FoodLogRequest(
          op: 'add', description: 'Борщ', kcal: 500, meal: 'lunch'));
      await svc.reschedule();
      expect(gw.last.any((n) => n.slot == 'lunch' && n.at.day == 10), isFalse);
    });

    test('тон меняет тексты, выключение очищает расписание', () async {
      await svc.reschedule();
      final caring = gw.last.first.body;
      await svc.setTone(NotifTone.strict);
      expect(gw.last.first.body, isNot(caring));
      await svc.setEnabled(false);
      expect(gw.last, isEmpty);
      expect((await svc.prefs()).enabled, isFalse);
    });

    test('неточные будильники, если нет права на точные', () async {
      gw.exactFlag = false;
      await svc.reschedule();
      expect(gw.exactFlag, isFalse);
      expect(gw.replaced, 1);
    });

    test('первый вопрос в чате берётся локально, без модели', () {
      expect(NotificationTexts.openers['lunch'], contains(svc.opener('lunch')));
      expect(NotificationTexts.openers['dinner'],
          contains(svc.opener('dinner')));
      expect(NotificationTexts.openers['lunch']!.first, contains('пообедали'));
      expect(svc.opener('нет_такого'), isNotEmpty);
    });

    test('schedule_notification: слот, custom, лимит, мусор', () async {
      final disp = ActionDispatcher(
        memory: MemoryService(env.memory, clock: () => env.now),
        handlers: [ScheduleNotificationHandler(svc, sched)],
      );
      DispatchContext ctx() => DispatchContext(userMessageId: 1, now: env.now);

      var r = await disp.handle(
          ReplyParser.parse(
              '{"reply":"ок","actions":[{"type":"schedule_notification","slot":"lunch","time":"14:15"}]}'),
          ctx());
      expect(r.footers.single, contains('14:15'));
      expect(
          gw.last
              .where((n) => n.slot == 'lunch')
              .every((n) => n.at.hour == 14 && n.at.minute == 15),
          isTrue);

      // отключение слота
      await disp.handle(
          ReplyParser.parse(
              '{"reply":"ок","actions":[{"type":"schedule_notification","slot":"summary","enabled":false}]}'),
          ctx());
      expect(gw.last.any((n) => n.slot == 'summary'), isFalse);

      // своё напоминание
      r = await disp.handle(
          ReplyParser.parse(
              '{"reply":"ок","actions":[{"type":"schedule_notification","slot":"custom","time":"16:00","text":"Выпить воды"}]}'),
          ctx());
      expect(r.footers.single, contains('16:00'));
      expect(gw.last.any((n) => n.slot == 'custom' && n.body == 'Выпить воды'),
          isTrue);

      // лимит своих напоминаний
      for (var i = 0; i < 6; i++) {
        r = await disp.handle(
            ReplyParser.parse(
                '{"reply":"ок","actions":[{"type":"schedule_notification","slot":"custom","time":"1$i:00","text":"x$i"}]}'),
            ctx());
      }
      expect((await sched.all()).where((o) => o.slot == 'custom').length,
          maxCustomReminders);

      // мусор игнорируется без падения
      r = await disp.handle(
          ReplyParser.parse(
              '{"reply":"ок","actions":[{"type":"schedule_notification","slot":"bogus","time":"1"},{"type":"schedule_notification","slot":"custom","time":"bad","text":"y"}]}'),
          ctx());
      expect(r.footers, isEmpty);
    });
  });
}
