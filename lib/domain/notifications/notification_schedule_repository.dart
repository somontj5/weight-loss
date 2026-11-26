import 'package:weightloss/domain/notifications/notification_models.dart';

abstract class NotificationScheduleRepository {
  Future<List<NotifOverride>> all();

  /// Ставит (или меняет) настройку именованного слота.
  Future<void> upsertSlot(
    String slot, {
    int? minuteOfDay,
    int? weekdaysMask,
    bool? enabled,
  });

  /// Новое пользовательское напоминание. null — достигнут лимит.
  Future<int?> addCustom({
    required int minuteOfDay,
    required int weekdaysMask,
    required String text,
  });

  Future<void> removeCustom(int id);
  Future<void> setCustomEnabled(int id, bool enabled);
}

const maxCustomReminders = 5;
