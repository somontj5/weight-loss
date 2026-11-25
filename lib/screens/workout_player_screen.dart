import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../controllers/workout_controller.dart';
import '../models/workout.dart';
import '../providers/workout_hub.dart';
import '../services/workout_music.dart';
import '../theme/app_theme.dart';
import '../widgets/chunky_button.dart';
import '../widgets/exercise_stage.dart';
import '../widgets/timer_ring.dart';
import 'workout_summary_screen.dart';

/// Экран выполнения тренировки.
class WorkoutPlayerScreen extends StatefulWidget {
  const WorkoutPlayerScreen({super.key, required this.workout});

  final Workout workout;

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  late final WorkoutMusic _music = WorkoutMusic();
  late final WorkoutController _c;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    final hub = context.read<WorkoutHub>();
    _c = WorkoutController(
      workout: widget.workout,
      profile: hub.profile,
      music: _music,
    )..addListener(_onChange);
    _c.start();
    try {
      WakelockPlus.enable();
    } catch (_) {}
  }

  void _onChange() {
    if (_c.phase == WorkoutPhase.finished && !_navigated && mounted) {
      _navigated = true;
      final session = _c.session!;
      context.read<WorkoutHub>().addSession(session);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => WorkoutSummaryScreen(session: session),
      ));
    }
  }

  @override
  void dispose() {
    try {
      WakelockPlus.disable();
    } catch (_) {}
    _c.removeListener(_onChange);
    _c.dispose();
    _music.dispose();
    super.dispose();
  }

  Future<void> _confirmFinish() async {
    final wasPaused = _c.paused;
    if (!wasPaused) _c.pause(60);
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Закончить досрочно?',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
            'Прогресс сохранится, а Фитти учтёт это в следующей тренировке.',
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Продолжить',
                style: TextStyle(
                    fontWeight: FontWeight.w900, color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Закончить',
                style: TextStyle(
                    fontWeight: FontWeight.w900, color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (yes == true) {
      _c.finishEarly();
    } else if (!wasPaused) {
      _c.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmFinish();
      },
      child: ListenableBuilder(
        listenable: _c,
        builder: (context, _) {
          final ready = _c.phase == WorkoutPhase.ready;
          final rest = _c.phase == WorkoutPhase.rest;
          final accent = ready
              ? AppColors.primary
              : rest
                  ? AppColors.mint
                  : AppColors.accent;
          final bool finished = _c.phase == WorkoutPhase.finished;
          if (finished) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      _TopBar(c: _c, onClose: _confirmFinish),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                          child: Column(
                            children: [
                              _PhaseChip(c: _c, color: accent),
                              const SizedBox(height: 10),
                              Expanded(
                                child: ExerciseStage(
                                  animationId: ready
                                      ? _c.current.animationId
                                      : (rest
                                          ? (_c.next?.animationId ?? 'generic')
                                          : _c.current.animationId),
                                  resting: rest,
                                  running: !_c.paused,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _Info(c: _c),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TimerRing(
                                    size: 132,
                                    progress: _c.progress,
                                    seconds: _c.remainingCeil,
                                    color: accent,
                                    caption: ready ? 'старт' : 'сек',
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(child: _KcalCard(c: _c)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      _Controls(c: _c, onFinish: _confirmFinish),
                    ],
                  ),
                  if (_c.paused) _PauseOverlay(c: _c, onFinish: _confirmFinish),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.c, required this.onClose});

  final WorkoutController c;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final total = c.workout.exercises.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 28),
            color: AppColors.textSoft,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    for (var i = 0; i < total; i++)
                      Expanded(
                        child: Container(
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: i < c.index ||
                                    (i == c.index &&
                                        c.phase == WorkoutPhase.rest)
                                ? AppColors.mint
                                : i == c.index &&
                                        c.phase == WorkoutPhase.exercise
                                    ? AppColors.accent
                                    : AppColors.border,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  c.phase == WorkoutPhase.ready
                      ? '$total упражнений'
                      : 'Упражнение ${c.index + 1} из $total',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSoft),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => c.music.setMuted(!c.music.muted),
            icon: Icon(
                c.music.muted ? Icons.music_off_rounded : Icons.music_note_rounded,
                size: 26),
            color: AppColors.textSoft,
          ),
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.c, required this.color});

  final WorkoutController c;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = switch (c.phase) {
      WorkoutPhase.ready => 'ПРИГОТОВЬСЯ',
      WorkoutPhase.exercise => 'УПРАЖНЕНИЕ',
      WorkoutPhase.rest => 'ОТДЫХ',
      WorkoutPhase.finished => '',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 13,
              letterSpacing: 1,
              fontWeight: FontWeight.w900,
              color: color)),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.c});

  final WorkoutController c;

  @override
  Widget build(BuildContext context) {
    final Exercise? show =
        c.phase == WorkoutPhase.rest ? c.next : c.current;
    final title = c.phase == WorkoutPhase.rest
        ? 'Дальше: ${show?.name ?? ''}'
        : (show?.name ?? '');
    final sub = c.phase == WorkoutPhase.exercise
        ? (show?.tips ?? '')
        : (show?.description ?? '');
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text),
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: AppColors.textSoft),
        ),
      ],
    );
  }
}

class _KcalCard extends StatelessWidget {
  const _KcalCard({required this.c});

  final WorkoutController c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department_rounded,
                  color: AppColors.accent, size: 20),
              SizedBox(width: 4),
              Text('Сожжено',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSoft)),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${c.kcal.toStringAsFixed(1)} ккал',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentDark),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Вес ${c.profile.weightKg.toStringAsFixed(c.profile.weightKg % 1 == 0 ? 0 : 1)} кг, ${c.profile.age} лет',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.c, required this.onFinish});

  final WorkoutController c;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final ready = c.phase == WorkoutPhase.ready;
    final rest = c.phase == WorkoutPhase.rest;
    final bool last = c.next == null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ChunkyButton(
                  size: 52,
                  circle: false,
                  radius: 18,
                  color: Colors.white,
                  shadowColor: AppColors.borderDark,
                  onTap: ready ? null : () => c.pause(30),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pause_rounded,
                          color: ready ? AppColors.borderDark : AppColors.text),
                      const SizedBox(width: 6),
                      Text('Пауза',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: ready
                                  ? AppColors.borderDark
                                  : AppColors.text)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ChunkyButton(
                  size: 52,
                  circle: false,
                  radius: 18,
                  color: rest ? AppColors.mint : AppColors.primary,
                  shadowColor:
                      rest ? const Color(0xFF14A47F) : AppColors.primaryDark,
                  onTap: ready
                      ? c.skipReady
                      : rest
                          ? c.skipRest
                          : c.skipExercise,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          ready
                              ? 'Начать сразу'
                              : rest
                                  ? 'Пропустить отдых'
                                  : (last ? 'Пропустить и завершить' : 'Следующее'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.skip_next_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onFinish,
            child: const Text('ЗАКОНЧИТЬ ДОСРОЧНО',
                style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w900,
                    color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({required this.c, required this.onFinish});

  final WorkoutController c;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ПАУЗА',
                style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textSoft)),
            const SizedBox(height: 14),
            TimerRing(
              size: 170,
              progress: 1 - c.pauseRemaining / c.pauseLimit,
              seconds: c.pauseRemaining,
              color: AppColors.primary,
              caption: 'до продолжения',
            ),
            const SizedBox(height: 22),
            const Text('Сколько отдохнуть?',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSoft)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final s in WorkoutController.pauseOptions)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: GestureDetector(
                      onTap: () => c.setPauseLimit(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: c.pauseLimit == s
                              ? AppColors.primarySoft
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: c.pauseLimit == s
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 2),
                        ),
                        child: Text('$s с',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: c.pauseLimit == s
                                    ? AppColors.primary
                                    : AppColors.text)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            ChunkyButton(
              size: 56,
              width: double.infinity,
              circle: false,
              radius: 20,
              color: AppColors.primary,
              shadowColor: AppColors.primaryDark,
              onTap: c.resume,
              child: const Text('ПРОДОЛЖИТЬ',
                  style: TextStyle(
                      fontSize: 17,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onFinish,
              child: const Text('ЗАКОНЧИТЬ ДОСРОЧНО',
                  style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w900,
                      color: AppColors.danger)),
            ),
          ],
        ),
      ),
    );
  }
}
