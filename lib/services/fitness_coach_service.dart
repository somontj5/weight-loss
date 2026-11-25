import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../data/exercise_catalog.dart';
import '../models/user_profile.dart';
import '../models/workout.dart';
import '../models/workout_session.dart';

/// Всё, что тренер должен знать, чтобы составить тренировку.
class WorkoutRequest {
  const WorkoutRequest({
    required this.profile,
    required this.caloriesEaten,
    required this.minutes,
    this.recent = const [],
  });

  final UserProfile profile;

  /// Сколько ккал съедено сегодня (0 — неизвестно).
  final int caloriesEaten;
  final int minutes;

  /// Последние тренировки (новые первыми) — ИИ видит, что пропускали и как уставали.
  final List<WorkoutSession> recent;
}

class CoachException implements Exception {
  CoachException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Контракт ИИ-тренера. Реализации: [LlmFitnessCoach] (через API) и
/// [LocalFitnessCoach] (без сети, запасной вариант).
abstract class FitnessCoachService {
  Future<Workout> generateWorkout(WorkoutRequest request);

  /// Короткий разбор завершённой тренировки.
  Future<String> reviewSession({
    required UserProfile profile,
    required WorkoutSession session,
    required int caloriesEaten,
  });
}

// ---------------------------------------------------------------------------
// LLM через OpenAI-совместимый API
// ---------------------------------------------------------------------------

class LlmFitnessCoach implements FitnessCoachService {
  LlmFitnessCoach({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _timeout = Duration(seconds: 75);

  Future<String> _chat(String system, String user, {double temperature = 0.6}) async {
    final http.Response res;
    try {
      res = await _client
          .post(
            ApiConfig.chatUri,
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Authorization': 'Bearer ${ApiConfig.apiKey}',
              'X-Title': 'Fitty',
            },
            body: jsonEncode({
              'model': ApiConfig.model,
              'temperature': temperature,
              'messages': [
                {'role': 'system', 'content': system},
                {'role': 'user', 'content': user},
              ],
            }),
          )
          .timeout(_timeout);
    } catch (e) {
      throw CoachException('Нет связи с ИИ: $e');
    }
    if (res.statusCode != 200) {
      throw CoachException('ИИ вернул ошибку ${res.statusCode}');
    }
    try {
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final content = data['choices'][0]['message']['content'];
      if (content is String && content.trim().isNotEmpty) return content;
    } catch (_) {}
    throw CoachException('ИИ вернул пустой ответ');
  }

  @override
  Future<Workout> generateWorkout(WorkoutRequest r) async {
    final raw = await _chat(_workoutSystemPrompt(), _workoutUserPrompt(r),
        temperature: 0.5);
    final json = _extractJson(raw);
    try {
      return Workout.fromJson(json, source: WorkoutSource.ai);
    } on FormatException catch (e) {
      throw CoachException('Не удалось разобрать план ИИ: ${e.message}');
    }
  }

  @override
  Future<String> reviewSession({
    required UserProfile profile,
    required WorkoutSession session,
    required int caloriesEaten,
  }) async {
    final text = await _chat(
      'Ты Фитти — дружелюбный фитнес-тренер в приложении для похудения. '
      'Отвечай по-русски, тепло и конкретно, без markdown и списков со звёздочками.',
      'Вот итоги тренировки пользователя (JSON):\n'
      '${jsonEncode(session.toJson())}\n\n'
      'Профиль: ${jsonEncode(profile.toJson())}\n'
      'Съедено сегодня: $caloriesEaten ккал.\n\n'
      'Напиши разбор на 3-5 предложений: что получилось, что пропущено или '
      'прервано и почему это важно, и как скорректируешь следующую тренировку. '
      'Если пользователь закончил досрочно или пропускал — поддержи, не ругай.',
      temperature: 0.7,
    );
    return text.trim();
  }

  String _workoutSystemPrompt() {
    final cat = StringBuffer();
    for (final t in kExerciseCatalog) {
      cat.writeln('${t.id} | ${t.name} | ${t.muscle} | MET ${t.met} | '
          '${t.highImpact ? "прыжки/ударная" : "щадящее"} | ${t.stage}');
    }
    return 'Ты Фитти — персональный фитнес-тренер в приложении для похудения. '
        'Составляешь домашнюю тренировку без оборудования.\n'
        'Отвечай ТОЛЬКО одним JSON-объектом, без пояснений и без markdown.\n\n'
        'Схема:\n'
        '{"title": "короткое название", "intro": "1-2 тёплых мотивирующих предложения", '
        '"exercises": [{"id": "id из каталога", "name": "название", '
        '"description": "как выполнять, 1 предложение", "tips": "1 совет по технике", '
        '"muscleGroup": "группа мышц", "durationSec": 40, "restSec": 15, "met": 5.0}]}\n\n'
        'Правила:\n'
        '- Выбирай упражнения ТОЛЬКО из каталога и указывай их id точно. Для них '
        'используй MET из каталога.\n'
        '- Порядок: сначала разминка (stage=warmup), затем основные, в конце '
        'растяжка (stage=cooldown) с restSec=0.\n'
        '- durationSec от 20 до 90, restSec от 5 до 60. restSec — отдых ПОСЛЕ упражнения.\n'
        '- Суммарное время (сумма durationSec и restSec, кроме последнего отдыха) '
        'должно быть близко к запрошенным минутам.\n'
        '- Не ставь два одинаковых упражнения подряд; чередуй группы мышц.\n'
        '- Новичкам, людям старше 50 лет и при ИМТ от 32 исключай прыжковые и '
        'ударные упражнения.\n'
        '- Учитывай съеденные калории: если очень мало (<900) — снизь интенсивность; '
        'если много (>2400) — добавь больше кардио.\n'
        '- Учитывай недавние тренировки: если упражнения пропускали, прерывали или '
        'делали паузы — упрости и сократи нагрузку; если всё выполнено — слегка усложни.\n'
        '- Названия, описания и советы — на русском.\n\n'
        'Каталог (id | название | мышцы | MET | нагрузка | этап):\n$cat';
  }

  String _workoutUserPrompt(WorkoutRequest r) {
    final recent = [for (final s in r.recent.take(3)) s.toJson()];
    return 'Составь тренировку.\n'
        'Профиль: ${jsonEncode(r.profile.toJson())}\n'
        'ИМТ: ${r.profile.bmi.toStringAsFixed(1)}\n'
        'Съедено сегодня: ${r.caloriesEaten > 0 ? "${r.caloriesEaten} ккал" : "неизвестно"}\n'
        'Желаемая длительность: ${r.minutes} минут\n'
        'Недавние тренировки (новые первыми): ${jsonEncode(recent)}';
  }

  static Map<String, dynamic> _extractJson(String raw) {
    var s = raw.trim();
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(s);
    if (fence != null) s = fence.group(1)!.trim();
    final a = s.indexOf('{');
    final b = s.lastIndexOf('}');
    if (a < 0 || b <= a) throw CoachException('ИИ ответил не в формате JSON');
    try {
      final v = jsonDecode(s.substring(a, b + 1));
      if (v is Map<String, dynamic>) return v;
    } catch (_) {}
    throw CoachException('ИИ ответил не в формате JSON');
  }
}

// ---------------------------------------------------------------------------
// Локальный тренер (без сети)
// ---------------------------------------------------------------------------

class LocalFitnessCoach implements FitnessCoachService {
  @override
  Future<Workout> generateWorkout(WorkoutRequest r) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final p = r.profile;
    final gentle = p.level == FitnessLevel.beginner || p.age >= 50 || p.bmi >= 32;

    var work = switch (p.level) {
      FitnessLevel.beginner => 40,
      FitnessLevel.intermediate => 45,
      FitnessLevel.advanced => 50,
    };
    var rest = switch (p.level) {
      FitnessLevel.beginner => 25,
      FitnessLevel.intermediate => 20,
      FitnessLevel.advanced => 15,
    };

    String note = '';
    if (r.caloriesEaten > 0 && r.caloriesEaten < 900) {
      work -= 5;
      rest += 5;
      note = ' Ты съел(а) пока немного, поэтому нагрузка помягче.';
    } else if (r.caloriesEaten > 2400) {
      work += 5;
      note = ' Калорий сегодня много, поэтому добавил кардио.';
    }
    if (r.recent.isNotEmpty) {
      final last = r.recent.first;
      if (last.finishedEarly || last.skippedCount >= 2) {
        work -= 5;
        rest += 5;
        note += ' В прошлый раз было тяжело, делаем чуть легче.';
      }
    }
    work = work.clamp(20, 60);
    rest = rest.clamp(8, 40);

    final warm = kExerciseCatalog.where((t) => t.stage == 'warmup').toList();
    final cool = kExerciseCatalog.where((t) => t.stage == 'cooldown').toList();
    final main = kExerciseCatalog
        .where((t) => t.stage == 'main' && !(gentle && t.highImpact))
        .toList();
    if (p.level == FitnessLevel.beginner) {
      main.removeWhere((t) => t.id == 'pushup' || t.id == 'burpee');
    } else {
      main.removeWhere((t) => t.id == 'knee_pushup');
    }

    final now = DateTime.now();
    final rnd = Random(now.year * 1000 + now.month * 50 + now.day + p.age);

    final list = <Exercise>[];
    Exercise make(ExerciseTemplate t, int d, int rs) => Exercise(
          id: t.id,
          name: t.name,
          description: t.description,
          tips: t.tips,
          muscleGroup: t.muscle,
          durationSec: d,
          restSec: rs,
          met: t.met,
        );

    final warmCount = r.minutes >= 20 ? 2 : 1;
    for (var i = 0; i < warmCount; i++) {
      list.add(make(warm[i % warm.length], 30, 10));
    }
    final coolT = cool.first;
    const coolSec = 45;
    final left = r.minutes * 60 -
        list.fold<int>(0, (a, e) => a + e.durationSec + e.restSec) -
        coolSec;
    final slot = work + rest;
    final count = max(3, (left / slot).floor());

    main.shuffle(rnd);
    String? prev;
    final pool = <ExerciseTemplate>[];
    while (pool.length < count) {
      final round = List<ExerciseTemplate>.of(main)..shuffle(rnd);
      for (final t in round) {
        if (pool.length >= count) break;
        if (t.id == prev) continue;
        pool.add(t);
        prev = t.id;
      }
    }
    for (final t in pool) {
      // удержание позы — чуть короче, динамика — полная
      final d = (t.id == 'plank' || t.id == 'wall_sit') ? max(20, work - 5) : work;
      list.add(make(t, d, rest));
    }
    // последний силовой — без длинного отдыха перед растяжкой
    final last = list.removeLast();
    list.add(Exercise(
      id: last.id,
      name: last.name,
      description: last.description,
      tips: last.tips,
      muscleGroup: last.muscleGroup,
      durationSec: last.durationSec,
      restSec: 10,
      met: last.met,
    ));
    list.add(make(coolT, coolSec, 0));

    return Workout(
      title: 'Тренировка на ${r.minutes} минут',
      intro: 'Начнём с разминки, потом основная часть и растяжка. '
          'Двигайся в своём темпе, я рядом!$note',
      exercises: list,
      source: WorkoutSource.demo,
    );
  }

  @override
  Future<String> reviewSession({
    required UserProfile profile,
    required WorkoutSession session,
    required int caloriesEaten,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final b = StringBuffer();
    final min = (session.activeSec / 60).floor();
    final kcal = session.kcal.round();
    if (session.finishedEarly) {
      b.write('Ты закончил(а) досрочно, и это нормально: '
          'за $min мин сожжено около $kcal ккал, а такая нагрузка тоже считается. ');
    } else {
      b.write('Отличная работа! За $min мин ты сжёг(ла) около $kcal ккал. ');
    }
    if (session.skippedCount > 0) {
      b.write('Пропущено упражнений: ${session.skippedCount}. '
          'В следующий раз сделаю план полегче в этих местах. ');
    }
    if (session.pausesCount > 0) {
      b.write('Ты делал(а) паузы (${session.pausesCount}) — слушать тело правильно. ');
    }
    if (!session.finishedEarly && session.skippedCount == 0) {
      b.write('Всё выполнено, поэтому в следующий раз можно слегка добавить нагрузку. ');
    }
    b.write('Пей воду и отдыхай!');
    return b.toString();
  }
}
