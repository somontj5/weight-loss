import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:weightloss/domain/entities/stored_message.dart';
import 'package:weightloss/domain/repositories/repositories.dart';
import 'package:weightloss/models/chat_message.dart';
import 'package:weightloss/services/chat_service.dart';

/// Чат хранится в БД на устройстве; ответы идут через ChatService
/// (ContextAssembler + Gemini).
class ChatProvider extends ChangeNotifier {
  ChatProvider(this._service, this._repo);

  final ChatService _service;
  final ConversationRepository _repo;
  final ImagePicker _picker = ImagePicker();

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  final List<String> _draftImages = [];
  List<String> get draftImages => List.unmodifiable(_draftImages);

  bool _typing = false;
  bool get isTyping => _typing;
  bool get demoMode => _service.demoMode;

  bool _loaded = false;
  bool get loaded => _loaded;

  static const maxImages = 10;
  static const _historyLimit = 300;

  /// Очередь: ответы на сообщения идут строго по одному.
  Future<void> _queue = Future.value();

  Future<void> load() async {
    final list = await _repo.recent(limit: _historyLimit);
    _messages
      ..clear()
      ..addAll(list.map(_toUi));
    _loaded = true;
    notifyListeners();
  }

  /// Сброс после удаления всех данных.
  void reset() {
    _messages.clear();
    _draftImages.clear();
    _typing = false;
    notifyListeners();
  }

  ChatMessage _toUi(StoredMessage m) => ChatMessage(
    id: 'db${m.id}',
    sender: m.isUser ? Sender.user : Sender.fitty,
    text: m.body,
    images: m.images,
    audioPath: m.audioPath,
    audioDuration: Duration(milliseconds: m.audioMs),
    waveform: m.waveform,
    time: m.createdAt,
  );

  /// Приветствие Фитти после регистрации.
  Future<void> postFitty(String text, {bool notice = false}) async {
    final id = await _repo.addMessage(
      role: 'fitty',
      kind: notice ? 'notice' : 'chat',
      body: text,
    );
    _messages.add(ChatMessage(id: 'db$id', sender: Sender.fitty, text: text));
    notifyListeners();
  }

  /// Фитти сам задаёт первый вопрос после нажатия на уведомление.
  /// Запрос к модели не тратится. Повторное нажатие не плодит дубли.
  Future<void> postOpener(String text) async {
    if (_messages.isNotEmpty) {
      final last = _messages.last;
      if (last.sender == Sender.fitty && last.text == text) return;
    }
    await postFitty(text);
  }

  /// Выбор нескольких фото из галереи.
  Future<String?> pickFromGallery() async {
    try {
      final left = maxImages - _draftImages.length;
      if (left <= 0) return 'Можно прикрепить не больше $maxImages фото';
      final files = await _picker.pickMultiImage(limit: left > 1 ? left : null);
      if (files.isEmpty) return null;
      _draftImages.addAll(files.take(left).map((f) => f.path));
      notifyListeners();
      if (files.length > left) {
        return 'Добавлено только $left фото (максимум $maxImages)';
      }
    } catch (e) {
      if (kDebugMode) debugPrint('pickMultiImage error: $e');
      return 'Не удалось открыть галерею';
    }
    return null;
  }

  Future<String?> takePhoto() async {
    try {
      if (_draftImages.length >= maxImages) {
        return 'Можно прикрепить не больше $maxImages фото';
      }
      final f = await _picker.pickImage(source: ImageSource.camera);
      if (f == null) return null;
      _draftImages.add(f.path);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('camera error: $e');
      return 'Не удалось открыть камеру';
    }
    return null;
  }

  void removeDraftImage(int index) {
    if (index < 0 || index >= _draftImages.length) return;
    _draftImages.removeAt(index);
    notifyListeners();
  }

  Future<void> sendText(String text) async {
    final t = text.trim();
    if (t.isEmpty && _draftImages.isEmpty) return;
    final images = List<String>.of(_draftImages);
    _draftImages.clear();
    final id = await _repo.addMessage(role: 'user', body: t, images: images);
    _messages.add(
      ChatMessage(id: 'db$id', sender: Sender.user, text: t, images: images),
    );
    notifyListeners();
    _enqueue(id, text: t, images: images);
  }

  Future<void> sendVoice(RecordedAudio audio) async {
    // фото из черновика уходят вместе с голосовым
    final images = List<String>.of(_draftImages);
    _draftImages.clear();
    final id = await _repo.addMessage(
      role: 'user',
      images: images,
      audioPath: audio.path,
      audioMs: audio.duration.inMilliseconds,
      waveform: audio.waveform,
    );
    _messages.add(
      ChatMessage(
        id: 'db$id',
        sender: Sender.user,
        images: images,
        audioPath: audio.path,
        audioDuration: audio.duration,
        waveform: audio.waveform,
      ),
    );
    notifyListeners();
    _enqueue(id, images: images, audio: audio.duration, audioPath: audio.path);
  }

  /// Расшифровка голосового появляется под волной в том же сообщении.
  void _applyHeard(int dbId, String heard) {
    final i = _messages.indexWhere((m) => m.id == 'db$dbId');
    if (i < 0) return;
    final m = _messages[i];
    _messages[i] = ChatMessage(
      id: m.id,
      sender: m.sender,
      text: heard,
      images: m.images,
      audioPath: m.audioPath,
      audioDuration: m.audioDuration,
      waveform: m.waveform,
      time: m.time,
    );
  }

  void _enqueue(
    int userMessageId, {
    String text = '',
    List<String> images = const [],
    Duration? audio,
    String? audioPath,
  }) {
    _typing = true;
    notifyListeners();
    _queue = _queue.then((_) async {
      try {
        final r = await _service.respond(
          userMessageId: userMessageId,
          text: text,
          images: images,
          audio: audio,
          audioPath: audioPath,
        );
        if (r.heard != null) _applyHeard(userMessageId, r.heard!);
        final id = await _repo.addMessage(
          role: 'fitty',
          kind: r.notice ? 'notice' : 'chat',
          body: r.text,
        );
        _messages.add(
          ChatMessage(id: 'db$id', sender: Sender.fitty, text: r.text),
        );
      } catch (e) {
        if (kDebugMode) debugPrint('chat error: $e');
        _messages.add(
          ChatMessage(
            id: 'err${DateTime.now().microsecondsSinceEpoch}',
            sender: Sender.fitty,
            text: 'Ой, что-то пошло не так. Попробуй ещё раз.',
          ),
        );
      } finally {
        _typing = false;
        notifyListeners();
      }
    });
  }
}
