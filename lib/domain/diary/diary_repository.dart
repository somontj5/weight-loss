import 'package:weightloss/domain/entities/diary_entry.dart';

abstract class DiaryRepository {
  /// Возвращает номер новой записи.
  Future<int> insert(DiaryEntry e);
  Future<DiaryEntry?> byId(int id);
  Future<DiaryEntry?> byMessageId(int messageId);
  Future<void> update(DiaryEntry e);
  Future<bool> delete(int id);

  /// Записи за [from, to), по времени еды.
  Future<List<DiaryEntry>> between(DateTime from, DateTime to);

  /// Последняя созданная запись.
  Future<DiaryEntry?> latest();
}
