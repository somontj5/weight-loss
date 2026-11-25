import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:weightloss/models/user_profile.dart';
import 'package:weightloss/models/workout.dart';
import 'package:weightloss/models/workout_session.dart';
import 'package:weightloss/services/calorie_calc.dart';
import 'package:weightloss/services/workout_music.dart';

enum WorkoutPhase { ready, exercise, rest, finished }

/// Ход тренировки: таймеры, отдых, паузы, подсчёт калорий в реальном времени
/// и журнал действий пользователя (для ИИ-тренера).
class WorkoutController extends ChangeNotifier {
  WorkoutController({
    required this.workout,
    required this.profile,
    required this.music,
  }) {
    logs = [
      for (final e in workout.exercises)
        ExerciseLog(
          exerciseId: e.id,
          name: e.name,
          plannedSec: e.durationSec,
          plannedRestSec: e.restSec,
        ),
    ];
  }

  final Workout workout;
  final UserProfile profile;
  final WorkoutMusic music;
  late final List<ExerciseLog> logs;

  static const readySeconds = 5;
  static const pauseOptions = [15, 30, 60];

  WorkoutPhase _phase = WorkoutPhase.ready;
  WorkoutPhase get phase => _phase;

  int _index = 0;
  int get index => _index;
  Exercise get current => workout.exercises[_index];
  Exercise? get next =>
      _index + 1 < workout.exercises.length ? workout.exercises[_index + 1] : null;

  /// Сколько секунд прошло в текущей фазе.
  double _elapsed = 0;
  double get elapsed => _elapsed;

  double get phaseTotal => switch (_phase) {
        WorkoutPhase.ready => readySeconds.toDouble(),
        WorkoutPhase.exercise => current.durationSec.toDouble(),
        WorkoutPhase.rest => current.restSec.toDouble(),
        WorkoutPhase.finished => 0,
      };

  double get remaining => (phaseTotal - _elapsed).clamp(0, phaseTotal);
  int get remainingCeil => remaining.ceil();
  double get progress => phaseTotal == 0 ? 1 : (_elapsed / phaseTotal).clamp(0, 1);

  double _kcal = 0;
  double get kcal => _kcal;

  double _activeSec = 0;
  double _pausedSec = 0;
  double get activeSec => _activeSec;

  bool _paused = false;
  bool get paused => _paused;
  double _pauseElapsed = 0;
  int _pauseLimit = 30;
  int get pauseLimit => _pauseLimit;
  int get pauseRemaining => (_pauseLimit - _pauseElapsed).clamp(0, _pauseLimit).ceil();

  bool _finishedEarly = false;
  DateTime? _startedAt;
  WorkoutSession? _session;
  WorkoutSession? get session => _session;

  Timer? _timer;
  final Stopwatch _sw = Stopwatch();
  int _lastBeepSecond = -1;

  void start() {
    _startedAt = DateTime.now();
    _sw
      ..reset()
      ..start();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
    music.start(energetic: false);
    notifyListeners();
  }

  ExerciseLog get _log => logs[_index];

  void _tick() {
    final dt = _sw.elapsedMilliseconds / 1000.0;
    _sw
      ..reset()
      ..start();
    if (_phase == WorkoutPhase.finished) return;

    if (_paused) {
      _pauseElapsed += dt;
      _pausedSec += dt;
      if (_pauseElapsed >= _pauseLimit) {
        resume();
      } else {
        notifyListeners();
      }
      return;
    }

    _elapsed += dt;
    switch (_phase) {
      case WorkoutPhase.ready:
        break;
      case WorkoutPhase.exercise:
        final k = CalorieCalc.kcal(
          met: current.met,
          weightKg: profile.weightKg,
          age: profile.age,
          seconds: dt,
        );
        _kcal += k;
        _log.kcal += k;
        _log.actualSec += dt;
        _activeSec += dt;
      case WorkoutPhase.rest:
        final k = CalorieCalc.kcal(
          met: CalorieCalc.restMet,
          weightKg: profile.weightKg,
          age: profile.age,
          seconds: dt,
        );
        _kcal += k;
        _log.restActualSec += dt;
        _activeSec += dt;
      case WorkoutPhase.finished:
        break;
    }

    final left = remainingCeil;
    if (left <= 3 && left >= 1 && left != _lastBeepSecond) {
      _lastBeepSecond = left;
      HapticFeedback.selectionClick();
    }

    if (_elapsed >= phaseTotal) _advance();
    notifyListeners();
  }

  void _advance() {
    switch (_phase) {
      case WorkoutPhase.ready:
        _enterExercise();
      case WorkoutPhase.exercise:
        _log.status = 'completed';
        _log.actualSec = current.durationSec.toDouble();
        if (next == null) {
          _finish(early: false);
        } else if (current.restSec > 0) {
          _enterRest();
        } else {
          _log.restOutcome = 'none';
          _index++;
          _enterExercise();
        }
      case WorkoutPhase.rest:
        _log.restOutcome = 'completed';
        _index++;
        _enterExercise();
      case WorkoutPhase.finished:
        break;
    }
  }

  void _enterExercise() {
    _phase = WorkoutPhase.exercise;
    _elapsed = 0;
    _lastBeepSecond = -1;
    music.setEnergetic(true);
    HapticFeedback.mediumImpact();
  }

  void _enterRest() {
    _phase = WorkoutPhase.rest;
    _elapsed = 0;
    _lastBeepSecond = -1;
    music.setEnergetic(false);
    HapticFeedback.lightImpact();
  }

  // ---- действия пользователя ----

  /// Пауза на выбранное число секунд (потом продолжится само).
  void pause([int seconds = 30]) {
    if (_paused || _phase == WorkoutPhase.finished) return;
    _paused = true;
    _pauseElapsed = 0;
    _pauseLimit = seconds;
    music.setEnergetic(false);
    notifyListeners();
  }

  void setPauseLimit(int seconds) {
    if (!_paused) return;
    _pauseLimit = seconds;
    _pauseElapsed = 0;
    notifyListeners();
  }

  void resume() {
    if (!_paused) return;
    _paused = false;
    if (_phase != WorkoutPhase.finished && _phase != WorkoutPhase.ready) {
      _log.pauses.add(_pauseElapsed.round());
    }
    music.setEnergetic(_phase == WorkoutPhase.exercise);
    notifyListeners();
  }

  /// «Следующее упражнение»: текущее пропускается, отдыха нет.
  void skipExercise() {
    if (_phase != WorkoutPhase.exercise || _paused) return;
    if (_log.actualSec < 3) {
      _log.status = 'skipped';
    } else {
      _log.status = 'stopped_early';
    }
    _log.restOutcome = 'omitted';
    if (next == null) {
      _finish(early: false);
    } else {
      _index++;
      _enterExercise();
    }
    notifyListeners();
  }

  void skipRest() {
    if (_phase != WorkoutPhase.rest || _paused) return;
    _log.restOutcome = 'skipped';
    _index++;
    _enterExercise();
    notifyListeners();
  }

  void skipReady() {
    if (_phase != WorkoutPhase.ready) return;
    _enterExercise();
    notifyListeners();
  }

  void finishEarly() {
    if (_phase == WorkoutPhase.finished) return;
    if (_paused) {
      _paused = false;
      if (_phase != WorkoutPhase.ready) _log.pauses.add(_pauseElapsed.round());
    }
    if (_phase == WorkoutPhase.exercise) {
      _log.status = _log.actualSec >= 3 ? 'stopped_early' : 'skipped';
      _log.restOutcome = 'omitted';
    } else if (_phase == WorkoutPhase.rest) {
      _log.restOutcome = 'skipped';
    }
    _finish(early: true);
    notifyListeners();
  }

  void _finish({required bool early}) {
    _finishedEarly = early;
    _phase = WorkoutPhase.finished;
    _timer?.cancel();
    _sw.stop();
    music.fadeOutAndStop();
    HapticFeedback.heavyImpact();
    _session = WorkoutSession(
      startedAt: _startedAt ?? DateTime.now(),
      title: workout.title,
      plannedSec: workout.totalSec,
      activeSec: _activeSec.round(),
      pausedSec: _pausedSec.round(),
      kcal: _kcal,
      finishedEarly: _finishedEarly,
      logs: logs,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
