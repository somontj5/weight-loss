import 'package:weightloss/config/ai_config.dart';
import 'package:weightloss/data/repositories/usage_repository.dart';

/// Дневной счётчик запросов по каждой модели и выбор модели.
/// Google сбрасывает бесплатные лимиты в полночь по тихоокеанскому времени,
/// поэтому «день» считаем по нему.
class QuotaManager {
  QuotaManager(this._usage, this._config, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final UsageRepository _usage;
  final AiConfig _config;
  final DateTime Function() _clock;

  /// Ключ дня по тихоокеанскому времени (учтён переход на летнее время США).
  static String pacificDay(DateTime now) {
    final utc = now.toUtc();
    final pt = utc.add(Duration(hours: _isUsDst(utc) ? -7 : -8));
    String two(int v) => v.toString().padLeft(2, '0');
    return '${pt.year}-${two(pt.month)}-${two(pt.day)}';
  }

  // DST в США: со 2-го воскресенья марта (10:00 UTC) до 1-го воскресенья
  // ноября (09:00 UTC).
  static bool _isUsDst(DateTime utc) {
    DateTime nthSunday(int month, int n, int hourUtc) {
      var d = DateTime.utc(utc.year, month, 1, hourUtc);
      while (d.weekday != DateTime.sunday) {
        d = d.add(const Duration(days: 1));
      }
      return d.add(Duration(days: 7 * (n - 1)));
    }

    final start = nthSunday(3, 2, 10);
    final end = nthSunday(11, 1, 9);
    return !utc.isBefore(start) && utc.isBefore(end);
  }

  String get today => pacificDay(_clock());

  int _effectiveLimit(ModelQuota m) =>
      (m.dailyLimit - _config.safetyMargin).clamp(1, m.dailyLimit);

  Future<int> used(String model) => _usage.count(today, model);

  Future<int> remaining(ModelQuota m) async =>
      (_effectiveLimit(m) - await used(m.name)).clamp(0, m.dailyLimit);

  /// Модели, у которых ещё есть лимит, в порядке приоритета.
  Future<List<ModelQuota>> available() async {
    final out = <ModelQuota>[];
    for (final m in _config.models) {
      if (await remaining(m) > 0) out.add(m);
    }
    return out;
  }

  Future<void> recordSuccess(String model) => _usage.increment(today, model);

  /// Сервер сказал, что дневной лимит кончился.
  Future<void> markExhausted(ModelQuota m) =>
      _usage.setAtLeast(today, m.name, _effectiveLimit(m));

  Future<Map<String, int>> remainingByModel() async => {
        for (final m in _config.models) m.name: await remaining(m),
      };
}
