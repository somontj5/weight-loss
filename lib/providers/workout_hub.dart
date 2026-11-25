import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/user_profile.dart';
import '../models/workout.dart';
import '../models/workout_session.dart';
import '../services/calorie_calc.dart';
import '../services/fitness_coach_service.dart';

/// Единое состояние раздела «Тренировка»: профиль, съеденные калории,
/// текущий план от ИИ и история тренировок.
class WorkoutHub extends ChangeNotifier {
  WorkoutHub({FitnessCoachService? llm})
      : _llm = llm ?? (ApiConfig.hasKey ? LlmFitnessCoach() : null);

  final FitnessCoachService? _llm;
  final LocalFitnessCoach _local = LocalFitnessCoach();

  bool get aiConnected => _llm != null;

  UserProfile _profile = const UserProfile();
  UserProfile get profile => _profile;

  int _caloriesEaten = 0;
  int get caloriesEaten => _caloriesEaten;

  int _minutes = 20;
  int get minutes => _minutes;

  Workout? _workout;
  Workout? get workout => _workout;

  final List<WorkoutSession> _history = [];
  List<WorkoutSession> get history => List.unmodifiable(_history);

  bool _generating = false;
  bool get generating => _generating;

  /// Сообщение пользователю (например, «ИИ недоступен — составил план сам»).
  String? _notice;
  String? get notice => _notice;

  bool _loaded = false;
  bool get loaded => _loaded;

  static const _kProfile = 'fitty.profile';
  static const _kWorkout = 'fitty.workout';
  static const _kHistory = 'fitty.history';
  static const _kKcal = 'fitty.kcal';
  static const _kMinutes = 'fitty.minutes';

  String get _today {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final pj = p.getString(_kProfile);
      if (pj != null) {
        _profile = UserProfile.fromJson(jsonDecode(pj) as Map<String, dynamic>);
      }
      final wj = p.getString(_kWorkout);
      if (wj != null) {
        _workout = Workout.fromJson(jsonDecode(wj) as Map<String, dynamic>);
      }
      final hj = p.getString(_kHistory);
      if (hj != null) {
        for (final e in (jsonDecode(hj) as List)) {
          _history.add(WorkoutSession.fromJson(e as Map<String, dynamic>));
        }
      }
      final kj = p.getString(_kKcal);
      if (kj != null) {
        final m = jsonDecode(kj) as Map<String, dynamic>;
        if (m['date'] == _today) _caloriesEaten = (m['kcal'] as num).toInt();
      }
      _minutes = p.getInt(_kMinutes) ?? 20;
    } catch (e) {
      if (kDebugMode) debugPrint('WorkoutHub.load error: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save(String key, Object value) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(key, jsonEncode(value));
    } catch (e) {
      if (kDebugMode) debugPrint('WorkoutHub.save error: $e');
    }
  }

  void updateProfile(UserProfile p) {
    _profile = p;
    notifyListeners();
    _save(_kProfile, p.toJson());
  }

  void setCaloriesEaten(int kcal) {
    _caloriesEaten = kcal.clamp(0, 20000);
    notifyListeners();
    _save(_kKcal, {'date': _today, 'kcal': _caloriesEaten});
  }

  /// Точка входа для «Диетолога» и «Зрения»: добавить съеденное.
  void addCaloriesEaten(int kcal) => setCaloriesEaten(_caloriesEaten + kcal);

  Future<void> setMinutes(int m) async {
    _minutes = m;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(_kMinutes, m);
    } catch (_) {}
  }

  void dismissNotice() {
    _notice = null;
    notifyListeners();
  }

  Future<void> generate() async {
    if (_generating) return;
    _generating = true;
    _notice = null;
    notifyListeners();

    final req = WorkoutRequest(
      profile: _profile,
      caloriesEaten: _caloriesEaten,
      minutes: _minutes,
      recent: _history.take(3).toList(),
    );

    Workout? result;
    if (_llm != null) {
      try {
        result = await _llm.generateWorkout(req);
      } catch (e) {
        if (kDebugMode) debugPrint('LLM workout failed: $e');
        _notice = 'ИИ сейчас недоступен, поэтому я составил план сам. '
            'Попробуй позже, и я подстрою его точнее.';
      }
    } else {
      _notice = 'ИИ пока не подключён: это план из локального генератора.';
    }
    result ??= await _local.generateWorkout(req);

    _workout = result;
    _generating = false;
    notifyListeners();
    _save(_kWorkout, result.toJson());
  }

  /// Оценка калорий всей тренировки по плану.
  double estimateKcal(Workout w) {
    var k = 0.0;
    for (var i = 0; i < w.exercises.length; i++) {
      final e = w.exercises[i];
      k += CalorieCalc.kcal(
          met: e.met,
          weightKg: _profile.weightKg,
          age: _profile.age,
          seconds: e.durationSec.toDouble());
      if (i < w.exercises.length - 1) {
        k += CalorieCalc.kcal(
            met: CalorieCalc.restMet,
            weightKg: _profile.weightKg,
            age: _profile.age,
            seconds: e.restSec.toDouble());
      }
    }
    return k;
  }

  void addSession(WorkoutSession s) {
    _history.insert(0, s);
    if (_history.length > 20) _history.removeRange(20, _history.length);
    notifyListeners();
    _save(_kHistory, _history.map((e) => e.toJson()).toList());
  }

  Future<String> review(WorkoutSession s) async {
    if (_llm != null) {
      try {
        return await _llm.reviewSession(
            profile: _profile, session: s, caloriesEaten: _caloriesEaten);
      } catch (e) {
        if (kDebugMode) debugPrint('LLM review failed: $e');
      }
    }
    return _local.reviewSession(
        profile: _profile, session: s, caloriesEaten: _caloriesEaten);
  }
}
