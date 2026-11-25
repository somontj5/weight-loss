import '../data/exercise_catalog.dart';

enum WorkoutSource { ai, demo }

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.tips,
    required this.muscleGroup,
    required this.durationSec,
    required this.restSec,
    required this.met,
  });

  final String id;
  final String name;
  final String description;
  final String tips;
  final String muscleGroup;
  final int durationSec;

  /// Отдых ПОСЛЕ этого упражнения.
  final int restSec;
  final double met;

  /// Ключ 3D-анимации; для неизвестных упражнений — 'generic'.
  String get animationId => catalogById(id) != null ? id : 'generic';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'tips': tips,
        'muscleGroup': muscleGroup,
        'durationSec': durationSec,
        'restSec': restSec,
        'met': met,
      };

  /// Разбор JSON от ИИ (или из хранилища). Пропуски добираются из каталога,
  /// числа ограничиваются разумными пределами.
  factory Exercise.fromJson(Map<String, dynamic> j) {
    final id = (j['id'] ?? '').toString().trim();
    final t = catalogById(id);
    String s(String k, String? fallback) {
      final v = j[k]?.toString().trim() ?? '';
      return v.isNotEmpty ? v : (fallback ?? '');
    }

    num n(String k, num fallback) {
      final v = j[k];
      if (v is num) return v;
      return num.tryParse(v?.toString() ?? '') ?? fallback;
    }

    final name = s('name', t?.name);
    if (name.isEmpty) throw const FormatException('exercise without name');
    return Exercise(
      id: id.isEmpty ? 'custom' : id,
      name: name,
      description: s('description', t?.description),
      tips: s('tips', t?.tips),
      muscleGroup: s('muscleGroup', t?.muscle ?? 'Всё тело'),
      durationSec: n('durationSec', 40).round().clamp(10, 300),
      restSec: n('restSec', 15).round().clamp(0, 120),
      met: n('met', t?.met ?? 5).toDouble().clamp(1.5, 14.0),
    );
  }
}

class Workout {
  Workout({
    required this.title,
    required this.intro,
    required this.exercises,
    required this.source,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String title;

  /// Короткое мотивирующее вступление от тренера.
  final String intro;
  final List<Exercise> exercises;
  final WorkoutSource source;
  final DateTime createdAt;

  /// Общая длительность: упражнения + отдых между ними (после последнего
  /// упражнения отдыха нет).
  int get totalSec {
    var t = 0;
    for (var i = 0; i < exercises.length; i++) {
      t += exercises[i].durationSec;
      if (i < exercises.length - 1) t += exercises[i].restSec;
    }
    return t;
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'intro': intro,
        'source': source.name,
        'createdAt': createdAt.toIso8601String(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory Workout.fromJson(Map<String, dynamic> j, {WorkoutSource? source}) {
    final raw = j['exercises'];
    if (raw is! List || raw.isEmpty) {
      throw const FormatException('no exercises');
    }
    final list = <Exercise>[];
    for (final e in raw) {
      if (e is Map) {
        try {
          list.add(Exercise.fromJson(Map<String, dynamic>.from(e)));
        } on FormatException {
          // пропускаем битое упражнение
        }
      }
    }
    if (list.isEmpty) throw const FormatException('no valid exercises');
    return Workout(
      title: (j['title']?.toString().trim().isNotEmpty ?? false)
          ? j['title'].toString().trim()
          : 'Тренировка от Фитти',
      intro: j['intro']?.toString().trim() ?? '',
      exercises: list,
      source: source ??
          (j['source'] == 'ai' ? WorkoutSource.ai : WorkoutSource.demo),
      createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? ''),
    );
  }
}
