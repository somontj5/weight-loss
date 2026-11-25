import 'dart:math';

/// Результат расчёта нормы.
class NutritionNorm {
  const NutritionNorm({
    required this.bmr,
    required this.tdee,
    required this.kcal,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.deficitKcal,
    required this.weeklyLossKg,
    required this.effectiveWeeks,
    required this.toleranceKcal,
    this.notes = const [],
    this.paceAdjusted = false,
  });

  final int bmr;
  final int tdee;
  final int kcal;
  final int proteinG;
  final int fatG;
  final int carbsG;
  final int deficitKcal;
  final double weeklyLossKg;

  /// За сколько недель цель реально достижима при этой норме.
  final int effectiveWeeks;

  /// Допустимое отклонение от нормы за день (± ккал).
  final int toleranceKcal;
  final List<String> notes;

  /// true — срок пользователя слишком жёсткий, темп смягчён.
  final bool paceAdjusted;
}

/// Формула Миффлина — Сан Жеора + безопасный дефицит под срок цели.
class NutritionCalculator {
  static const kcalPerKg = 7700.0;
  static const minBmi = 18.5;

  /// Базовый обмен, ккал/сутки.
  static double bmr({
    required bool female,
    required int age,
    required double heightCm,
    required double weightKg,
  }) =>
      10 * weightKg + 6.25 * heightCm - 5 * age + (female ? -161 : 5);

  /// Коэффициент активности: образ жизни Фитти узнаёт позже в разговоре,
  /// пока берём «малоподвижный» 1.30 + надбавка за время на тренировки.
  static double activityFactor(int trainingMinutes) =>
      1.30 + min(max(trainingMinutes, 0), 90) / 90 * 0.15;

  static double minHealthyWeight(double heightCm) =>
      minBmi * pow(heightCm / 100, 2);

  static double maxWeeklyLossKg(double weightKg) => min(1.0, weightKg * 0.01);

  static NutritionNorm calculate({
    required bool female,
    required int age,
    required double heightCm,
    required double weightKg,
    required double targetWeightKg,
    required int weeks,
    int trainingMinutes = 20,
    double? activity,
  }) {
    final notes = <String>[];
    final b = bmr(
        female: female, age: age, heightCm: heightCm, weightKg: weightKg);
    final tdee = b * (activity ?? activityFactor(trainingMinutes));
    final floor = female ? 1200.0 : 1500.0;

    var target = targetWeightKg;
    final minW = minHealthyWeight(heightCm);
    if (target < minW) {
      target = minW;
      notes.add(
          'Цель ниже здорового веса (ИМТ 18,5). Считаю до ${minW.toStringAsFixed(1)} кг.');
    }

    final toLose = weightKg - target;
    var deficit = 0.0;
    var adjusted = false;
    var effWeeks = max(weeks, 1);

    if (age < 18) {
      notes.add(
          'До 18 лет дефицит калорий не ставлю: обсуди снижение веса с врачом.');
    } else if (toLose <= 0.2) {
      notes.add('Цель близка к текущему весу: считаю норму для поддержания.');
    } else {
      final w = max(weeks, 1);
      final desired = toLose * kcalPerKg / (w * 7);
      final byRate = maxWeeklyLossKg(weightKg) * kcalPerKg / 7;
      final byShare = tdee * 0.25;
      final byFloor = max(tdee - floor, 0.0);
      final cap = [byRate, byShare, byFloor, 1000.0].reduce(min);
      deficit = min(desired, cap);
      if (deficit < desired - 1) {
        adjusted = true;
        effWeeks = (toLose * kcalPerKg / max(deficit, 1) / 7).ceil();
        notes.add(deficit <= 0
            ? 'Для твоих данных безопасного дефицита нет, держим поддержание.'
            : 'Срок слишком короткий для безопасного темпа. '
                'Безопасно — около $effWeeks нед. вместо $w.');
      } else {
        effWeeks = w;
      }
    }

    var kcal = tdee - deficit;
    if (age >= 18 && deficit > 0) kcal = max(kcal, floor);
    kcal = min(kcal, tdee);
    final kcalR = (kcal / 10).round() * 10;
    final realDeficit = max(tdee.round() - kcalR, 0);

    // Макросы: белок ~1,6 г/кг (но 15–35% калорий), жиры ~27%, остальное углеводы.
    var protein = min(1.6 * weightKg, 0.35 * kcalR / 4);
    protein = max(protein, 0.15 * kcalR / 4);
    var fat = max(0.27 * kcalR / 9, min(0.6 * weightKg, 0.4 * kcalR / 9));
    var carbs = (kcalR - protein * 4 - fat * 9) / 4;
    if (carbs < 0) {
      carbs = 0;
      protein = (kcalR - fat * 9) / 4;
    }

    final weekly = realDeficit * 7 / kcalPerKg;
    final tol = ((kcalR * 0.05) / 10).round() * 10;

    return NutritionNorm(
      bmr: b.round(),
      tdee: tdee.round(),
      kcal: kcalR,
      proteinG: protein.round(),
      fatG: fat.round(),
      carbsG: carbs.round(),
      deficitKcal: realDeficit,
      weeklyLossKg: double.parse(weekly.toStringAsFixed(2)),
      effectiveWeeks: effWeeks,
      toleranceKcal: tol.clamp(50, 150),
      notes: notes,
      paceAdjusted: adjusted,
    );
  }
}
