import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import 'package:weightloss/data/db/app_database.dart';

void main() {
  test('миграция v1 → v2 сохраняет старые данные и добавляет новое', () async {
    // Настоящая база версии 1: как её создала часть 1.
    final raw = sql.sqlite3.openInMemory();
    raw.execute('''
      CREATE TABLE diary_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eaten_at INTEGER NOT NULL,
        meal TEXT NOT NULL DEFAULT 'snack',
        description TEXT NOT NULL,
        kcal INTEGER NULL,
        protein_g REAL NULL, fat_g REAL NULL, carbs_g REAL NULL,
        photo_paths_json TEXT NOT NULL DEFAULT '[]',
        source TEXT NOT NULL DEFAULT 'chat_text',
        message_id INTEGER NULL,
        created_at INTEGER NOT NULL
      );
      CREATE TABLE notification_schedule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kind TEXT NOT NULL, title TEXT NOT NULL,
        body TEXT NOT NULL DEFAULT '',
        minute_of_day INTEGER NOT NULL,
        weekdays_mask INTEGER NOT NULL DEFAULT 127,
        one_off_at INTEGER NULL,
        enabled INTEGER NOT NULL DEFAULT 1,
        created_by TEXT NOT NULL DEFAULT 'fitty',
        created_at INTEGER NOT NULL
      );
      INSERT INTO diary_entries (eaten_at, meal, description, kcal, created_at)
        VALUES (1700000000, 'lunch', 'Борщ', 320, 1700000000);
      INSERT INTO notification_schedule (kind, title, minute_of_day, created_at)
        VALUES ('meal', 'Обед', 780, 1700000000);
      PRAGMA user_version = 1;
    ''');

    final db = AppDatabase(NativeDatabase.opened(raw));
    addTearDown(db.close);

    final e = await db.select(db.diaryEntries).getSingle();
    expect(e.description, 'Борщ');
    expect(e.kcal, 320);
    expect(e.offPlan, isFalse);
    expect(e.note, isNull);

    final n = await db.select(db.notificationSchedule).getSingle();
    expect(n.title, 'Обед');
    expect(n.minuteOfDay, 780);
    expect(n.slot, 'custom');

    // новая таблица работает
    await db.into(db.appSettings).insert(AppSettingsCompanion.insert(
        key: 'activity.level', value: 'light', updatedAt: DateTime(2026)));
    expect((await db.select(db.appSettings).getSingle()).value, 'light');
    expect(AppDatabase.dbSchemaVersion, 3);
  });
}
