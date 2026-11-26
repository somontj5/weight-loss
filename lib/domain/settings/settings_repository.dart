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

  /// Рацион: '1' — план составлен без полной информации («черновик»).
  static const rationDraft = 'ration.draft';

  /// Рацион: JSON {дата: 'kcal'} — дни, где сумма не сошлась с нормой.
  static const rationMarks = 'ration.marks';
  static const rationLastAttempt = 'ration.last_attempt';
  static const rationLastDeviation = 'ration.last_deviation';

  /// Вес: JSON отложенной записи (скачок ждёт подтверждения человека).
  static const weightPending = 'weight.pending';
  static const weightLastAsked = 'weight.last_asked';
  static const weightGirthsAt = 'weight.girths_at';
}
