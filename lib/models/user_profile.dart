enum FitnessLevel { beginner, intermediate, advanced }

extension FitnessLevelX on FitnessLevel {
  String get label => switch (this) {
        FitnessLevel.beginner => 'Новичок',
        FitnessLevel.intermediate => 'Средний',
        FitnessLevel.advanced => 'Продвинутый',
      };
}

/// Данные пользователя, на основе которых тренер подбирает нагрузку.
class UserProfile {
  const UserProfile({
    this.female = true,
    this.age = 30,
    this.weightKg = 70,
    this.heightCm = 170,
    this.waistCm,
    this.chestCm,
    this.hipsCm,
    this.level = FitnessLevel.beginner,
    this.configured = false,
  });

  final bool female;
  final int age;
  final double weightKg;
  final double heightCm;
  final double? waistCm;
  final double? chestCm;
  final double? hipsCm;
  final FitnessLevel level;

  /// false — пока пользователь ни разу не сохранил свои данные.
  final bool configured;

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  Map<String, dynamic> toJson() => {
        'sex': female ? 'female' : 'male',
        'age': age,
        'weightKg': weightKg,
        'heightCm': heightCm,
        if (waistCm != null) 'waistCm': waistCm,
        if (chestCm != null) 'chestCm': chestCm,
        if (hipsCm != null) 'hipsCm': hipsCm,
        'level': level.name,
        'configured': configured,
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) {
    double? d(String k) => (j[k] as num?)?.toDouble();
    return UserProfile(
      female: j['sex'] != 'male',
      age: (j['age'] as num?)?.toInt() ?? 30,
      weightKg: d('weightKg') ?? 70,
      heightCm: d('heightCm') ?? 170,
      waistCm: d('waistCm'),
      chestCm: d('chestCm'),
      hipsCm: d('hipsCm'),
      level: FitnessLevel.values.firstWhere(
        (l) => l.name == j['level'],
        orElse: () => FitnessLevel.beginner,
      ),
      configured: j['configured'] == true,
    );
  }
}
