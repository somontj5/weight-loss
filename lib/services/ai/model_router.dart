import 'package:weightloss/config/ai_config.dart';
import 'package:weightloss/domain/context/context_assembler.dart';
import 'package:weightloss/services/ai/ai_exceptions.dart';
import 'package:weightloss/services/ai/gemini_client.dart';
import 'package:weightloss/services/ai/media_preparer.dart';
import 'package:weightloss/services/ai/quota_manager.dart';

class RoutedResult {
  const RoutedResult(this.text, this.model, this.switched);
  final String text;
  final String model;

  /// true — основная модель недоступна, ответила запасная.
  final bool switched;
}

/// Выбирает модель по остатку лимита и переключается на запасную.
class ModelRouter {
  ModelRouter(this._transport, this._quota, this._config);

  final ModelTransport _transport;
  final QuotaManager _quota;
  final AiConfig _config;

  Future<RoutedResult> generate(
      {required String system,
      required List<ChatTurn> turns,
      List<Attachment> attachments = const []}) async {
    if (!_config.hasKey) throw const AiNoKey();

    final candidates = await _quota.available();
    if (candidates.isEmpty) throw const AiLimitReached();

    AiException? last;
    for (final m in candidates) {
      try {
        final text = await _transport.generate(
            model: m.name,
            system: system,
            turns: turns,
            attachments: attachments);
        await _quota.recordSuccess(m.name);
        return RoutedResult(
            text, m.name, m.name != _config.models.first.name);
      } on AiRateLimited catch (e) {
        if (e.daily) await _quota.markExhausted(m);
        last = e;
      } on AiUnavailable catch (e) {
        last = e;
      } on AiOffline {
        rethrow; // со второй моделью сети не станет больше
      }
      // AiBadKey / AiBlocked / AiNoKey пробрасываются сами.
    }

    // Все перебраны. Если лимит кончился у всех — говорим об этом честно.
    if (last is AiRateLimited && last.daily && (await _quota.available()).isEmpty) {
      throw const AiLimitReached();
    }
    throw last ?? const AiUnavailable();
  }
}
