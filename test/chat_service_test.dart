import 'package:flutter_test/flutter_test.dart';
import 'package:weightloss/config/ai_config.dart';
import 'package:weightloss/config/context_config.dart';
import 'package:weightloss/data/repositories/usage_repository.dart';
import 'package:weightloss/domain/actions/action_dispatcher.dart';
import 'package:weightloss/domain/context/context_assembler.dart';
import 'package:weightloss/domain/memory/memory_service.dart';
import 'package:weightloss/services/ai/ai_exceptions.dart';
import 'package:weightloss/services/ai/gemini_client.dart';
import 'package:weightloss/services/ai/media_preparer.dart';
import 'package:weightloss/services/ai/model_router.dart';
import 'package:weightloss/services/ai/quota_manager.dart';
import 'package:weightloss/services/chat_service.dart';

import 'helpers.dart';

class Scripted implements ModelTransport {
  Scripted(this.answer);
  Object answer; // String | AiException
  final systems = <String>[];
  int calls = 0;

  @override
  Future<String> generate(
      {required String model,
      required String system,
      required List<ChatTurn> turns,
      List<Attachment> attachments = const []}) async {
    calls++;
    systems.add(system);
    final a = answer;
    if (a is AiException) throw a;
    return a as String;
  }
}

void main() {
  final now = DateTime(2026, 3, 10, 12);
  const cfg = AiConfig(
    apiKey: 'k',
    models: [ModelQuota(name: 'm1', dailyLimit: 100)],
    safetyMargin: 0,
  );
  late Env env;

  setUp(() async {
    env = Env(now);
    await env.seedProfile();
  });
  tearDown(() => env.close());

  ChatService make(Scripted tr, {AiConfig config = cfg}) {
    final quota = QuotaManager(UsageRepository(env.db), config, clock: () => now);
    final mem = MemoryService(env.memory, clock: () => now);
    return ChatService(
      assembler: ContextAssembler(
        profiles: env.profiles,
        memory: env.memory,
        conversation: env.conv,
        clock: () => now,
      ),
      router: ModelRouter(tr, quota, config),
      dispatcher: ActionDispatcher(memory: mem),
      conversation: env.conv,
      aiConfig: config,
      contextConfig: ContextConfig.defaults,
      clock: () => now,
    );
  }

  test('один запрос: ответ + память; в системный промт попали профиль и характер',
      () async {
    final tr = Scripted('''
{"reply":"Поняла, учту!","actions":[{"type":"save_memory","facts":[
 {"key":"intolerance.lactose","fact":"Нет лактозы","category":"intolerance","confidence":0.9}]}]}''');
    final id = await env.conv.addMessage(role: 'user', body: 'у меня нет лактозы');
    final r = await make(tr).respond(userMessageId: id, text: 'у меня нет лактозы');

    expect(r.text, 'Поняла, учту!');
    expect(r.memoryChanged, isTrue);
    expect(tr.calls, 1);
    expect((await env.memory.active()).single.fact, 'Нет лактозы');
    expect(tr.systems.single, contains('Ты — Фитти'));
    expect(tr.systems.single, contains('[ПРОФИЛЬ]'));
    expect(tr.systems.single, contains('Аня'));
  });

  test('много старых сообщений: резюме приходит в том же запросе', () async {
    for (var i = 0; i < 50; i++) {
      await env.conv.addMessage(
          role: i.isEven ? 'user' : 'fitty',
          body: 'реплика $i',
          at: now.subtract(Duration(minutes: 60 - i)));
    }
    final tr = Scripted(
        '{"reply":"Ок","summary":"Обсуждали ужины и режим сна"}');
    final id = await env.conv.addMessage(role: 'user', body: 'как дела', at: now);
    await make(tr).respond(userMessageId: id, text: 'как дела');

    expect(tr.calls, 1, reason: 'резюме не должно тратить отдельный запрос');
    expect(tr.systems.single, contains('[СЖАТЬ В РЕЗЮМЕ]'));
    final s = await env.conv.summaries();
    expect(s.single.body, 'Обсуждали ужины и режим сна');
    expect(s.single.messageCount, greaterThan(10));
  });

  test('модель вернула просто текст: показываем его, не падаем', () async {
    final tr = Scripted('Привет без JSON');
    final r = await make(tr).respond(userMessageId: 1, text: 'hi');
    expect(r.text, 'Привет без JSON');
    expect(r.notice, isFalse);
  });

  test('нет сети: честное служебное сообщение, не падает', () async {
    final r = await make(Scripted(const AiOffline()))
        .respond(userMessageId: 1, text: 'hi');
    expect(r.notice, isTrue);
    expect(r.text, contains('Нет связи'));
  });

  test('лимит исчерпан: честное сообщение про обе модели', () async {
    const c = AiConfig(
        apiKey: 'k',
        models: [ModelQuota(name: 'm1', dailyLimit: 1)],
        safetyMargin: 0);
    final tr = Scripted('{"reply":"ok"}');
    final svc = make(tr, config: c);
    await svc.respond(userMessageId: 1, text: 'a');
    final r = await svc.respond(userMessageId: 2, text: 'b');
    expect(r.notice, isTrue);
    expect(r.text, contains('лимит'));
    expect(tr.calls, 1);
  });

  test('без ключа: демо-режим, к модели не обращаемся', () async {
    const c = AiConfig(apiKey: '');
    final tr = Scripted('{"reply":"не должно вызываться"}');
    final svc = make(tr, config: c);
    expect(svc.demoMode, isTrue);
    final r = await svc.respond(userMessageId: 1, text: 'привет');
    expect(tr.calls, 0);
    expect(r.notice, isTrue);
    expect(r.text, contains('Демо-режим'));
  });

  test('ключ нигде не зашит в код', () {
    expect(const AiConfig().apiKey, isEmpty);
  });
}
