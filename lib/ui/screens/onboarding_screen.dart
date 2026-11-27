import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weightloss/domain/entities/profile.dart';
import 'package:weightloss/domain/nutrition/nutrition_calculator.dart';
import 'package:weightloss/domain/nutrition/validators.dart';
import 'package:weightloss/ui/providers/app_state.dart';
import 'package:weightloss/ui/theme/app_theme.dart';
import 'package:weightloss/ui/widgets/chunky_button.dart';
import 'package:weightloss/ui/widgets/fitty_avatar.dart';

/// Регистрация короткими шагами (только первый запуск). Только измеримое:
/// всё остальное Фитти узнаёт в разговоре. Править данные потом можно на
/// экране [ProfileEditScreen], сюда повторно не возвращаемся.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onDone});

  /// Вызывается после сохранения (для приветствия в чате).
  final Future<void> Function(Profile profile, NutritionNorm norm, int weeks)?
      onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Step { hello, name, sex, age, height, weight, target, girths, weeks, training, result }

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _steps = _Step.values;

  int _i = 0;
  String? _error;
  bool _saving = false;
  NutritionNorm? _norm;

  final _name = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _target = TextEditingController();
  final _waist = TextEditingController();
  final _chest = TextEditingController();
  final _hips = TextEditingController();

  String _sex = 'female';
  int _weeks = 12;
  int _minutes = 20;
  String _slot = 'evening';

  @override
  void dispose() {
    for (final c in [_name, _age, _height, _weight, _target, _waist, _chest, _hips]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _fmt(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  double get _w => Validators.parse(_weight.text) ?? 70;
  double get _h => Validators.parse(_height.text) ?? 170;

  String? _validate(_Step s) {
    switch (s) {
      case _Step.name:
        return Validators.name(_name.text);
      case _Step.age:
        return Validators.age(_age.text);
      case _Step.height:
        return Validators.height(_height.text);
      case _Step.weight:
        return Validators.weight(_weight.text);
      case _Step.target:
        return Validators.targetWeight(_target.text,
            weightKg: _w, heightCm: _h);
      case _Step.girths:
        return Validators.girth(_waist.text) ??
            Validators.girth(_chest.text) ??
            Validators.girth(_hips.text);
      case _Step.weeks:
        return Validators.weeks(_weeks);
      default:
        return null;
    }
  }

  Profile _build() {
    double? opt(TextEditingController c) =>
        c.text.trim().isEmpty ? null : Validators.parse(c.text);
    return Profile(
      name: _name.text.trim(),
      sex: _sex,
      birthYear: DateTime.now().year - int.parse(_age.text.trim()),
      heightCm: _h,
      weightKg: _w,
      targetWeightKg: Validators.parse(_target.text)!,
      waistCm: opt(_waist),
      chestCm: opt(_chest),
      hipsCm: opt(_hips),
      trainingMinutes: _minutes,
      trainingSlot: _slot,
      onboardingDone: true,
    );
  }

  Future<void> _next() async {
    final s = _steps[_i];
    final err = _validate(s);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _error = null);

    if (s == _Step.training) {
      // считаем и показываем результат (пока не сохраняем)
      final p = _build();
      final norm = context.read<AppState>().deps.profileService.calculate(p, _weeks);
      setState(() {
        _norm = norm;
        _i++;
      });
      return;
    }
    if (s == _Step.result) {
      await _finish();
      return;
    }
    setState(() => _i++);
  }

  void _back() {
    if (_i == 0) return;
    setState(() {
      _error = null;
      _i--;
    });
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    final state = context.read<AppState>();
    final p = _build();
    try {
      final norm =
          await state.saveProfile(p, weeks: _weeks, source: 'onboarding');
      await widget.onDone?.call(p, norm, _weeks);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Не удалось сохранить данные. Попробуй ещё раз.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _steps[_i];
    final progress = (_i + 1) / _steps.length;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Стрелка «назад» занимает отдельную строку фиксированной высоты
            // (на первом шаге её просто нет), а полоска прогресса всегда стоит
            // на одном и том же месте и не «ездит» между шагами.
            SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _i == 0
                    ? const SizedBox.shrink()
                    : IconButton(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        onPressed: _back,
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.textSoft),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 14,
                  backgroundColor: AppColors.border,
                  color: AppColors.mint,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: KeyedSubtree(key: ValueKey(s), child: _stepBody(s)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                    ),
                  ChunkyButton(
                    size: 56,
                    width: double.infinity,
                    circle: false,
                    radius: 18,
                    color: AppColors.primary,
                    shadowColor: AppColors.primaryDark,
                    onTap: _saving ? null : _next,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 3, color: Colors.white))
                        : Text(_buttonLabel(s),
                            style: const TextStyle(
                                fontSize: 17,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w900,
                                color: Colors.white)),
                  ),
                  if (s == _Step.girths)
                    TextButton(
                      onPressed: () => setState(() {
                        _waist.clear();
                        _chest.clear();
                        _hips.clear();
                        _error = null;
                        _i++;
                      }),
                      child: const Text('ПРОПУСТИТЬ',
                          style: TextStyle(
                              color: AppColors.textSoft,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buttonLabel(_Step s) => switch (s) {
        _Step.hello => 'ПОЕХАЛИ',
        _Step.result => 'НАЧАТЬ',
        _ => 'ПРОДОЛЖИТЬ',
      };

  Widget _title(String t, {String? sub}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t,
              style: const TextStyle(
                  fontSize: 26,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text)),
          if (sub != null) ...[
            const SizedBox(height: 8),
            Text(sub,
                style: const TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSoft)),
          ],
          const SizedBox(height: 24),
        ],
      );

  Widget _numField(TextEditingController c, String unit,
      {bool decimal = true, String? hint}) {
    return TextField(
      controller: c,
      autofocus: true,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(decimal ? r'[0-9.,]' : r'[0-9]')),
        LengthLimitingTextInputFormatter(6),
      ],
      onChanged: (_) => setState(() => _error = null),
      onSubmitted: (_) => _next(),
      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
      textAlign: TextAlign.center,
      decoration: _dec(hint: hint, suffix: unit),
    );
  }

  InputDecoration _dec({String? hint, String? suffix, String? label}) =>
      InputDecoration(
        hintText: hint,
        labelText: label,
        suffixText: suffix,
        suffixStyle: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textSoft),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border, width: 2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      );

  Widget _stepBody(_Step s) {
    switch (s) {
      case _Step.hello:
        return Column(
          children: [
            const SizedBox(height: 20),
            const FittyAvatar(size: 120),
            const SizedBox(height: 24),
            const Text('Привет! Я Фитти',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text)),
            const SizedBox(height: 12),
            const Text(
              'Буду твоим диетологом и тренером. Сначала несколько цифр, '
              'чтобы посчитать твою норму. Всё остальное расскажешь мне в чате.\n\n'
              'Данные хранятся только на твоём телефоне.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSoft),
            ),
          ],
        );
      case _Step.name:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _title('Как тебя зовут?'),
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _next(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            textAlign: TextAlign.start,
            decoration: _dec(hint: 'Имя'),
          ),
        ]);
      case _Step.sex:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _title('Твой пол?',
              sub: 'Нужен для точного расчёта обмена веществ.'),
          _Choice('Женщина', _sex == 'female',
              () => setState(() => _sex = 'female')),
          const SizedBox(height: 12),
          _Choice('Мужчина', _sex == 'male', () => setState(() => _sex = 'male')),
        ]);
      case _Step.age:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _title('Сколько тебе лет?'),
          _numField(_age, 'лет', decimal: false),
        ]);
      case _Step.height:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _title('Какой у тебя рост?'),
          _numField(_height, 'см', decimal: false),
        ]);
      case _Step.weight:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _title('Сколько ты весишь сейчас?'),
          _numField(_weight, 'кг'),
        ]);
      case _Step.target:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _title('До какого веса хочешь дойти?',
              sub: 'Реалистичная цель — залог успеха.'),
          _numField(_target, 'кг'),
        ]);
      case _Step.girths:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _title('Замеры тела',
              sub: 'Необязательно, в сантиметрах. Помогут видеть прогресс, когда вес стоит.'),
          _girth(_waist, 'Талия'),
          const SizedBox(height: 12),
          _girth(_chest, 'Грудная клетка'),
          const SizedBox(height: 12),
          _girth(_hips, 'Бёдра'),
        ]);
      case _Step.weeks:
        final p = _tryProfile();
        final w = p?.weightKg ?? 70;
        final t = Validators.parse(_target.text) ?? w;
        final lose = (w - t).clamp(0, 500);
        final perWeek = _weeks == 0 ? 0 : lose / _weeks;
        final safe = perWeek <= NutritionCalculator.maxWeeklyLossKg(w);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _title('За какой срок?',
              sub: 'Скинуть ${_fmt(lose.toDouble())} кг. Безопасный темп — до 1% веса в неделю.'),
          Center(
            child: Text('$_weeks нед.',
                style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary)),
          ),
          Slider(
            value: _weeks.toDouble(),
            min: 2,
            max: 52,
            divisions: 50,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() {
              _weeks = v.round();
              _error = null;
            }),
          ),
          Center(
            child: Text(
              lose == 0
                  ? 'Будем держать вес'
                  : '≈ ${perWeek.toStringAsFixed(2)} кг в неделю'
                      '${safe ? '' : ' — многовато, я смягчу темп'}',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: safe ? AppColors.textSoft : AppColors.accentDark),
            ),
          ),
        ]);
      case _Step.training:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _title('Время для тренировок',
              sub: 'Сколько минут в день и когда тебе удобнее?'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final m in const [10, 20, 30, 45, 60])
                _Pill('$m мин', _minutes == m, () => setState(() => _minutes = m)),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Pill('Утром', _slot == 'morning',
                  () => setState(() => _slot = 'morning')),
              _Pill('Днём', _slot == 'day', () => setState(() => _slot = 'day')),
              _Pill('Вечером', _slot == 'evening',
                  () => setState(() => _slot = 'evening')),
            ],
          ),
        ]);
      case _Step.result:
        return _result();
    }
  }

  Profile? _tryProfile() {
    final w = Validators.parse(_weight.text);
    return w == null ? null : Profile(
        name: '', sex: _sex, birthYear: 1990, heightCm: _h, weightKg: w,
        targetWeightKg: w);
  }

  Widget _girth(TextEditingController c, String label) => TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          LengthLimitingTextInputFormatter(6),
        ],
        onChanged: (_) => setState(() => _error = null),
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        decoration: _dec(label: label, suffix: 'см'),
      );

  Widget _result() {
    final n = _norm!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title('Твоя норма готова!'),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFD9CBFF), width: 2),
        ),
        child: Column(children: [
          Text('${n.kcal}',
              style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary)),
          const Text('ккал в день',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSoft)),
          const SizedBox(height: 16),
          Row(children: [
            _Macro('Белки', n.proteinG, AppColors.accent),
            _Macro('Жиры', n.fatG, const Color(0xFFFFB020)),
            _Macro('Углеводы', n.carbsG, AppColors.mint),
          ]),
        ]),
      ),
      const SizedBox(height: 14),
      Text(
        'Обмен в покое ${n.bmr} ккал, с учётом активности ${n.tdee} ккал. '
        'Дефицит ${n.deficitKcal} ккал, это около ${n.weeklyLossKg.toStringAsFixed(2)} кг в неделю.',
        style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w700,
            color: AppColors.textSoft),
      ),
      for (final note in n.notes)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1EC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_rounded,
                  color: AppColors.accentDark, size: 20),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(note,
                      style: const TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text))),
            ]),
          ),
        ),
      const SizedBox(height: 10),
      const Text(
        'Это ориентир, а не медицинское назначение. При заболеваниях проконсультируйся с врачом.',
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSoft),
      ),
    ]);
  }
}

class _Macro extends StatelessWidget {
  const _Macro(this.label, this.grams, this.color);
  final String label;
  final int grams;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text('$grams г',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSoft)),
        ]),
      );
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 2),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 18,
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 2),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: selected ? AppColors.primary : AppColors.text)),
        ),
      );
}
