/// Слоты напоминаний.
class NotifSlot {
  static const breakfast = 'breakfast';
  static const lunch = 'lunch';
  static const dinner = 'dinner';
  static const summary = 'summary';
  static const workout = 'workout';
  static const weigh = 'weigh';
  static const planReady = 'plan_ready';
  static const custom = 'custom';

  /// Слоты, которые пользователь может настраивать по имени.
  static const named = [breakfast, lunch, dinner, summary];
  static const meals = [breakfast, lunch, dinner];

  static bool isValid(String? s) =>
      s == custom ||
      s == workout ||
      s == weigh ||
      s == planReady ||
      named.contains(s);

  static String ru(String slot) => switch (slot) {
    breakfast => 'завтрак',
    lunch => 'обед',
    dinner => 'ужин',
    summary => 'вечерний итог',
    workout => 'тренировка',
    weigh => 'взвешивание',
    planReady => 'план на завтра',
    _ => 'напоминание',
  };

  /// Код слота для стабильного id уведомления.
  static int code(String slot) => switch (slot) {
    breakfast => 1,
    lunch => 2,
    dinner => 3,
    summary => 4,
    workout => 5,
    weigh => 6,
    planReady => 7,
    _ => 9,
  };

  /// Меньше число — важнее при отборе под дневной лимит.
  static int priority(String slot) => switch (slot) {
    custom => 0,
    lunch => 1,
    workout => 2,
    dinner => 3,
    breakfast => 4,
    weigh => 5,
    summary => 5,
    planReady => 6,
    _ => 9,
  };
}

class NotifTone {
  static const caring = 'caring';
  static const playful = 'playful';
  static const strict = 'strict';
  static const all = [caring, playful, strict];

  static String normalize(String? t) => all.contains(t) ? t! : caring;

  static String ru(String t) => switch (t) {
    playful => 'Шутливый',
    strict => 'Строгий',
    _ => 'Заботливый',
  };
}

/// Настройки уведомлений (хранятся в app_settings).
class NotifPrefs {
  const NotifPrefs({
    this.enabled = true,
    this.tone = NotifTone.caring,
    this.maxPerDay = 4,
    this.quietFromMin = 22 * 60 + 30,
    this.quietToMin = 7 * 60 + 30,
  });

  final bool enabled;
  final String tone;

  /// Не больше стольких уведомлений в день (всего).
  final int maxPerDay;

  /// Тихие часы («не беспокоить»): с … до … (минуты от полуночи).
  final int quietFromMin;
  final int quietToMin;

  NotifPrefs copyWith({
    bool? enabled,
    String? tone,
    int? maxPerDay,
    int? quietFromMin,
    int? quietToMin,
  }) => NotifPrefs(
    enabled: enabled ?? this.enabled,
    tone: tone ?? this.tone,
    maxPerDay: maxPerDay ?? this.maxPerDay,
    quietFromMin: quietFromMin ?? this.quietFromMin,
    quietToMin: quietToMin ?? this.quietToMin,
  );

  bool inQuiet(int minuteOfDay) {
    if (quietFromMin == quietToMin) return false;
    if (quietFromMin > quietToMin) {
      return minuteOfDay >= quietFromMin || minuteOfDay < quietToMin;
    }
    return minuteOfDay >= quietFromMin && minuteOfDay < quietToMin;
  }
}

/// Ручная настройка пользователя (или Фитти по просьбе человека):
/// строка notification_schedule.
class NotifOverride {
  const NotifOverride({
    required this.id,
    required this.slot,
    required this.minuteOfDay,
    required this.weekdaysMask,
    required this.enabled,
    this.text,
  });

  final int id;
  final String slot;
  final int minuteOfDay;

  /// bit0 = Пн … bit6 = Вс.
  final int weekdaysMask;
  final bool enabled;

  /// Только для custom.
  final String? text;

  bool runsOn(DateTime day) => weekdaysMask & (1 << (day.weekday - 1)) != 0;
}

/// Вход планировщика: что известно о режиме дня и о том, что уже записано.
class PlanInput {
  static String dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  const PlanInput({
    required this.now,
    required this.prefs,
    this.wakeUpMin,
    this.bedtimeMin,
    this.breakfastMin,
    this.lunchMin,
    this.dinnerMin,
    this.overrides = const [],
    this.loggedMealsToday = const {},
    this.workouts = const [],
    this.planTimes = const {},
    this.planDays = const {},
    this.lastWeighAt,
    this.days = 7,
  });

  final DateTime now;
  final NotifPrefs prefs;
  final int? wakeUpMin;
  final int? bedtimeMin;
  final int? breakfastMin;
  final int? lunchMin;
  final int? dinnerMin;
  final List<NotifOverride> overrides;

  /// breakfast | lunch | dinner, уже записанные СЕГОДНЯ.
  final Set<String> loggedMealsToday;

  /// Запланированные тренировки (время начала).
  final List<DateTime> workouts;

  /// Время приёмов из рациона: 'ГГГГ-М-Д' -> {слот: минуты}. Слоты
  /// breakfast / lunch / dinner (из рациона берётся время еды).
  final Map<String, Map<String, int>> planTimes;

  /// Дни ('ГГГГ-М-Д'), на которые рацион уже составлен.
  final Set<String> planDays;

  /// Дата последнего взвешивания (null — взвешиваний нет).
  final DateTime? lastWeighAt;

  /// На сколько дней вперёд (включая сегодня).
  final int days;
}

class PlannedNotif {
  const PlannedNotif({
    required this.id,
    required this.slot,
    required this.at,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String slot;
  final DateTime at;
  final String title;
  final String body;

  /// «slot|yyyy-mm-dd|customId» — по нему открывается чат.
  final String payload;
}
