import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../models/chat_message.dart';

/// Запись голоса с живой амплитудой для анимации волн.
class VoiceRecorder extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();

  static const _sampleInterval = Duration(milliseconds: 70);
  static const minDuration = Duration(milliseconds: 800);

  bool _recording = false;
  bool get isRecording => _recording;

  final List<double> _samples = [];
  List<double> get samples => _samples;

  /// Последнее сглаженное значение 0..1 — для пульсации.
  double level = 0;

  final Stopwatch _watch = Stopwatch();
  Duration get elapsed => _watch.elapsed;

  StreamSubscription<Amplitude>? _ampSub;
  Timer? _ticker;

  /// Возвращает false, если нет разрешения на микрофон.
  Future<bool> start() async {
    if (_recording) return true;
    try {
      if (!await _recorder.hasPermission()) return false;

      var encoder = kIsWeb ? AudioEncoder.opus : AudioEncoder.aacLc;
      if (!await _recorder.isEncoderSupported(encoder)) {
        encoder = AudioEncoder.wav;
      }
      final ext = switch (encoder) {
        AudioEncoder.opus => 'webm',
        AudioEncoder.wav => 'wav',
        _ => 'm4a',
      };

      var path = '';
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        final sep = Platform.pathSeparator;
        path =
            '${dir.path}${sep}fitty_${DateTime.now().millisecondsSinceEpoch}.$ext';
      }

      await _recorder.start(
        RecordConfig(encoder: encoder, numChannels: 1, bitRate: 64000),
        path: path,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Recorder start error: $e');
      return false;
    }

    _samples.clear();
    level = 0;
    _watch
      ..reset()
      ..start();
    _recording = true;

    _ampSub = _recorder.onAmplitudeChanged(_sampleInterval).listen((amp) {
      // dBFS: речь обычно лежит в диапазоне -45..-8
      final raw = ((amp.current + 45) / 45).clamp(0.0, 1.0);
      final v = raw * raw * 0.35 + raw * 0.65; // чуть усиливаем тихое
      level = level * 0.35 + v * 0.65;
      _samples.add(level);
      notifyListeners();
    });

    // таймер для плавного обновления секундомера даже в тишине
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_recording) notifyListeners();
    });

    notifyListeners();
    return true;
  }

  Future<RecordedAudio?> stop() async {
    if (!_recording) return null;
    final duration = _watch.elapsed;
    await _teardown();
    String? path;
    try {
      path = await _recorder.stop();
    } catch (e) {
      if (kDebugMode) debugPrint('Recorder stop error: $e');
    }
    final wave = downsample(_samples, 40);
    _samples.clear();
    notifyListeners();
    if (path == null || path.isEmpty || duration < minDuration) return null;
    return RecordedAudio(path: path, duration: duration, waveform: wave);
  }

  Future<void> cancel() async {
    if (!_recording) return;
    await _teardown();
    try {
      await _recorder.cancel();
    } catch (_) {}
    _samples.clear();
    notifyListeners();
  }

  Future<void> _teardown() async {
    _recording = false;
    _watch.stop();
    _ticker?.cancel();
    await _ampSub?.cancel();
    _ampSub = null;
  }

  /// Сжимает список амплитуд до [bars] столбиков (максимум в корзине).
  static List<double> downsample(List<double> src, int bars) {
    if (src.isEmpty) return List.filled(bars, 0.08);
    final out = <double>[];
    for (var i = 0; i < bars; i++) {
      final from = (i * src.length / bars).floor();
      var to = ((i + 1) * src.length / bars).ceil();
      if (to <= from) to = from + 1;
      if (to > src.length) to = src.length;
      var m = 0.0;
      for (var j = from; j < to; j++) {
        if (src[j] > m) m = src[j];
      }
      out.add(m.clamp(0.06, 1.0));
    }
    return out;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ampSub?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}
