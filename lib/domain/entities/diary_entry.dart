/// Запись дневника питания (то, что лежит в таблице diary_entries).
class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.eatenAt,
    required this.meal,
    required this.description,
    required this.createdAt,
    this.kcal,
    this.proteinG,
    this.fatG,
    this.carbsG,
    this.photos = const [],
    this.source = 'chat_text',
    this.messageId,
    this.offPlan = false,
    this.note,
  });

  final int id;
  final DateTime eatenAt;

  /// breakfast | lunch | dinner | snack
  final String meal;
  final String description;
  final int? kcal;
  final double? proteinG;
  final double? fatG;
  final double? carbsG;
  final List<String> photos;

  /// chat_text | chat_photo | chat_voice | manual
  final String source;
  final int? messageId;
  final DateTime createdAt;
  final bool offPlan;
  final String? note;
}
