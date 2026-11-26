import 'package:drift/drift.dart';
import 'package:weightloss/data/db/app_database.dart';
import 'package:weightloss/domain/notifications/notification_models.dart';
import 'package:weightloss/domain/notifications/notification_schedule_repository.dart';

class NotificationScheduleRepositoryImpl
    implements NotificationScheduleRepository {
  NotificationScheduleRepositoryImpl(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;
  final AppDatabase _db;
  final DateTime Function() _clock;

  NotifOverride _map(NotificationScheduleRow r) => NotifOverride(
    id: r.id,
    slot: r.slot,
    minuteOfDay: r.minuteOfDay,
    weekdaysMask: r.weekdaysMask,
    enabled: r.enabled,
    text: r.slot == NotifSlot.custom ? r.body : null,
  );

  @override
  Future<List<NotifOverride>> all() async =>
      (await _db.select(_db.notificationSchedule).get()).map(_map).toList();

  @override
  Future<void> upsertSlot(
    String slot, {
    int? minuteOfDay,
    int? weekdaysMask,
    bool? enabled,
  }) async {
    final t = _db.notificationSchedule;
    final row = await (_db.select(
      t,
    )..where((r) => r.slot.equals(slot))).getSingleOrNull();
    if (row == null) {
      await _db
          .into(t)
          .insert(
            NotificationScheduleCompanion.insert(
              kind: slot == NotifSlot.workout ? 'workout' : 'meal',
              title: NotifSlot.ru(slot),
              minuteOfDay: minuteOfDay ?? -1,
              weekdaysMask: Value(weekdaysMask ?? 127),
              enabled: Value(enabled ?? true),
              createdBy: const Value('fitty'),
              createdAt: _clock(),
              slot: Value(slot),
            ),
          );
      return;
    }
    await (_db.update(t)..where((r) => r.id.equals(row.id))).write(
      NotificationScheduleCompanion(
        minuteOfDay: minuteOfDay == null
            ? const Value.absent()
            : Value(minuteOfDay),
        weekdaysMask: weekdaysMask == null
            ? const Value.absent()
            : Value(weekdaysMask),
        enabled: enabled == null ? const Value.absent() : Value(enabled),
      ),
    );
  }

  @override
  Future<int?> addCustom({
    required int minuteOfDay,
    required int weekdaysMask,
    required String text,
  }) async {
    final t = _db.notificationSchedule;
    final n = await (_db.select(
      t,
    )..where((r) => r.slot.equals(NotifSlot.custom))).get();
    if (n.length >= maxCustomReminders) return null;
    return _db
        .into(t)
        .insert(
          NotificationScheduleCompanion.insert(
            kind: 'custom',
            title: 'Напоминание',
            body: Value(text),
            minuteOfDay: minuteOfDay,
            weekdaysMask: Value(weekdaysMask),
            createdAt: _clock(),
            slot: const Value(NotifSlot.custom),
          ),
        );
  }

  @override
  Future<void> removeCustom(int id) async {
    await (_db.delete(
      _db.notificationSchedule,
    )..where((r) => r.id.equals(id) & r.slot.equals(NotifSlot.custom))).go();
  }

  @override
  Future<void> setCustomEnabled(int id, bool enabled) async {
    await (_db.update(_db.notificationSchedule)..where((r) => r.id.equals(id)))
        .write(NotificationScheduleCompanion(enabled: Value(enabled)));
  }
}
