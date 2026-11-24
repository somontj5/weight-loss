import 'package:flutter/material.dart';

/// Статичная волна голосового сообщения с подсветкой проигранной части.
class StaticWaveform extends StatelessWidget {
  const StaticWaveform({
    super.key,
    required this.bars,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    this.onSeek,
  });

  final List<double> bars;
  final double progress; // 0..1
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<double>? onSeek;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      void seek(Offset p) {
        if (onSeek == null || c.maxWidth <= 0) return;
        onSeek!((p.dx / c.maxWidth).clamp(0.0, 1.0));
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => seek(d.localPosition),
        onHorizontalDragUpdate: (d) => seek(d.localPosition),
        child: CustomPaint(
          size: Size(c.maxWidth, 30),
          painter: _StaticPainter(
            bars: bars,
            progress: progress,
            active: activeColor,
            inactive: inactiveColor,
          ),
        ),
      );
    });
  }
}

class _StaticPainter extends CustomPainter {
  _StaticPainter({
    required this.bars,
    required this.progress,
    required this.active,
    required this.inactive,
  });

  final List<double> bars;
  final double progress;
  final Color active;
  final Color inactive;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    final n = bars.length;
    final slot = size.width / n;
    final w = (slot * 0.55).clamp(2.0, 4.0);
    final midY = size.height / 2;

    for (var i = 0; i < n; i++) {
      final x = slot * i + slot / 2;
      final h = 4 + bars[i] * (size.height - 4);
      final done = (i + 0.5) / n <= progress;
      final paint = Paint()
        ..color = done ? active : inactive
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w;
      canvas.drawLine(Offset(x, midY - h / 2), Offset(x, midY + h / 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StaticPainter old) =>
      old.progress != progress || old.bars != bars || old.active != active;
}
