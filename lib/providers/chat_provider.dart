import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/chat_message.dart';
import '../services/fitty_ai_service.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._ai) {
    _messages.add(ChatMessage(
      id: 'welcome',
      sender: Sender.fitty,
      text: 'Привет! Я Фитти, твой помощник по похудению.\n\n'
          'Пиши, присылай фото еды или записывай голосовое — разберём питание, '
          'тренировки и всё, что мешает дойти до цели.',
    ));
  }

  final FittyAiService _ai;
  final ImagePicker _picker = ImagePicker();

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  final List<String> _draftImages = [];
  List<String> get draftImages => List.unmodifiable(_draftImages);

  bool _typing = false;
  bool get isTyping => _typing;

  static const maxImages = 10;
  int _counter = 0;
  String _nextId() => 'm${_counter++}';

  /// Выбор нескольких фото из галереи.
  Future<String?> pickFromGallery() async {
    try {
      final left = maxImages - _draftImages.length;
      if (left <= 0) return 'Можно прикрепить не больше $maxImages фото';
      final files = await _picker.pickMultiImage(limit: left > 1 ? left : null);
      if (files.isEmpty) return null;
      _draftImages.addAll(files.take(left).map((f) => f.path));
      notifyListeners();
      if (files.length > left) return 'Добавлено только $left фото (максимум $maxImages)';
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
    _add(ChatMessage(
        id: _nextId(), sender: Sender.user, text: t, images: images));
    await _askFitty(text: t, images: images);
  }

  Future<void> sendVoice(RecordedAudio audio) async {
    // фото из черновика уходят вместе с голосовым
    final images = List<String>.of(_draftImages);
    _draftImages.clear();
    _add(ChatMessage(
      id: _nextId(),
      sender: Sender.user,
      images: images,
      audioPath: audio.path,
      audioDuration: audio.duration,
      waveform: audio.waveform,
    ));
    await _askFitty(text: '', images: images, audio: audio.duration);
  }

  Future<void> _askFitty({
    required String text,
    required List<String> images,
    Duration? audio,
  }) async {
    _typing = true;
    notifyListeners();
    try {
      final answer = await _ai.reply(
        text: text,
        imagePaths: images,
        audioDuration: audio,
        history: _messages,
      );
      _add(ChatMessage(id: _nextId(), sender: Sender.fitty, text: answer));
    } catch (e) {
      _add(ChatMessage(
        id: _nextId(),
        sender: Sender.fitty,
        text: 'Ой, что-то пошло не так. Попробуй ещё раз.',
      ));
    } finally {
      _typing = false;
      notifyListeners();
    }
  }

  void _add(ChatMessage m) {
    _messages.add(m);
    notifyListeners();
  }
}
