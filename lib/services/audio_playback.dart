import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Один общий плеер на всё приложение: при старте нового голосового
/// предыдущее автоматически останавливается.
class AudioPlayback extends ChangeNotifier {
  AudioPlayback() {
    _subs.add(_player.onPositionChanged.listen((p) {
      _position = p;
      notifyListeners();
    }));
    _subs.add(_player.onPlayerComplete.listen((_) {
      _playing = false;
      _position = Duration.zero;
      notifyListeners();
    }));
    _subs.add(_player.onPlayerStateChanged.listen((s) {
      final p = s == PlayerState.playing;
      if (p != _playing) {
        _playing = p;
        notifyListeners();
      }
    }));
  }

  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subs = [];

  String? _currentId;
  bool _playing = false;
  Duration _position = Duration.zero;

  String? get currentId => _currentId;
  bool isPlaying(String id) => _currentId == id && _playing;
  Duration positionOf(String id) =>
      _currentId == id ? _position : Duration.zero;

  Future<void> toggle(String id, String path) async {
    try {
      if (_currentId == id) {
        if (_playing) {
          await _player.pause();
        } else {
          await _player.resume();
        }
        return;
      }
      await _player.stop();
      _currentId = id;
      _position = Duration.zero;
      notifyListeners();
      final source = kIsWeb ? UrlSource(path) : DeviceFileSource(path);
      await _player.play(source);
    } catch (e) {
      if (kDebugMode) debugPrint('Playback error: $e');
    }
  }

  Future<void> seek(String id, Duration to) async {
    if (_currentId != id) return;
    try {
      await _player.seek(to);
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _player.dispose();
    super.dispose();
  }
}
