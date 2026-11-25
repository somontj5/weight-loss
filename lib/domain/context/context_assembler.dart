import 'package:weightloss/config/context_config.dart';
import 'package:weightloss/domain/entities/diet_plan.dart';
import 'package:weightloss/domain/entities/memory_fact.dart';
import 'package:weightloss/domain/entities/part2_entities.dart';
import 'package:weightloss/domain/entities/profile.dart';
import 'package:weightloss/domain/entities/stored_message.dart';
import 'package:weightloss/domain/repositories/repositories.dart';

/// Одна реплика для модели.
class ChatTurn {
  const ChatTurn(this.role, this.text);

  /// 'user' | 'model'
  final String role;
  final String text;
}

/// Готовый срез: блок контекста (идёт в системную инструкцию) и реплики.
class AssembledContext {
  const AssembledContext({
    required this.contextText,
    required this.turns,
    required this.tokens,
    required this.sections,
    required this.needsSummary,
  });

  final String contextText;
  final List<ChatTurn> turns;

  /// Оценка размера всего (контекст + реплики).
  final int tokens;

  /// Размер каждой секции в токенах (для отладки и тестов).
  final Map<String, int> sections;

  /// Есть ли много старых несжатых сообщений: можно попросить резюме
  /// в этом же запросе.
  final bool needsSummary;
}

/// Собирает компактный срез под каждый запрос. Порядок и приоритет:
/// профиль → память → сегодня → остаток → неделя → тренировки →
/// резюме прошлого → последние сообщения. При нехватке бюджета
/// режутся самые «дешёвые по ценности» части, а не всё подряд.
class ContextAssembler {
  ContextAssembler({
    required this.profiles,
    required this.memory,
    required this.conversation,
    this.diary = const _NoDiary(),
    this.workouts = const _NoWorkouts(),
    this.config = ContextConfig.defaults,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final ProfileRepository profiles;
  final MemoryRepository memory;
  final ConversationRepository conversation;
  final DiarySource diary;
  final WorkoutHistorySource workouts;
  final ContextConfig config;
  final DateTime Function() _clock;

  Future<AssembledContext> assemble() async {
    final now = _clock();
    final c = config;
    final sections = <String, int>{};

    final profile = await profiles.getProfile();
    final goal = await profiles.getGoal();
    final plan = await profiles.getDietPlan();
    final weights = await profiles.weightHistory(limit: 6);
    final facts = await memory.active();
    final today = await diary.today(now);
    final week = await diary.lastDays(now, 7);
    final trainings = await workouts.recent(now, limit: 5);
    final summaries = await conversation.summaries();
    final pending =
        await conversation.pendingForSummary(keepLast: c.keepRecentRaw);
    final recent = await conversation.lastChatMessages(c.recentMessagesMax);

    final parts = <_Part>[
      _Part('now', _nowLine(now), 60, 0),
      _Part('profile', _profileBlock(profile, goal, plan, weights, now),
          c.profileBudget, 1),
      _Part('memory', _memoryBlock(facts), c.memoryBudget, 2),
      _Part('today', _todayBlock(today, plan), c.todayBudget, 3),
      _Part('week', _weekBlock(week, plan), c.weekBudget, 6),
      _Part('workouts', _workoutsBlock(trainings), c.workoutsBudget, 5),
      _Part('summaries', _summariesBlock(summaries), c.summariesBudget, 4),
    ];

    // Каждая секция в своём бюджете.
    for (final p in parts) {
      p.text = _fit(p.text, p.budget);
    }

    // Последние сообщения: берём с конца, пока влезает.
    var turns = _recentTurns(recent, c.recentBudget);
    int partsTokens() =>
        parts.fold<int>(0, (s, p) => s + ContextConfig.estimateTokens(p.text));
    int turnsTokens() =>
        turns.fold<int>(0, (s, t) => s + ContextConfig.estimateTokens(t.text));

    // Общий потолок: сначала режем наименее важные секции
    // (больший priority — раньше), потом самые старые реплики.
    final byPriorityDesc = [...parts]
      ..sort((a, b) => b.priority.compareTo(a.priority));
    for (final p in byPriorityDesc) {
      final over = partsTokens() + turnsTokens() - c.totalBudget;
      if (over <= 0) break;
      final room = ContextConfig.estimateTokens(p.text) - over;
      p.text = room <= 0 ? '' : _fit(p.text, room);
    }
    while (partsTokens() + turnsTokens() > c.totalBudget && turns.length > 1) {
      turns = turns.sublist(1);
    }
    // Первая реплика обязана быть от пользователя.
    while (turns.length > 1 && turns.first.role != 'user') {
      turns = turns.sublist(1);
    }
    final recentNow = turnsTokens();
    sections['recent'] = recentNow;

    final text = StringBuffer();
    for (final p in parts) {
      if (p.text.trim().isEmpty) continue;
      sections[p.name] = ContextConfig.estimateTokens(p.text);
      text.writeln(p.text.trimRight());
      text.writeln();
    }
    final contextText = text.toString().trimRight();

    return AssembledContext(
      contextText: contextText,
      turns: turns,
      tokens: ContextConfig.estimateTokens(contextText) + recentNow,
      sections: sections,
      needsSummary: pending.length >= c.summarizeWhenPending,
    );
  }

  // ───────────── блоки ─────────────

  static const _weekdays = [
    'понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота',
    'воскресенье'
  ];

  String _nowLine(DateTime now) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '[СЕЙЧАС] ${now.year}-${two(now.month)}-${two(now.day)} '
        '${_weekdays[now.weekday - 1]}, ${two(now.hour)}:${two(now.minute)}';
  }

  static String _n(num v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  String _profileBlock(Profile? p, Goal? goal, DietPlanData? plan,
      List<WeightPoint> weights, DateTime now) {
    if (p == null || !p.onboardingDone) {
      return '[ПРОФИЛЬ] Регистрация не завершена, цифр о человеке нет.';
    }
    final b = StringBuffer('[ПРОФИЛЬ]\n');
    b.write('${p.name.isEmpty ? 'Имя не указано' : p.name}, '
        '${p.female ? 'женщина' : 'мужчина'}, ${p.ageAt(now)} лет, '
        'рост ${_n(p.heightCm)} см, вес ${_n(p.weightKg)} кг, '
        'цель ${_n(p.targetWeightKg)} кг');
    if (goal != null) {
      b.write(', срок ${goal.weeks} нед. (осталось ${goal.weeksLeft(now)})');
    }
    b.writeln('.');
    final girths = <String>[
      if (p.waistCm != null) 'талия ${_n(p.waistCm!)}',
      if (p.chestCm != null) 'грудь ${_n(p.chestCm!)}',
      if (p.hipsCm != null) 'бёдра ${_n(p.hipsCm!)}',
    ];
    if (girths.isNotEmpty) b.writeln('Обхваты, см: ${girths.join(', ')}.');
    b.writeln('Время на тренировки: ${p.trainingMinutes} мин, '
        '${switch (p.trainingSlot) {
      'morning' => 'утром',
      'day' => 'днём',
      _ => 'вечером',
    }}.');
    if (weights.length > 1) {
      b.writeln('Вес по датам: ${weights.map((w) => '${w.at.month}/${w.at.day}=${_n(w.weightKg)}').join(', ')}.');
    }
    if (plan != null) {
      b.writeln('Норма: ${plan.kcal} ккал/день (±${plan.toleranceKcal}), '
          'Б ${plan.proteinG} / Ж ${plan.fatG} / У ${plan.carbsG} г, '
          'дефицит ${plan.deficitKcal} ккал, темп ~${_n(plan.weeklyLossKg)} кг/нед.');
    }
    return b.toString();
  }

  String _memoryBlock(List<MemoryFact> facts) {
    if (facts.isEmpty) {
      return '[ПАМЯТЬ] Пока ничего не известно об образе жизни, режиме дня, '
          'непереносимостях, продуктах, бюджете, здоровье, привычках, '
          'мотивации и том, что мешало. Узнавай по ходу разговора.';
    }
    // Сначала уверенные и свежие.
    final sorted = [...facts]..sort((a, b) {
        final c = b.confidence.compareTo(a.confidence);
        return c != 0 ? c : b.updatedAt.compareTo(a.updatedAt);
      });
    final b = StringBuffer('[ПАМЯТЬ О ЧЕЛОВЕКЕ]\n');
    for (final f in sorted) {
      final mark = f.confidence < 0.6 ? ' (неточно)' : '';
      b.writeln('- [${f.category}] ${f.fact}$mark');
    }
    return b.toString();
  }

  String _todayBlock(DiaryDay today, DietPlanData? plan) {
    if (!diary.available) {
      return '[СЕГОДНЯ] Дневник питания пока не ведётся: не называй '
          'остаток калорий и не утверждай, сколько человек съел.';
    }
    final b = StringBuffer('[СЕГОДНЯ]\n');
    if (today.items.isEmpty) {
      b.writeln('Пока ничего не записано.');
    } else {
      for (final e in today.items) {
        b.writeln('- ${_hm(e.time)} ${e.meal}: ${e.description}'
            '${e.kcal != null ? ' ~${e.kcal} ккал' : ''}');
      }
      b.writeln('Итого ~${today.kcal} ккал, Б ${_n(today.protein)} / '
          'Ж ${_n(today.fat)} / У ${_n(today.carbs)} г.');
    }
    if (plan != null) {
      final left = plan.kcal - today.kcal;
      b.writeln('Остаток на сегодня ~$left ккал (приблизительно).');
    }
    return b.toString();
  }

  String _weekBlock(List<DiaryDay> week, DietPlanData? plan) {
    if (!diary.available || week.isEmpty) return '';
    final b = StringBuffer('[НЕДЕЛЯ]\n');
    for (final d in week) {
      b.writeln('${d.date.month}/${d.date.day}: ~${d.kcal} ккал'
          '${plan != null ? ' (норма ${plan.kcal})' : ''}');
    }
    return b.toString();
  }

  String _workoutsBlock(List<WorkoutBrief> list) {
    if (list.isEmpty) return '';
    final b = StringBuffer('[ТРЕНИРОВКИ]\n');
    for (final w in list) {
      b.writeln('- ${w.date.month}/${w.date.day} ${w.title}: ${w.status}'
          '${w.minutes > 0 ? ', ${w.minutes} мин' : ''}'
          '${w.kcal > 0 ? ', ~${w.kcal} ккал' : ''}'
          '${w.note != null ? ' (${w.note})' : ''}');
    }
    return b.toString();
  }

  String _summariesBlock(List<ConversationSummary> list) {
    if (list.isEmpty) return '';
    final b = StringBuffer('[РЕЗЮМЕ ПРОШЛЫХ РАЗГОВОРОВ]\n');
    // Последние резюме важнее: идём с конца, потом разворачиваем.
    final lines = <String>[];
    for (final s in list.reversed) {
      lines.add('- ${s.fromTime.month}/${s.fromTime.day}–'
          '${s.toTime.month}/${s.toTime.day}: ${s.body}');
    }
    for (final l in lines) {
      b.writeln(l);
    }
    return b.toString();
  }

  String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  List<ChatTurn> _recentTurns(
      List<StoredMessage> recent, int budget) {
    final turns = <ChatTurn>[];
    var used = 0;
    for (final m in recent.reversed) {
      var t = m.body.trim();
      if (m.audioPath != null && t.isEmpty) {
        t = '(голосовое сообщение, ${(m.audioMs / 1000).round()} с, '
            'расшифровки пока нет)';
      }
      if (m.images.isNotEmpty) {
        t = '${t.isEmpty ? '' : '$t '}(приложено фото: ${m.images.length}, '
            'содержимое пока недоступно)';
      }
      if (t.isEmpty) continue;
      t = ContextConfig.clipToTokens(t, config.messageMaxTokens);
      final cost = ContextConfig.estimateTokens(t);
      if (used + cost > budget && turns.isNotEmpty) break;
      used += cost;
      turns.add(ChatTurn(m.isUser ? 'user' : 'model', t));
    }
    final list = turns.reversed.toList();
    // Gemini требует, чтобы первая реплика была от пользователя.
    while (list.isNotEmpty && list.first.role != 'user') {
      list.removeAt(0);
    }
    return _mergeSameRole(list);
  }

  List<ChatTurn> _mergeSameRole(List<ChatTurn> list) {
    final out = <ChatTurn>[];
    for (final t in list) {
      if (out.isNotEmpty && out.last.role == t.role) {
        out[out.length - 1] = ChatTurn(t.role, '${out.last.text}\n${t.text}');
      } else {
        out.add(t);
      }
    }
    return out;
  }

  /// Режет текст по строкам, чтобы не рвать посередине факта.
  String _fit(String text, int budget) {
    if (ContextConfig.estimateTokens(text) <= budget) return text;
    final lines = text.split('\n');
    final out = <String>[];
    var used = 0;
    for (final l in lines) {
      final cost = ContextConfig.estimateTokens(l) + 1;
      if (used + cost > budget) break;
      out.add(l);
      used += cost;
    }
    if (out.isEmpty) return ContextConfig.clipToTokens(text, budget);
    return out.join('\n');
  }
}

class _Part {
  _Part(this.name, this.text, this.budget, this.priority);
  final String name;
  String text;
  final int budget;

  /// Чем больше, тем раньше режется при нехватке общего бюджета.
  final int priority;
}

class _NoDiary implements DiarySource {
  const _NoDiary();
  @override
  bool get available => false;
  @override
  Future<DiaryDay> today(DateTime now) async =>
      DiaryDay(date: now, items: const []);
  @override
  Future<List<DiaryDay>> lastDays(DateTime now, int days) async => const [];
}

class _NoWorkouts implements WorkoutHistorySource {
  const _NoWorkouts();
  @override
  Future<List<WorkoutBrief>> recent(DateTime now, {int limit = 5}) async =>
      const [];
}
