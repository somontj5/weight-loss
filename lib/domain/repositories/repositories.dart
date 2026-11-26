import 'package:weightloss/domain/entities/diet_plan.dart';
import 'package:weightloss/domain/entities/memory_fact.dart';
import 'package:weightloss/domain/entities/part2_entities.dart';
import 'package:weightloss/domain/entities/profile.dart';
import 'package:weightloss/domain/entities/stored_message.dart';

abstract class ProfileRepository {
  Future<Profile?> getProfile();
  Future<Goal?> getGoal();
  Future<DietPlanData?> getDietPlan();
  Future<List<WeightPoint>> weightHistory({int limit = 10});

  /// Сохраняет профиль, пишет снимок в историю, пересчитывает цель и норму.
  Future<void> saveProfile(Profile p,
      {required Goal goal,
      required DietPlanData plan,
      String source = 'settings'});
}

abstract class MemoryRepository {
  Future<List<MemoryFact>> active();
  Future<List<MemoryFact>> all();
  Future<MemoryFact?> activeByKey(String key);
  Future<int> insert({
    required String key,
    required String fact,
    required String category,
    required double confidence,
    required DateTime now,
    int? sourceMessageId,
  });
  Future<void> touch(int id, {required double confidence, required DateTime now});
  Future<void> supersede(int id, {int? by, required DateTime now});
}

abstract class ConversationRepository {
  Future<int> addMessage({
    required String role,
    String kind = 'chat',
    String body = '',
    List<String> images = const [],
    String? audioPath,
    int audioMs = 0,
    List<double> waveform = const [],
    DateTime? at,
  });
  Future<List<StoredMessage>> recent({int limit = 100});

  /// Записывает расшифровку голосового (или правит текст) сообщения.
  Future<void> updateBody(int id, String body);
  Future<List<StoredMessage>> lastChatMessages(int n);

  /// Сообщения чата, ещё не сжатые в резюме, кроме последних [keepLast].
  Future<List<StoredMessage>> pendingForSummary({required int keepLast});
  Future<List<ConversationSummary>> summaries();
  Future<int> addSummary(
      {required String body,
      required List<StoredMessage> covered,
      required DateTime now});
}

/// Источники данных части 2. Сейчас — заглушки с пустыми данными.
abstract class DiarySource {
  /// false — учёт еды ещё не подключён (модель должна знать об этом честно).
  bool get available;
  Future<DiaryDay> today(DateTime now);
  Future<List<DiaryDay>> lastDays(DateTime now, int days);
}

abstract class WorkoutHistorySource {
  Future<List<WorkoutBrief>> recent(DateTime now, {int limit = 5});
}
