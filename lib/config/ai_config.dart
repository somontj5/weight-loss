/// Настройки Gemini. Ключ только через --dart-define:
///
///   flutter build apk --release --dart-define=GEMINI_API_KEY=ваш_ключ
///
/// Ключ бесплатно берётся в Google AI Studio (aistudio.google.com).
/// Имена моделей и лимиты можно переопределить так же:
///   --dart-define=GEMINI_MODEL_PRIMARY=gemini-3.1-flash-lite
///   --dart-define=GEMINI_MODEL_FALLBACK=gemini-3.5-flash-lite
///   --dart-define=GEMINI_DAILY_LIMIT=500
class AiConfig {
  const AiConfig({
    this.apiKey = const String.fromEnvironment('GEMINI_API_KEY'),
    this.baseUrl = 'https://generativelanguage.googleapis.com/v1beta',
    this.models = const [
      ModelQuota(
        name: String.fromEnvironment('GEMINI_MODEL_PRIMARY',
            defaultValue: 'gemini-3.1-flash-lite'),
        dailyLimit: int.fromEnvironment('GEMINI_DAILY_LIMIT',
            defaultValue: 500),
      ),
      ModelQuota(
        name: String.fromEnvironment('GEMINI_MODEL_FALLBACK',
            defaultValue: 'gemini-3.5-flash-lite'),
        dailyLimit: int.fromEnvironment('GEMINI_DAILY_LIMIT',
            defaultValue: 500),
      ),
    ],
    this.timeout = const Duration(seconds: 45),
    this.maxOutputTokens = 1200,
    this.temperature = 0.8,
    this.safetyMargin = 5,
  });

  final String apiKey;
  final String baseUrl;

  /// По порядку приоритета: первая — основная, дальше запасные.
  final List<ModelQuota> models;
  final Duration timeout;
  final int maxOutputTokens;
  final double temperature;

  /// Запас под запросы, которые не видит наш счётчик (500 → 495).
  final int safetyMargin;

  bool get hasKey => apiKey.trim().isNotEmpty;

  static const defaults = AiConfig();
}

class ModelQuota {
  const ModelQuota({required this.name, required this.dailyLimit});
  final String name;
  final int dailyLimit;
}
