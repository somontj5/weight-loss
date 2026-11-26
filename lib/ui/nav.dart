import 'package:flutter/foundation.dart';

/// Выбранная вкладка нижней навигации (0 — чат, 1 — тренировка).
/// Нужна, чтобы нажатие на уведомление открывало чат.
final ValueNotifier<int> homeTab = ValueNotifier<int>(0);
