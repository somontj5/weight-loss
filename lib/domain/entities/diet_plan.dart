class DietPlanData {
  const DietPlanData({
    required this.kcal,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.toleranceKcal,
    required this.bmr,
    required this.tdee,
    required this.deficitKcal,
    required this.weeklyLossKg,
    this.notes = const [],
  });

  final int kcal;
  final int proteinG;
  final int fatG;
  final int carbsG;
  final int toleranceKcal;
  final int bmr;
  final int tdee;
  final int deficitKcal;
  final double weeklyLossKg;
  final List<String> notes;
}
