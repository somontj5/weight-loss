import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weightloss/data/exercise_catalog.dart';
import 'package:weightloss/models/user_profile.dart';
import 'package:weightloss/models/workout.dart';
import 'package:weightloss/models/workout_session.dart';
import 'package:weightloss/ui/providers/workout_hub.dart';
import 'package:weightloss/ui/theme/app_theme.dart';
import 'package:weightloss/ui/widgets/chunky_button.dart';
import 'package:weightloss/ui/widgets/fitty_avatar.dart';
import 'package:weightloss/ui/providers/app_state.dart';
import 'package:weightloss/ui/screens/profile_edit_screen.dart';
import 'package:weightloss/ui/screens/workout_player_screen.dart';

/// Раздел «Тренировка»: данные пользователя, запрос плана у ИИ-тренера,
/// список упражнений и запуск.
class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hub = context.watch<WorkoutHub>();
    final w = hub.workout;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: !hub.loaded
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                      children: [
                        _ProfileCard(hub: hub),
                        if (hub.notice != null) ...[
                          const SizedBox(height: 12),
                          _Notice(text: hub.notice!, onClose: hub.dismissNotice),
                        ],
                        const SizedBox(height: 16),
                        if (w == null)
                          const _Empty()
                        else
                          _PlanCard(hub: hub, workout: w),
                        if (hub.history.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 8),
                            child: Text('Прошлые тренировки',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.text)),
                          ),
                          for (final s in hub.history.take(5))
                            _HistoryRow(session: s),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
      ),
      child: Row(
        children: [
          const FittyAvatar(size: 48),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Фитнес-тренер',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text)),
                SizedBox(height: 2),
                Text('Персональный план упражнений',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSoft)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _card() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border, width: 2),
    );

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.hub});

  final WorkoutHub hub;

  @override
  Widget build(BuildContext context) {
    final p = hub.profile;
    String n(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    return GestureDetector(
      onTap: () async {
        final app = context.read<AppState>();
        final initial = app.profile;
        if (initial == null) return;
        final res = await Navigator.of(context).push<bool>(MaterialPageRoute(
          builder: (_) => ProfileEditScreen(
              initial: initial, initialWeeks: app.goal?.weeks),
        ));
        if (res == true && app.profile != null) {
          hub.syncFromProfile(app.profile!);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _card(),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                  color: AppColors.primarySoft, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: p.configured
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${n(p.weightKg)} кг · ${p.age} лет · ${n(p.heightCm)} см',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            p.level.label,
                            if (p.waistCm != null) 'талия ${n(p.waistCm!)}',
                            if (p.hipsCm != null) 'бёдра ${n(p.hipsCm!)}',
                            if (p.chestCm != null) 'грудная клетка ${n(p.chestCm!)}',
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSoft),
                        ),
                      ],
                    )
                  : const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Заполни свои данные',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.text)),
                        SizedBox(height: 2),
                        Text('Вес, возраст, замеры',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSoft)),
                      ],
                    ),
            ),
            const Icon(Icons.edit_rounded, color: AppColors.textSoft, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, required this.onClose});

  final String text;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3EE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD2C4), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.accentDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text)),
          ),
          IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, size: 20),
              color: AppColors.textSoft),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _card(),
      child: const Column(
        children: [
          Icon(Icons.fitness_center_rounded,
              size: 44, color: AppColors.borderDark),
          SizedBox(height: 10),
          Text('Плана пока нет',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text)),
          SizedBox(height: 4),
          Text(
            'Фитти сам подготовит тренировку, когда придёт время, и сообщит в чате и уведомлением.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.hub, required this.workout});

  final WorkoutHub hub;
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final mins = (workout.totalSec / 60).ceil();
    final kcal = hub.estimateKcal(workout).round();
    return Container(
      decoration: _card(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(workout.title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: workout.source == WorkoutSource.ai
                      ? AppColors.primarySoft
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  workout.source == WorkoutSource.ai ? 'ИИ' : 'демо',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: workout.source == WorkoutSource.ai
                          ? AppColors.primary
                          : AppColors.textSoft),
                ),
              ),
            ],
          ),
          if (hub.plannedAt != null) ...[
            const SizedBox(height: 6),
            Text(
                '${_dayWord(hub.plannedAt!)} в ${hub.plannedAt!.hour.toString().padLeft(2, '0')}:${hub.plannedAt!.minute.toString().padLeft(2, '0')}'
                '${hub.plannedDifficulty != null ? ', сложность ${hub.plannedDifficulty} из 3' : ''}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSoft)),
          ],
          if (workout.intro.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(workout.intro,
                  style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text)),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _Chip(Icons.timer_rounded, '~$mins мин', AppColors.primary),
              const SizedBox(width: 8),
              _Chip(Icons.local_fire_department_rounded, '~$kcal ккал',
                  AppColors.accent),
              const SizedBox(width: 8),
              _Chip(Icons.format_list_numbered_rounded,
                  '${workout.exercises.length} упр.', AppColors.mint),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < workout.exercises.length; i++)
            _ExerciseRow(
                index: i,
                exercise: workout.exercises[i],
                isLast: i == workout.exercises.length - 1),
          const SizedBox(height: 14),
          ChunkyButton(
            size: 58,
            width: double.infinity,
            circle: false,
            radius: 20,
            color: AppColors.primary,
            shadowColor: AppColors.primaryDark,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => WorkoutPlayerScreen(workout: workout),
              ));
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                SizedBox(width: 6),
                Text('НАЧАТЬ ТРЕНИРОВКУ',
                    style: TextStyle(
                        fontSize: 17,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.icon, this.text, this.color);

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(text,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: color)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.index,
    required this.exercise,
    required this.isLast,
  });

  final int index;
  final Exercise exercise;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final tpl = catalogById(exercise.id);
    final color = tpl?.stage == 'warmup'
        ? AppColors.mint
        : tpl?.stage == 'cooldown'
            ? AppColors.primary
            : AppColors.accent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text('${index + 1}',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w900, color: color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text)),
                const SizedBox(height: 2),
                Text(
                  '${exercise.muscleGroup} · ${exercise.durationSec} с'
                  '${isLast || exercise.restSec == 0 ? '' : ' · отдых ${exercise.restSec} с'}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final d = session.startedAt;
    String two(int v) => v.toString().padLeft(2, '0');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: _card(),
      child: Row(
        children: [
          Icon(
            session.finishedEarly
                ? Icons.timelapse_rounded
                : Icons.check_circle_rounded,
            color: session.finishedEarly ? AppColors.accent : AppColors.mint,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text)),
                Text(
                    '${two(d.day)}.${two(d.month)} ${two(d.hour)}:${two(d.minute)} · ${session.completedCount}/${session.logs.length} упр.',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSoft)),
              ],
            ),
          ),
          Text('${session.kcal.round()} ккал',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentDark)),
        ],
      ),
    );
  }
}

String _dayWord(DateTime t) {
  final now = DateTime.now();
  final d = DateTime(t.year, t.month, t.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
  return d <= 0 ? 'Сегодня' : (d == 1 ? 'Завтра' : '${t.day}.${t.month}');
}
