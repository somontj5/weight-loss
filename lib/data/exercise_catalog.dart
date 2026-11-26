import 'dart:convert';

/// Каталог упражнений. `id` — ключ, по которому позже подключится
/// 3D-анимация (см. ExerciseStage), а также список, из которого Фитти-тренер
/// выбирает упражнения. Каталог расширяется файлом assets/data/exercises.json.
class ExerciseTemplate {
  const ExerciseTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.tips,
    required this.muscle,
    required this.met,
    this.highImpact = false,
    this.stage = 'main',
    this.difficulty = 2,
    this.kcalPerMin,
    this.muscles = const [],
  });

  final String id;
  final String name;
  final String description;
  final String tips;
  final String muscle;

  /// Метаболический эквивалент (ккал на кг веса в час).
  final double met;

  /// Прыжки/ударная нагрузка — исключаем для новичков, пожилых и при большом весе.
  final bool highImpact;

  /// warmup | main | cooldown
  final String stage;

  /// 1 (легко) … 3 (тяжело).
  final int difficulty;

  /// Необязательная справочная оценка ккал в минуту.
  final double? kcalPerMin;

  /// Необязательный подробный список задействованных мышц.
  final List<String> muscles;
}

class CatalogLoad {
  const CatalogLoad(this.items, {this.skipped = 0, this.replaced = 0});
  final List<ExerciseTemplate> items;

  /// Сколько записей файла оказались битыми и были пропущены.
  final int skipped;

  /// Сколько встроенных упражнений заменено файлом (одинаковый id).
  final int replaced;
}

/// Единый каталог: встроенные упражнения + файл. Одинаковый id в файле
/// заменяет встроенное. Битые записи пропускаются, остальные работают.
class ExerciseCatalog {
  static List<ExerciseTemplate> _all = kExerciseCatalog;
  static Map<String, ExerciseTemplate> _byId = {
    for (final t in kExerciseCatalog) t.id: t
  };

  static List<ExerciseTemplate> get all => _all;
  static ExerciseTemplate? byId(String id) => _byId[id];

  /// Подключает файл каталога (текст JSON). Никогда не бросает исключений.
  static CatalogLoad load(String? jsonText) {
    final r = build(kExerciseCatalog, jsonText);
    _all = r.items;
    _byId = {for (final t in r.items) t.id: t};
    return r;
  }

  /// Возвращает каталог к встроенному (для тестов).
  static void reset() => load(null);

  static const stages = ['warmup', 'main', 'cooldown'];

  /// Чистая сборка: [builtin] + записи из [jsonText].
  static CatalogLoad build(List<ExerciseTemplate> builtin, String? jsonText) {
    final map = <String, ExerciseTemplate>{for (final t in builtin) t.id: t};
    final order = [for (final t in builtin) t.id];
    var skipped = 0;
    var replaced = 0;
    Object? data;
    if (jsonText != null && jsonText.trim().isNotEmpty) {
      try {
        data = jsonDecode(jsonText);
      } catch (_) {
        return CatalogLoad(List.unmodifiable(builtin), skipped: 1);
      }
    }
    if (data is Map) data = data['exercises'];
    if (data is List) {
      for (final e in data) {
        final t = e is Map ? _parse(Map<String, dynamic>.from(e)) : null;
        if (t == null) {
          skipped++;
          continue;
        }
        if (map.containsKey(t.id)) {
          if (builtin.any((b) => b.id == t.id)) replaced++;
        } else {
          order.add(t.id);
        }
        map[t.id] = t;
      }
    } else if (data != null) {
      skipped++;
    }
    return CatalogLoad(
      List.unmodifiable([for (final id in order) map[id]!]),
      skipped: skipped,
      replaced: replaced,
    );
  }

  static String? _s(Object? v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static ExerciseTemplate? _parse(Map<String, dynamic> j) {
    try {
      final id = _s(j['id']);
      final name = _s(j['name']);
      final desc = _s(j['description']);
      final tips = _s(j['tips']);
      final muscle = _s(j['muscle']);
      final metRaw = j['met'];
      final met = metRaw is num ? metRaw.toDouble() : double.tryParse('$metRaw');
      if (id == null || !RegExp(r'^[a-z0-9_]{1,40}$').hasMatch(id)) return null;
      if (name == null ||
          desc == null ||
          tips == null ||
          muscle == null ||
          met == null ||
          met.isNaN ||
          met < 1 ||
          met > 20) {
        return null;
      }
      final stage = _s(j['stage']);
      final diff = j['difficulty'];
      final kpm = j['kcalPerMin'];
      final ms = j['muscles'];
      return ExerciseTemplate(
        id: id,
        name: name,
        description: desc,
        tips: tips,
        muscle: muscle,
        met: met,
        stage: stages.contains(stage) ? stage! : 'main',
        difficulty: diff is num && diff >= 1 && diff <= 3 ? diff.round() : 2,
        highImpact: j['highImpact'] == true,
        kcalPerMin: kpm is num && kpm > 0 && kpm < 40 ? kpm.toDouble() : null,
        muscles: ms is List
            ? [for (final m in ms) if (_s(m) != null) _s(m)!]
            : const [],
      );
    } catch (_) {
      return null;
    }
  }
}

const kExerciseCatalog = <ExerciseTemplate>[
  ExerciseTemplate(
    id: 'arm_circles',
    difficulty: 1,
    name: 'Круговые махи руками',
    description: 'Встань прямо, разведи руки в стороны и делай плавные круги.',
    tips: 'Плечи опущены, спина ровная. Через полминуты смени направление.',
    muscle: 'Плечи',
    met: 2.8,
    stage: 'warmup',
  ),
  ExerciseTemplate(
    id: 'march_in_place',
    difficulty: 1,
    name: 'Ходьба на месте',
    description: 'Шагай на месте, высоко поднимая колени и двигая руками.',
    tips: 'Дыши ровно, держи корпус прямо.',
    muscle: 'Всё тело',
    met: 3.5,
    stage: 'warmup',
  ),
  ExerciseTemplate(
    id: 'jumping_jack',
    difficulty: 2,
    name: 'Прыжки «звёздочка»',
    description: 'Прыгай, разводя ноги и руки в стороны, затем возвращайся.',
    tips: 'Приземляйся мягко, на носки. Колени слегка согнуты.',
    muscle: 'Всё тело',
    met: 8.0,
    highImpact: true,
  ),
  ExerciseTemplate(
    id: 'high_knees',
    difficulty: 3,
    name: 'Бег с высокими коленями',
    description: 'Быстро бегай на месте, поднимая колени до уровня таза.',
    tips: 'Работай руками, спина прямая, приземляйся на носок.',
    muscle: 'Ноги, кардио',
    met: 8.0,
    highImpact: true,
  ),
  ExerciseTemplate(
    id: 'side_step',
    difficulty: 1,
    name: 'Приставные шаги с руками',
    description: 'Шагай в стороны, приставляя ногу и поднимая руки вверх.',
    tips: 'Шаг широкий, колени слегка согнуты.',
    muscle: 'Ноги, кардио',
    met: 4.5,
  ),
  ExerciseTemplate(
    id: 'shadow_boxing',
    difficulty: 2,
    name: 'Бой с тенью',
    description: 'Наноси прямые удары руками в воздух, перемещая вес с ноги на ногу.',
    tips: 'Кулаки у подбородка, удар с поворотом корпуса.',
    muscle: 'Руки, кардио',
    met: 6.0,
  ),
  ExerciseTemplate(
    id: 'squat',
    difficulty: 2,
    name: 'Приседания',
    description: 'Ноги на ширине плеч, садись назад, как на стул, и вставай.',
    tips: 'Колени не выходят за носки, спина прямая, пятки на полу.',
    muscle: 'Ноги, ягодицы',
    met: 5.0,
  ),
  ExerciseTemplate(
    id: 'lunge',
    difficulty: 2,
    name: 'Выпады назад',
    description: 'Шагни назад, опустись до прямого угла в коленях и вернись.',
    tips: 'Корпус прямой, переднее колено над стопой.',
    muscle: 'Ноги, ягодицы',
    met: 5.0,
  ),
  ExerciseTemplate(
    id: 'wall_sit',
    difficulty: 2,
    name: 'Стульчик у стены',
    description: 'Обопрись спиной о стену и удерживай позу «сидя» без стула.',
    tips: 'Колени под углом 90°, спина прижата к стене.',
    muscle: 'Ноги',
    met: 3.8,
  ),
  ExerciseTemplate(
    id: 'knee_pushup',
    difficulty: 1,
    name: 'Отжимания с колен',
    description: 'Упор на колени и ладони, опускай грудь к полу и выжимайся.',
    tips: 'Тело от колен до головы — прямая линия.',
    muscle: 'Грудь, руки',
    met: 4.0,
  ),
  ExerciseTemplate(
    id: 'pushup',
    difficulty: 3,
    name: 'Отжимания',
    description: 'Упор лёжа, опускайся до касания грудью пола и выжимайся.',
    tips: 'Локти под углом 45° к корпусу, пресс напряжён.',
    muscle: 'Грудь, руки',
    met: 6.0,
  ),
  ExerciseTemplate(
    id: 'plank',
    difficulty: 2,
    name: 'Планка',
    description: 'Упор на предплечья, тело — прямая линия, удерживай позу.',
    tips: 'Не прогибай поясницу, напряги пресс и ягодицы.',
    muscle: 'Пресс, корпус',
    met: 3.8,
  ),
  ExerciseTemplate(
    id: 'mountain_climber',
    difficulty: 3,
    name: 'Скалолаз',
    description: 'В упоре лёжа поочерёдно подтягивай колени к груди.',
    tips: 'Таз не поднимай, двигайся в своём темпе.',
    muscle: 'Пресс, кардио',
    met: 8.0,
    highImpact: true,
  ),
  ExerciseTemplate(
    id: 'burpee',
    difficulty: 3,
    name: 'Бёрпи',
    description: 'Присед, упор лёжа, возврат и выпрыгивание вверх.',
    tips: 'Если тяжело — убери прыжок и просто вставай.',
    muscle: 'Всё тело',
    met: 10.0,
    highImpact: true,
  ),
  ExerciseTemplate(
    id: 'glute_bridge',
    difficulty: 1,
    name: 'Ягодичный мостик',
    description: 'Лёжа на спине, согни ноги и поднимай таз вверх.',
    tips: 'Вверху сожми ягодицы на секунду, поясницу не прогибай.',
    muscle: 'Ягодицы',
    met: 3.5,
  ),
  ExerciseTemplate(
    id: 'crunch',
    difficulty: 1,
    name: 'Скручивания',
    description: 'Лёжа на спине, отрывай лопатки от пола, напрягая пресс.',
    tips: 'Подбородок не прижимай к груди, шею не тяни руками.',
    muscle: 'Пресс',
    met: 3.8,
  ),
  ExerciseTemplate(
    id: 'bicycle_crunch',
    difficulty: 2,
    name: 'Велосипед',
    description: 'Лёжа на спине, тянись локтем к противоположному колену.',
    tips: 'Двигайся плавно, поясница прижата к полу.',
    muscle: 'Пресс',
    met: 4.5,
  ),
  ExerciseTemplate(
    id: 'superman',
    difficulty: 1,
    name: 'Супермен',
    description: 'Лёжа на животе, одновременно приподнимай руки и ноги.',
    tips: 'Шею не запрокидывай, смотри в пол.',
    muscle: 'Спина',
    met: 3.0,
  ),
  ExerciseTemplate(
    id: 'stretching',
    difficulty: 1,
    name: 'Растяжка всего тела',
    description: 'Плавные наклоны и растяжка ног, спины и плеч.',
    tips: 'Без рывков, дыши глубоко и медленно.',
    muscle: 'Всё тело',
    met: 2.3,
    stage: 'cooldown',
  ),
];

ExerciseTemplate? catalogById(String id) => ExerciseCatalog.byId(id);
