import 'nutrition_calculator.dart';

/// Проверка чисел регистрации. Возвращает текст ошибки или null.
class Validators {
  static String? name(String v) {
    final t = v.trim();
    if (t.isEmpty) return 'Напиши, как к тебе обращаться';
    if (t.length > 30) return 'Слишком длинное имя';
    return null;
  }

  static double? parse(String v) =>
      double.tryParse(v.trim().replaceAll(',', '.'));

  static String? age(String v) {
    final n = int.tryParse(v.trim());
    if (n == null) return 'Введи возраст числом';
    if (n < 14 || n > 100) return 'Возраст от 14 до 100 лет';
    return null;
  }

  static String? height(String v) {
    final n = parse(v);
    if (n == null) return 'Введи рост числом';
    if (n < 120 || n > 230) return 'Рост от 120 до 230 см';
    return null;
  }

  static String? weight(String v) {
    final n = parse(v);
    if (n == null) return 'Введи вес числом';
    if (n < 30 || n > 300) return 'Вес от 30 до 300 кг';
    return null;
  }

  static String? targetWeight(String v,
      {required double weightKg, required double heightCm}) {
    final n = parse(v);
    if (n == null) return 'Введи целевой вес числом';
    if (n < 30 || n > 300) return 'Вес от 30 до 300 кг';
    if (n > weightKg) return 'Цель должна быть не больше текущего веса';
    final minW = NutritionCalculator.minHealthyWeight(heightCm);
    if (n < minW) {
      return 'Это ниже здорового веса. Минимум для твоего роста — ${minW.ceil()} кг';
    }
    return null;
  }

  /// Обхват необязателен: пустая строка допустима.
  static String? girth(String v) {
    if (v.trim().isEmpty) return null;
    final n = parse(v);
    if (n == null) return 'Введи число';
    if (n < 40 || n > 250) return 'От 40 до 250 см';
    return null;
  }

  static String? weeks(int w) =>
      (w < 2 || w > 104) ? 'Срок от 2 до 104 недель' : null;
}
