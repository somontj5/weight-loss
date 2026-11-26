import 'package:weightloss/data/exercise_catalog.dart';
import 'package:weightloss/models/workout.dart';

/// Результат технической проверки плана Фитти.
class ValidatedPlan {
  const ValidatedPlan({
    required this.workout,
    required this.scheduledAt,
    required this.difficulty,
    this.droppedUnknown = 0,
    this.trimmed = false,
    this.timeMoved = false,
  });

  final Workout workout;
  final DateTime scheduledAt;
  final int difficulty;

  /// Сколько id не нашлось в каталоге (отброшены).
  final int droppedUnknown;

  /// Упражнения в конце убраны, чтобы уложиться в потолок по времени.
  final bool trimmed;

  /// Время пришлось перенести (прошлое, дальше 48 часов, тихие часы).
  final bool timeMoved;
}

/// ТОЛЬКО техническая проверка плана от Фитти. Никаких решений о том, нужна
/// ли тренировка, какой сложности и из чего: всё это решает Фитти.
/// Проверяем: id есть в каталоге, длительности в границах, общий потолок
/// по времени, время не в прошлом, не дальше 48 часов и не в тихие часы.
class PlanValidator {
  static const minWorkSec = 20;
  static const maxWorkSec = 90;
  static const minRestSec = 0;
  static const maxRestSec = 60;
  static const maxTotalSec = 60 * 60;
  static const horizon = Duration(hours: 48);
  static const defaultWorkSec = 40;
  static const defaultRestSec = 20;

  static int _int(Object? v, int d) =>
      v is num ? v.round() : (int.tryParse('${v ?? ''}'.trim()) ?? d);

  static Exercise _make(ExerciseTemplate t, int work, int rest) => Exercise(
    id: t.id,
    name: t.name,
    description: t.description,
    tips: t.tips,
    muscleGroup: t.muscle,
    durationSec: work.clamp(minWorkSec, maxWorkSec),
    restSec: rest.clamp(minRestSec, maxRestSec),
    met: t.met,
  );

  static int total(List<Exercise> l) {
    var t = 0;
    for (var i = 0; i < l.length; i++) {
      t += l[i].durationSec;
      if (i < l.length - 1) t += l[i].restSec;
    }
    return t;
  }

  static bool _quiet(DateTime t, int fromMin, int toMin) {
    final m = t.hour * 60 + t.minute;
    if (fromMin == toMin) return false;
    if (fromMin > toMin) return m >= fromMin || m < toMin;
    return m >= fromMin && m < toMin;
  }

  /// Ближайшее разумное время: через полчаса, а если тихие часы,
  /// то когда они закончатся.
  static DateTime nearestReasonable(DateTime now, int quietFrom, int quietTo) {
    final soon = now.add(const Duration(minutes: 30));
    var t = DateTime(
      soon.year,
      soon.month,
      soon.day,
      soon.hour,
    ).add(Duration(minutes: (soon.minute / 5).ceil() * 5));
    return _outOfQuiet(t, quietFrom, quietTo);
  }

  static DateTime _outOfQuiet(DateTime t, int quietFrom, int quietTo) {
    if (!_quiet(t, quietFrom, quietTo)) return t;
    var day = DateTime(t.year, t.month, t.day);
    var end = day.add(Duration(minutes: quietTo));
    if (!end.isAfter(t)) end = end.add(const Duration(days: 1));
    return end;
  }

  static DateTime? parseWhen(Object? v) {
    if (v == null) return null;
    final s = v.toString().trim().replaceFirst(' ', 'T');
    final d = DateTime.tryParse(s);
    return d == null
        ? null
        : DateTime(d.year, d.month, d.day, d.hour, d.minute);
  }

  /// [picks]: [{id, durationSec, restSec}]. null, если не осталось ни одного
  /// упражнения из каталога.
  static ValidatedPlan? validate({
    required List<Map<String, dynamic>> picks,
    required DateTime now,
    String? title,
    String? intro,
    Object? difficulty,
    Object? scheduledFor,
    int quietFromMin = 22 * 60 + 30,
    int quietToMin = 7 * 60 + 30,
  }) {
    var dropped = 0;
    final list = <Exercise>[];
    for (final p in picks) {
      final t = ExerciseCatalog.byId('${p['id'] ?? ''}'.trim());
      if (t == null) {
        dropped++;
        continue;
      }
      list.add(
        _make(
          t,
          _int(p['durationSec'], defaultWorkSec),
          _int(p['restSec'], defaultRestSec),
        ),
      );
    }
    if (list.isEmpty) return null;

    var trimmed = false;
    while (list.length > 1 && total(list) > maxTotalSec) {
      list.removeLast();
      trimmed = true;
    }
    if (total(list) > maxTotalSec) {
      // одно упражнение не может быть дольше 90 сек, но на всякий случай
      return null;
    }

    final d = _int(difficulty, 2).clamp(1, 3);

    var at = parseWhen(scheduledFor);
    var moved = false;
    if (at == null ||
        at.isBefore(now.subtract(const Duration(minutes: 5))) ||
        at.isAfter(now.add(horizon))) {
      at = nearestReasonable(now, quietFromMin, quietToMin);
      moved = true;
    } else if (_quiet(at, quietFromMin, quietToMin)) {
      at = _outOfQuiet(at, quietFromMin, quietToMin);
      moved = true;
      if (at.isAfter(now.add(horizon))) {
        at = nearestReasonable(now, quietFromMin, quietToMin);
      }
    }

    String clip(String? s, int n) {
      final t = (s ?? '').trim();
      return t.length > n ? t.substring(0, n) : t;
    }

    final tt = clip(title, 60);
    return ValidatedPlan(
      workout: Workout(
        title: tt.isEmpty ? 'Тренировка' : tt,
        intro: clip(intro, 300),
        exercises: list,
        source: WorkoutSource.ai,
      ),
      scheduledAt: at,
      difficulty: d,
      droppedUnknown: dropped,
      trimmed: trimmed,
      timeMoved: moved,
    );
  }
}
