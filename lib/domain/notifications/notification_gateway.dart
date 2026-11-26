import 'package:weightloss/domain/notifications/notification_models.dart';

/// Граница с системой: настоящая реализация — на flutter_local_notifications,
/// в тестах подставляется фальшивая.
abstract class NotificationGateway {
  Future<void> init({required void Function(String payload) onTap});

  /// Запрос разрешения (Android 13+). true — разрешено.
  Future<bool> requestPermission();
  Future<bool> hasPermission();

  /// Точные будильники доступны? (без запроса у пользователя)
  Future<bool> canScheduleExact();

  /// Отменяет все наши запланированные и ставит новые.
  Future<void> replaceAll(List<PlannedNotif> items, {required bool exact});

  /// Если приложение открыто нажатием на уведомление (холодный старт).
  Future<String?> launchPayload();
}
