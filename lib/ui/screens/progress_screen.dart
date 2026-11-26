import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weightloss/app_deps.dart';
import 'package:weightloss/domain/entities/profile.dart';
import 'package:weightloss/domain/weight/weight_service.dart';
import 'package:weightloss/ui/providers/app_state.dart';
import 'package:weightloss/ui/theme/app_theme.dart';

/// Прогресс: простой график веса (рисуем сами, без библиотек),
/// цель и сколько осталось.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  WeightFacts? _facts;
  List<WeightPoint> _pts = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final d = context.read<AppDeps>();
    final f = await d.weight.facts();
    final p = await d.profiles.weightHistory(limit: 60);
    if (!mounted) return;
    setState(() {
      _facts = f;
      _pts = ([...p]..sort((a, b) => a.at.compareTo(b.at)));
    });
  }

  String _kg(double v) => '${v.toStringAsFixed(1)} кг';

  @override
  Widget build(BuildContext context) {
    final goal = context.watch<AppState>().goal;
    final f = _facts;
    final last = _pts.isEmpty ? null : _pts.last.weightKg;
    String left = '—';
    if (f?.leftKg != null) {
      left = f!.leftKg! <= 0 ? 'цель достигнута 🎉' : _kg(f.leftKg!);
    }
    String days = '—';
    if (goal != null) {
      final n = goal.targetDate.difference(DateTime.now()).inDays;
      days = n < 0 ? 'срок прошёл' : '$n дн.';
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Мой прогресс',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            height: 240,
            child: _pts.length < 2
                ? const Center(
                    child: Text(
                      'График появится после двух взвешиваний.\nСкажи Фитти свой вес в чате.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSoft),
                    ),
                  )
                : CustomPaint(
                    size: Size.infinite,
                    painter: WeightChartPainter(_pts, goal?.targetWeightKg),
                  ),
          ),
          const SizedBox(height: 16),
          _Row('Сейчас', last == null ? '—' : _kg(last)),
          _Row('Цель', goal == null ? '—' : _kg(goal.targetWeightKg)),
          _Row('Осталось сбросить', left),
          _Row('До срока', days),
          if (f?.weekDelta != null)
            _Row('За неделю', '${f!.weekDelta!.toStringAsFixed(1)} кг'),
          if (f?.monthDelta != null)
            _Row('За месяц', '${f!.monthDelta!.toStringAsFixed(1)} кг'),
          if (f?.paceOk == false)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Темп немного отстаёт от срока. Это нормально. '
                'Можно спросить Фитти, не стоит ли пересмотреть срок: '
                'решаешь ты.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.a, this.b);
  final String a;
  final String b;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            a,
            style: const TextStyle(
              color: AppColors.textSoft,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(b, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    ),
  );
}

class WeightChartPainter extends CustomPainter {
  WeightChartPainter(this.pts, this.target);
  final List<WeightPoint> pts;
  final double? target;

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.length < 2) return;
    final ws = pts.map((e) => e.weightKg).toList();
    if (target != null) ws.add(target!);
    var lo = ws.reduce((a, b) => a < b ? a : b) - 1;
    var hi = ws.reduce((a, b) => a > b ? a : b) + 1;
    if (hi - lo < 2) hi = lo + 2;
    const padL = 36.0, padB = 8.0, padT = 8.0;
    final w = size.width - padL, h = size.height - padB - padT;
    final t0 = pts.first.at.millisecondsSinceEpoch;
    final span = (pts.last.at.millisecondsSinceEpoch - t0).clamp(1, 1 << 62);
    Offset pos(WeightPoint p) => Offset(
      padL + w * (p.at.millisecondsSinceEpoch - t0) / span,
      padT + h * (1 - (p.weightKg - lo) / (hi - lo)),
    );

    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = padT + h * i / 3;
      canvas.drawLine(Offset(padL, y), Offset(size.width, y), grid);
      final v = hi - (hi - lo) * i / 3;
      final tp = TextPainter(
        text: TextSpan(
          text: v.toStringAsFixed(0),
          style: const TextStyle(fontSize: 10, color: AppColors.textSoft),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - 6));
    }
    if (target != null) {
      final y = padT + h * (1 - (target! - lo) / (hi - lo));
      final dash = Paint()
        ..color = AppColors.mint
        ..strokeWidth = 2;
      for (var x = padL; x < size.width; x += 10) {
        canvas.drawLine(Offset(x, y), Offset(x + 5, y), dash);
      }
    }
    final line = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(pos(pts.first).dx, pos(pts.first).dy);
    for (final p in pts.skip(1)) {
      path.lineTo(pos(p).dx, pos(p).dy);
    }
    canvas.drawPath(path, line);
    final dot = Paint()..color = AppColors.primaryDark;
    for (final p in pts) {
      canvas.drawCircle(pos(p), 4, dot);
    }
  }

  @override
  bool shouldRepaint(WeightChartPainter old) =>
      old.pts != pts || old.target != target;
}
