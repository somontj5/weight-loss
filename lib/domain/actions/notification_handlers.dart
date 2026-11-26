import 'package:weightloss/domain/actions/action_dispatcher.dart';
import 'package:weightloss/domain/notifications/notification_models.dart';
import 'package:weightloss/domain/notifications/notification_planner.dart';
import 'package:weightloss/domain/notifications/notification_schedule_repository.dart';
import 'package:weightloss/domain/notifications/notification_service.dart';

const _days = {
  'mon': 0,
  'tue': 1,
  'wed': 2,
  'thu': 3,
  'fri': 4,
  'sat': 5,
  'sun': 6,
  'пн': 0,
  'вт': 1,
  'ср': 2,
  'чт': 3,
  'пт': 4,
  'сб': 5,
  'вс': 6,
};

/// «mon,tue» / [0,1] / «daily» → маска; null — не удалось разобрать.
int? parseWeekdays(Object? v) {
  if (v == null) return 127;
  if (v is String) {
    final s = v.trim().toLowerCase();
    if (s.isEmpty || s == 'daily' || s == 'all' || s == 'ежедневно') return 127;
    if (s == 'weekdays' || s == 'будни') return 31;
    if (s == 'weekend' || s == 'выходные') return 96;
    return parseWeekdays(
      s.split(RegExp(r'[,\s]+')).where((e) => e.isNotEmpty).toList(),
    );
  }
  if (v is List) {
    var mask = 0;
    for (final e in v) {
      int? bit;
      if (e is num && e >= 0 && e <= 6) bit = e.toInt();
      if (e is num && e >= 1 && e <= 7) bit = e.toInt() - 1;
      if (e is String) {
        bit =
            _days[e.trim().toLowerCase()] ??
            _days[e.trim().toLowerCase().substring(
              0,
              e.trim().length < 2 ? e.trim().length : 2,
            )];
      }
      if (bit != null) mask |= 1 << bit;
    }
    return mask == 0 ? null : mask;
  }
  return null;
}

/// schedule_notification: slot, time, days, text (для custom), enabled.
class ScheduleNotificationHandler extends ActionHandler {
  ScheduleNotificationHandler(this.service, this.repo);
  final NotificationService service;
  final NotificationScheduleRepository repo;

  @override
  String get type => 'schedule_notification';

  @override
  Future<String?> handle(Map<String, dynamic> data, DispatchContext ctx) async {
    final slot = (data['slot']?.toString() ?? NotifSlot.custom).trim();
    if (!NotifSlot.isValid(slot) || slot == NotifSlot.workout) return null;
    final time = NotificationPlanner.parseTime(data['time']?.toString());
    final mask = parseWeekdays(data['days']) ?? 127;
    final enabled = data['enabled'] is bool ? data['enabled'] as bool : true;

    String? line;
    if (slot == NotifSlot.custom) {
      final text = data['text']?.toString().trim() ?? '';
      if (text.isEmpty || time == null) return null;
      final clipped = text.length > 120 ? text.substring(0, 120) : text;
      if (!enabled) return null;
      final id = await repo.addCustom(
        minuteOfDay: time,
        weekdaysMask: mask,
        text: clipped,
      );
      if (id == null) {
        line =
            'Напоминаний уже много (не больше $maxCustomReminders), новое не создал.';
      } else {
        line = 'Поставил напоминание на ${_hm(time)}.';
      }
    } else {
      await repo.upsertSlot(
        slot,
        minuteOfDay: time,
        weekdaysMask: data['days'] == null ? null : mask,
        enabled: enabled,
      );
      line = enabled
          ? 'Напоминание (${NotifSlot.ru(slot)})${time != null ? ' теперь в ${_hm(time)}' : ' включено'}.'
          : 'Напоминание (${NotifSlot.ru(slot)}) выключил.';
    }
    await service.reschedule();
    return line;
  }

  static String _hm(int m) =>
      '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
}
