/// Простые настройки «ключ → значение» (таблица app_settings).
abstract class SettingsRepository {
  Future<String?> get(String key);
  Future<void> set(String key, String value);
  Future<void> remove(String key);
}

class SettingKeys {
  /// sedentary | light | moderate | high
  static const activityLevel = 'activity.level';

  /// Сколько уточняющих вопросов Фитти задал подряд (считает код).
  static const clarifyStreak = 'food.clarify_streak';
}
