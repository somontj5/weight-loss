import 'package:weightloss/data/db/app_database.dart';
import 'package:weightloss/domain/settings/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._db, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;
  final AppDatabase _db;
  final DateTime Function() _clock;

  @override
  Future<String?> get(String key) async {
    final r = await (_db.select(_db.appSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return r?.value;
  }

  @override
  Future<void> set(String key, String value) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
        AppSettingsCompanion.insert(
            key: key, value: value, updatedAt: _clock()));
  }

  @override
  Future<void> remove(String key) async {
    await (_db.delete(_db.appSettings)..where((t) => t.key.equals(key))).go();
  }
}
