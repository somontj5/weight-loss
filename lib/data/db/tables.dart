import 'package:drift/drift.dart';

/// Все таблицы создаются сразу (в том числе для части 2), чтобы потом
/// не делать миграций. Время хранится как DateTime (UTC-совместимо).

/// Профиль человека: всегда одна строка с id = 1.
@DataClassName('ProfilesRow')
class Profiles extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().withDefault(const Constant(''))();

  /// 'female' | 'male'
  TextColumn get sex => text().withDefault(const Constant('female'))();
  IntColumn get birthYear => integer().withDefault(const Constant(1990))();
  RealColumn get heightCm => real().withDefault(const Constant(170))();
  RealColumn get weightKg => real().withDefault(const Constant(70))();
  RealColumn get targetWeightKg => real().withDefault(const Constant(65))();
  RealColumn get waistCm => real().nullable()();
  RealColumn get chestCm => real().nullable()();
  RealColumn get hipsCm => real().nullable()();

  /// Сколько минут в день человек готов отдавать тренировкам.
  IntColumn get trainingMinutes => integer().withDefault(const Constant(20))();

  /// 'morning' | 'day' | 'evening'
  TextColumn get trainingSlot => text().withDefault(const Constant('evening'))();
  BoolColumn get onboardingDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// История изменений цифр: снимок при каждом изменении.
@DataClassName('ProfileHistoryRow')
class ProfileHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get recordedAt => dateTime()();
  RealColumn get weightKg => real()();
  RealColumn get targetWeightKg => real()();
  RealColumn get heightCm => real()();
  RealColumn get waistCm => real().nullable()();
  RealColumn get chestCm => real().nullable()();
  RealColumn get hipsCm => real().nullable()();

  /// 'onboarding' | 'settings' | 'chat' | 'workout'
  TextColumn get source => text().withDefault(const Constant('settings'))();
}

@DataClassName('GoalsRow')
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get startWeightKg => real()();
  RealColumn get targetWeightKg => real()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get targetDate => dateTime()();
  IntColumn get weeks => integer()();

  /// 'active' | 'archived'
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('MemoryFactsRow')
class MemoryFacts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Стабильный ключ темы, например «intolerance.lactose». Один ключ —
  /// один актуальный факт.
  TextColumn get key => text()();
  TextColumn get fact => text()();

  /// lifestyle | schedule | intolerance | food | budget | health | habit |
  /// motivation | obstacle | other
  TextColumn get category => text().withDefault(const Constant('other'))();
  RealColumn get confidence => real().withDefault(const Constant(0.8))();

  /// 'active' | 'superseded'
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get supersededBy => integer().nullable()();
  IntColumn get sourceMessageId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('DietPlansRow')
class DietPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get kcalTarget => integer()();
  IntColumn get proteinG => integer()();
  IntColumn get fatG => integer()();
  IntColumn get carbsG => integer()();
  IntColumn get bmr => integer()();
  IntColumn get tdee => integer()();
  IntColumn get deficitKcal => integer()();
  RealColumn get weeklyLossKg => real()();

  /// Допустимое отклонение от нормы в день (± ккал).
  IntColumn get toleranceKcal => integer().withDefault(const Constant(100))();

  /// Предупреждения и заметки о расчёте (JSON-массив строк).
  TextColumn get notesJson => text().withDefault(const Constant('[]'))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

/// Заполняется в части 2.
@DataClassName('DiaryEntriesRow')
class DiaryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get eatenAt => dateTime()();

  /// breakfast | lunch | dinner | snack
  TextColumn get meal => text().withDefault(const Constant('snack'))();
  TextColumn get description => text()();

  /// Калории «примерно».
  IntColumn get kcal => integer().nullable()();
  RealColumn get proteinG => real().nullable()();
  RealColumn get fatG => real().nullable()();
  RealColumn get carbsG => real().nullable()();
  TextColumn get photoPathsJson => text().withDefault(const Constant('[]'))();

  /// chat_text | chat_photo | chat_voice | manual
  TextColumn get source => text().withDefault(const Constant('chat_text'))();
  IntColumn get messageId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  /// (v2) Еда вне плана: человек сам или Фитти пометили приём как «срыв».
  BoolColumn get offPlan => boolean().withDefault(const Constant(false))();

  /// (v3) Связь с пунктом рациона (meal_plan_items.id), если Фитти её указал.
  IntColumn get planItemId => integer().nullable()();

  /// (v2) Короткая заметка к записи.
  TextColumn get note => text().nullable()();
}

/// Заполняется в части 2.
@DataClassName('WorkoutsRow')
class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  TextColumn get title => text()();
  TextColumn get planJson => text().withDefault(const Constant('{}'))();

  /// coach | local | manual
  TextColumn get source => text().withDefault(const Constant('coach'))();

  /// planned | done | skipped
  TextColumn get status => text().withDefault(const Constant('planned'))();
}

/// Заполняется в части 2.
@DataClassName('WorkoutResultsRow')
class WorkoutResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutId => integer().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();

  /// completed | aborted | skipped
  TextColumn get status => text()();
  IntColumn get doneExercises => integer().withDefault(const Constant(0))();
  IntColumn get skippedExercises => integer().withDefault(const Constant(0))();
  IntColumn get pauses => integer().withDefault(const Constant(0))();
  IntColumn get pausedSeconds => integer().withDefault(const Constant(0))();
  IntColumn get durationSec => integer().withDefault(const Constant(0))();
  IntColumn get kcal => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
}

/// Заполняется в части 2.
@DataClassName('NotificationScheduleRow')
class NotificationSchedule extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// meal | water | workout | weigh_in | custom
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get body => text().withDefault(const Constant(''))();

  /// Минуты от полуночи (локальное время).
  IntColumn get minuteOfDay => integer()();

  /// Битовая маска дней недели (bit0 = Пн … bit6 = Вс); 127 = каждый день.
  IntColumn get weekdaysMask => integer().withDefault(const Constant(127))();
  DateTimeColumn get oneOffAt => dateTime().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  /// user | fitty
  TextColumn get createdBy => text().withDefault(const Constant('fitty'))();
  DateTimeColumn get createdAt => dateTime()();

  /// (v2) breakfast | lunch | dinner | summary | workout | custom
  TextColumn get slot => text().withDefault(const Constant('custom'))();
}

/// (v2) Простые настройки «ключ → значение»: уровень активности,
/// будущие настройки уведомлений (часть 2Б).
@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('MessagesRow')
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 'user' | 'fitty'
  TextColumn get role => text()();

  /// 'chat' | 'notice' (служебные сообщения не попадают в контекст модели)
  TextColumn get kind => text().withDefault(const Constant('chat'))();
  TextColumn get body => text().withDefault(const Constant(''))();
  TextColumn get imagesJson => text().withDefault(const Constant('[]'))();
  TextColumn get audioPath => text().nullable()();
  IntColumn get audioMs => integer().withDefault(const Constant(0))();
  TextColumn get waveformJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();

  /// Если сообщение уже сжато в резюме — id резюме.
  IntColumn get summaryId => integer().nullable()();
}

@DataClassName('ConversationSummariesRow')
class ConversationSummaries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get fromTime => dateTime()();
  DateTimeColumn get toTime => dateTime()();
  TextColumn get body => text()();
  IntColumn get messageCount => integer().withDefault(const Constant(0))();
}

/// Счётчик запросов к модели по дням (день — по тихоокеанскому времени,
/// как сбрасывает лимиты Google).
@DataClassName('ApiUsageRow')
class ApiUsage extends Table {
  TextColumn get day => text()();
  TextColumn get model => text()();
  IntColumn get count => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {day, model};
}

/// (v3) Рацион: пункты плана питания на дни вперёд.
@DataClassName('MealPlanItemsRow')
class MealPlanItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Начало дня (локальная полночь).
  DateTimeColumn get date => dateTime()();

  /// breakfast | snack | lunch | afternoon_snack | dinner
  TextColumn get meal => text()();

  /// «ЧЧ:ММ».
  TextColumn get time => text().withDefault(const Constant('12:00'))();
  TextColumn get title => text()();

  /// JSON-список строк: состав блюда.
  TextColumn get compositionJson => text().withDefault(const Constant('[]'))();
  IntColumn get kcal => integer()();
  RealColumn get proteinG => real().withDefault(const Constant(0))();
  RealColumn get fatG => real().withDefault(const Constant(0))();
  RealColumn get carbsG => real().withDefault(const Constant(0))();

  /// planned | eaten | skipped | replaced
  TextColumn get status => text().withDefault(const Constant('planned'))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
