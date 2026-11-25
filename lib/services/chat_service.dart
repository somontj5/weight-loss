import 'package:weightloss/config/ai_config.dart';
import 'package:weightloss/config/context_config.dart';
import 'package:weightloss/domain/context/context_assembler.dart';
import 'package:weightloss/domain/entities/stored_message.dart';
import 'package:weightloss/domain/memory/memory_service.dart';
import 'package:weightloss/domain/repositories/repositories.dart';
import 'package:weightloss/services/ai/ai_exceptions.dart';
import 'package:weightloss/services/ai/demo_responder.dart';
import 'package:weightloss/services/ai/fitty_persona.dart';
import 'package:weightloss/services/ai/model_router.dart';
import 'package:weightloss/services/ai/reply_parser.dart';

class ChatReply {
  const ChatReply({
    required this.text,
    this.notice = false,
    this.model,
    this.switchedModel = false,
    this.memoryChanged = false,
  });

  final String text;

  /// true — служебное сообщение (ошибка, демо): в контекст модели не попадает.
  final bool notice;
  final String? model;
  final bool switchedModel;
  final bool memoryChanged;
}

/// Один «ход» разговора: контекст → Gemini → разбор ответа → память и резюме.
/// Всё в ОДНОМ запросе к модели: ответ, факты памяти и (при необходимости)
/// резюме старых сообщений.
class ChatService {
  ChatService({
    required this.assembler,
    required this.router,
    required this.memory,
    required this.conversation,
    required this.aiConfig,
    required this.contextConfig,
    DemoResponder? demo,
    DateTime Function()? clock,
  })  : demo = demo ?? DemoResponder(),
        _clock = clock ?? DateTime.now;

  final ContextAssembler assembler;
  final ModelRouter router;
  final MemoryService memory;
  final ConversationRepository conversation;
  final AiConfig aiConfig;
  final ContextConfig contextConfig;
  final DemoResponder demo;
  final DateTime Function() _clock;

  bool get demoMode => !aiConfig.hasKey;

  Future<ChatReply> respond({
    required int userMessageId,
    String text = '',
    List<String> images = const [],
    Duration? audio,
  }) async {
    if (demoMode) {
      final t = await demo.reply(
          text: text, imagePaths: images, audioDuration: audio);
      return ChatReply(
          text: '$t\n\n(Демо-режим: ключ Gemini не подключён.)', notice: true);
    }

    try {
      final ctx = await assembler.assemble();
      final batch = ctx.needsSummary ? await _summaryBatch() : <StoredMessage>[];

      final system = StringBuffer(FittyPersona.systemPrompt)
        ..writeln()
        ..writeln('=== КОНТЕКСТ ===')
        ..writeln(ctx.contextText);
      if (batch.isNotEmpty) {
        system
          ..writeln()
          ..writeln('[СЖАТЬ В РЕЗЮМЕ] Старые сообщения. Верни их краткое '
              'резюме в поле "summary":')
          ..writeln(_formatBatch(batch));
      }

      var turns = ctx.turns;
      if (turns.isEmpty) {
        turns = [
          ChatTurn('user', text.isEmpty ? '(сообщение без текста)' : text)
        ];
      }

      final routed =
          await router.generate(system: system.toString(), turns: turns);
      final parsed = ReplyParser.parse(routed.text);

      var memoryChanged = false;
      final updates = parsed.memoryUpdates;
      if (updates.isNotEmpty) {
        try {
          final r =
              await memory.apply(updates, sourceMessageId: userMessageId);
          memoryChanged = r.added + r.replaced + r.forgotten > 0;
        } catch (_) {
          // память не должна ронять ответ
        }
      }

      if (batch.isNotEmpty && parsed.summary != null) {
        try {
          var body = parsed.summary!;
          if (body.length > contextConfig.summaryMaxChars) {
            body = body.substring(0, contextConfig.summaryMaxChars);
          }
          await conversation.addSummary(
              body: body, covered: batch, now: _clock());
        } catch (_) {}
      }

      return ChatReply(
        text: parsed.text,
        model: routed.model,
        switchedModel: routed.switched,
        memoryChanged: memoryChanged,
      );
    } on AiException catch (e) {
      return ChatReply(text: e.userMessage, notice: true);
    } catch (_) {
      return const ChatReply(
          text: 'Ой, что-то пошло не так. Попробуй ещё раз.', notice: true);
    }
  }

  Future<List<StoredMessage>> _summaryBatch() async {
    final pending = await conversation.pendingForSummary(
        keepLast: contextConfig.keepRecentRaw);
    final out = <StoredMessage>[];
    var tokens = 0;
    for (final m in pending) {
      final line = _line(m);
      final cost = ContextConfig.estimateTokens(line);
      if (out.length >= contextConfig.summaryBatchMax ||
          tokens + cost > contextConfig.summaryInputTokens) {
        break;
      }
      tokens += cost;
      out.add(m);
    }
    return out;
  }

  String _line(StoredMessage m) {
    var t = m.body.trim();
    if (t.isEmpty && m.audioPath != null) t = '(голосовое)';
    if (m.images.isNotEmpty) t = '$t (фото: ${m.images.length})'.trim();
    t = ContextConfig.clipToTokens(t, 120);
    return '${m.isUser ? 'Человек' : 'Фитти'}: $t';
  }

  String _formatBatch(List<StoredMessage> batch) =>
      batch.map(_line).join('\n');
}
