import 'package:flutter_test/flutter_test.dart';
import 'package:weightloss/domain/nutrition/nutrition_calculator.dart';
import 'package:weightloss/domain/nutrition/validators.dart';

NutritionNorm calc({
  bool female = true,
  int age = 30,
  double h = 165,
  double w = 80,
  double t = 70,
  int weeks = 12,
  int minutes = 30,
}) =>
    NutritionCalculator.calculate(
      female: female,
      age: age,
      heightCm: h,
      weightKg: w,
      targetWeightKg: t,
      weeks: weeks,
      trainingMinutes: minutes,
    );

void main() {
  group('Миффлин — Сан Жеор', () {
    test('женщина 30 лет, 165 см, 80 кг = 1520', () {
      // 10*80 + 6.25*165 - 5*30 - 161 = 800 + 1031.25 - 150 - 161
      expect(
          NutritionCalculator.bmr(
              female: true, age: 30, heightCm: 165, weightKg: 80),
          closeTo(1520.25, 0.01));
    });

    test('мужчина 40 лет, 180 см, 90 кг', () {
      // 900 + 1125 - 200 + 5 = 1830
      expect(
          NutritionCalculator.bmr(
              female: false, age: 40, heightCm: 180, weightKg: 90),
          closeTo(1830, 0.01));
    });
  });

  group('Дефицит под срок', () {
    test('реалистичный срок: дефицит ровно под цель, без смягчения', () {
      final n = calc(t: 75, weeks: 12); // 5 кг за 12 недель
      expect(n.paceAdjusted, isFalse);
      expect(n.kcal, lessThan(n.tdee));
      expect(n.effectiveWeeks, 12);
      // желаемый темп 5/12 = 0.42 кг/нед
      expect(n.weeklyLossKg, closeTo(0.42, 0.06));
    });

    test('10 кг за 12 недель для 80 кг: нужен дефицит ~45%, темп смягчается',
        () {
      final n = calc(); // t: 70, weeks: 12
      expect(n.paceAdjusted, isTrue);
      expect(n.deficitKcal, lessThanOrEqualTo((n.tdee * 0.25).round() + 1));
      expect(n.effectiveWeeks, greaterThan(12));
    });

    test('слишком жёсткий срок смягчается, темп не больше 1% веса в неделю',
        () {
      final n = calc(w: 80, t: 60, weeks: 4); // 20 кг за 4 недели — опасно
      expect(n.paceAdjusted, isTrue);
      expect(n.weeklyLossKg, lessThanOrEqualTo(0.85));
      expect(n.effectiveWeeks, greaterThan(4));
      expect(n.notes.join(), contains('Срок слишком короткий'));
    });

    test('калории никогда не ниже 1200 (жен.) / 1500 (муж.)', () {
      final f = calc(w: 55, t: 50, h: 160, weeks: 2, minutes: 0);
      expect(f.kcal, greaterThanOrEqualTo(1200));
      final m = calc(
          female: false, w: 60, t: 55, h: 165, age: 50, weeks: 2, minutes: 0);
      expect(m.kcal, greaterThanOrEqualTo(1500));
    });

    test('дефицит не больше 25% от расхода', () {
      final n = calc(w: 120, t: 70, h: 175, weeks: 4);
      expect(n.deficitKcal, lessThanOrEqualTo((n.tdee * 0.25).round() + 1));
    });

    test('цель ниже здорового ИМТ 18,5 обрезается', () {
      final n = calc(w: 60, t: 40, h: 165, weeks: 30);
      expect(n.notes.join(), contains('здорового веса'));
      final minW = NutritionCalculator.minHealthyWeight(165);
      final lossKg = n.weeklyLossKg * n.effectiveWeeks;
      expect(lossKg, lessThanOrEqualTo(60 - minW + 1.5));
    });

    test('цель = текущий вес: поддержание, дефицит 0', () {
      final n = calc(w: 70, t: 70);
      expect(n.deficitKcal, 0);
      expect(n.kcal, closeTo(n.tdee, 10));
    });

    test('несовершеннолетним дефицит не ставится', () {
      final n = calc(age: 16);
      expect(n.deficitKcal, 0);
      expect(n.notes.join(), contains('18'));
    });
  });

  group('Макросы', () {
    test('БЖУ сходятся с калориями (±3%)', () {
      for (final w in [55.0, 70.0, 90.0, 130.0]) {
        final n = calc(w: w, t: w - 5, weeks: 10);
        final kcal = n.proteinG * 4 + n.fatG * 9 + n.carbsG * 4;
        expect(kcal, closeTo(n.kcal, n.kcal * 0.03), reason: 'вес $w');
        expect(n.proteinG, greaterThan(0));
        expect(n.fatG, greaterThan(0));
        expect(n.carbsG, greaterThanOrEqualTo(0));
      }
    });

    test('допуск отклонения в разумных пределах', () {
      final n = calc();
      expect(n.toleranceKcal, inInclusiveRange(50, 150));
    });
  });

  group('Валидация', () {
    test('возраст, рост, вес', () {
      expect(Validators.age('30'), isNull);
      expect(Validators.age('10'), isNotNull);
      expect(Validators.age('abc'), isNotNull);
      expect(Validators.height('170'), isNull);
      expect(Validators.height('90'), isNotNull);
      expect(Validators.weight('72,5'), isNull);
      expect(Validators.weight('10'), isNotNull);
    });

    test('целевой вес: не больше текущего и не ниже здорового', () {
      expect(
          Validators.targetWeight('70', weightKg: 80, heightCm: 165), isNull);
      expect(Validators.targetWeight('85', weightKg: 80, heightCm: 165),
          isNotNull);
      expect(Validators.targetWeight('40', weightKg: 80, heightCm: 165),
          contains('ниже здорового'));
    });

    test('обхваты можно пропустить', () {
      expect(Validators.girth(''), isNull);
      expect(Validators.girth('  '), isNull);
      expect(Validators.girth('90'), isNull);
      expect(Validators.girth('5'), isNotNull);
    });
  });
}
