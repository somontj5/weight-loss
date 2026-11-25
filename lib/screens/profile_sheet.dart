import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/chunky_button.dart';

/// Редактор данных пользователя (вес, возраст, обхваты).
Future<UserProfile?> showProfileSheet(BuildContext context, UserProfile p) {
  return showModalBottomSheet<UserProfile>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ProfileSheet(initial: p),
  );
}

class _ProfileSheet extends StatefulWidget {
  const _ProfileSheet({required this.initial});

  final UserProfile initial;

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  late bool _female = widget.initial.female;
  late FitnessLevel _level = widget.initial.level;
  late final _age = TextEditingController(text: '${widget.initial.age}');
  late final _weight = TextEditingController(text: _n(widget.initial.weightKg));
  late final _height = TextEditingController(text: _n(widget.initial.heightCm));
  late final _waist = TextEditingController(text: _n(widget.initial.waistCm));
  late final _chest = TextEditingController(text: _n(widget.initial.chestCm));
  late final _hips = TextEditingController(text: _n(widget.initial.hipsCm));
  String? _error;

  static String _n(double? v) =>
      v == null ? '' : (v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1));

  @override
  void dispose() {
    for (final c in [_age, _weight, _height, _waist, _chest, _hips]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  void _save() {
    final age = int.tryParse(_age.text.trim());
    final w = _num(_weight);
    final h = _num(_height);
    if (age == null || age < 12 || age > 100) {
      return setState(() => _error = 'Возраст: от 12 до 100 лет');
    }
    if (w == null || w < 30 || w > 300) {
      return setState(() => _error = 'Вес: от 30 до 300 кг');
    }
    if (h == null || h < 120 || h > 230) {
      return setState(() => _error = 'Рост: от 120 до 230 см');
    }
    double? opt(TextEditingController c) {
      final v = _num(c);
      return (v != null && v > 20 && v < 250) ? v : null;
    }

    Navigator.pop(
      context,
      UserProfile(
        female: _female,
        age: age,
        weightKg: w,
        heightCm: h,
        waistCm: opt(_waist),
        chestCm: opt(_chest),
        hipsCm: opt(_hips),
        level: _level,
        configured: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Твои данные',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text)),
                const SizedBox(height: 4),
                const Text('Тренер подбирает нагрузку и считает калории по ним',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSoft)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _Choice(
                        label: 'Женщина',
                        selected: _female,
                        onTap: () => setState(() => _female = true)),
                    const SizedBox(width: 10),
                    _Choice(
                        label: 'Мужчина',
                        selected: !_female,
                        onTap: () => setState(() => _female = false)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _Field(c: _age, label: 'Возраст', suffix: 'лет', int: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _Field(c: _weight, label: 'Вес', suffix: 'кг')),
                    const SizedBox(width: 10),
                    Expanded(child: _Field(c: _height, label: 'Рост', suffix: 'см')),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Обхваты (необязательно)',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _Field(c: _waist, label: 'Талия', suffix: 'см')),
                    const SizedBox(width: 10),
                    Expanded(child: _Field(c: _chest, label: 'Грудь', suffix: 'см')),
                    const SizedBox(width: 10),
                    Expanded(child: _Field(c: _hips, label: 'Бёдра', suffix: 'см')),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Уровень подготовки',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final l in FitnessLevel.values) ...[
                      _Choice(
                          label: l.label,
                          selected: _level == l,
                          onTap: () => setState(() => _level = l)),
                      if (l != FitnessLevel.values.last)
                        const SizedBox(width: 8),
                    ],
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.danger)),
                ],
                const SizedBox(height: 16),
                ChunkyButton(
                  size: 54,
                  width: double.infinity,
                  circle: false,
                  radius: 20,
                  color: AppColors.primary,
                  shadowColor: AppColors.primaryDark,
                  onTap: _save,
                  child: const Text('СОХРАНИТЬ',
                      style: TextStyle(
                          fontSize: 16,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border, width: 2),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: selected ? AppColors.primary : AppColors.text)),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.c,
    required this.label,
    required this.suffix,
    this.int = false,
  });

  final TextEditingController c;
  final String label;
  final String suffix;
  final bool int;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.numberWithOptions(decimal: !int),
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        labelStyle: const TextStyle(
            fontWeight: FontWeight.w800, color: AppColors.textSoft),
        suffixStyle: const TextStyle(
            fontWeight: FontWeight.w800, color: AppColors.textSoft),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
