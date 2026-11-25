import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/chat_provider.dart';
import 'providers/workout_hub.dart';
import 'screens/home_shell.dart';
import 'services/audio_playback.dart';
import 'services/fitty_ai_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const FittyApp());
}

class FittyApp extends StatelessWidget {
  const FittyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Чтобы подключить настоящий ИИ — замени MockFittyAiService
        // своей реализацией FittyAiService.
        ChangeNotifierProvider(create: (_) => ChatProvider(MockFittyAiService())),
        ChangeNotifierProvider(create: (_) => AudioPlayback()),
        ChangeNotifierProvider(create: (_) => WorkoutHub()..load()),
      ],
      child: MaterialApp(
        title: 'Fitty Coach',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeShell(),
      ),
    );
  }
}
