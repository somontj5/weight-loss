import 'package:weightloss/data/exercise_catalog.dart';
import 'package:weightloss/domain/coach/coach_models.dart';
import 'package:weightloss/models/workout.dart';

/// Строит тренировку из выбора модели (id из каталога). Сложность,
/// длительность и ударные упражнения контролирует КОД: всё лишнее убирается,
/// недостающее добавляется.
class WorkoutBuilder {
  static const minWork = 20;
  static const maxWork = 90;
  static const minRest = 5;
  static const maxRest = 60;

  static int _workFor(int difficulty) => switch (difficulty) {
    1 => 30,
    3 => 45,
    _ => 40,
  };
  static int _restFor(int difficulty) => switch (difficulty) {
    1 => 25,
    3 => 15,
    _ => 20,
  };

  static bool _allowed(ExerciseTemplate t, CoachDecision d) =>
      t.stage != 'main' ||
      (t.difficulty <= d.difficulty && (d.allowHighImpact || !t.highImpact));

  static Exercise _make(ExerciseTemplate t, int work, int rest) => Exercise(
    id: t.id,
    name: t.name,
    description: t.description,
    tips: t.tips,
    muscleGroup: t.muscle,
    durationSec: work.clamp(minWork, maxWork),
    restSec: rest.clamp(0, maxRest),
    met: t.met,
  );

  static int _total(List<Exercise> l) {
    var t = 0;
    for (var i = 0; i < l.length; i++) {
      t += l[i].durationSec;
      if (i < l.length - 1) t += l[i].restSec;
    }
    return t;
  }

  /// [picks] — выбор модели: [{id, durationSec, restSec}]. Может быть пустым:
  /// тогда план собирает код сам.
  static Workout build({
    required CoachDecision decision,
    required List<Map<String, dynamic>> picks,
    String? title,
    String? intro,
    int seed = 0,
  }) {
    final cat = ExerciseCatalog.all;
    int num_(Object? v, int d) =>
        v is num ? v.round() : (int.tryParse('${v ?? ''}') ?? d);

    final mains = <Exercise>[];
    final usedIds = <String>{};
    String? prev;
    for (final p in picks) {
      final t = ExerciseCatalog.byId('${p['id'] ?? ''}'.trim());
      if (t == null || t.stage != 'main') {
        continue; // неизвестные id отбрасываем
      }
      if (!_allowed(t, decision)) continue;
      if (t.id == prev) continue;
      mains.add(
        _make(
          t,
          num_(p['durationSec'], _workFor(decision.difficulty)),
          num_(p['restSec'], _restFor(decision.difficulty)),
        ),
      );
      usedIds.add(t.id);
      prev = t.id;
    }

    final warm = cat
        .where(
          (t) =>
              t.stage == 'warmup' &&
              (decision.allowHighImpact || !t.highImpact),
        )
        .toList();
    final cool = cat.where((t) => t.stage == 'cooldown').toList();
    final pool = cat
        .where(
          (t) =>
              t.stage == 'main' &&
              _allowed(t, decision) &&
              !usedIds.contains(t.id),
        )
        .toList();
    // стабильное «перемешивание» по дню
    if (pool.isNotEmpty) {
      final k = seed.abs() % pool.length;
      pool.setAll(0, [...pool.skip(k), ...pool.take(k)]);
    }

    final warmups = <Exercise>[
      for (final t in warm.take(decision.minutes >= 20 ? 2 : 1))
        _make(t, 30, 10),
    ];
    final cooldown = cool.isEmpty ? null : _make(cool.first, 45, 0);

    final target = decision.minutes * 60;
    final fixed = _total([...warmups, if (cooldown != null) cooldown]) + 10;

    // Лишнее убираем с конца (оставляем минимум 2 основных).
    while (mains.length > 2 && fixed + _total(mains) > target * 1.1) {
      mains.removeLast();
    }
    // Не хватает: добираем из каталога, не повторяя подряд.
    var guard = 0;
    while (fixed + _total(mains) < target * 0.9 &&
        pool.isNotEmpty &&
        guard++ < 30) {
      final t = pool.removeAt(0);
      if (mains.isNotEmpty && mains.last.id == t.id) continue;
      mains.add(
        _make(t, _workFor(decision.difficulty), _restFor(decision.difficulty)),
      );
      if (pool.isEmpty) break;
    }
    if (mains.isEmpty) {
      // каталог слишком узок: берём что разрешено без повторов подряд
      final any = cat
          .where((t) => t.stage == 'main' && _allowed(t, decision))
          .toList();
      for (final t in any.take(3)) {
        mains.add(
          _make(
            t,
            _workFor(decision.difficulty),
            _restFor(decision.difficulty),
          ),
        );
      }
    }

    final list = <Exercise>[...warmups, ...mains];
    if (list.isNotEmpty && cooldown != null) {
      // перед растяжкой длинного отдыха не нужно
      final last = list.removeLast();
      list.add(
        Exercise(
          id: last.id,
          name: last.name,
          description: last.description,
          tips: last.tips,
          muscleGroup: last.muscleGroup,
          durationSec: last.durationSec,
          restSec: 10,
          met: last.met,
        ),
      );
      list.add(cooldown);
    } else if (list.isNotEmpty) {
      final last = list.removeLast();
      list.add(
        Exercise(
          id: last.id,
          name: last.name,
          description: last.description,
          tips: last.tips,
          muscleGroup: last.muscleGroup,
          durationSec: last.durationSec,
          restSec: 0,
          met: last.met,
        ),
      );
    }

    String clip(String? s, int n) {
      final t = (s ?? '').trim();
      return t.length > n ? t.substring(0, n) : t;
    }

    final tt = clip(title, 60);
    return Workout(
      title: tt.isEmpty ? 'Тренировка на ${decision.minutes} минут' : tt,
      intro: clip(intro, 300),
      exercises: list,
      source: WorkoutSource.ai,
    );
  }
}
