import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weightloss/app_deps.dart';
import 'package:weightloss/services/ai/fitty_persona.dart';
import 'package:weightloss/ui/providers/app_state.dart';
import 'package:weightloss/ui/providers/chat_provider.dart';
import 'package:weightloss/ui/providers/workout_hub.dart';
import 'package:weightloss/ui/screens/home_shell.dart';
import 'package:weightloss/ui/screens/onboarding_screen.dart';
import 'package:weightloss/services/audio_playback.dart';
import 'package:weightloss/ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(FittyApp(deps: AppDeps.create()));
}

class FittyApp extends StatelessWidget {
  const FittyApp({super.key, required this.deps});

  final AppDeps deps;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDeps>.value(value: deps),
        ChangeNotifierProvider(create: (_) => AppState(deps)),
        ChangeNotifierProvider(
            create: (_) => ChatProvider(deps.chat, deps.conversation)..load()),
        ChangeNotifierProvider(create: (_) => AudioPlayback()),
        ChangeNotifierProvider(create: (_) => WorkoutHub()..load()),
      ],
      child: MaterialApp(
        title: 'FITTY',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _Root(),
      ),
    );
  }
}

/// Решает, что показать: регистрацию или основное приложение.
class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final app = context.read<AppState>();
      final hub = context.read<WorkoutHub>();
      await app.load();
      if (app.profile != null) hub.syncFromProfile(app.profile!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (!app.loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!app.onboarded) {
      return OnboardingScreen(
        key: const ValueKey('onboarding'),
        onDone: (profile, norm, weeks) async {
          final chat = context.read<ChatProvider>();
          context.read<WorkoutHub>().syncFromProfile(profile);
          await chat.postFitty(FittyPersona.welcome(
            name: profile.name,
            kcal: norm.kcal,
            proteinG: norm.proteinG,
            fatG: norm.fatG,
            carbsG: norm.carbsG,
            weeks: weeks,
            paceAdjusted: norm.paceAdjusted,
            effectiveWeeks: norm.effectiveWeeks,
          ));
        },
      );
    }
    return const HomeShell();
  }
}
