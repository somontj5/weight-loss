import 'package:weightloss/domain/notifications/notification_gateway.dart';
import 'package:weightloss/domain/notifications/notification_models.dart';
import 'package:weightloss/domain/notifications/notification_planner.dart';
import 'package:weightloss/domain/notifications/notification_schedule_repository.dart';
import 'package:weightloss/domain/notifications/notification_texts.dart';
import 'package:weightloss/domain/diary/diary_service.dart';
import 'package:weightloss/domain/repositories/repositories.dart';
import 'package:weightloss/domain/settings/settings_repository.dart';

class NotifKeys {
  static const enabled = 'notif.enabled';
  static const tone = 'notif.tone';
  static const maxPerDay = 'notif.max_per_day';
  static const quietFrom = 'notif.quiet_from';
  static const quietTo = 'notif.quiet_to';
  static const askedPermission = 'notif.asked_permission';
  static const lastOpened = 'notif.last_opened';
}

/// Управляет расписанием: читает режим дня, настройки и дневник,
/// считает план (NotificationPlanner) и отдаёт его системе.
class NotificationService {
  NotificationService({
    required this.gateway,
    required this.settings,
    required this.schedule,
    required this.memory,
    required this.profiles,
    required this.diary,

    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final NotificationGateway gateway;
  final SettingsRepository settings;
  final NotificationScheduleRepository schedule;
  final MemoryRepository memory;
  final ProfileRepository profiles;
  final DiaryService diary;

  /// Времена запланированных тренировок (подключается тренером).
  Future<List<DateTime>> Function()? plannedWorkouts;

  /// Время приёмов и дни рациона (подключается рационом).
  Future<({Map<String, Map<String, int>> times, Set<String> days})> Function()?
  rationInfo;

  /// Дата последнего взвешивания.
  Future<DateTime?> Function()? lastWeighAt;
  final DateTime Function() _clock;

  /// Вызывается при нажатии на уведомление (slot).
  void Function(String slot)? onOpenSlot;

  Future<void> init() async {
    await gateway.init(onTap: _handlePayload);
    final launch = await gateway.launchPayload();
    if (launch != null) _handlePayload(launch);
    await reschedule();
  }

  void _handlePayload(String payload) {
    final slot = payload.split('|').first;
    if (!NotifSlot.isValid(slot)) return;
    onOpenSlot?.call(slot);
  }

  // ───────── настройки ─────────

  Future<NotifPrefs> prefs() async {
    int? i(String? s) => int.tryParse(s ?? '');
    const d = NotifPrefs();
    final en = await settings.get(NotifKeys.enabled);
    return NotifPrefs(
      enabled: en == null ? d.enabled : en == '1',
      tone: NotifTone.normalize(await settings.get(NotifKeys.tone)),
      maxPerDay: (i(await settings.get(NotifKeys.maxPerDay)) ?? d.maxPerDay)
          .clamp(1, 8),
      quietFromMin:
          i(await settings.get(NotifKeys.quietFrom)) ?? d.quietFromMin,
      quietToMin: i(await settings.get(NotifKeys.quietTo)) ?? d.quietToMin,
    );
  }

  Future<void> setEnabled(bool v) async {
    await settings.set(NotifKeys.enabled, v ? '1' : '0');
    await reschedule();
  }

  Future<void> setTone(String tone) async {
    await settings.set(NotifKeys.tone, NotifTone.normalize(tone));
    await reschedule();
  }

  /// Спрашивает разрешение один раз (Android 13+). true — разрешено.
  Future<bool> ensurePermission({bool force = false}) async {
    if (await gateway.hasPermission()) return true;
    final asked = await settings.get(NotifKeys.askedPermission) == '1';
    if (asked && !force) return false;
    await settings.set(NotifKeys.askedPermission, '1');
    return gateway.requestPermission();
  }

  // ───────── расписание ─────────

  Future<int?> _mem(String key) async =>
      NotificationPlanner.parseTime((await memory.activeByKey(key))?.fact);

  Future<PlanInput> buildInput() async {
    final now = _clock();
    final today = await diary.day(now);
    final workouts = <DateTime>[];
    try {
      workouts.addAll(await plannedWorkouts?.call() ?? const []);
    } catch (_) {}
    var planTimes = <String, Map<String, int>>{};
    var planDays = <String>{};
    DateTime? lw;
    try {
      final r = await rationInfo?.call();
      if (r != null) {
        planTimes = r.times;
        planDays = r.days;
      }
    } catch (_) {}
    try {
      lw = await lastWeighAt?.call();
    } catch (_) {}
    return PlanInput(
      planTimes: planTimes,
      planDays: planDays,
      lastWeighAt: lw,
      now: now,
      prefs: await prefs(),
      wakeUpMin: await _mem('schedule.wake_up'),
      bedtimeMin: await _mem('schedule.bedtime'),
      breakfastMin: await _mem('schedule.breakfast'),
      lunchMin: await _mem('schedule.lunch'),
      dinnerMin: await _mem('schedule.dinner'),
      overrides: await schedule.all(),
      loggedMealsToday: {for (final e in today) e.meal},
      workouts: workouts,
    );
  }

  PlannedText pickText(String tone, String slot, DateTime at, String? custom) {
    if (slot == NotifSlot.custom &&
        custom != null &&
        custom.trim().isNotEmpty) {
      return PlannedText(
        NotificationTexts.titles[NotifSlot.custom]!,
        custom.trim(),
      );
    }
    final list =
        NotificationTexts.bodies[tone]?[slot] ??
        NotificationTexts.bodies[NotifTone.caring]![slot]!;
    final idx = TextRotator.forDay(
      count: list.length,
      day: at,
      seed: NotifSlot.code(slot),
    );
    return PlannedText(NotificationTexts.titles[slot] ?? 'Фитти', list[idx]);
  }

  /// План для текущего состояния (без отправки в систему; для тестов).
  Future<List<PlannedNotif>> buildPlan() async {
    final input = await buildInput();
    return NotificationPlanner.plan(input, (slot, at, id, text) {
      final t = pickText(input.prefs.tone, slot, at, text);
      return (title: t.title, body: t.body);
    });
  }

  /// Пересоздаёт расписание. Вызывать при смене режима дня, записи еды,
  /// настроек и появлении тренировки. Никогда не бросает исключений.
  Future<void> reschedule() async {
    try {
      final plan = await buildPlan();
      final exact = await gateway.canScheduleExact();
      await gateway.replaceAll(plan, exact: exact);
    } catch (_) {}
  }

  /// Первый вопрос Фитти после нажатия на уведомление: без обращения к модели.
  String opener(String slot, {DateTime? at}) {
    final list =
        NotificationTexts.openers[slot] ??
        NotificationTexts.openers[NotifSlot.custom]!;
    final d = at ?? _clock();
    return list[TextRotator.forDay(count: list.length, day: d, seed: 7)];
  }
}

class PlannedText {
  const PlannedText(this.title, this.body);
  final String title;
  final String body;
}
