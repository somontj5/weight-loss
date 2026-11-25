import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weightloss/models/chat_message.dart';
import 'package:weightloss/services/audio_playback.dart';
import 'package:weightloss/ui/theme/app_theme.dart';
import 'package:weightloss/ui/widgets/static_waveform.dart';

String formatDuration(Duration d) {
  final m = d.inMinutes.remainder(60).toString();
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Содержимое голосового сообщения: кнопка play, волна, таймер.
class VoiceBubble extends StatelessWidget {
  const VoiceBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<AudioPlayback>();
    final playing = playback.isPlaying(message.id);
    final pos = playback.positionOf(message.id);
    final total = message.audioDuration;
    final progress = total.inMilliseconds == 0
        ? 0.0
        : (pos.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);

    final user = message.isUser;
    final fg = user ? Colors.white : AppColors.primary;
    final fgSoft =
        user ? Colors.white.withValues(alpha: 0.45) : AppColors.borderDark;

    return SizedBox(
      width: 230,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => playback.toggle(message.id, message.audioPath!),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: user ? Colors.white : AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StaticWaveform(
                  bars: message.waveform,
                  progress: progress,
                  activeColor: fg,
                  inactiveColor: fgSoft,
                  onSeek: (p) => playback.seek(
                    message.id,
                    Duration(
                        milliseconds: (total.inMilliseconds * p).round()),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDuration(playing || pos > Duration.zero ? pos : total),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: user
                        ? Colors.white.withValues(alpha: 0.85)
                        : AppColors.textSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
