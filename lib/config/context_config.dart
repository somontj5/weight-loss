/// Бюджет размера контекста. Всё в «токенах» (оценка, см. [estimateTokens]).
/// Меняется здесь в одном месте.
class ContextConfig {
  const ContextConfig({
    this.totalBudget = 5000,
    this.profileBudget = 350,
    this.memoryBudget = 800,
    this.todayBudget = 400,
    this.weekBudget = 350,
    this.workoutsBudget = 250,
    this.rationBudget = 320,
    this.weightBudget = 220,
    this.summariesBudget = 600,
    this.recentBudget = 1500,
    this.recentMessagesMax = 12,
    this.messageMaxTokens = 350,
    this.summarizeWhenPending = 30,
    this.keepRecentRaw = 12,
    this.summaryMaxChars = 900,
    this.summaryInputTokens = 1800,
    this.summaryBatchMax = 40,
  });

  /// Потолок всего контекста (без системного промта характера).
  final int totalBudget;
  final int profileBudget;
  final int memoryBudget;

  /// Слоты части 2: пока пустые, но место зарезервировано.
  final int todayBudget;
  final int weekBudget;
  final int workoutsBudget;
  final int rationBudget;
  final int weightBudget;
  final int summariesBudget;
  final int recentBudget;

  /// Сколько последних сообщений максимум берём «как есть».
  final int recentMessagesMax;

  /// Длинное сообщение обрезается до этого размера.
  final int messageMaxTokens;

  /// Когда несжатых старых сообщений набралось столько — просим резюме.
  final int summarizeWhenPending;

  /// Последние сообщения, которые никогда не сжимаются.
  final int keepRecentRaw;
  final int summaryMaxChars;

  /// Сколько старых сообщений (в токенах и штуках) отдаём на сжатие за раз.
  final int summaryInputTokens;
  final int summaryBatchMax;

  static const defaults = ContextConfig();

  /// Грубая, но стабильная оценка: для русского ~2,6 символа на токен.
  static int estimateTokens(String s) => (s.length / 2.6).ceil();

  static String clipToTokens(String s, int tokens) {
    final maxChars = (tokens * 2.6).floor();
    if (s.length <= maxChars) return s;
    return '${s.substring(0, maxChars - 1).trimRight()}…';
  }
}
