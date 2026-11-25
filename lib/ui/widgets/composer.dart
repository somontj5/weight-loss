import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:weightloss/models/chat_message.dart';
import 'package:weightloss/services/voice_recorder.dart';
import 'package:weightloss/ui/theme/app_theme.dart';
import 'package:weightloss/ui/widgets/chat_image.dart';
import 'package:weightloss/ui/widgets/chunky_button.dart';
import 'package:weightloss/ui/widgets/live_waveform.dart';
import 'package:weightloss/ui/widgets/voice_bubble.dart' show formatDuration;

/// Нижняя панель ввода. Режимы:
///  * обычный: [+] [поле ввода] [микрофон | отправить]
///  * запись: удерживай микрофон, свайп влево — отмена, свайп вверх — замок
///  * запись в замке: волны, корзина и отправка
class Composer extends StatefulWidget {
  const Composer({
    super.key,
    required this.recorder,
    required this.draftImages,
    required this.onSendText,
    required this.onSendVoice,
    required this.onAttach,
    required this.onRemoveImage,
    required this.onMicDenied,
  });

  final VoiceRecorder recorder;
  final List<String> draftImages;
  final ValueChanged<String> onSendText;
  final ValueChanged<RecordedAudio> onSendVoice;
  final VoidCallback onAttach;
  final ValueChanged<int> onRemoveImage;
  final VoidCallback onMicDenied;

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  bool _hasText = false;
  bool _locked = false;
  bool _starting = false;
  bool _cancelHint = false;
  bool _pointerDown = false;

  Offset _dragStart = Offset.zero;
  double _dragDx = 0;
  double _dragDy = 0;

  static const _cancelDistance = 110.0;
  static const _lockDistance = 70.0;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _pulse.dispose();
    super.dispose();
  }

  bool get _recording => widget.recorder.isRecording || _starting;
  bool get _canSend => _hasText || widget.draftImages.isNotEmpty;

  void _send() {
    final t = _controller.text;
    _controller.clear();
    widget.onSendText(t);
  }

  // ---------------- запись ----------------

  Future<void> _startRecording(Offset globalPos) async {
    if (_recording) return;
    _pointerDown = true;
    _dragStart = globalPos;
    _dragDx = 0;
    _dragDy = 0;
    _cancelHint = false;
    _locked = false;
    _focus.unfocus();
    HapticFeedback.mediumImpact();
    setState(() => _starting = true);

    final ok = await widget.recorder.start();
    if (!mounted) return;
    setState(() => _starting = false);

    if (!ok) {
      _pointerDown = false;
      widget.onMicDenied();
      return;
    }
    // палец уже отпустили, пока шёл запуск
    if (!_pointerDown && !_locked) {
      await _finish(send: true);
    }
  }

  void _onMove(Offset globalPos) {
    if (!_pointerDown || _locked || !widget.recorder.isRecording) return;
    final d = globalPos - _dragStart;
    setState(() {
      _dragDx = math.min(0, d.dx);
      _dragDy = math.min(0, d.dy);
      _cancelHint = -_dragDx > _cancelDistance * 0.55;
    });
    if (-_dragDx >= _cancelDistance) {
      _pointerDown = false;
      HapticFeedback.lightImpact();
      _finish(send: false);
    } else if (-_dragDy >= _lockDistance) {
      HapticFeedback.mediumImpact();
      setState(() {
        _locked = true;
        _dragDx = 0;
        _dragDy = 0;
        _cancelHint = false;
      });
    }
  }

  Future<void> _onRelease() async {
    final was = _pointerDown;
    _pointerDown = false;
    if (!was || _locked) return;
    if (_starting) return; // дождёмся старта, _startRecording сам завершит
    if (widget.recorder.isRecording) await _finish(send: true);
  }

  Future<void> _finish({required bool send}) async {
    if (!widget.recorder.isRecording) return;
    if (send) {
      final audio = await widget.recorder.stop();
      if (audio != null) {
        HapticFeedback.lightImpact();
        widget.onSendVoice(audio);
      }
    } else {
      await widget.recorder.cancel();
    }
    if (!mounted) return;
    setState(() {
      _locked = false;
      _dragDx = 0;
      _dragDy = 0;
      _cancelHint = false;
    });
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 2)),
      ),
      child: SafeArea(
        top: false,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.draftImages.isNotEmpty && !_recording) _drafts(),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: _recording ? _recordingRow() : _inputRow(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drafts() {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
        scrollDirection: Axis.horizontal,
        itemCount: widget.draftImages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ChatImage(path: widget.draftImages[i]),
                  ),
                ),
              ),
              Positioned(
                right: -6,
                top: -6,
                child: GestureDetector(
                  onTap: () => widget.onRemoveImage(i),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.text,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: ChunkyButton(
            size: 46,
            color: AppColors.primarySoft,
            shadowColor: const Color(0xFFD9CBFF),
            onTap: widget.onAttach,
            child: const Icon(Icons.add_photo_alternate_rounded,
                color: AppColors.primary, size: 26),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: AppColors.primary,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
              decoration: const InputDecoration(
                hintText: 'Напиши Фитти...',
                hintStyle: TextStyle(
                  color: AppColors.textSoft,
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: _canSend
                ? ChunkyButton(
                    key: const ValueKey('send'),
                    size: 46,
                    color: AppColors.primary,
                    shadowColor: AppColors.primaryDark,
                    onTap: _send,
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 22),
                  )
                : _micButton(),
          ),
        ),
      ],
    );
  }

  Widget _micButton() {
    return Listener(
      key: const ValueKey('mic'),
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) => _startRecording(e.position),
      onPointerMove: (e) => _onMove(e.position),
      onPointerUp: (_) => _onRelease(),
      onPointerCancel: (_) => _onRelease(),
      child: Container(
        width: 46,
        height: 46,
        margin: const EdgeInsets.only(bottom: 4),
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.accentDark, offset: Offset(0, 4))],
        ),
        child: const Icon(Icons.mic_rounded, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _recordingRow() {
    final rec = widget.recorder;
    final slide = (-_dragDx / _cancelDistance).clamp(0.0, 1.0);
    final lockProgress = (-_dragDy / _lockDistance).clamp(0.0, 1.0);

    return SizedBox(
      height: 62,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // основная капсула с волнами
          Positioned.fill(
            right: 0,
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    height: 52,
                    padding: const EdgeInsets.only(left: 6, right: 16),
                    decoration: BoxDecoration(
                      color: _cancelHint
                          ? const Color(0xFFFFECEC)
                          : AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: _cancelHint
                            ? AppColors.danger
                            : const Color(0xFFD9CBFF),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (_locked)
                          GestureDetector(
                            onTap: () => _finish(send: false),
                            child: const SizedBox(
                              width: 42,
                              height: 42,
                              child: Icon(Icons.delete_outline_rounded,
                                  color: AppColors.danger, size: 26),
                            ),
                          )
                        else
                          AnimatedBuilder(
                            animation: _pulse,
                            builder: (_, __) => SizedBox(
                              width: 28,
                              height: 42,
                              child: Center(
                                child: Container(
                                  width: 12 + _pulse.value * 2,
                                  height: 12 + _pulse.value * 2,
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withValues(
                                        alpha: 0.55 + _pulse.value * 0.45),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 42,
                          child: Text(
                            formatDuration(rec.elapsed),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _locked || !_cancelHint
                              ? SizedBox(
                                  height: 36,
                                  child: LiveWaveform(
                                    samples: rec.samples,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        if (!_locked)
                          Transform.translate(
                            offset: Offset(_dragDx * 0.35, 0),
                            child: Opacity(
                              opacity: (1 - slide * 1.3).clamp(0.0, 1.0),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.chevron_left_rounded,
                                      color: AppColors.textSoft, size: 22),
                                  Text(
                                    'Отмена',
                                    style: TextStyle(
                                      color: AppColors.textSoft,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (!_locked && _cancelHint)
                          const Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Отпусти, чтобы удалить',
                                style: TextStyle(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // место под кнопку справа
                const SizedBox(width: 56),
              ],
            ),
          ),

          // замок над кнопкой
          if (!_locked)
            Positioned(
              right: 0,
              bottom: 62 + lockProgress * 10,
              width: 46,
              child: Opacity(
                opacity: 0.4 + lockProgress * 0.6,
                child: Container(
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(23),
                    border: Border.all(color: AppColors.border, width: 2),
                    boxShadow: const [
                      BoxShadow(color: AppColors.border, offset: Offset(0, 3))
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          size: 20, color: AppColors.textSoft),
                      Icon(Icons.keyboard_arrow_up_rounded,
                          size: 20,
                          color: AppColors.textSoft.withValues(alpha: 0.7)),
                    ],
                  ),
                ),
              ),
            ),

          // кнопка справа: пульсирующая во время удержания / отправка в замке
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 56,
            child: Center(child: _recordingActionButton(rec.level)),
          ),
        ],
      ),
    );
  }

  Widget _recordingActionButton(double level) {
    if (_locked) {
      return ChunkyButton(
        size: 46,
        color: AppColors.primary,
        shadowColor: AppColors.primaryDark,
        onTap: () => _finish(send: true),
        child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
      );
    }
    final scale = 1 + level * 0.9;
    return Transform.translate(
      offset: Offset(_dragDx * 0.5, _dragDy * 0.5),
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // «дыхание» от громкости голоса
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              width: 46 * scale,
              height: 46 * scale,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.accentDark, offset: Offset(0, 4))
                ],
              ),
              child:
                  const Icon(Icons.mic_rounded, color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}
