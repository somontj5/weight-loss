import 'package:weightloss/domain/diary/diary_calc.dart';
import 'package:weightloss/domain/diary/diary_service.dart';
import 'package:weightloss/domain/diary/food_action.dart';
import 'package:weightloss/domain/memory/memory_service.dart';
import 'package:weightloss/services/ai/reply_parser.dart';

/// Откуда пришло сообщение человека.
class DispatchContext {
  const DispatchContext({
    required this.userMessageId,
    required this.now,
    this.images = const [],
    this.hasAudio = false,
  });

  final int userMessageId;
  final DateTime now;
  final List<String> images;
  final bool hasAudio;

  String get foodSource => images.isNotEmpty
      ? 'chat_photo'
      : (hasAudio ? 'chat_voice' : 'chat_text');
}

class DispatchResult {
  const DispatchResult({
    this.memoryChanged = false,
    this.footers = const [],
    this.food,
    this.ignored = const [],
    this.clarify = false,
  });

  final bool memoryChanged;

  /// Строки, которые код добавляет под ответ Фитти.
  final List<String> footers;
  final FoodLogOutcome? food;

  /// Принятые, но пока не исполняемые действия (тренер, уведомления…).
  final List<String> ignored;
  final bool clarify;

  static const empty = DispatchResult();
}

/// ЕДИНАЯ точка обработки действий из ответа модели. Любое действие,
/// которого здесь нет, принимается и тихо игнорируется.
class ActionDispatcher {
  ActionDispatcher({
    required this.memory,
    this.diary,
    this.calc,
    this.handlers = const [],
    this.afterFood,
  });

  final MemoryService memory;
  final DiaryService? diary;
  final DiaryCalc? calc;

  /// Дополнительные обработчики (например, set_activity).
  final List<ActionHandler> handlers;

  /// После успешной записи еды (тренер может усложнить сегодняшний план).
  /// Возвращает строку-подвал или null.
  final Future<String?> Function()? afterFood;

  /// Типы действий частей 2Б/3: пока принимаются и игнорируются.
  static const deferredTypes = {
    'plan_workout',
    'schedule_notification',
    'cancel_notification',
    'coach_plan',
    'coach_note',
  };

  Future<DispatchResult> handle(ParsedReply parsed, DispatchContext ctx) async {
    var memoryChanged = false;
    final footers = <String>[];
    final ignored = <String>[];
    FoodLogOutcome? food;

    // 1. Память.
    final updates = parsed.memoryUpdates;
    if (updates.isNotEmpty) {
      try {
        final r = await memory.apply(
          updates,
          sourceMessageId: ctx.userMessageId,
        );
        memoryChanged = r.added + r.replaced + r.forgotten > 0;
      } catch (_) {
        // память не должна ронять ответ
      }
    }

    // 2. Уточнение: еду не записываем, считаем вопрос.
    if (calc != null) {
      try {
        final streak = await calc!.clarifyStreak();
        if (parsed.clarify) {
          if (streak < DiaryCalc.maxClarify) {
            await calc!.setClarifyStreak(streak + 1);
          }
        } else if (streak != 0) {
          await calc!.setClarifyStreak(0);
        }
      } catch (_) {}
    }

    // 3. Остальные действия по порядку. log_food — не больше одного
    // на сообщение.
    var foodDone = false;
    for (final a in parsed.actions) {
      switch (a.type) {
        case 'save_memory':
          break; // уже обработано выше
        case 'log_food':
          if (diary == null || parsed.clarify || foodDone) {
            ignored.add(a.type);
            break;
          }
          final req = FoodActionParser.parse(a.data, ctx.now);
          if (req == null) {
            ignored.add('log_food(некорректно)');
            break;
          }
          foodDone = true;
          try {
            food = await diary!.apply(
              req,
              messageId: ctx.userMessageId,
              source: ctx.foodSource,
              photos: ctx.foodSource == 'chat_photo' ? ctx.images : const [],
            );
            final f = await calc?.footer(food);
            if (f != null) footers.add(f);
            if (food.ok && afterFood != null) {
              final extra = await afterFood!();
              if (extra != null) footers.add(extra);
            }
          } catch (_) {
            ignored.add('log_food(ошибка)');
          }
        default:
          var taken = false;
          for (final h in handlers) {
            if (h.type != a.type) continue;
            try {
              final line = await h.handle(a.data, ctx);
              if (line != null) footers.add(line);
              taken = true;
            } catch (_) {
              taken = true;
            }
            break;
          }
          if (!taken) ignored.add(a.type);
      }
    }

    return DispatchResult(
      memoryChanged: memoryChanged,
      footers: footers,
      food: food,
      ignored: ignored,
      clarify: parsed.clarify,
    );
  }
}

/// Обработчик одного типа действия. Возвращает строку-подвал или null.
abstract class ActionHandler {
  String get type;
  Future<String?> handle(Map<String, dynamic> data, DispatchContext ctx);
}
