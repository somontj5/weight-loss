import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../services/voice_recorder.dart';
import '../theme/app_theme.dart';
import '../widgets/composer.dart';
import '../widgets/fitty_avatar.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scroll = ScrollController();
  final _recorder = VoiceRecorder();
  int _lastCount = 0;
  bool _lastTyping = false;

  @override
  void dispose() {
    _scroll.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _scrollToEnd({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final to = _scroll.position.maxScrollExtent;
      if (animate) {
        _scroll.animateTo(to,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut);
      } else {
        _scroll.jumpTo(to);
      }
    });
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _showAttachSheet() async {
    final chat = context.read<ChatProvider>();
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AttachSheet(),
    );
    if (choice == null) return;
    final msg = choice == 'camera'
        ? await chat.takePhoto()
        : await chat.pickFromGallery();
    if (msg != null && mounted) _toast(msg);
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final messages = chat.messages;

    if (messages.length != _lastCount || chat.isTyping != _lastTyping) {
      _lastCount = messages.length;
      _lastTyping = chat.isTyping;
      _scrollToEnd();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(typing: chat.isTyping),
            Expanded(
              child: Container(
                color: AppColors.surface,
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  itemCount: messages.length + (chat.isTyping ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == messages.length) return const TypingBubble();
                    return MessageBubble(
                      key: ValueKey(messages[i].id),
                      message: messages[i],
                    );
                  },
                ),
              ),
            ),
            ListenableBuilder(
              listenable: _recorder,
              builder: (_, __) => Composer(
                recorder: _recorder,
                draftImages: chat.draftImages,
                onSendText: chat.sendText,
                onSendVoice: chat.sendVoice,
                onAttach: _showAttachSheet,
                onRemoveImage: chat.removeDraftImage,
                onMicDenied: () => _toast(
                    'Разреши доступ к микрофону, чтобы записывать голосовые'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.typing});

  final bool typing;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Фитти',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: typing ? AppColors.accent : AppColors.mint,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      typing ? 'печатает...' : 'онлайн',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSoft,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachSheet extends StatelessWidget {
  const _AttachSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Option(
                    icon: Icons.photo_library_rounded,
                    label: 'Галерея',
                    color: AppColors.primary,
                    shadow: AppColors.primaryDark,
                    onTap: () => Navigator.pop(context, 'gallery'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Option(
                    icon: Icons.photo_camera_rounded,
                    label: 'Камера',
                    color: AppColors.accent,
                    shadow: AppColors.accentDark,
                    onTap: () => Navigator.pop(context, 'camera'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.label,
    required this.color,
    required this.shadow,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color shadow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 34),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
