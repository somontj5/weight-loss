import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weightloss/domain/entities/profile.dart';
import 'package:weightloss/domain/nutrition/nutrition_calculator.dart';
import 'package:weightloss/domain/nutrition/validators.dart';
import 'package:weightloss/ui/providers/app_state.dart';
import 'package:weightloss/ui/theme/app_theme.dart';
import 'package:weightloss/ui/widgets/chunky_button.dart';

/// Правка своих данных: одна страница со всеми полями, как в обычных
/// приложениях. Регистрация заново не нужна. Закрывается результатом `true`,
/// если данные сохранены.
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, required this.initial, this.initialWeeks});

  final Profile initial;
  final int? initialWeeks;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _target = TextEditingController();
  final _waist = TextEditingController();
  final _chest = TextEditingController();
  final _hips = TextEditingController();

  late String _sex;
  late int _weeks;
  late int _minutes;
  late String _slot;

  final Map<String, String?> _errors = {};
  String? _saveError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _name.text = p.name;
    _sex = p.sex;
    _age.text = '${p.ageAt(DateTime.now())}';
    _height.text = _fmt(p.heightCm);
    _weight.text = _fmt(p.weightKg);
    _target.text = _fmt(p.targetWeightKg);
    _waist.text = p.waistCm == null ? '' : _fmt(p.waistCm!);
    _chest.text = p.chestCm == null ? '' : _fmt(p.chestCm!);
    _hips.text = p.hipsCm == null ? '' : _fmt(p.hipsCm!);
    _minutes = p.trainingMinutes;
    _slot = p.trainingSlot;
    _weeks = (widget.initialWeeks ?? 12).clamp(2, 52);
  }

  @override
  void dispose() {
    for (final c in [_name, _age, _height, _weight, _target, _waist, _chest, _hips]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _fmt(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  bool _validate() {
    final w = Validators.parse(_weight.text) ?? 70;
    final h = Validators.parse(_height.text) ?? 170;
    _errors
      ..clear()
      ..['name'] = Validators.name(_name.text)
      ..['age'] = Validators.age(_age.text)
      ..['height'] = Validators.height(_height.text)
      ..['weight'] = Validators.weight(_weight.text)
      ..['target'] =
          Validators.targetWeight(_target.text, weightKg: w, heightCm: h)
      ..['waist'] = Validators.girth(_waist.text)
      ..['chest'] = Validators.girth(_chest.text)
      ..['hips'] = Validators.girth(_hips.text)
      ..['weeks'] = Validators.weeks(_weeks);
    return _errors.values.every((e) => e == null);
  }

  Profile _build() {
    double? opt(TextEditingController c) =>
        c.text.trim().isEmpty ? null : Validators.parse(c.text);
    return widget.initial.copyWith(
      name: _name.text.trim(),
      sex: _sex,
      birthYear: DateTime.now().year - int.parse(_age.text.trim()),
      heightCm: Validators.parse(_height.text)!,
      weightKg: Validators.parse(_weight.text)!,
      targetWeightKg: Validators.parse(_target.text)!,
      waistCm: opt(_waist),
      chestCm: opt(_chest),
      hipsCm: opt(_hips),
      trainingMinutes: _minutes,
      trainingSlot: _slot,
      onboardingDone: true,
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
    if (!_validate()) {
      setState(() => _saveError = 'Проверь поля, отмеченные красным');
      return;
    }
    setState(() {
      _saving = true;
      _saveError = null;
    });
    final state = context.read<AppState>();
    final nav = Navigator.of(context);
    try {
      await state.saveProfile(_build(), weeks: _weeks, source: 'settings');
      if (nav.mounted) nav.pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = 'Не удалось сохранить данные. Попробуй ещё раз.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = Validators.parse(_weight.text) ?? widget.initial.weightKg;
    final t = Validators.parse(_target.text) ?? w;
    final lose = (w - t).clamp(0, 500).toDouble();
    final perWeek = lose / _weeks;
    final safe = perWeek <= NutritionCalculator.maxWeeklyLossKg(w);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Мои данные',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _Section('О тебе', [
                  _field(_name, 'Имя', 'name',
                      capitalization: TextCapitalization.words),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                        child: _Choice('Женщина', _sex == 'female',
                            () => setState(() => _sex = 'female'))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _Choice('Мужчина', _sex == 'male',
                            () => setState(() => _sex = 'male'))),
                  ]),
                  const SizedBox(height: 14),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                        child: _field(_age, 'Возраст', 'age',
                            unit: 'лет', decimal: false)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _field(_height, 'Рост', 'height',
                            unit: 'см', decimal: false)),
                  ]),
                ]),
                const SizedBox(height: 14),
                _Section('Цель', [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                        child: _field(_weight, 'Вес сейчас', 'weight',
                            unit: 'кг')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _field(_target, 'Хочу прийти к', 'target',
                            unit: 'кг')),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Expanded(
                      child: Text('Срок',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text)),
                    ),
                    Text('$_weeks нед.',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary)),
                  ]),
                  Slider(
                    value: _weeks.toDouble(),
                    min: 2,
                    max: 52,
                    divisions: 50,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _weeks = v.round()),
                  ),
                  Text(
                    lose == 0
                        ? 'Будем держать вес'
                        : '≈ ${perWeek.toStringAsFixed(2)} кг в неделю'
                            '${safe ? '' : ' — многовато, я смягчу темп'}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: safe ? AppColors.textSoft : AppColors.accentDark),
                  ),
                ]),
                const SizedBox(height: 14),
                _Section('Тренировки', [
                  const _Label('Сколько минут в день'),
                  const SizedBox(height: 8),
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    for (final m in const [10, 20, 30, 45, 60])
                      _Pill('$m мин', _minutes == m,
                          () => setState(() => _minutes = m)),
                  ]),
                  const SizedBox(height: 16),
                  const _Label('Когда удобнее'),
                  const SizedBox(height: 8),
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    _Pill('Утром', _slot == 'morning',
                        () => setState(() => _slot = 'morning')),
                    _Pill('Днём', _slot == 'day',
                        () => setState(() => _slot = 'day')),
                    _Pill('Вечером', _slot == 'evening',
                        () => setState(() => _slot = 'evening')),
                  ]),
                ]),
                const SizedBox(height: 14),
                _Section('Замеры тела (необязательно)', [
                  _field(_waist, 'Талия', 'waist', unit: 'см'),
                  const SizedBox(height: 12),
                  _field(_chest, 'Грудная клетка', 'chest', unit: 'см'),
                  const SizedBox(height: 12),
                  _field(_hips, 'Бёдра', 'hips', unit: 'см'),
                ]),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: AppColors.border, width: 2)),
            ),
            child: SafeArea(
              top: false,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (_saveError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(_saveError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                  ),
                ChunkyButton(
                  size: 54,
                  width: double.infinity,
                  circle: false,
                  radius: 18,
                  color: AppColors.primary,
                  shadowColor: AppColors.primaryDark,
                  onTap: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 3, color: Colors.white))
                      : const Text('СОХРАНИТЬ',
                          style: TextStyle(
                              fontSize: 17,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    String key, {
    String? unit,
    bool decimal = true,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    final numeric = unit != null;
    return TextField(
      controller: c,
      textCapitalization: capitalization,
      keyboardType:
          numeric ? TextInputType.numberWithOptions(decimal: decimal) : null,
      inputFormatters: numeric
          ? [
              FilteringTextInputFormatter.allow(
                  RegExp(decimal ? r'[0-9.,]' : r'[0-9]')),
              LengthLimitingTextInputFormatter(6),
            ]
          : null,
      onChanged: (_) => setState(() {
        _errors[key] = null;
        _saveError = null;
      }),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        errorText: _errors[key],
        errorMaxLines: 3,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border, width: 2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.danger, width: 2)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.danger, width: 2)),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.children);
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text)),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.textSoft));
}

class _Choice extends StatelessWidget {
  const _Choice(this.label, this.selected, this.onTap);
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 2),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: selected ? AppColors.primary : AppColors.text)),
          ),
        ),
      );
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, this.selected, this.onTap);
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 2),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: selected ? AppColors.primary : AppColors.text)),
        ),
      );
}
