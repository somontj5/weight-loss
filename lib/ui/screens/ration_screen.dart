import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weightloss/app_deps.dart';
import 'package:weightloss/domain/ration/ration_models.dart';
import 'package:weightloss/domain/ration/ration_service.dart';
import 'package:weightloss/ui/nav.dart';
import 'package:weightloss/ui/providers/chat_provider.dart';
import 'package:weightloss/ui/screens/progress_screen.dart';
import 'package:weightloss/ui/theme/app_theme.dart';

/// Экран «Рацион»: план питания на 3 дня. Сам план составляет Фитти,
/// экран только показывает то, что лежит в базе.
class RationScreen extends StatefulWidget {
  const RationScreen({super.key});

  @override
  State<RationScreen> createState() => _RationScreenState();
}

class _RationScreenState extends State<RationScreen> {
  int _day = 0;
  Map<int, List<MealPlanItem>> _items = {};
  bool _draft = false;
  bool _loaded = false;
  RationService? _ration;

  static const _names = ['Сегодня', 'Завтра', 'Послезавтра'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final r = context.read<AppDeps>().ration;
    if (!identical(r, _ration)) {
      _ration?.revision.removeListener(_load);
      _ration = r..revision.addListener(_load);
      homeTab.addListener(_onTab);
      _load();
    }
  }

  void _onTab() {
    if (homeTab.value == 2) _load();
  }

  @override
  void dispose() {
    _ration?.revision.removeListener(_load);
    homeTab.removeListener(_onTab);
    super.dispose();
  }

  Future<void> _load() async {
    final r = _ration;
    if (r == null) return;
    final today = RationService.dayOf(DateTime.now());
    final m = <int, List<MealPlanItem>>{};
    for (var i = 0; i < 3; i++) {
      final d = DateTime(today.year, today.month, today.day + i);
      final list = await r.repo.day(d);
      list.sort((a, b) => a.minuteOfDay.compareTo(b.minuteOfDay));
      m[i] = list;
    }
    final draft = await r.isDraft();
    if (!mounted) return;
    setState(() {
      _items = m;
      _draft = draft;
      _loaded = true;
    });
  }

  void _askReplace(MealPlanItem it) {
    homeTab.value = 0;
    context.read<ChatProvider>().sendText(
      'Замени, пожалуйста, ${MealSlot.ru(it.meal).toLowerCase()} '
      '(${_names[_day].toLowerCase()}): «${it.title}»',
    );
  }

  void _askPlan() {
    homeTab.value = 0;
    context.read<ChatProvider>().sendText(
      'Составь мне, пожалуйста, рацион на ближайшие дни',
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items[_day] ?? const <MealPlanItem>[];
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Рацион',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                ),
                if (_draft) const _Pill('черновик', AppColors.accent),
                IconButton(
                  tooltip: 'Прогресс и вес',
                  icon: const Icon(
                    Icons.show_chart_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProgressScreen()),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _day = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _day == i ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _day == i
                                ? AppColors.primaryDark
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _names[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _day == i
                                ? Colors.white
                                : AppColors.textSoft,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: context.read<AppDeps>().ration.working,
              builder: (context, working, _) {
                if (!_loaded) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (items.isEmpty) return _empty(working);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    if (working) _workingBar(),
                    _Header(items: items),
                    const SizedBox(height: 12),
                    for (final it in items) ...[
                      _MealCard(it: it, onReplace: () => _askReplace(it)),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _workingBar() => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.primarySoft,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        SizedBox(width: 12),
        Text(
          'Фитти составляет план…',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );

  Widget _empty(bool working) {
    if (working) {
      return Center(child: _workingBar());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🥗', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            const Text(
              'Плана на этот день пока нет',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Фитти составит рацион под твою норму и вкусы. '
              'Можно попросить прямо сейчас.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSoft),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _askPlan,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              child: const Text(
                'Попросить Фитти',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.items});
  final List<MealPlanItem> items;

  @override
  Widget build(BuildContext context) {
    var kcal = 0, eaten = 0;
    double p = 0, f = 0, c = 0;
    for (final i in items) {
      kcal += i.kcal;
      p += i.proteinG;
      f += i.fatG;
      c += i.carbsG;
      if (i.status == PlanStatus.eaten || i.status == PlanStatus.replaced) {
        eaten += i.kcal;
      }
    }
    final share = kcal == 0 ? 0.0 : (eaten / kcal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$kcal',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'ккал по плану',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSoft,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: share,
              minHeight: 12,
              backgroundColor: AppColors.border,
              color: AppColors.mint,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Съедено $eaten из $kcal ккал',
            style: const TextStyle(fontSize: 12, color: AppColors.textSoft),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Macro('Белки', p, AppColors.primary),
              _Macro('Жиры', f, AppColors.accent),
              _Macro('Углеводы', c, AppColors.mint),
            ],
          ),
        ],
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  const _Macro(this.name, this.g, this.color);
  final String name;
  final double g;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          '${g.round()} г',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          name,
          style: const TextStyle(fontSize: 12, color: AppColors.textSoft),
        ),
      ],
    ),
  );
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.it, required this.onReplace});
  final MealPlanItem it;
  final VoidCallback onReplace;

  Color get _color => switch (it.status) {
    PlanStatus.eaten => AppColors.mint,
    PlanStatus.skipped => AppColors.textSoft,
    PlanStatus.replaced => AppColors.accent,
    _ => AppColors.primary,
  };

  String get _chip =>
      it.status == PlanStatus.planned ? 'по плану' : PlanStatus.ru(it.status);

  @override
  Widget build(BuildContext context) {
    final canReplace = it.status == PlanStatus.planned;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.border, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                MealSlot.emoji(it.meal),
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MealSlot.ru(it.meal),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      it.time,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _Pill(_chip, _color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            it.title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          for (final c in it.composition)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '• $c',
                style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
              ),
            ),
          if (it.note != null && it.note!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                it.note!,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: AppColors.textSoft,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${it.kcal} ккал · Б ${it.proteinG.round()} Ж ${it.fatG.round()} У ${it.carbsG.round()}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              if (canReplace)
                TextButton(
                  onPressed: onReplace,
                  child: const Text(
                    'Попросить заменить',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.accent,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
