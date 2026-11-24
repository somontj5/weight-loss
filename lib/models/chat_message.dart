enum Sender { user, fitty }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.sender,
    this.text = '',
    this.images = const [],
    this.audioPath,
    this.audioDuration = Duration.zero,
    this.waveform = const [],
    DateTime? time,
  }) : time = time ?? DateTime.now();

  final String id;
  final Sender sender;
  final String text;

  /// Пути к фото (на вебе — blob-ссылки, на Android — пути к файлам).
  final List<String> images;

  final String? audioPath;
  final Duration audioDuration;

  /// Нормализованные амплитуды 0..1 для отрисовки волны.
  final List<double> waveform;
  final DateTime time;

  bool get isUser => sender == Sender.user;
  bool get hasAudio => audioPath != null;
  bool get hasImages => images.isNotEmpty;
}

class RecordedAudio {
  const RecordedAudio({
    required this.path,
    required this.duration,
    required this.waveform,
  });

  final String path;
  final Duration duration;
  final List<double> waveform;
}
