import 'package:flutter_test/flutter_test.dart';
import 'package:weightloss/domain/entities/memory_fact.dart';
import 'package:weightloss/domain/memory/memory_service.dart';
import 'package:weightloss/services/ai/reply_parser.dart';

import 'helpers.dart';

void main() {
  late Env env;
  late MemoryService mem;

  setUp(() {
    env = Env(DateTime(2026, 3, 10, 12));
    mem = MemoryService(env.memory, clock: () => env.now);
  });
  tearDown(() => env.close());

  test('новый факт сохраняется как актуальный', () async {
    final r = await mem.apply([
      const MemoryUpdate(
          key: 'intolerance.lactose',
          fact: 'Не переносит молоко',
          category: 'intolerance',
          confidence: 0.9)
    ]);
    expect(r.added, 1);
    final a = await env.memory.active();
    expect(a.single.fact, 'Не переносит молоко');
    expect(a.single.category, 'intolerance');
    expect(a.single.confidence, 0.9);
  });

  test('изменённые слова: старый факт помечается заменённым', () async {
    await mem.apply([
      const MemoryUpdate(key: 'food.diet', fact: 'Вегетарианка', confidence: 0.9)
    ]);
    env.now = env.now.add(const Duration(days: 20));
    final r = await mem.apply([
      const MemoryUpdate(
          key: 'food.diet', fact: 'Снова ест рыбу и курицу', confidence: 0.9)
    ]);
    expect(r.replaced, 1);

    final active = await env.memory.active();
    expect(active.length, 1);
    expect(active.single.fact, 'Снова ест рыбу и курицу');

    final all = await env.memory.all();
    expect(all.length, 2);
    final old = all.firstWhere((f) => f.fact == 'Вегетарианка');
    expect(old.active, isFalse);
    expect(old.supersededBy, active.single.id);
  });

  test('противоречия не копятся: на ключ один актуальный факт', () async {
    for (final t in ['Работает из дома', 'Работает в офисе', 'Снова на удалёнке']) {
      await mem.apply(
          [MemoryUpdate(key: 'lifestyle.work', fact: t, confidence: 0.8)]);
    }
    final active = await env.memory.active();
    expect(active.where((f) => f.key == 'lifestyle.work').length, 1);
    expect(active.single.fact, 'Снова на удалёнке');
    expect((await env.memory.all()).length, 3);
  });

  test('тот же факт повторно: подтверждение, дубля нет', () async {
    await mem.apply([
      const MemoryUpdate(key: 'habit.sweets', fact: 'Любит сладкое', confidence: 0.6)
    ]);
    final r = await mem.apply([
      const MemoryUpdate(key: 'habit.sweets', fact: 'любит сладкое!', confidence: 0.9)
    ]);
    expect(r.confirmed, 1);
    final all = await env.memory.all();
    expect(all.length, 1);
    expect(all.single.confidence, 0.9);
  });

  test('догадка модели не вытесняет уверенный факт', () async {
    await mem.apply([
      const MemoryUpdate(key: 'health.knee', fact: 'Болит колено', confidence: 0.9)
    ]);
    final r = await mem.apply([
      const MemoryUpdate(key: 'health.knee', fact: 'Колено здорово', confidence: 0.3)
    ]);
    expect(r.ignored, 1);
    expect((await env.memory.active()).single.fact, 'Болит колено');
  });

  test('forget закрывает факт без замены', () async {
    await mem.apply([
      const MemoryUpdate(key: 'health.knee', fact: 'Болит колено', confidence: 0.9)
    ]);
    final r = await mem.apply(
        [const MemoryUpdate(key: 'health.knee', fact: '', forget: true)]);
    expect(r.forgotten, 1);
    expect(await env.memory.active(), isEmpty);
    expect((await env.memory.all()).single.active, isFalse);
  });

  test('мусор отсекается: пустой ключ/факт, длинный текст, лимит за ответ',
      () async {
    final r = await mem.apply([
      const MemoryUpdate(key: '', fact: 'x'),
      const MemoryUpdate(key: 'a.b', fact: '   '),
      MemoryUpdate(key: 'long.one', fact: 'я' * 1000),
      for (var i = 0; i < 20; i++) MemoryUpdate(key: 'k.$i', fact: 'факт $i'),
    ]);
    expect(r.added, lessThanOrEqualTo(MemoryService.maxUpdatesPerReply));
    final all = await env.memory.all();
    expect(all.length, lessThanOrEqualTo(MemoryService.maxUpdatesPerReply));
    expect(all.every((f) => f.fact.length <= MemoryService.maxFactChars), isTrue);
  });

  test('неизвестная категория становится other', () async {
    await mem.apply([
      const MemoryUpdate(key: 'x.y', fact: 'что-то', category: 'weird')
    ]);
    expect((await env.memory.active()).single.category, 'other');
  });

  group('разбор ответа модели', () {
    test('обычный JSON: текст + save_memory', () {
      final p = ReplyParser.parse('''
{"reply":"Запомнил!","actions":[{"type":"save_memory","facts":[
 {"key":"schedule.wake","fact":"Встаёт в 7","category":"schedule","confidence":0.9}]}]}''');
      expect(p.text, 'Запомнил!');
      expect(p.memoryUpdates.single.key, 'schedule.wake');
      expect(p.memoryUpdates.single.confidence, 0.9);
    });

    test('JSON в markdown-обёртке', () {
      final p = ReplyParser.parse('```json\n{"reply":"Привет"}\n```');
      expect(p.text, 'Привет');
      expect(p.wellFormed, isTrue);
    });

    test('не JSON: весь текст — ответ, ничего не падает', () {
      final p = ReplyParser.parse('Просто текст без JSON');
      expect(p.text, 'Просто текст без JSON');
      expect(p.wellFormed, isFalse);
      expect(p.memoryUpdates, isEmpty);
    });

    test('действия части 2 принимаются и игнорируются', () {
      final p = ReplyParser.parse('''
{"reply":"Ок","actions":[
 {"type":"log_food","items":[{"name":"яблоко"}]},
 {"type":"plan_workout"},
 {"type":"schedule_notification","at":"08:00"},
 {"type":"save_memory","facts":[{"key":"a.b","fact":"x"}]}]}''');
      expect(p.actions.length, 4);
      expect(p.memoryUpdates.length, 1);
      expect(p.deferredActions.map((a) => a.type),
          ['log_food', 'plan_workout', 'schedule_notification']);
    });

    test('битые факты пропускаются', () {
      final p = ReplyParser.parse(
          '{"reply":"a","actions":[{"type":"save_memory","facts":[1,{"fact":"без ключа"},{"key":"k","fact":""},{"key":"z","forget":true}]}]}');
      expect(p.memoryUpdates.single.key, 'z');
      expect(p.memoryUpdates.single.forget, isTrue);
    });
  });
}
