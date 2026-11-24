import 'package:flutter/material.dart';

/// Живая волна во время записи, как в WhatsApp: новые столбики появляются
/// справа и едут влево, высота зависит от громкости голоса.
class LiveWaveform extends StatelessWidget {
  const LiveWaveform({
    super.key,
    required this.samples,
    required this.color,
    this.barWidth = 3,
    this.gap = 3,
  });

  final List<double> samples;
  final Color color;
  final double barWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LivePainter(
        samples: samples,
        color: color,
        barWidth: barWidth,
        gap: gap,
        count: samples.length,
      ),
      size: Size.infinite,
    );
  }
}

class _LivePainter extends CustomPainter {
  _LivePainter({
    required this.samples,
    required this.color,
    required this.barWidth,
    required this.gap,
    required this.count,
  });

  final List<double> samples;
  final Color color;
  final double barWidth;
  final double gap;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final step = barWidth + gap;
    final maxBars = (size.width / step).floor();
    final midY = size.height / 2;
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    // Тихая «базовая линия» слева, пока записи ещё мало — как в WhatsApp.
    final shown = samples.length > maxBars
        ? samples.sublist(samples.length - maxBars)
        : samples;
    final empty = maxBars - shown.length;

    for (var i = 0; i < maxBars; i++) {
      final x = i * step + barWidth / 2;
      double h;
      var p = paint;
      if (i < empty) {
        h = 3;
        p = Paint()
          ..color = color.withValues(alpha: 0.28)
          ..strokeCap = StrokeCap.round
          ..strokeWidth = barWidth;
      } else {
        final v = shown[i - empty];
        h = 3 + v * (size.height - 3);
      }
      canvas.drawLine(Offset(x, midY - h / 2), Offset(x, midY + h / 2), p);
    }
  }

  @override
  bool shouldRepaint(covariant _LivePainter old) =>
      old.count != count || old.color != color || old.samples != samples;
}
