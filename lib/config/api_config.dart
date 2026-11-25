/// Настройки LLM-API. Ключ НЕ хранится в коде — передаётся при сборке:
///
///   flutter build apk --release \
///     --dart-define=FITTY_API_KEY=ваш_ключ \
///     --dart-define=FITTY_API_URL=https://openrouter.ai/api/v1 \
///     --dart-define=FITTY_MODEL=meta-llama/llama-3.3-70b-instruct:free
///
/// Подойдёт любой OpenAI-совместимый эндпоинт (/chat/completions):
/// OpenRouter, Groq, Together, Gemini (через openai-совместимый URL) и т.д.
/// Без ключа приложение работает в демо-режиме (локальный генератор).
class ApiConfig {
  static const apiKey = String.fromEnvironment('FITTY_API_KEY');
  static const baseUrl = String.fromEnvironment(
    'FITTY_API_URL',
    defaultValue: 'https://openrouter.ai/api/v1',
  );
  static const model = String.fromEnvironment(
    'FITTY_MODEL',
    defaultValue: 'meta-llama/llama-3.3-70b-instruct:free',
  );

  static bool get hasKey => apiKey.trim().isNotEmpty;

  static Uri get chatUri {
    final b = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$b/chat/completions');
  }
}
