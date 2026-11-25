import 'package:flutter_test/flutter_test.dart';
import 'package:weightloss/config/ai_config.dart';
import 'package:weightloss/data/repositories/data_export_service.dart';
import 'package:weightloss/data/repositories/usage_repository.dart';
import 'package:weightloss/domain/context/context_assembler.dart';
import 'package:weightloss/services/ai/ai_exceptions.dart';
import 'package:weightloss/services/ai/gemini_client.dart';
import 'package:weightloss/services/ai/model_router.dart';
import 'package:weightloss/services/ai/quota_manager.dart';

import 'helpers.dart';

class FakeTransport implements ModelTransport {
  final calls = <String>[];
  final Map<String, Object> behaviour = {}; // model -> String | AiException

  @override
  Future<String> generate(
      {required String model,
      required String system,
      required List<ChatTurn> turns}) async {
    calls.add(model);
    final b = behaviour[model] ?? '{"reply":"ok from $model"}';
    if (b is AiException) throw b;
    return b as String;
  }
}

void main() {
  const cfg = AiConfig(
    apiKey: 'test-key',
    models: [
      ModelQuota(name: 'm1', dailyLimit: 10),
      ModelQuota(name: 'm2', dailyLimit: 10),
    ],
    safetyMargin: 0,
  );

  late Env env;
  late FakeTransport tr;
  late QuotaManager quota;
  late ModelRouter router;
  var clock = DateTime.utc(2026, 3, 10, 20);

  setUp(() {
    clock = DateTime.utc(2026, 3, 10, 20);
    env = Env(clock);
    tr = FakeTransport();
    quota = QuotaManager(UsageRepository(env.db), cfg, clock: () => clock);
    router = ModelRouter(tr, quota, cfg);
  });
  tearDown(() => env.close());

  Future<RoutedResult> ask() => router.generate(system: 's', turns: const [
        ChatTurn('user', 'hi'),
      ]);

  test('сначала основная модель, счётчик растёт', () async {
    final r = await ask();
    expect(r.model, 'm1');
    expect(r.switched, isFalse);
    expect(await quota.used('m1'), 1);
    expect(await quota.used('m2'), 0);
  });

  test('лимит основной исчерпан: автоматически вторая', () async {
    for (var i = 0; i < 10; i++) {
      await ask();
    }
    expect(await quota.remaining(cfg.models[0]), 0);
    final r = await ask();
    expect(r.model, 'm2');
    expect(r.switched, isTrue);
    expect(tr.calls.where((c) => c == 'm1').length, 10);
  });

  test('лимит кончился у обеих: честная ошибка, к сети не ходим', () async {
    for (var i = 0; i < 20; i++) {
      await ask();
    }
    final before = tr.calls.length;
    await expectLater(ask(), throwsA(isA<AiLimitReached>()));
    expect(tr.calls.length, before);
    expect(const AiLimitReached().userMessage, contains('обеих'));
  });

  test('сервер ответил 429 «в день»: модель помечается исчерпанной, идём на вторую',
      () async {
    tr.behaviour['m1'] = const AiRateLimited(daily: true);
    final r = await ask();
    expect(r.model, 'm2');
    expect(await quota.remaining(cfg.models[0]), 0);
  });

  test('временный сбой первой: пробуем вторую, счётчик первой не растёт',
      () async {
    tr.behaviour['m1'] = const AiUnavailable();
    final r = await ask();
    expect(r.model, 'm2');
    expect(await quota.used('m1'), 0);
  });

  test('обе недоступны из-за сбоя — понятная ошибка', () async {
    tr.behaviour['m1'] = const AiUnavailable();
    tr.behaviour['m2'] = const AiUnavailable();
    await expectLater(ask(), throwsA(isA<AiUnavailable>()));
  });

  test('нет сети: сразу AiOffline, вторую не мучаем', () async {
    tr.behaviour['m1'] = const AiOffline();
    await expectLater(ask(), throwsA(isA<AiOffline>()));
    expect(tr.calls, ['m1']);
  });

  test('неверный ключ пробрасывается', () async {
    tr.behaviour['m1'] = const AiBadKey();
    await expectLater(ask(), throwsA(isA<AiBadKey>()));
  });

  test('без ключа: AiNoKey и ни одного запроса', () async {
    final r = ModelRouter(tr, quota, const AiConfig(apiKey: ''));
    await expectLater(
        r.generate(system: 's', turns: const []), throwsA(isA<AiNoKey>()));
    expect(tr.calls, isEmpty);
  });

  test('новый день (по тихоокеанскому времени): счётчик обнуляется', () async {
    for (var i = 0; i < 10; i++) {
      await ask();
    }
    expect(await quota.remaining(cfg.models[0]), 0);
    clock = clock.add(const Duration(hours: 24));
    expect(await quota.remaining(cfg.models[0]), 10);
  });

  test('запас safetyMargin уменьшает лимит', () async {
    const c = AiConfig(
        apiKey: 'k',
        models: [ModelQuota(name: 'a', dailyLimit: 500)],
        safetyMargin: 5);
    final q = QuotaManager(UsageRepository(env.db), c, clock: () => clock);
    expect(await q.remaining(c.models[0]), 495);
  });

  test('граница суток по Тихому океану', () {
    // Зима (PST, UTC-8): 07:59 UTC ещё вчера, 08:00 UTC уже сегодня.
    expect(QuotaManager.pacificDay(DateTime.utc(2026, 1, 15, 7, 59)),
        '2026-01-14');
    expect(QuotaManager.pacificDay(DateTime.utc(2026, 1, 15, 8, 0)),
        '2026-01-15');
    // Лето (PDT, UTC-7).
    expect(QuotaManager.pacificDay(DateTime.utc(2026, 7, 15, 6, 59)),
        '2026-07-14');
    expect(QuotaManager.pacificDay(DateTime.utc(2026, 7, 15, 7, 0)),
        '2026-07-15');
  });

  group('разбор ответа Gemini', () {
    test('успешный ответ', () {
      const body =
          '{"candidates":[{"content":{"parts":[{"text":"{\\"reply\\":\\"hi\\"}"}]}}]}';
      expect(GeminiClient.parseHttp(200, body), '{"reply":"hi"}');
    });

    test('мысли модели (thought) отбрасываются', () {
      const body =
          '{"candidates":[{"content":{"parts":[{"thought":true,"text":"думаю"},{"text":"ответ"}]}}]}';
      expect(GeminiClient.parseHttp(200, body), 'ответ');
    });

    test('коды ошибок → понятные исключения', () {
      expect(() => GeminiClient.parseHttp(429, '{"error":{"message":"quota PerDay"}}'),
          throwsA(isA<AiRateLimited>().having((e) => e.daily, 'daily', true)));
      expect(() => GeminiClient.parseHttp(429, '{}'),
          throwsA(isA<AiRateLimited>().having((e) => e.daily, 'daily', false)));
      expect(() => GeminiClient.parseHttp(403, '{}'), throwsA(isA<AiBadKey>()));
      expect(() => GeminiClient.parseHttp(400, 'API key not valid'),
          throwsA(isA<AiBadKey>()));
      expect(() => GeminiClient.parseHttp(500, '{}'),
          throwsA(isA<AiUnavailable>()));
      expect(() => GeminiClient.parseHttp(200, 'not json'),
          throwsA(isA<AiUnavailable>()));
      expect(() => GeminiClient.parseHttp(200, '{"candidates":[]}'),
          throwsA(isA<AiUnavailable>()));
      expect(
          () => GeminiClient.parseHttp(
              200, '{"promptFeedback":{"blockReason":"SAFETY"}}'),
          throwsA(isA<AiBlocked>()));
    });
  });

  group('экспорт и удаление данных', () {
    test('экспорт содержит все таблицы и данные', () async {
      await env.seedProfile();
      await env.conv.addMessage(role: 'user', body: 'привет');
      final data = await DataExportService(env.db).buildExport();
      final t = data['tables'] as Map<String, dynamic>;
      for (final name in [
        'profiles', 'profile_history', 'goals', 'memory_facts', 'diet_plans',
        'diary_entries', 'workouts', 'workout_results',
        'notification_schedule', 'messages', 'conversation_summaries',
      ]) {
        expect(t.containsKey(name), isTrue, reason: name);
      }
      expect((t['profiles'] as List).single['name'], 'Аня');
      expect((t['messages'] as List).single['body'], 'привет');
      expect((t['diet_plans'] as List), isNotEmpty);
    });

    test('полное удаление очищает все таблицы', () async {
      await env.seedProfile();
      await env.conv.addMessage(role: 'user', body: 'привет');
      await env.db.wipeAll();
      expect(await env.profiles.getProfile(), isNull);
      expect(await env.conv.recent(), isEmpty);
      final data = await DataExportService(env.db).buildExport();
      for (final rows in (data['tables'] as Map).values) {
        expect(rows, isEmpty);
      }
    });

    test('смена цифр пишет историю и пересчитывает норму', () async {
      await env.seedProfile();
      final p = (await env.profiles.getProfile())!;
      await env.service
          .save(p.copyWith(weightKg: 78), weeks: 10, source: 'settings');
      final hist = await env.profiles.weightHistory();
      expect(hist.map((e) => e.weightKg), [80, 78]);
      expect((await env.profiles.getGoal())!.weeks, 10);
      expect((await env.profiles.getDietPlan()), isNotNull);
    });
  });
}
