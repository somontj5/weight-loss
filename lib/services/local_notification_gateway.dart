import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:weightloss/domain/notifications/notification_gateway.dart';
import 'package:weightloss/domain/notifications/notification_models.dart';

/// Настоящие локальные уведомления Android. Без сервера и без оплаты.
class LocalNotificationGateway implements NotificationGateway {
  final FlutterLocalNotificationsPlugin _p = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  AndroidFlutterLocalNotificationsPlugin? get _android => _p
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  static const _channel = AndroidNotificationDetails(
    'fitty_reminders',
    'Напоминания Фитти',
    channelDescription: 'Напоминания о еде, итогах дня и тренировках',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  @override
  Future<void> init({required void Function(String payload) onTap}) async {
    if (_ready || kIsWeb) return;
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.UTC);
      await _p.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (r) {
          final pl = r.payload;
          if (pl != null && pl.isNotEmpty) onTap(pl);
        },
      );
      _ready = true;
    } catch (e) {
      if (kDebugMode) debugPrint('notifications init: $e');
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (!_ready) return false;
    try {
      return await _android?.requestNotificationsPermission() ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasPermission() async {
    if (!_ready) return false;
    try {
      return await _android?.areNotificationsEnabled() ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> canScheduleExact() async {
    if (!_ready) return false;
    try {
      return await _android?.canScheduleExactNotifications() ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> replaceAll(
    List<PlannedNotif> items, {
    required bool exact,
  }) async {
    if (!_ready) return;
    try {
      await _p.cancelAll();
    } catch (_) {}
    for (final n in items) {
      final when = tz.TZDateTime.from(n.at, tz.UTC);
      Future<void> go(AndroidScheduleMode mode) => _p.zonedSchedule(
        n.id,
        n.title,
        n.body,
        when,
        const NotificationDetails(android: _channel),
        androidScheduleMode: mode,
        payload: n.payload,
      );
      try {
        await go(
          exact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } on PlatformException {
        // нет права на точные будильники: ставим неточное
        try {
          await go(AndroidScheduleMode.inexactAllowWhileIdle);
        } catch (_) {}
      } catch (_) {}
    }
  }

  @override
  Future<String?> launchPayload() async {
    if (!_ready) return null;
    try {
      final d = await _p.getNotificationAppLaunchDetails();
      if (d?.didNotificationLaunchApp ?? false) {
        return d!.notificationResponse?.payload;
      }
    } catch (_) {}
    return null;
  }
}
