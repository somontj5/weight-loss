import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:weightloss/config/ai_config.dart';
import 'package:weightloss/config/context_config.dart';
import 'package:weightloss/data/repositories/settings_repository_impl.dart';
import 'package:weightloss/data/repositories/usage_repository.dart';
import 'package:weightloss/domain/actions/action_dispatcher.dart';
import 'package:weightloss/domain/actions/set_activity_handler.dart';
import 'package:weightloss/domain/context/context_assembler.dart';
import 'package:weightloss/domain/memory/memory_service.dart';
import 'package:weightloss/domain/profile_service.dart';
import 'package:weightloss/domain/settings/settings_repository.dart';
import 'package:weightloss/services/ai/ai_exceptions.dart';
import 'package:weightloss/services/ai/gemini_client.dart';
import 'package:weightloss/services/ai/media_preparer.dart';
import 'package:weightloss/services/ai/model_router.dart';
import 'package:weightloss/services/ai/quota_manager.dart';
import 'package:weightloss/services/ai/reply_parser.dart';
import 'package:weightloss/services/chat_service.dart';

import 'helpers.dart';

Uint8List png(int w, int h) =>
    Uint8List.fromList(img.encodePng(img.Image(width: w, height: h)));

class _Rec implements ModelTransport {
  _Rec(this.behaviour);
  final Map<String, Object> behaviour;
  final calls = <String>[];
  List<Attachment> lastAttachments = const [];

  @override
  Future<String> generate(
      {required String model,
      required String system,
      required List<ChatTurn> turns,
      List<Attachment> attachments = const []}) async {
    calls.add(model);
    lastAttachments = attachments;
    final b = behaviour[model] ?? '{"reply":"ok"}';
    if (b is AiException) throw b;
    return b as String;
  }
}

void main() {
  final now = DateTime(2026, 3, 10, 12);

  group('сжатие фото и сборка запроса', () {
    test('большое фото сжимается до 1024 px по длинной стороне, это JPEG', () {
      final out = MediaPreparer.compressJpeg(png(3000, 1500))!;
      final im = img.decodeJpg(out)!;
      expect(im.width, 1024);
      expect(im.height, 512);
    });

    test('маленькое фото не увеличивается; не картинка — null', () {
      final im = img.decodeJpg(MediaPreparer.compressJpeg(png(400, 300))!)!;
      expect(im.width, 400);
      expect(MediaPreparer.compressJpeg(Uint8List.fromList([1, 2, 3])), isNull);
    });

    test('максимум 4 фото за запрос, битое пропускается, аудио добавляется',
        () async {
      final p = MediaPreparer(reader: (path) async {
        if (path == 'bad') return Uint8List.fromList([0, 1]);
        if (path.endsWith('.m4a')) return Uint8List.fromList([9, 9, 9]);
        return png(50, 50);
      });
      final r = await p.prepare(
          images: ['a', 'b', 'bad', 'c', 'd', 'e', 'f'], audioPath: 'v.m4a');
      final photos = r.where((a) => !a.isAudio).toList();
      // из первых четырёх одно битое
      expect(photos.length, 3);
      expect(photos.every((a) => a.mime == 'image/jpeg'), isTrue);
      final audio = r.singleWhere((a) => a.isAudio);
      expect(audio.mime, 'audio/mp4');
    });

    test('mime аудио по расширению', () {
      expect(MediaPreparer.audioMime('x.webm'), 'audio/webm');
      expect(MediaPreparer.audioMime('x.wav'), 'audio/wav');
      expect(MediaPreparer.audioMime('x.m4a'), 'audio/mp4');
    });

    test('inlineData уходит в ПОСЛЕДНЕЕ сообщение пользователя', () {
      const cfg = AiConfig(apiKey: 'k');
      final body = GeminiClient(cfg).buildBody('sys', const [
        ChatTurn('user', 'раньше'),
        ChatTurn('model', 'ответ'),
        ChatTurn('user', 'вот еда'),
      ], [
        Attachment(mime: 'image/jpeg', bytes: Uint8List.fromList([1, 2])),
        Attachment(
            mime: 'audio/mp4',
            bytes: Uint8List.fromList([3]),
            isAudio: true),
      ]);
      final contents = body['contents'] as List;
      expect((contents[0]['parts'] as List).length, 1);
      final last = contents[2]['parts'] as List;
      expect(last.length, 3);
      expect(last[0]['inlineData']['mimeType'], 'image/jpeg');
      expect(last[0]['inlineData']['data'], base64Encode([1, 2]));
      expect(last[1]['inlineData']['mimeType'], 'audio/mp4');
      expect(last[2]['text'], 'вот еда');
    });
  });

  group('пересчёт нормы (set_activity)', () {
    late Env env;
    late SettingsRepositoryImpl settings;
    late ProfileService ps;

    setUp(() async {
      env = Env(now);
      settings = SettingsRepositoryImpl(env.db);
      ps = ProfileService(env.profiles, settings: settings, clock: () => now);
      await ps.save(
          (await (() async {
            await env.seedProfile();
            return env.profiles.getProfile();
          })())!,
          weeks: 12);
    });
    tearDown(() => env.close());

    test('уровень сохраняется, новая норма, подвал «было X, стало Y»',
        () async {
      final before = (await env.profiles.getDietPlan())!.kcal;
      final histBefore = (await env.profiles.weightHistory(limit: 50)).length;
      final d = ActionDispatcher(
        memory: MemoryService(env.memory, clock: () => now),
        handlers: [SetActivityHandler(ps)],
      );
      final r = await d.handle(
        ReplyParser.parse(
            '{"reply":"ок","actions":[{"type":"set_activity","level":"high"}]}'),
        DispatchContext(userMessageId: 1, now: now),
      );
      final after = (await env.profiles.getDietPlan())!.kcal;
      expect(await settings.get(SettingKeys.activityLevel), 'high');
      expect(after, greaterThan(before));
      expect(r.footers.single, 'Пересчитал норму: было $before, стало $after ккал');
      // история цифр не тронута
      expect((await env.profiles.weightHistory(limit: 50)).length, histBefore);
    });

    test('неверный уровень игнорируется, норма не меняется', () async {
      final before = (await env.profiles.getDietPlan())!.kcal;
      final d = ActionDispatcher(
        memory: MemoryService(env.memory, clock: () => now),
        handlers: [SetActivityHandler(ps)],
      );
      final r = await d.handle(
        ReplyParser.parse(
            '{"reply":"ок","actions":[{"type":"set_activity","level":"super"}]}'),
        DispatchContext(userMessageId: 1, now: now),
      );
      expect(r.footers, isEmpty);
      expect((await env.profiles.getDietPlan())!.kcal, before);
      expect(await settings.get(SettingKeys.activityLevel), isNull);
    });

    test('правка профиля потом учитывает сохранённый уровень', () async {
      await ps.applyActivity('sedentary');
      final low = (await env.profiles.getDietPlan())!.kcal;
      await ps.applyActivity('high');
      final high = (await env.profiles.getDietPlan())!.kcal;
      expect(high, greaterThan(low));
      await ps.save((await env.profiles.getProfile())!,
          weeks: 12, source: 'settings');
      expect((await env.profiles.getDietPlan())!.kcal, high);
    });
  });

  group('ошибка неверной модели', () {
    const cfg = AiConfig(
      apiKey: 'k',
      models: [
        ModelQuota(name: 'bad1', dailyLimit: 10),
        ModelQuota(name: 'good2', dailyLimit: 10),
      ],
      safetyMargin: 0,
    );
    late Env env;
    setUp(() => env = Env(now));
    tearDown(() => env.close());

    ModelRouter router(_Rec tr) => ModelRouter(
        tr, QuotaManager(UsageRepository(env.db), cfg, clock: () => now), cfg);

    test('разбор HTTP: 404 и 400 «not found» → AiModelNotFound с именем', () {
      expect(
          () => GeminiClient.parseHttp(404, '{}', model: 'abc'),
          throwsA(isA<AiModelNotFound>()
              .having((e) => e.userMessage, 'msg', contains('abc'))));
      expect(
          () => GeminiClient.parseHttp(
              400, '{"error":{"message":"models/x is not found"}}',
              model: 'x'),
          throwsA(isA<AiModelNotFound>()));
      // а это по-прежнему плохой ключ
      expect(() => GeminiClient.parseHttp(400, 'API key not valid', model: 'x'),
          throwsA(isA<AiBadKey>()));
    });

    test('сообщение содержит подсказку про GEMINI_MODEL_PRIMARY/FALLBACK', () {
      final m = AiModelNotFound(['m']).userMessage;
      expect(m, contains('GEMINI_MODEL_PRIMARY'));
      expect(m, contains('GEMINI_MODEL_FALLBACK'));
    });

    test('неверная модель пропускается, вторая отвечает; больше не опрашивается',
        () async {
      final tr = _Rec({'bad1': AiModelNotFound(['bad1'])});
      final r = router(tr);
      final a = await r.generate(system: 's', turns: const [ChatTurn('user', 'q')]);
      expect(a.model, 'good2');
      await r.generate(system: 's', turns: const [ChatTurn('user', 'q')]);
      expect(tr.calls, ['bad1', 'good2', 'good2']);
    });

    test('обе неверные: понятная ошибка, повторно сеть не трогаем', () async {
      final tr = _Rec({
        'bad1': AiModelNotFound(['bad1']),
        'good2': AiModelNotFound(['good2']),
      });
      final r = router(tr);
      await expectLater(
          r.generate(system: 's', turns: const [ChatTurn('user', 'q')]),
          throwsA(isA<AiModelNotFound>()));
      final n = tr.calls.length;
      await expectLater(
          r.generate(system: 's', turns: const [ChatTurn('user', 'q')]),
          throwsA(isA<AiModelNotFound>()));
      expect(tr.calls.length, n);
    });

    test('ChatService показывает сообщение, не падает', () async {
      final tr = _Rec({
        'bad1': AiModelNotFound(['bad1']),
        'good2': AiModelNotFound(['good2']),
      });
      await env.seedProfile();
      final svc = ChatService(
        assembler: ContextAssembler(
            profiles: env.profiles,
            memory: env.memory,
            conversation: env.conv,
            clock: () => now),
        router: router(tr),
        dispatcher: ActionDispatcher(
            memory: MemoryService(env.memory, clock: () => now)),
        conversation: env.conv,
        aiConfig: cfg,
        contextConfig: ContextConfig.defaults,
        clock: () => now,
      );
      final id = await env.conv.addMessage(role: 'user', body: 'привет');
      final r = await svc.respond(userMessageId: id, text: 'привет');
      expect(r.notice, isTrue);
      expect(r.text, contains('GEMINI_MODEL_PRIMARY'));
    });
  });

  group('голос: heard и вложения в ChatService', () {
    test('heard пишется в текст сообщения; аудио и ≤4 фото уходят в модель',
        () async {
      const cfg = AiConfig(
          apiKey: 'k',
          models: [ModelQuota(name: 'm1', dailyLimit: 10)],
          safetyMargin: 0);
      final env = Env(now);
      addTearDown(env.close);
      await env.seedProfile();
      final tr = _Rec({'m1': '{"reply":"Поняла","heard":"съел борщ"}'});
      final svc = ChatService(
        assembler: ContextAssembler(
            profiles: env.profiles,
            memory: env.memory,
            conversation: env.conv,
            clock: () => now),
        router: ModelRouter(tr,
            QuotaManager(UsageRepository(env.db), cfg, clock: () => now), cfg),
        dispatcher: ActionDispatcher(
            memory: MemoryService(env.memory, clock: () => now)),
        conversation: env.conv,
        aiConfig: cfg,
        contextConfig: ContextConfig.defaults,
        media: MediaPreparer(
            reader: (p) async =>
                p.endsWith('.m4a') ? Uint8List.fromList([1, 2]) : png(20, 20)),
        clock: () => now,
      );
      final id = await env.conv.addMessage(
          role: 'user', audioPath: 'v.m4a', images: ['1', '2', '3', '4', '5', '6']);
      final r = await svc.respond(
          userMessageId: id,
          images: ['1', '2', '3', '4', '5', '6'],
          audio: const Duration(seconds: 3),
          audioPath: 'v.m4a');
      expect(r.heard, 'съел борщ');
      final msg = (await env.conv.recent()).firstWhere((m) => m.id == id);
      expect(msg.body, 'съел борщ');
      expect(tr.lastAttachments.where((a) => !a.isAudio).length, 4);
      expect(tr.lastAttachments.where((a) => a.isAudio).length, 1);
    });
  });
}
