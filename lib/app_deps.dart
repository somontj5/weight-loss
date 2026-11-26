import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:weightloss/config/ai_config.dart';
import 'package:weightloss/domain/notifications/notification_planner.dart';
import 'package:weightloss/config/context_config.dart';
import 'package:weightloss/data/db/app_database.dart';
import 'package:weightloss/data/db/connection.dart';
import 'package:weightloss/data/repositories/conversation_repository_impl.dart';
import 'package:weightloss/data/repositories/data_export_service.dart';
import 'package:weightloss/data/repositories/memory_repository_impl.dart';
import 'package:weightloss/data/repositories/profile_repository_impl.dart';
import 'package:weightloss/data/repositories/usage_repository.dart';
import 'package:weightloss/domain/context/context_assembler.dart';
import 'package:weightloss/data/repositories/diary_repository_impl.dart';
import 'package:weightloss/data/repositories/settings_repository_impl.dart';
import 'package:weightloss/domain/actions/action_dispatcher.dart';
import 'package:weightloss/domain/actions/set_activity_handler.dart';
import 'package:weightloss/domain/context/part2_stubs.dart';
import 'package:weightloss/data/repositories/notification_schedule_repository_impl.dart';
import 'package:weightloss/domain/actions/notification_handlers.dart';
import 'package:weightloss/domain/notifications/notification_gateway.dart';
import 'package:weightloss/domain/notifications/notification_service.dart';
import 'package:weightloss/data/repositories/workout_repository_impl.dart';
import 'package:weightloss/domain/actions/plan_workout_handler.dart';
import 'package:weightloss/domain/coach/coach_service.dart';
import 'package:weightloss/domain/coach/workout_repository.dart';
import 'package:weightloss/services/local_notification_gateway.dart';
import 'package:weightloss/domain/diary/diary_calc.dart';
import 'package:weightloss/domain/diary/diary_service.dart';
import 'package:weightloss/domain/settings/settings_repository.dart';
import 'package:weightloss/domain/memory/memory_service.dart';
import 'package:weightloss/domain/profile_service.dart';
import 'package:weightloss/domain/repositories/repositories.dart';
import 'package:weightloss/services/ai/gemini_client.dart';
import 'package:weightloss/services/ai/model_router.dart';
import 'package:weightloss/services/ai/quota_manager.dart';
import 'package:weightloss/services/chat_service.dart';

/// Сборка всех зависимостей в одном месте (простая ручная DI).
class AppDeps {
  AppDeps._(
    this.db,
    this.aiConfig,
    this.contextConfig, [
    NotificationGateway? gateway,
  ]) {
    profiles = ProfileRepositoryImpl(db);
    memoryRepo = MemoryRepositoryImpl(db);
    conversation = ConversationRepositoryImpl(db);
    final usage = UsageRepository(db);
    quota = QuotaManager(usage, aiConfig);
    memoryService = MemoryService(memoryRepo);
    exporter = DataExportService(db);

    settings = SettingsRepositoryImpl(db);
    profileService = ProfileService(profiles, settings: settings);
    diary = DiaryService(DiaryRepositoryImpl(db));
    diarySource = DbDiarySource(diary);
    diaryCalc = DiaryCalc(
      diary: diary,
      source: diarySource,
      profiles: profiles,
      settings: settings,
    );
    final schedule = NotificationScheduleRepositoryImpl(db);
    notifications = NotificationService(
      gateway: gateway ?? LocalNotificationGateway(),
      settings: settings,
      schedule: schedule,
      memory: memoryRepo,
      profiles: profiles,
      diary: diary,
    );
    workoutRepo = WorkoutRepositoryImpl(db);
    coach = CoachService(
      profiles: profiles,
      diary: diary,
      memory: memoryRepo,
      workouts: workoutRepo,
      onChanged: notifications.reschedule,
      quietRange: () async =>
          NotificationPlanner.quietRange(await notifications.buildInput()),
      onlineProbe: () async {
        if (!aiConfig.hasKey || kIsWeb) return false;
        try {
          final r = await InternetAddress.lookup(
            'generativelanguage.googleapis.com',
          ).timeout(const Duration(seconds: 3));
          return r.isNotEmpty;
        } catch (_) {
          return false;
        }
      },
    );
    notifications.plannedWorkouts = () =>
        workoutRepo.plannedTimes(DateTime.now());
    dispatcher = ActionDispatcher(
      memory: memoryService,
      diary: diary,
      calc: diaryCalc,
      handlers: [
        SetActivityHandler(profileService),
        ScheduleNotificationHandler(notifications, schedule),
        PlanWorkoutHandler(coach),
      ],
    );

    assembler = ContextAssembler(
      profiles: profiles,
      memory: memoryRepo,
      conversation: conversation,
      diary: diarySource,
      workouts: DbWorkoutHistorySource(workoutRepo),
      config: contextConfig,
    );
    router = ModelRouter(GeminiClient(aiConfig), quota, aiConfig);
    chat = ChatService(
      assembler: assembler,
      router: router,
      dispatcher: dispatcher,
      calc: diaryCalc,
      onScheduleDirty: notifications.reschedule,
      coachBlock: coach.block,
      onAiStatus: (ok) => coach.aiOnline = ok,
      conversation: conversation,
      aiConfig: aiConfig,
      contextConfig: contextConfig,
    );
  }

  factory AppDeps.create({
    AiConfig aiConfig = AiConfig.defaults,
    ContextConfig contextConfig = ContextConfig.defaults,
    NotificationGateway? gateway,
  }) => AppDeps._(
    AppDatabase(openDeviceDatabase()),
    aiConfig,
    contextConfig,
    gateway,
  );

  final AppDatabase db;
  final AiConfig aiConfig;
  final ContextConfig contextConfig;

  late final ProfileRepository profiles;
  late final MemoryRepository memoryRepo;
  late final ConversationRepository conversation;
  late final QuotaManager quota;
  late final ProfileService profileService;
  late final MemoryService memoryService;
  late final DataExportService exporter;
  late final SettingsRepository settings;
  late final DiaryService diary;
  late final DbDiarySource diarySource;
  late final DiaryCalc diaryCalc;
  late final NotificationService notifications;
  late final WorkoutRepository workoutRepo;
  late final CoachService coach;
  late final ActionDispatcher dispatcher;
  late final ContextAssembler assembler;
  late final ModelRouter router;
  late final ChatService chat;
}
