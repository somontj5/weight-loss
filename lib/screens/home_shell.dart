import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'chat_screen.dart';
import 'workout_screen.dart';

/// Нижняя навигация. Сейчас два раздела: чат с Фитти и тренировки.
/// «Диетолог» и «Зрение» добавятся сюда же отдельными вкладками.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [ChatScreen(), WorkoutScreen()],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 2)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.chat_bubble_rounded,
                  label: 'Чат',
                  selected: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                const SizedBox(width: 8),
                _NavItem(
                  icon: Icons.fitness_center_rounded,
                  label: 'Тренировка',
                  selected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? const Color(0xFFD9CBFF) : Colors.transparent,
                width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 26,
                  color: selected ? AppColors.primary : AppColors.textSoft),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: selected ? AppColors.primary : AppColors.textSoft)),
            ],
          ),
        ),
      ),
    );
  }
}
