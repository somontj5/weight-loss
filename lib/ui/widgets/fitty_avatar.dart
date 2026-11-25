import 'package:flutter/material.dart';
import 'package:weightloss/ui/theme/app_theme.dart';

/// Талисман Фитти — весёлое яблочко с листиком.
class FittyAvatar extends StatelessWidget {
  const FittyAvatar({super.key, this.size = 44, this.background = true});

  final double size;
  final bool background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: background
          ? BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD9CBFF), width: 2),
            )
          : null,
      child: CustomPaint(painter: _ApplePainter()),
    );
  }
}

class _ApplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;

    // тело
    final body = Paint()..color = AppColors.accent;
    final bodyRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.56),
      width: w * 0.62,
      height: h * 0.56,
    );
    canvas.drawRRect(
        RRect.fromRectAndRadius(bodyRect, Radius.circular(w * 0.28)), body);

    // блик
    canvas.drawCircle(Offset(w * 0.36, h * 0.46), w * 0.04,
        Paint()..color = Colors.white.withValues(alpha: 0.55));

    // глаза
    final eye = Paint()..color = Colors.white;
    final pupil = Paint()..color = AppColors.text;
    for (final dx in [0.41, 0.59]) {
      canvas.drawCircle(Offset(w * dx, h * 0.55), w * 0.065, eye);
      canvas.drawCircle(Offset(w * dx, h * 0.56), w * 0.035, pupil);
    }

    // улыбка
    final smile = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.04;
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.62), width: w * 0.2, height: h * 0.14),
      0.25,
      2.6,
      false,
      smile,
    );

    // щёчки
    final cheek = Paint()..color = Colors.white.withValues(alpha: 0.28);
    canvas.drawCircle(Offset(w * 0.32, h * 0.63), w * 0.04, cheek);
    canvas.drawCircle(Offset(w * 0.68, h * 0.63), w * 0.04, cheek);

    // веточка
    final stem = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.045;
    canvas.drawLine(Offset(w * 0.5, h * 0.3), Offset(w * 0.52, h * 0.2), stem);

    // листик
    final leaf = Path()
      ..moveTo(w * 0.53, h * 0.22)
      ..quadraticBezierTo(w * 0.62, h * 0.08, w * 0.76, h * 0.14)
      ..quadraticBezierTo(w * 0.7, h * 0.28, w * 0.53, h * 0.22)
      ..close();
    canvas.drawPath(leaf, Paint()..color = AppColors.mint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
