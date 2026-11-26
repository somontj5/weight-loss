import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weightloss/domain/notifications/notification_models.dart';
import 'package:weightloss/domain/notifications/notification_service.dart';
import 'package:weightloss/ui/providers/app_state.dart';
import 'package:weightloss/ui/providers/chat_provider.dart';
import 'package:weightloss/ui/providers/workout_hub.dart';
import 'package:weightloss/ui/screens/onboarding_screen.dart';
import 'package:weightloss/ui/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;
  Map<String, int>? _quota;
  NotifPrefs _np = const NotifPrefs();
  bool _permOk = true;

  NotificationService get _notif => context.read<AppState>().deps.notifications;

  Future<void> _loadNotif() async {
    final p = await _notif.prefs();
    final ok = await _notif.gateway.hasPermission();
    if (!mounted) return;
    setState(() {
      _np = p;
      _permOk = ok;
    });
  }

  Future<void> _toggleNotif(bool v) async {
    await _notif.setEnabled(v);
    if (v) {
      final ok = await _notif.ensurePermission(force: true);
      if (!ok) _toast('Уведомления выключены в настройках телефона');
      await _notif.reschedule();
    }
    await _loadNotif();
  }

  Future<void> _setTone(String t) async {
    await _notif.setTone(t);
    await _loadNotif();
  }

  @override
  void initState() {
    super.initState();
    _loadQuota();
    _loadNotif();
  }

  Future<void> _loadQuota() async {
    final app = context.read<AppState>();
    if (!app.deps.aiConfig.hasKey) return;
    final q = await app.deps.quota.remainingByModel();
    if (mounted) setState(() => _quota = q);
  }

  void _toast(String t) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(t)));

  Future<void> _export() async {
    setState(() => _busy = true);
    File? exported;
    try {
      final app = context.read<AppState>();
      exported = await app.deps.exporter.exportToFile();
      await Share.shareXFiles([
        XFile(exported.path, mimeType: 'application/json'),
      ], subject: 'FITTY: мои данные');
    } catch (_) {
      _toast('Не удалось выгрузить данные');
    } finally {
      // Выгрузка содержит все данные о здоровье: не оставляем копию на диске.
      try {
        await exported?.delete();
      } catch (_) {}
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text(
          'Удалить все данные?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Профиль, переписка, память Фитти и история будут стёрты с телефона без возможности восстановления. Сначала можно выгрузить копию.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text(
              'Удалить',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final app = context.read<AppState>();
    final chat = context.read<ChatProvider>();
    final hub = context.read<WorkoutHub>();
    final nav = Navigator.of(context);
    try {
      await app.wipeAll();
      chat.reset();
      await hub.resetAll();
      if (nav.mounted) nav.popUntil((r) => r.isFirst);
    } catch (_) {
      _toast('Не удалось удалить данные');
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editProfile() async {
    final app = context.read<AppState>();
    final hub = context.read<WorkoutHub>();
    final res = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OnboardingScreen(
          initial: app.profile,
          initialWeeks: app.goal?.weeks,
        ),
      ),
    );
    if (res == true) {
      final p = app.profile;
      if (p != null) hub.syncFromProfile(p);
      _toast('Данные обновлены, норма пересчитана');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final plan = app.plan;
    final p = app.profile;
    final demo = !app.deps.aiConfig.hasKey;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Настройки',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (p != null && plan != null)
            _Card(
              children: [
                Text(
                  p.name.isEmpty ? 'Мой профиль' : p.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${p.weightKg.toStringAsFixed(p.weightKg % 1 == 0 ? 0 : 1)} кг → '
                  '${p.targetWeightKg.toStringAsFixed(p.targetWeightKg % 1 == 0 ? 0 : 1)} кг, '
                  '${plan.kcal} ккал в день',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSoft,
                  ),
                ),
                const SizedBox(height: 12),
                _Btn(
                  'Изменить мои данные',
                  Icons.edit_rounded,
                  _editProfile,
                  enabled: !_busy,
                ),
              ],
            ),
          const SizedBox(height: 12),
          _Card(
            children: [
              const Text(
                'Напоминания',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'Фитти напомнит про завтрак, обед, ужин и подведёт итог дня. Без интернета и без сервера, всё на телефоне.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSoft,
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Присылать напоминания',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                value: _np.enabled,
                onChanged: _toggleNotif,
              ),
              if (_np.enabled && !_permOk)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Телефон не разрешает уведомления. Включите их для FITTY в настройках телефона.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              if (_np.enabled) ...[
                const Text(
                  'Тон',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final t in NotifTone.all)
                      ChoiceChip(
                        label: Text(NotifTone.ru(t)),
                        selected: _np.tone == t,
                        onSelected: (_) => _setTone(t),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Не больше ${_np.maxPerDay} в день, ночью не беспокоим. Время подстраивается под ваш режим дня; можно сказать Фитти в чате: «напоминай про обед в 13:30».',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSoft,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _Card(
            children: [
              const Text(
                'Мои данные',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'Всё хранится только на этом телефоне. Можно выгрузить одним файлом или удалить совсем.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSoft,
                ),
              ),
              const SizedBox(height: 12),
              _Btn(
                'Выгрузить все данные (JSON)',
                Icons.ios_share_rounded,
                _export,
                enabled: !_busy,
              ),
              const SizedBox(height: 8),
              _Btn(
                'Удалить все данные',
                Icons.delete_forever_rounded,
                _delete,
                danger: true,
                enabled: !_busy,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Card(
            children: [
              const Text(
                'Фитти и ИИ',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                demo
                    ? 'Демо-режим: ключ Gemini не подключён, Фитти отвечает заготовками.'
                    : 'Подключён Gemini. Осталось ответов на сегодня:',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSoft,
                ),
              ),
              if (_quota != null)
                for (final e in _quota!.entries)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.key,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          '${e.value}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
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
      children: children,
    ),
  );
}

class _Btn extends StatelessWidget {
  const _Btn(
    this.label,
    this.icon,
    this.onTap, {
    this.danger = false,
    this.enabled = true,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = danger ? AppColors.danger : AppColors.primary;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.withValues(alpha: 0.4), width: 2),
          ),
          child: Row(
            children: [
              Icon(icon, color: c),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.w900, color: c),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
