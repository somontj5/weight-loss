import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/stored_message.dart';
import '../../domain/repositories/repositories.dart';
import '../db/app_database.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  ConversationRepositoryImpl(this._db, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;
  final AppDatabase _db;
  final DateTime Function() _clock;

  StoredMessage _map(MessagesRow r) => StoredMessage(
        id: r.id,
        role: r.role,
        kind: r.kind,
        body: r.body,
        createdAt: r.createdAt,
        images: (jsonDecode(r.imagesJson) as List).cast<String>(),
        audioPath: r.audioPath,
        audioMs: r.audioMs,
        waveform: (jsonDecode(r.waveformJson) as List)
            .map((e) => (e as num).toDouble())
            .toList(),
        summaryId: r.summaryId,
      );

  @override
  Future<int> addMessage({
    required String role,
    String kind = 'chat',
    String body = '',
    List<String> images = const [],
    String? audioPath,
    int audioMs = 0,
    List<double> waveform = const [],
    DateTime? at,
  }) =>
      _db.into(_db.messages).insert(MessagesCompanion.insert(
            role: role,
            kind: Value(kind),
            body: Value(body),
            imagesJson: Value(jsonEncode(images)),
            audioPath: Value(audioPath),
            audioMs: Value(audioMs),
            waveformJson: Value(jsonEncode(waveform)),
            createdAt: at ?? _clock(),
          ));

  @override
  Future<List<StoredMessage>> recent({int limit = 100}) async {
    final rows = await (_db.select(_db.messages)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(limit))
        .get();
    return rows.reversed.map(_map).toList();
  }

  @override
  Future<List<StoredMessage>> lastChatMessages(int n) async {
    final rows = await (_db.select(_db.messages)
          ..where((t) => t.kind.equals('chat'))
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(n))
        .get();
    return rows.reversed.map(_map).toList();
  }

  @override
  Future<List<StoredMessage>> pendingForSummary({required int keepLast}) async {
    final rows = await (_db.select(_db.messages)
          ..where((t) => t.kind.equals('chat'))
          ..orderBy([(t) => OrderingTerm.desc(t.id)]))
        .get();
    if (rows.length <= keepLast) return [];
    return rows
        .skip(keepLast)
        .where((r) => r.summaryId == null)
        .toList()
        .reversed
        .map(_map)
        .toList();
  }

  @override
  Future<List<ConversationSummary>> summaries() async =>
      (await (_db.select(_db.conversationSummaries)
                ..orderBy([(t) => OrderingTerm.asc(t.id)]))
              .get())
          .map((r) => ConversationSummary(
                id: r.id,
                createdAt: r.createdAt,
                fromTime: r.fromTime,
                toTime: r.toTime,
                body: r.body,
                messageCount: r.messageCount,
              ))
          .toList();

  @override
  Future<int> addSummary(
      {required String body,
      required List<StoredMessage> covered,
      required DateTime now}) {
    return _db.transaction(() async {
      final id = await _db
          .into(_db.conversationSummaries)
          .insert(ConversationSummariesCompanion.insert(
            createdAt: now,
            fromTime: covered.first.createdAt,
            toTime: covered.last.createdAt,
            body: body,
            messageCount: Value(covered.length),
          ));
      await (_db.update(_db.messages)
            ..where((t) => t.id.isIn(covered.map((m) => m.id))))
          .write(MessagesCompanion(summaryId: Value(id)));
      return id;
    });
  }
}
