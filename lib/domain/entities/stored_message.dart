class StoredMessage {
  const StoredMessage({
    required this.id,
    required this.role,
    required this.kind,
    required this.body,
    required this.createdAt,
    this.images = const [],
    this.audioPath,
    this.audioMs = 0,
    this.waveform = const [],
    this.summaryId,
  });

  final int id;

  /// 'user' | 'fitty'
  final String role;

  /// 'chat' | 'notice'
  final String kind;
  final String body;
  final DateTime createdAt;
  final List<String> images;
  final String? audioPath;
  final int audioMs;
  final List<double> waveform;
  final int? summaryId;

  bool get isUser => role == 'user';
  bool get isChat => kind == 'chat';
}

class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.createdAt,
    required this.fromTime,
    required this.toTime,
    required this.body,
    required this.messageCount,
  });

  final int id;
  final DateTime createdAt;
  final DateTime fromTime;
  final DateTime toTime;
  final String body;
  final int messageCount;
}
