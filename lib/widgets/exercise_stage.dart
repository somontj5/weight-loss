import 'package:flutter/material.dart';

import '../data/exercise_catalog.dart';
import '../theme/app_theme.dart';
import 'fitty_avatar.dart';

/// Сцена для 3D-анимации упражнения.
///
/// СЕЙЧАС это заготовка-плейсхолдер. Чтобы подключить 3D позже, достаточно
/// заменить содержимое [_Placeholder] на виджет модели (например,
/// ModelViewer / Flutter Unity / Rive) и выбирать анимацию по [animationId]
/// (он совпадает с `id` из kExerciseCatalog; для неизвестных — 'generic').
class ExerciseStage extends StatefulWidget {
  const ExerciseStage({
    super.key,
    required this.animationId,
    this.resting = false,
    this.running = true,
  });

  final String animationId;
  final bool resting;

  /// false — анимация на паузе.
  final bool running;

  @override
  State<ExerciseStage> createState() => _ExerciseStageState();
}

class _ExerciseStageState extends State<ExerciseStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void didUpdateWidget(covariant ExerciseStage old) {
    super.didUpdateWidget(old);
    if (widget.running && !_c.isAnimating) _c.repeat(reverse: true);
    if (!widget.running && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tpl = catalogById(widget.animationId);
    return Container(
      decoration: BoxDecoration(
        color: widget.resting ? const Color(0xFFE9FBF5) : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: widget.resting ? const Color(0xFFB6EFDD) : const Color(0xFFD9CBFF),
          width: 2,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final compact = box.maxHeight < 150;
          return Stack(
            children: [
              Center(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (_, child) {
                    final t = Curves.easeInOut.transform(_c.value);
                    final s = widget.resting ? 1.0 : 0.94 + 0.12 * t;
                    return Transform.scale(scale: s, child: child);
                  },
                  child: FittyAvatar(
                    size: (box.maxHeight * 0.45).clamp(48, 120),
                    background: false,
                  ),
                ),
              ),
              if (!compact)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.view_in_ar_rounded,
                            size: 16, color: AppColors.textSoft),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            widget.resting
                                ? 'Отдых'
                                : '3D-анимация: ${tpl?.name ?? 'упражнение'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
            ],
          );
        },
      ),
    );
  }
}
