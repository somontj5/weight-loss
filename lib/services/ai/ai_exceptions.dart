/// Ошибки ИИ с честными сообщениями для человека.
sealed class AiException implements Exception {
  const AiException(this.userMessage);
  final String userMessage;

  @override
  String toString() => '$runtimeType: $userMessage';
}

/// Нет интернета.
class AiOffline extends AiException {
  const AiOffline()
      : super('Нет связи с интернетом, поэтому я не могу ответить. '
            'Сообщение сохранено, напиши мне ещё раз, когда сеть появится.');
}

/// Ключ не задан.
class AiNoKey extends AiException {
  const AiNoKey()
      : super('Ключ Gemini не подключён, я работаю в демо-режиме '
            'и отвечаю заготовками.');
}

/// Ключ неверный или не имеет доступа.
class AiBadKey extends AiException {
  const AiBadKey()
      : super('Ключ Gemini не подошёл (неверный или без доступа). '
            'Нужно собрать приложение с правильным ключом.');
}

/// Дневной лимит исчерпан у всех моделей.
class AiLimitReached extends AiException {
  const AiLimitReached()
      : super('На сегодня бесплатный лимит моих ответов закончился '
            '(у обеих моделей). Он обновится завтра. Сообщение сохранено, '
            'я отвечу, когда лимит вернётся.');
}

/// Слишком частые запросы (лимит в минуту).
class AiRateLimited extends AiException {
  const AiRateLimited({this.daily = false})
      : super('Сейчас слишком много запросов подряд. '
            'Подожди минуту и напиши ещё раз.');
  final bool daily;
}

/// Сбой на стороне сервиса или неожиданный ответ.
class AiUnavailable extends AiException {
  const AiUnavailable([String? detail])
      : super('Сервис ответов сейчас не отвечает. Попробуй через минуту.');
}

/// Ответ заблокирован фильтрами безопасности.
class AiBlocked extends AiException {
  const AiBlocked()
      : super('Я не смог ответить на это сообщение. '
            'Попробуй переформулировать.');
}

/// Модель не найдена (404, либо 400 с текстом «model not found»).
class AiModelNotFound extends AiException {
  AiModelNotFound(List<String> models)
      : models = List.unmodifiable(models),
        super('Gemini не нашёл модель «${models.join('», «')}». '
            'Скорее всего, имя написано неверно или модель закрыта для '
            'вашего ключа. Проверь имена при сборке приложения: '
            '--dart-define=GEMINI_MODEL_PRIMARY=... (основная) и '
            '--dart-define=GEMINI_MODEL_FALLBACK=... (запасная).');
  final List<String> models;
}
