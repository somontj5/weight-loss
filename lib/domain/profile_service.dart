import 'package:weightloss/domain/entities/diet_plan.dart';
import 'package:weightloss/domain/entities/profile.dart';
import 'package:weightloss/domain/nutrition/nutrition_calculator.dart';
import 'package:weightloss/domain/repositories/repositories.dart';
import 'package:weightloss/domain/settings/settings_repository.dart';

/// Уровни активности и коэффициенты к базовому обмену.
class ActivityLevel {
  static const factors = {
    'sedentary': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'high': 1.725,
  };

  static bool valid(String? l) => factors.containsKey(l);
  static double? factor(String? l) => factors[l];
}

class ActivityChange {
  const ActivityChange(this.level, this.oldKcal, this.newKcal);
  final String level;
  final int? oldKcal;
  final int newKcal;
}

/// Сохраняет профиль и каждый раз пересчитывает цель и норму.
class ProfileService {
  ProfileService(this._repo, {this.settings, DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;
  final SettingsRepository? settings;
  final ProfileRepository _repo;
  final DateTime Function() _clock;

  static DietPlanData planFrom(NutritionNorm n) => DietPlanData(
        kcal: n.kcal,
        proteinG: n.proteinG,
        fatG: n.fatG,
        carbsG: n.carbsG,
        toleranceKcal: n.toleranceKcal,
        bmr: n.bmr,
        tdee: n.tdee,
        deficitKcal: n.deficitKcal,
        weeklyLossKg: n.weeklyLossKg,
        notes: n.notes,
      );

  NutritionNorm calculate(Profile p, int weeks, {String? activityLevel}) =>
      NutritionCalculator.calculate(
        activity: ActivityLevel.factor(activityLevel),
        female: p.female,
        age: p.ageAt(_clock()),
        heightCm: p.heightCm,
        weightKg: p.weightKg,
        targetWeightKg: p.targetWeightKg,
        weeks: weeks,
        trainingMinutes: p.trainingMinutes,
      );

  Future<NutritionNorm> save(Profile p,
      {required int weeks, String source = 'onboarding'}) async {
    final now = _clock();
    final level = await settings?.get(SettingKeys.activityLevel);
    final norm = calculate(p, weeks, activityLevel: level);
    final goal = Goal(
      startWeightKg: p.weightKg,
      targetWeightKg: p.targetWeightKg,
      startDate: now,
      targetDate: now.add(Duration(days: weeks * 7)),
      weeks: weeks,
    );
    await _repo.saveProfile(p,
        goal: goal, plan: planFrom(norm), source: source);
    return norm;
  }

  /// set_activity: сохраняет уровень и пересчитывает ТОЛЬКО норму
  /// (профиль, цель и история цифр не меняются). null — нет профиля/уровень
  /// неверный.
  Future<ActivityChange?> applyActivity(String level) async {
    if (!ActivityLevel.valid(level)) return null;
    final p = await _repo.getProfile();
    final goal = await _repo.getGoal();
    if (p == null) return null;
    final old = await _repo.getDietPlan();
    await settings?.set(SettingKeys.activityLevel, level);
    final norm = calculate(p, goal?.weeks ?? 12, activityLevel: level);
    await _repo.replaceDietPlan(planFrom(norm));
    return ActivityChange(level, old?.kcal, norm.kcal);
  }
}
