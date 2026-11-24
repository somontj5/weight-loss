import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Показывает фото и на вебе (blob/network), и на Android (файл).
class ChatImage extends StatelessWidget {
  const ChatImage({super.key, required this.path, this.fit = BoxFit.cover});

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget broken(BuildContext c, Object e, StackTrace? s) => Container(
          color: AppColors.surface,
          child: const Icon(Icons.broken_image_rounded,
              color: AppColors.textSoft),
        );
    if (kIsWeb) {
      return Image.network(path, fit: fit, errorBuilder: broken);
    }
    return Image.file(File(path), fit: fit, errorBuilder: broken);
  }
}
