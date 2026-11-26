import 'package:weightloss/config/ai_config.dart';
import 'package:weightloss/config/context_config.dart';
import 'package:weightloss/domain/context/context_assembler.dart';
import 'package:weightloss/domain/entities/stored_message.dart';
import 'package:weightloss/domain/actions/action_dispatcher.dart';
import 'package:weightloss/domain/diary/diary_calc.dart';
import 'package:weightloss/domain/diary/food_action.dart';
import 'package:weightloss/domain/repositories/repositories.dart';
import 'package:weightloss/services/ai/ai_exceptions.dart';
import 'package:weightloss/services/ai/demo_responder.dart';
import 'package:weightloss/services/ai/fitty_persona.dart';
import 'package:weightloss/services/ai/media_preparer.dart';
import 'package:weightloss/services/ai/model_router.dart';
import 'package:weightloss/services/ai/reply_parser.dart';

class ChatReply {
  const ChatReply({
    required this.text,
    this.notice = false,
    this.model,
    this.switchedModel = false,
    this.memoryChanged = false,
    this.food,
    this.heard,
  });

  final String text;

  /// true — служебное сообщение (ошибка, демо): в контекст модели не попадает.
  final bool notice;
  final String? model;
  final bool switchedModel;
  final bool memoryChanged;

  /// Что сделано с дневником (если модель присылала log_food).
  final FoodLogOutcome? food;

  /// Расшифровка голосового (сохранена в тексте сообщения).
  final String? heard;
}

/// Один «ход» разговора: контекст → Gemini → разбор ответа → память и резюме.
/// Всё в ОДНОМ запросе к модели: ответ, факты памяти и (при необходимости)
/// резюме старых сообщений.
class ChatService {
  ChatService({
    required this.assembler,
    required this.router,
    required this.dispatcher,
    required this.conversation,
    required this.aiConfig,
    required this.contextConfig,
    this.calc,
    this.onScheduleDirty,
    this.coachBlock,
    this.afterReply,
    this.onAiStatus,
    MediaPreparer? media,
    DemoResponder? demo,
    DateTime Function()? clock,
  }) : demo = demo ?? DemoResponder(),
       media = media ?? MediaPreparer(),
       _clock = clock ?? DateTime.now;

  final ContextAssembler assembler;
  final ModelRouter router;
  final ActionDispatcher dispatcher;
  final DiaryCalc? calc;

  /// Вызывается, когда после ответа могло измениться расписание
  /// (записана еда, обновилась память о режиме дня, поставлено напоминание).
  final Future<void> Function()? onScheduleDirty;

  /// Блок [ДАННЫЕ ДЛЯ ТРЕНЕРА]: только факты, решает модель.
  final Future<String> Function()? coachBlock;

  /// Вызывается после успешного ответа модели.
  final Future<void> Function()? afterReply;

  /// Сообщает, отвечает ли ИИ (true) или недоступен (false).
  final void Function(bool ok)? onAiStatus;
  final MediaPreparer media;
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
    String? audioPath,
  }) async {
    if (demoMode) {
      final t = await demo.reply(
        text: text,
        imagePaths: images,
        audioDuration: audio,
      );
      return ChatReply(
        text: '$t\n\n(Демо-режим: ключ Gemini не подключён.)',
        notice: true,
      );
    }

    try {
      final ctx = await assembler.assemble();
      final batch = ctx.needsSummary
          ? await _summaryBatch()
          : <StoredMessage>[];

      final system = StringBuffer(FittyPersona.systemPrompt)
        ..writeln()
        ..writeln('=== КОНТЕКСТ ===')
        ..writeln(ctx.contextText);
      if (calc != null) {
        try {
          system
            ..writeln()
            ..writeln(await calc!.codeBlock());
        } catch (_) {}
      }
      if (coachBlock != null) {
        try {
          system
            ..writeln()
            ..writeln(await coachBlock!());
        } catch (_) {}
      }
      if (batch.isNotEmpty) {
        system
          ..writeln()
          ..writeln(
            '[СЖАТЬ В РЕЗЮМЕ] Старые сообщения. Верни их краткое '
            'резюме в поле "summary":',
          )
          ..writeln(_formatBatch(batch));
      }

      // Вложения: фото (≤4, сжатые) и голосовое — к последнему сообщению.
      final attachments = await media.prepare(
        images: images,
        audioPath: audioPath,
      );
      final photos = attachments.where((a) => !a.isAudio).length;
      final hasVoice = attachments.any((a) => a.isAudio);
      if (attachments.isNotEmpty) {
        system
          ..writeln()
          ..writeln(
            '[ВЛОЖЕНИЯ] К последнему сообщению человека приложено: '
            '${photos > 0 ? 'фото — $photos' : ''}'
            '${photos > 0 && hasVoice ? ', ' : ''}'
            '${hasVoice ? 'голосовое (слушай его сам)' : ''}. '
            'Смотри/слушай их. ${hasVoice ? 'В поле "heard" верни дословную расшифровку голосового. ' : ''}'
            '${images.length > photos ? 'Часть фото не дошла (максимум ${media.maxImages}). ' : ''}',
          );
      }

      var turns = ctx.turns;
      if (turns.isEmpty) {
        turns = [
          ChatTurn('user', text.isEmpty ? '(сообщение без текста)' : text),
        ];
      }

      final routed = await router.generate(
        system: system.toString(),
        turns: turns,
        attachments: attachments,
      );
      final parsed = ReplyParser.parse(routed.text);

      // Единая точка обработки действий (память, дневник, …).
      var dispatched = DispatchResult.empty;
      try {
        dispatched = await dispatcher.handle(
          parsed,
          DispatchContext(
            userMessageId: userMessageId,
            now: _clock(),
            images: images,
            hasAudio: audio != null,
          ),
        );
      } catch (_) {
        // действия не должны ронять ответ
      }

      if (dispatched.food != null ||
          dispatched.memoryChanged ||
          dispatched.footers.isNotEmpty) {
        try {
          await onScheduleDirty?.call();
        } catch (_) {}
      }

      String? heard;
      if (hasVoice && parsed.heard != null) {
        heard = parsed.heard!.length > 2000
            ? parsed.heard!.substring(0, 2000)
            : parsed.heard;
        try {
          await conversation.updateBody(userMessageId, heard!);
        } catch (_) {
          heard = null;
        }
      }

      if (batch.isNotEmpty && parsed.summary != null) {
        try {
          var body = parsed.summary!;
          if (body.length > contextConfig.summaryMaxChars) {
            body = body.substring(0, contextConfig.summaryMaxChars);
          }
          await conversation.addSummary(
            body: body,
            covered: batch,
            now: _clock(),
          );
        } catch (_) {}
      }

      final answer = dispatched.footers.isEmpty
          ? parsed.text
          : '${parsed.text}\n\n${dispatched.footers.join('\n')}';
      onAiStatus?.call(true);
      try {
        await afterReply?.call();
      } catch (_) {}
      return ChatReply(
        text: answer,
        model: routed.model,
        switchedModel: routed.switched,
        memoryChanged: dispatched.memoryChanged,
        food: dispatched.food,
        heard: heard,
      );
    } on AiException catch (e) {
      if (e is AiOffline) onAiStatus?.call(false);
      return ChatReply(text: e.userMessage, notice: true);
    } catch (_) {
      return const ChatReply(
        text: 'Ой, что-то пошло не так. Попробуй ещё раз.',
        notice: true,
      );
    }
  }

  Future<List<StoredMessage>> _summaryBatch() async {
    final pending = await conversation.pendingForSummary(
      keepLast: contextConfig.keepRecentRaw,
    );
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

  String _formatBatch(List<StoredMessage> batch) => batch.map(_line).join('\n');
}
