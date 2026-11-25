import 'package:flutter/material.dart';

import 'package:weightloss/models/chat_message.dart';
import 'package:weightloss/ui/theme/app_theme.dart';
import 'package:weightloss/ui/widgets/chat_image.dart';
import 'package:weightloss/ui/widgets/fitty_avatar.dart';
import 'package:weightloss/ui/widgets/image_viewer.dart';
import 'package:weightloss/ui/widgets/voice_bubble.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final user = message.isUser;
    final maxW = MediaQuery.of(context).size.width * 0.78;

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: maxW),
      padding: EdgeInsets.all(message.hasImages ? 6 : 14),
      decoration: BoxDecoration(
        color: user ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(user ? 20 : 6),
          bottomRight: Radius.circular(user ? 6 : 20),
        ),
        border: user
            ? null
            : const Border.fromBorderSide(
                BorderSide(color: AppColors.border, width: 2)),
        boxShadow: user
            ? const [
                BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 3))
              ]
            : const [BoxShadow(color: AppColors.border, offset: Offset(0, 3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.hasImages)
            _ImageGrid(images: message.images, maxWidth: maxW - 12),
          if (message.hasAudio)
            Padding(
              padding: EdgeInsets.fromLTRB(
                  message.hasImages ? 8 : 0, message.hasImages ? 8 : 0, 8, 0),
              child: VoiceBubble(message: message),
            ),
          if (message.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                message.hasImages ? 8 : 0,
                (message.hasImages || message.hasAudio) ? 8 : 0,
                message.hasImages ? 8 : 0,
                message.hasImages ? 6 : 0,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: user ? Colors.white : AppColors.text,
                ),
              ),
            ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment:
            user ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!user) ...[
            const FittyAvatar(size: 36),
            const SizedBox(width: 8),
          ],
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({required this.images, required this.maxWidth});

  final List<String> images;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    const gap = 4.0;
    final n = images.length;
    final w = maxWidth.clamp(0.0, 300.0);

    Widget tile(int i, double tw, double th, {int extra = 0}) {
      return GestureDetector(
        onTap: () => ImageViewer.open(context, images, i),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: tw,
            height: th,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ChatImage(path: images[i]),
                if (extra > 0)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    alignment: Alignment.center,
                    child: Text(
                      '+$extra',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    if (n == 1) return tile(0, w, w * 0.85);
    if (n == 2) {
      final tw = (w - gap) / 2;
      return Row(mainAxisSize: MainAxisSize.min, children: [
        tile(0, tw, tw * 1.25),
        const SizedBox(width: gap),
        tile(1, tw, tw * 1.25),
      ]);
    }
    if (n == 3) {
      final tw = (w - gap) / 2;
      return Row(mainAxisSize: MainAxisSize.min, children: [
        tile(0, tw, tw * 2 + gap),
        const SizedBox(width: gap),
        Column(children: [
          tile(1, tw, tw),
          const SizedBox(height: gap),
          tile(2, tw, tw),
        ]),
      ]);
    }
    // 4+ : сетка 2x2, на последней плитке счётчик «ещё»
    final tw = (w - gap) / 2;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        tile(0, tw, tw),
        const SizedBox(width: gap),
        tile(1, tw, tw),
      ]),
      const SizedBox(height: gap),
      Row(mainAxisSize: MainAxisSize.min, children: [
        tile(2, tw, tw),
        const SizedBox(width: gap),
        tile(3, tw, tw, extra: n - 4),
      ]),
    ]);
  }
}

/// Три прыгающие точки, пока Фитти «печатает».
class TypingBubble extends StatefulWidget {
  const TypingBubble({super.key});

  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const FittyAvatar(size: 36),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(6),
              ),
              border: Border.all(color: AppColors.border, width: 2),
              boxShadow: const [
                BoxShadow(color: AppColors.border, offset: Offset(0, 3))
              ],
            ),
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final t = ((_c.value - i * 0.15) % 1.0);
                  final y = t < 0.5 ? -4 * (1 - (t - 0.25).abs() * 4) : 0.0;
                  return Padding(
                    padding: EdgeInsets.only(right: i == 2 ? 0 : 5),
                    child: Transform.translate(
                      offset: Offset(0, y.clamp(-4.0, 0.0)),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.borderDark,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
