/// Расчёт сожжённых калорий в реальном времени.
/// ккал = MET × вес(кг) × часы × поправка на возраст.
class CalorieCalc {
  /// С возрастом обмен веществ немного замедляется: -0,4% за год после 25 лет
  /// (не ниже 0,85).
  static double ageFactor(int age) =>
      (1 - 0.004 * (age - 25)).clamp(0.85, 1.0).toDouble();

  static double kcal({
    required double met,
    required double weightKg,
    required int age,
    required double seconds,
  }) =>
      met * weightKg * (seconds / 3600) * ageFactor(age);

  /// MET во время отдыха между подходами.
  static const restMet = 1.8;
}
