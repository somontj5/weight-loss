import 'dart:convert';
import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

/// Вложение к запросу в Gemini (inlineData).
class Attachment {
  const Attachment({required this.mime, required this.bytes, this.isAudio = false});
  final String mime;
  final Uint8List bytes;
  final bool isAudio;

  Map<String, dynamic> toPart() => {
        'inlineData': {'mimeType': mime, 'data': base64Encode(bytes)}
      };
}

/// Читает байты по пути (файл на Android, blob-ссылка в вебе).
typedef BytesReader = Future<Uint8List> Function(String path);

Future<Uint8List> defaultBytesReader(String path) async {
  if (kIsWeb || path.startsWith('blob:') || path.startsWith('http')) {
    return http.readBytes(Uri.parse(path));
  }
  return File(path).readAsBytes();
}

/// Готовит фото и голос к отправке: фото сжимаются до ~1024 px (JPEG),
/// не больше [maxImages] фото за запрос, аудио уходит как есть.
class MediaPreparer {
  MediaPreparer({BytesReader? reader, this.maxImages = 4, this.maxSide = 1024})
      : _read = reader ?? defaultBytesReader;

  final BytesReader _read;
  final int maxImages;
  final int maxSide;

  static const maxAudioBytes = 15 * 1024 * 1024;

  Future<List<Attachment>> prepare(
      {List<String> images = const [], String? audioPath}) async {
    final out = <Attachment>[];
    for (final p in images.take(maxImages)) {
      try {
        final raw = await _read(p);
        final jpg = await compute(_compressJob, _Job(raw, maxSide));
        if (jpg != null) out.add(Attachment(mime: 'image/jpeg', bytes: jpg));
      } catch (_) {
        // нечитаемое фото пропускаем
      }
    }
    if (audioPath != null && audioPath.isNotEmpty) {
      try {
        final raw = await _read(audioPath);
        if (raw.isNotEmpty && raw.length <= maxAudioBytes) {
          out.add(Attachment(
              mime: audioMime(audioPath), bytes: raw, isAudio: true));
        }
      } catch (_) {}
    }
    return out;
  }

  static String audioMime(String path) {
    final l = path.toLowerCase();
    if (l.endsWith('.m4a') || l.endsWith('.mp4') || l.endsWith('.aac')) {
      return 'audio/mp4';
    }
    if (l.endsWith('.wav')) return 'audio/wav';
    if (l.endsWith('.mp3')) return 'audio/mp3';
    if (l.endsWith('.ogg')) return 'audio/ogg';
    return 'audio/webm';
  }

  /// Сжатие: длинная сторона не больше [maxSide], JPEG q80. null — не картинка.
  static Uint8List? compressJpeg(Uint8List raw, {int maxSide = 1024}) =>
      _compressJob(_Job(raw, maxSide));
}

class _Job {
  const _Job(this.raw, this.maxSide);
  final Uint8List raw;
  final int maxSide;
}

Uint8List? _compressJob(_Job j) {
  final decoded = img.decodeImage(j.raw);
  if (decoded == null) return null;
  var im = img.bakeOrientation(decoded);
  final longest = im.width > im.height ? im.width : im.height;
  if (longest > j.maxSide) {
    im = im.width >= im.height
        ? img.copyResize(im, width: j.maxSide)
        : img.copyResize(im, height: j.maxSide);
  }
  return Uint8List.fromList(img.encodeJpg(im, quality: 80));
}
