import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Круговой таймер с крупным числом секунд посередине.
class TimerRing extends StatelessWidget {
  const TimerRing({
    super.key,
    required this.progress,
    required this.seconds,
    required this.color,
    this.size = 150,
    this.caption,
  });

  final double progress; // 0..1 — сколько уже прошло
  final int seconds;
  final Color color;
  final double size;
  final String? caption;

  static String format(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return m > 0 ? '$m:${r.toString().padLeft(2, '0')}' : '$r';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress, color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                format(seconds),
                style: TextStyle(
                  fontSize: size * 0.36,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (caption != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    caption!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSoft,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.color);

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final stroke = s.width * 0.085;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(s.width - stroke, s.height - stroke);
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.border;
    canvas.drawArc(rect, 0, 2 * pi, false, bg);
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = color;
    // кольцо «тает»: остаётся оставшаяся часть времени
    final left = (1 - progress).clamp(0.0, 1.0);
    canvas.drawArc(rect, -pi / 2, 2 * pi * left, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}
