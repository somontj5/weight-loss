/// Человек, которого ведёт Фитти. Только измеримое из регистрации.
class Profile {
  const Profile({
    required this.name,
    required this.sex,
    required this.birthYear,
    required this.heightCm,
    required this.weightKg,
    required this.targetWeightKg,
    this.waistCm,
    this.chestCm,
    this.hipsCm,
    this.trainingMinutes = 20,
    this.trainingSlot = 'evening',
    this.onboardingDone = false,
  });

  final String name;

  /// 'female' | 'male'
  final String sex;
  final int birthYear;
  final double heightCm;
  final double weightKg;
  final double targetWeightKg;
  final double? waistCm;
  final double? chestCm;
  final double? hipsCm;
  final int trainingMinutes;

  /// 'morning' | 'day' | 'evening'
  final String trainingSlot;
  final bool onboardingDone;

  bool get female => sex != 'male';
  int ageAt(DateTime now) => now.year - birthYear;

  Profile copyWith({
    String? name,
    String? sex,
    int? birthYear,
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
    Object? waistCm = _keep,
    Object? chestCm = _keep,
    Object? hipsCm = _keep,
    int? trainingMinutes,
    String? trainingSlot,
    bool? onboardingDone,
  }) =>
      Profile(
        name: name ?? this.name,
        sex: sex ?? this.sex,
        birthYear: birthYear ?? this.birthYear,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        targetWeightKg: targetWeightKg ?? this.targetWeightKg,
        waistCm: identical(waistCm, _keep) ? this.waistCm : waistCm as double?,
        chestCm: identical(chestCm, _keep) ? this.chestCm : chestCm as double?,
        hipsCm: identical(hipsCm, _keep) ? this.hipsCm : hipsCm as double?,
        trainingMinutes: trainingMinutes ?? this.trainingMinutes,
        trainingSlot: trainingSlot ?? this.trainingSlot,
        onboardingDone: onboardingDone ?? this.onboardingDone,
      );

  static const _keep = Object();
}

class Goal {
  const Goal({
    required this.startWeightKg,
    required this.targetWeightKg,
    required this.startDate,
    required this.targetDate,
    required this.weeks,
  });

  final double startWeightKg;
  final double targetWeightKg;
  final DateTime startDate;
  final DateTime targetDate;
  final int weeks;

  /// Сколько недель осталось (минимум 1).
  int weeksLeft(DateTime now) {
    final d = targetDate.difference(now).inDays;
    return d <= 0 ? 1 : (d / 7).ceil();
  }
}

class WeightPoint {
  const WeightPoint(this.at, this.weightKg);
  final DateTime at;
  final double weightKg;
}
