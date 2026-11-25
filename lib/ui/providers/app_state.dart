import 'package:flutter/foundation.dart';
import 'package:weightloss/app_deps.dart';
import 'package:weightloss/domain/entities/diet_plan.dart';
import 'package:weightloss/domain/entities/profile.dart';
import 'package:weightloss/domain/nutrition/nutrition_calculator.dart';

/// Общее состояние: прошёл ли человек регистрацию, его профиль и норма.
class AppState extends ChangeNotifier {
  AppState(this.deps);
  final AppDeps deps;

  bool _loaded = false;
  bool get loaded => _loaded;

  Profile? _profile;
  Profile? get profile => _profile;
  Goal? _goal;
  Goal? get goal => _goal;
  DietPlanData? _plan;
  DietPlanData? get plan => _plan;

  bool get onboarded => _profile?.onboardingDone ?? false;

  Future<void> load() async {
    try {
      await _refresh();
    } catch (e) {
      if (kDebugMode) debugPrint('AppState.load error: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _refresh() async {
    _profile = await deps.profiles.getProfile();
    _goal = await deps.profiles.getGoal();
    _plan = await deps.profiles.getDietPlan();
  }

  /// Сохраняет данные регистрации (или их правку) и пересчитывает норму.
  Future<NutritionNorm> saveProfile(Profile p,
      {required int weeks, required String source}) async {
    final norm = await deps.profileService
        .save(p.copyWith(onboardingDone: true), weeks: weeks, source: source);
    await _refresh();
    notifyListeners();
    return norm;
  }

  /// Полное удаление данных с устройства.
  Future<void> wipeAll() async {
    await deps.exporter.wipeEverything();
    _profile = null;
    _goal = null;
    _plan = null;
    notifyListeners();
  }
}
