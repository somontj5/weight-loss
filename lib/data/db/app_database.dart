import 'package:drift/drift.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Profiles,
  ProfileHistory,
  Goals,
  MemoryFacts,
  DietPlans,
  DiaryEntries,
  Workouts,
  WorkoutResults,
  NotificationSchedule,
  Messages,
  ConversationSummaries,
  ApiUsage,
  AppSettings,
  MealPlanItems,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  static const dbSchemaVersion = 3;

  @override
  int get schemaVersion => dbSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Только добавляем: данные пользователя не трогаем.
          if (from < 2) {
            await m.addColumn(diaryEntries, diaryEntries.offPlan);
            await m.addColumn(diaryEntries, diaryEntries.note);
            await m.addColumn(notificationSchedule, notificationSchedule.slot);
            await m.createTable(appSettings);
          }
          if (from < 3) {
            await m.createTable(mealPlanItems);
            await m.addColumn(diaryEntries, diaryEntries.planItemId);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Полное удаление всех данных.
  Future<void> wipeAll() async {
    await transaction(() async {
      for (final t in allTables) {
        await delete(t).go();
      }
    });
  }
}
