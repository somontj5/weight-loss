import 'package:flutter_test/flutter_test.dart';
import 'package:weightloss/config/context_config.dart';
import 'package:weightloss/domain/context/context_assembler.dart';
import 'package:weightloss/domain/entities/memory_fact.dart';
import 'package:weightloss/domain/entities/part2_entities.dart';
import 'package:weightloss/domain/memory/memory_service.dart';
import 'package:weightloss/domain/repositories/repositories.dart';

import 'helpers.dart';

class FakeDiary implements DiarySource {
  @override
  bool get available => true;
  @override
  Future<DiaryDay> today(DateTime now) async => DiaryDay(date: now, items: [
        DiaryItem(
            time: DateTime(2026, 3, 10, 8, 30),
            meal: 'breakfast',
            description: 'Овсянка с ягодами',
            kcal: 320),
        DiaryItem(
            time: DateTime(2026, 3, 10, 13),
            meal: 'lunch',
            description: 'Курица с гречкой',
            kcal: 520),
      ]);
  @override
  Future<List<DiaryDay>> lastDays(DateTime now, int days) async =>
      [await today(now)];
}

class FakeWorkouts implements WorkoutHistorySource {
  @override
  Future<List<WorkoutBrief>> recent(DateTime now, {int limit = 5}) async => [
        WorkoutBrief(
            date: DateTime(2026, 3, 9),
            title: 'Кардио 20 мин',
            status: 'completed',
            minutes: 20,
            kcal: 150)
      ];
}

void main() {
  late Env env;
  final now = DateTime(2026, 3, 10, 18, 30);

  setUp(() async {
    env = Env(now);
    await env.seedProfile();
  });
  tearDown(() => env.close());

  ContextAssembler make({
    ContextConfig config = ContextConfig.defaults,
    DiarySource? diary,
    WorkoutHistorySource? workouts,
  }) =>
      ContextAssembler(
        profiles: env.profiles,
        memory: env.memory,
        conversation: env.conv,
        diary: diary ?? const _Empty(),
        workouts: workouts ?? const _EmptyW(),
        config: config,
        clock: () => now,
      );

  Future<void> addChat(int n, {String prefix = 'сообщение', int len = 0}) async {
    for (var i = 0; i < n; i++) {
      final pad = len > 0 ? ' ${'слово ' * (len ~/ 6)}' : '';
      await env.conv.addMessage(
          role: i.isEven ? 'user' : 'fitty',
          body: '$prefix $i$pad',
          at: now.subtract(Duration(minutes: n - i)));
    }
  }

  test('профиль, норма и дата попадают в контекст', () async {
    final c = await make().assemble();
    expect(c.contextText, contains('[СЕЙЧАС] 2026-03-10 вторник, 18:30'));
    expect(c.contextText, contains('Аня'));
    expect(c.contextText, contains('30 лет'));
    expect(c.contextText, contains('рост 165'));
    expect(c.contextText, contains('вес 80'));
    expect(c.contextText, contains('цель 70'));
    expect(c.contextText, contains('Норма:'));
    expect(c.contextText, contains('талия 90'));
  });

  test('актуальная память есть, заменённые факты не попадают', () async {
    final mem = MemoryService(env.memory, clock: () => now);
    await mem.apply([
      const MemoryUpdate(key: 'food.diet', fact: 'Вегетарианка', confidence: 0.9)
    ]);
    await mem.apply([
      const MemoryUpdate(
          key: 'food.diet', fact: 'Ест рыбу, но не мясо', confidence: 0.9),
      const MemoryUpdate(
          key: 'intolerance.lactose', fact: 'Нет лактозы', category: 'intolerance'),
    ]);
    final c = await make().assemble();
    expect(c.contextText, contains('Ест рыбу, но не мясо'));
    expect(c.contextText, contains('Нет лактозы'));
    expect(c.contextText, isNot(contains('Вегетарианка')));
  });

  test('пустая память: Фитти прямо сказано, что узнавать в разговоре',
      () async {
    final c = await make().assemble();
    expect(c.contextText, contains('[ПАМЯТЬ] Пока ничего не известно'));
  });

  test('слоты части 2 пусты: честная пометка, без остатка калорий', () async {
    final c = await make().assemble();
    expect(c.contextText, contains('Дневник питания пока не ведётся'));
    expect(c.contextText, isNot(contains('Остаток')));
    expect(c.contextText, isNot(contains('[ТРЕНИРОВКИ]')));
    expect(c.contextText, isNot(contains('[НЕДЕЛЯ]')));
  });

  test('слоты части 2 наполнены: дневник, остаток, неделя, тренировки',
      () async {
    final c = await make(diary: FakeDiary(), workouts: FakeWorkouts())
        .assemble();
    expect(c.contextText, contains('[СЕГОДНЯ]'));
    expect(c.contextText, contains('Овсянка с ягодами'));
    expect(c.contextText, contains('Итого ~840 ккал'));
    expect(c.contextText, contains('Остаток на сегодня'));
    expect(c.contextText, contains('[НЕДЕЛЯ]'));
    expect(c.contextText, contains('[ТРЕНИРОВКИ]'));
    expect(c.contextText, contains('Кардио 20 мин'));
  });

  test('последние сообщения: порядок, роли, начинается с user', () async {
    await addChat(5);
    final c = await make().assemble();
    expect(c.turns.first.role, 'user');
    expect(c.turns.map((t) => t.role).toSet().length, greaterThan(1));
    expect(c.turns.last.text, contains('сообщение 4'));
    // роли чередуются (подряд одинаковые склеены)
    for (var i = 1; i < c.turns.length; i++) {
      expect(c.turns[i].role, isNot(c.turns[i - 1].role));
    }
  });

  test('служебные сообщения (notice) не попадают в контекст', () async {
    await env.conv.addMessage(role: 'user', body: 'привет', at: now);
    await env.conv
        .addMessage(role: 'fitty', kind: 'notice', body: 'ОШИБКА СЕТИ', at: now);
    final c = await make().assemble();
    expect(c.turns.map((t) => t.text).join(), isNot(contains('ОШИБКА СЕТИ')));
  });

  test('фото и голос описываются текстом, без выдумок', () async {
    await env.conv.addMessage(
        role: 'user', images: ['/a.jpg', '/b.jpg'], at: now);
    await env.conv
        .addMessage(role: 'user', audioPath: '/v.m4a', audioMs: 5000, at: now);
    final c = await make().assemble();
    final all = c.turns.map((t) => t.text).join('\n');
    expect(all, contains('фото: 2'));
    expect(all, contains('голосовое'));
  });

  group('лимит размера', () {
    test('общий бюджет соблюдается при огромных данных', () async {
      final mem = MemoryService(env.memory, clock: () => now);
      // 8 фактов за раз × много раз
      for (var batch = 0; batch < 12; batch++) {
        await mem.apply([
          for (var i = 0; i < 8; i++)
            MemoryUpdate(
                key: 'k.$batch.$i',
                fact: 'Очень длинный факт номер $batch-$i ${'подробность ' * 12}',
                confidence: 0.8)
        ]);
      }
      await addChat(60, len: 600);
      for (var i = 0; i < 30; i++) {
        final msgs = await env.conv.pendingForSummary(keepLast: 12);
        if (msgs.isEmpty) break;
        await env.conv.addSummary(
            body: 'Резюме $i: ${'обсуждали питание ' * 20}',
            covered: [msgs.first],
            now: now);
      }

      const cfg = ContextConfig(totalBudget: 1500);
      final c = await make(config: cfg, diary: FakeDiary(), workouts: FakeWorkouts())
          .assemble();
      expect(c.tokens, lessThanOrEqualTo(cfg.totalBudget));
      expect(c.turns, isNotEmpty);
      // самое важное осталось: профиль и сегодняшняя дата
      expect(c.contextText, contains('[ПРОФИЛЬ]'));
      expect(c.contextText, contains('[СЕЙЧАС]'));
      expect(c.turns.last.text, contains('сообщение 59'));
    });

    test('каждая секция в своём бюджете', () async {
      final mem = MemoryService(env.memory, clock: () => now);
      for (var b = 0; b < 10; b++) {
        await mem.apply([
          for (var i = 0; i < 8; i++)
            MemoryUpdate(key: 'x.$b.$i', fact: 'Факт ${'длинный ' * 20} $b$i')
        ]);
      }
      const cfg = ContextConfig(memoryBudget: 200, totalBudget: 10000);
      final c = await make(config: cfg).assemble();
      expect(c.sections['memory'], lessThanOrEqualTo(200));
      // обрезается по строкам: нет «рваных» фактов
      final lines = c.contextText
          .split('\n')
          .where((l) => l.startsWith('- ['))
          .toList();
      expect(lines.every((l) => l.contains('Факт')), isTrue);
    });

    test('при нехватке бюджета режутся неважные секции, не профиль', () async {
      final mem = MemoryService(env.memory, clock: () => now);
      await mem.apply([
        const MemoryUpdate(
            key: 'health.heart',
            fact: 'Проблемы с сердцем, нужна осторожность',
            category: 'health',
            confidence: 0.95)
      ]);
      await addChat(10);
      const cfg = ContextConfig(totalBudget: 200);
      final c =
          await make(config: cfg, diary: FakeDiary(), workouts: FakeWorkouts())
              .assemble();
      expect(c.tokens, lessThanOrEqualTo(200));
      expect(c.contextText, contains('[ПРОФИЛЬ]'));
      expect(c.contextText, contains('Проблемы с сердцем'));
      expect(c.contextText, isNot(contains('[НЕДЕЛЯ]')));
    });

    test('длинное сообщение обрезается', () async {
      await env.conv
          .addMessage(role: 'user', body: 'я ' * 5000, at: now);
      final c = await make().assemble();
      final t = c.turns.last.text;
      expect(ContextConfig.estimateTokens(t),
          lessThanOrEqualTo(ContextConfig.defaults.messageMaxTokens + 1));
    });

    test('бюджет настраивается: меньше бюджет — меньше контекст', () async {
      await addChat(40, len: 300);
      final big = await make(config: const ContextConfig(totalBudget: 6000))
          .assemble();
      final small =
          await make(config: const ContextConfig(totalBudget: 700)).assemble();
      expect(small.tokens, lessThan(big.tokens));
      expect(small.tokens, lessThanOrEqualTo(700));
    });
  });

  group('сжатие старых разговоров', () {
    test('мало сообщений: сжатие не нужно', () async {
      await addChat(20);
      final c = await make().assemble();
      expect(c.needsSummary, isFalse);
    });

    test('много старых сообщений: просим резюме', () async {
      await addChat(60);
      final c = await make().assemble();
      expect(c.needsSummary, isTrue);
    });

    test('после резюме старые сообщения помечены и вместо них идёт резюме',
        () async {
      await addChat(60);
      final pending = await env.conv.pendingForSummary(keepLast: 12);
      expect(pending.length, 48);
      await env.conv.addSummary(
          body: 'Обсуждали завтраки и срыв на выходных',
          covered: pending,
          now: now);

      expect(await env.conv.pendingForSummary(keepLast: 12), isEmpty);
      final c = await make().assemble();
      expect(c.needsSummary, isFalse);
      expect(c.contextText, contains('[РЕЗЮМЕ ПРОШЛЫХ РАЗГОВОРОВ]'));
      expect(c.contextText, contains('срыв на выходных'));
      // сами сообщения целы в базе
      expect((await env.conv.recent(limit: 500)).length, 60);
      // последние сообщения остались «как есть»
      expect(c.turns.last.text, contains('сообщение 59'));
    });

    test('последние keepRecentRaw сообщений никогда не сжимаются', () async {
      await addChat(40);
      final pending = await env.conv.pendingForSummary(keepLast: 12);
      final texts = pending.map((m) => m.body).join();
      expect(texts, isNot(contains('сообщение 39')));
      expect(texts, isNot(contains('сообщение 28')));
      expect(texts, contains('сообщение 27'));
    });
  });
}

class _Empty implements DiarySource {
  const _Empty();
  @override
  bool get available => false;
  @override
  Future<DiaryDay> today(DateTime now) async =>
      DiaryDay(date: now, items: const []);
  @override
  Future<List<DiaryDay>> lastDays(DateTime now, int days) async => const [];
}

class _EmptyW implements WorkoutHistorySource {
  const _EmptyW();
  @override
  Future<List<WorkoutBrief>> recent(DateTime now, {int limit = 5}) async =>
      const [];
}
