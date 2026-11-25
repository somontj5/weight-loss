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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  static const dbSchemaVersion = 1;

  @override
  int get schemaVersion => dbSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
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
