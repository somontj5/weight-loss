class MemoryCategory {
  static const all = [
    'lifestyle', // образ жизни, работа, активность
    'schedule', // режим дня
    'intolerance', // непереносимости и аллергии
    'food', // любимые/нелюбимые продукты
    'budget',
    'health',
    'habit',
    'motivation',
    'obstacle', // что мешало
    'other',
  ];

  static String normalize(String? c) =>
      all.contains(c) ? c! : 'other';
}

class MemoryFact {
  const MemoryFact({
    required this.id,
    required this.key,
    required this.fact,
    required this.category,
    required this.confidence,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.supersededBy,
  });

  final int id;
  final String key;
  final String fact;
  final String category;
  final double confidence;
  final bool active;
  final int? supersededBy;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// Изменение памяти, которое вернула модель (действие save_memory).
class MemoryUpdate {
  const MemoryUpdate({
    required this.key,
    required this.fact,
    this.category = 'other',
    this.confidence = 0.8,
    this.forget = false,
  });

  final String key;
  final String fact;
  final String category;
  final double confidence;

  /// true — человек сказал, что это больше не так: факт просто закрывается.
  final bool forget;
}
