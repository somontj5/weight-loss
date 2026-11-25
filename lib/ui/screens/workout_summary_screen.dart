import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weightloss/models/workout_session.dart';
import 'package:weightloss/ui/providers/workout_hub.dart';
import 'package:weightloss/ui/theme/app_theme.dart';
import 'package:weightloss/ui/widgets/chunky_button.dart';
import 'package:weightloss/ui/widgets/fitty_avatar.dart';

/// Итоги тренировки + разбор от ИИ-тренера (ему же уходит весь журнал:
/// паузы, пропуски, досрочное завершение).
class WorkoutSummaryScreen extends StatefulWidget {
  const WorkoutSummaryScreen({super.key, required this.session});

  final WorkoutSession session;

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  String? _review;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final text = await context.read<WorkoutHub>().review(widget.session);
      if (mounted) setState(() => _review = text);
    });
  }

  static String _fmt(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
                children: [
                  const Center(child: FittyAvatar(size: 84)),
                  const SizedBox(height: 14),
                  Text(
                    s.finishedEarly ? 'Тренировка завершена' : 'Отличная работа!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _Stat(
                          icon: Icons.local_fire_department_rounded,
                          color: AppColors.accent,
                          value: s.kcal.toStringAsFixed(0),
                          label: 'ккал'),
                      const SizedBox(width: 10),
                      _Stat(
                          icon: Icons.timer_rounded,
                          color: AppColors.primary,
                          value: _fmt(s.activeSec),
                          label: 'активное время'),
                      const SizedBox(width: 10),
                      _Stat(
                          icon: Icons.check_circle_rounded,
                          color: AppColors.mint,
                          value: '${s.completedCount}/${s.logs.length}',
                          label: 'упражнений'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(22),
                      border:
                          Border.all(color: const Color(0xFFD9CBFF), width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Разбор от Фитти',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark)),
                        const SizedBox(height: 8),
                        if (_review == null)
                          const Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 3, color: AppColors.primary),
                              ),
                              SizedBox(width: 10),
                              Text('Фитти анализирует...',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSoft)),
                            ],
                          )
                        else
                          Text(_review!,
                              style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('По упражнениям',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text)),
                  const SizedBox(height: 8),
                  for (final l in s.logs) _LogRow(log: l),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: ChunkyButton(
                size: 56,
                width: double.infinity,
                circle: false,
                radius: 20,
                color: AppColors.primary,
                shadowColor: AppColors.primaryDark,
                onTap: () => Navigator.of(context).pop(),
                child: const Text('ГОТОВО',
                    style: TextStyle(
                        fontSize: 17,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text)),
            ),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSoft)),
          ],
        ),
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.log});

  final ExerciseLog log;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color, String label) = switch (log.status) {
      'completed' => (Icons.check_circle_rounded, AppColors.mint, 'выполнено'),
      'stopped_early' =>
        (Icons.timelapse_rounded, AppColors.accent, 'прервано'),
      'skipped' => (Icons.skip_next_rounded, AppColors.textSoft, 'пропущено'),
      _ => (Icons.radio_button_unchecked_rounded, AppColors.borderDark, 'не начато'),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(log.name,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text)),
          ),
          Text(
              log.status == 'completed' || log.status == 'stopped_early'
                  ? '$label · ${log.actualSec.round()} с'
                  : label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSoft)),
        ],
      ),
    );
  }
}
