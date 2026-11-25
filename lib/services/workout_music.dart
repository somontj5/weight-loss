import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Два зацикленных трека: энергичный (упражнение) и спокойный (отдых/пауза).
/// Между ними плавный кроссфейд.
class WorkoutMusic {
  final AudioPlayer _energetic = AudioPlayer();
  final AudioPlayer _calm = AudioPlayer();

  Timer? _timer;
  double _mix = 0; // 0 = спокойная, 1 = энергичная
  double _target = 0;
  double _master = 1; // 0..1, для общего затухания
  double _masterTarget = 1;
  bool _muted = false;
  bool _started = false;
  bool _disposed = false;

  bool get muted => _muted;

  static const _maxVolume = 0.85;

  Future<void> start({required bool energetic}) async {
    if (_started || _disposed) return;
    _started = true;
    _mix = _target = energetic ? 1 : 0;
    _master = _masterTarget = 1;
    try {
      for (final p in [_energetic, _calm]) {
        await p.setReleaseMode(ReleaseMode.loop);
        try {
          await p.setAudioContext(AudioContextConfig(
            focus: AudioContextConfigFocus.mixWithOthers,
          ).build());
        } catch (_) {}
      }
      await _apply();
      await _energetic.play(AssetSource('audio/energetic.mp3'),
          volume: _energeticVolume);
      await _calm.play(AssetSource('audio/calm.mp3'), volume: _calmVolume);
    } catch (e) {
      if (kDebugMode) debugPrint('music start error: $e');
    }
    _timer ??= Timer.periodic(const Duration(milliseconds: 50), (_) => _step());
  }

  double get _energeticVolume =>
      _muted ? 0 : _maxVolume * _master * sin(_mix * pi / 2);
  double get _calmVolume =>
      _muted ? 0 : _maxVolume * _master * cos(_mix * pi / 2);

  Future<void> _apply() async {
    try {
      await _energetic.setVolume(_energeticVolume.clamp(0, 1));
      await _calm.setVolume(_calmVolume.clamp(0, 1));
    } catch (_) {}
  }

  void _step() {
    // полный кроссфейд ~2 c
    const k = 0.05 / 2.0;
    var changed = false;
    if ((_mix - _target).abs() > 0.001) {
      _mix += (_target - _mix).sign * k;
      if ((_mix - _target).abs() < k) _mix = _target;
      changed = true;
    }
    if ((_master - _masterTarget).abs() > 0.001) {
      _master += (_masterTarget - _master).sign * k * 1.5;
      if ((_master - _masterTarget).abs() < k * 1.5) _master = _masterTarget;
      changed = true;
    }
    if (changed) _apply();
  }

  void setEnergetic(bool energetic) => _target = energetic ? 1 : 0;

  void setMuted(bool m) {
    _muted = m;
    _apply();
  }

  Future<void> fadeOutAndStop() async {
    _masterTarget = 0;
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (_disposed) return;
    try {
      await _energetic.stop();
      await _calm.stop();
    } catch (_) {}
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _energetic.dispose();
    _calm.dispose();
  }
}
