import 'package:weightloss/domain/entities/diary_entry.dart';

/// Разобранное и очищенное действие log_food от модели.
class FoodLogRequest {
  const FoodLogRequest({
    required this.op,
    this.entryId,
    this.meal,
    this.time,
    this.description,
    this.kcal,
    this.proteinG,
    this.fatG,
    this.carbsG,
    this.offPlan,
    this.note,
    this.problems = const [],
  });

  /// add | update | delete
  final String op;
  final int? entryId;
  final String? meal;
  final DateTime? time;
  final String? description;
  final int? kcal;
  final double? proteinG;
  final double? fatG;
  final double? carbsG;
  final bool? offPlan;
  final String? note;

  /// Что пришлось выбросить как мусор (для отладки и тестов).
  final List<String> problems;

  bool get isAdd => op == 'add';
  bool get isUpdate => op == 'update';
  bool get isDelete => op == 'delete';
}

class MealKind {
  static const all = ['breakfast', 'lunch', 'dinner', 'snack'];

  static const _aliases = {
    'завтрак': 'breakfast',
    'обед': 'lunch',
    'ужин': 'dinner',
    'перекус': 'snack',
    'полдник': 'snack',
    'снек': 'snack',
  };

  static String? normalize(String? raw) {
    if (raw == null) return null;
    final s = raw.trim().toLowerCase();
    if (all.contains(s)) return s;
    return _aliases[s];
  }

  /// Приём пищи по времени суток, если модель его не указала.
  static String byTime(DateTime t) {
    final h = t.hour;
    if (h >= 5 && h < 11) return 'breakfast';
    if (h >= 11 && h < 16) return 'lunch';
    if (h >= 16 && h < 21) return 'dinner';
    return 'snack';
  }

  static String ru(String meal) => switch (meal) {
        'breakfast' => 'завтрак',
        'lunch' => 'обед',
        'dinner' => 'ужин',
        _ => 'перекус',
      };
}

/// Защита от мусора: что бы ни прислала модель, в базу попадёт только
/// правдоподобное.
class FoodActionParser {
  static const maxKcal = 3500;
  static const maxMacroG = 400.0;
  static const maxDescriptionChars = 160;
  static const maxNoteChars = 200;

  static FoodLogRequest? parse(Map<String, dynamic> data, DateTime now) {
    final problems = <String>[];

    final opRaw = (data['op'] ?? 'add').toString().trim().toLowerCase();
    if (!const ['add', 'update', 'delete'].contains(opRaw)) return null;

    final id = _int(data['entry_id'] ?? data['id']);
    if (opRaw != 'add' && (id == null || id <= 0)) return null;

    if (opRaw == 'delete') return FoodLogRequest(op: 'delete', entryId: id);

    var kcal = _int(data['kcal']);
    if (kcal != null && (kcal < 0 || kcal > maxKcal)) {
      problems.add('kcal=$kcal вне диапазона');
      kcal = null;
    }

    double? macro(String key) {
      final v = _num(data[key]);
      if (v == null) return null;
      if (v < 0 || v > maxMacroG) {
        problems.add('$key=$v вне диапазона');
        return null;
      }
      return double.parse(v.toStringAsFixed(1));
    }

    var p = macro('protein_g');
    var f = macro('fat_g');
    var c = macro('carbs_g');
    // БЖУ, которые не сходятся с калориями, выбрасываем: лучше пусто, чем ложь.
    if (kcal != null && kcal >= 100 && p != null && f != null && c != null) {
      final fromMacros = p * 4 + f * 9 + c * 4;
      if (fromMacros > kcal * 1.6 + 50) {
        problems.add('БЖУ не сходятся с калориями');
        p = f = c = null;
      }
    }

    final desc = cleanDescription(data['description']?.toString());
    final note = _clip(data['note']?.toString(), maxNoteChars);

    return FoodLogRequest(
      op: opRaw,
      entryId: id,
      meal: MealKind.normalize(data['meal']?.toString()),
      time: parseTime(data['time']?.toString(), now),
      description: desc.isEmpty ? null : desc,
      kcal: kcal,
      proteinG: p,
      fatG: f,
      carbsG: c,
      offPlan: data['off_plan'] is bool ? data['off_plan'] as bool : null,
      note: (note == null || note.isEmpty) ? null : note,
      problems: problems,
    );
  }

  static String cleanDescription(String? raw) {
    var s = (raw ?? '').trim();
    s = s.replaceFirst(RegExp(r'^#\d+\s*'), ''); // модель могла повторить «#12»
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    if (s.length > maxDescriptionChars) {
      s = s.substring(0, maxDescriptionChars).trimRight();
    }
    return s;
  }

  /// «13:05», «13.05», «2026-03-10 13:05», «2026-03-10T13:05:00».
  /// Будущее и старше 3 суток — игнорируем (вернём null = «сейчас»).
  static DateTime? parseTime(String? raw, DateTime now) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;
    DateTime? t;
    final hm = RegExp(r'^(\d{1,2})[:.](\d{2})$').firstMatch(s);
    if (hm != null) {
      final h = int.parse(hm.group(1)!);
      final m = int.parse(hm.group(2)!);
      if (h > 23 || m > 59) return null;
      t = DateTime(now.year, now.month, now.day, h, m);
    } else {
      t = DateTime.tryParse(s.replaceFirst(' ', 'T'));
      if (t != null && t.isUtc) t = t.toLocal();
    }
    if (t == null) return null;
    if (t.isAfter(now.add(const Duration(minutes: 10)))) return null;
    if (t.isBefore(now.subtract(const Duration(days: 3)))) return null;
    return t;
  }

  static int? _int(Object? v) {
    final n = _num(v);
    if (n == null) return null;
    return n.round();
  }

  static double? _num(Object? v) {
    if (v == null) return null;
    double? out;
    if (v is num) {
      out = v.toDouble();
    } else if (v is String) {
      final m = RegExp(r'-?\d+(?:[.,]\d+)?').firstMatch(v);
      if (m == null) return null;
      out = double.tryParse(m.group(0)!.replaceAll(',', '.'));
    }
    if (out == null || out.isNaN || out.isInfinite) return null;
    return out;
  }

  static String? _clip(String? s, int max) {
    if (s == null) return null;
    final t = s.trim().replaceAll(RegExp(r'\s+'), ' ');
    return t.length > max ? t.substring(0, max) : t;
  }
}

/// Итог применения log_food.
enum FoodOutcomeKind { added, updated, deleted, rejected }

class FoodLogOutcome {
  const FoodLogOutcome(this.kind, {this.entry, this.reason, this.merged = false});
  final FoodOutcomeKind kind;

  /// Запись после изменения (для удаления — удалённая).
  final DiaryEntry? entry;
  final String? reason;

  /// true — фото и текст об одном приёме пищи слились в одну запись.
  final bool merged;

  bool get ok => kind != FoodOutcomeKind.rejected;
}
