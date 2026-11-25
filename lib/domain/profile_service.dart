import 'entities/diet_plan.dart';
import 'entities/profile.dart';
import 'nutrition/nutrition_calculator.dart';
import 'repositories/repositories.dart';

/// Сохраняет профиль и каждый раз пересчитывает цель и норму.
class ProfileService {
  ProfileService(this._repo, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;
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

  NutritionNorm calculate(Profile p, int weeks) => NutritionCalculator.calculate(
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
    final norm = calculate(p, weeks);
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
}
