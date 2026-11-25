import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weightloss/data/db/app_database.dart';

/// Экспорт всех данных одним JSON и полное удаление.
class DataExportService {
  DataExportService(this._db);
  final AppDatabase _db;

  static const formatVersion = 1;

  Future<Map<String, dynamic>> buildExport() async {
    final tables = <String, dynamic>{};
    for (final t in _db.allTables) {
      final rows = await _db.select(t).get();
      tables[t.actualTableName] = [
        for (final r in rows)
          (r as dynamic).toJson(
              serializer: const ValueSerializer.defaults()) as Map<String, dynamic>
      ];
    }
    return {
      'app': 'FITTY',
      'formatVersion': formatVersion,
      'schemaVersion': AppDatabase.dbSchemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'tables': tables,
    };
  }

  /// Пишет файл во временную папку и возвращает путь.
  Future<File> exportToFile() async {
    final data = await buildExport();
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().substring(0, 10);
    final f = File(p.join(dir.path, 'fitty-export-$stamp.json'));
    await f.writeAsString(const JsonEncoder.withIndent(' ').convert(data));
    return f;
  }

  /// Полностью стирает базу, настройки и сохранённые фото/голосовые.
  Future<void> wipeEverything() async {
    await _db.wipeAll();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
    try {
      final tmp = await getTemporaryDirectory();
      if (await tmp.exists()) {
        for (final e in tmp.listSync()) {
          try {
            e.deleteSync(recursive: true);
          } catch (_) {}
        }
      }
    } catch (_) {}
  }
}
