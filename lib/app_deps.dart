import 'package:weightloss/config/ai_config.dart';
import 'package:weightloss/config/context_config.dart';
import 'package:weightloss/data/db/app_database.dart';
import 'package:weightloss/data/db/connection.dart';
import 'package:weightloss/data/repositories/conversation_repository_impl.dart';
import 'package:weightloss/data/repositories/data_export_service.dart';
import 'package:weightloss/data/repositories/memory_repository_impl.dart';
import 'package:weightloss/data/repositories/profile_repository_impl.dart';
import 'package:weightloss/data/repositories/usage_repository.dart';
import 'package:weightloss/domain/context/context_assembler.dart';
import 'package:weightloss/domain/context/part2_stubs.dart';
import 'package:weightloss/domain/memory/memory_service.dart';
import 'package:weightloss/domain/profile_service.dart';
import 'package:weightloss/domain/repositories/repositories.dart';
import 'package:weightloss/services/ai/gemini_client.dart';
import 'package:weightloss/services/ai/model_router.dart';
import 'package:weightloss/services/ai/quota_manager.dart';
import 'package:weightloss/services/chat_service.dart';

/// Сборка всех зависимостей в одном месте (простая ручная DI).
class AppDeps {
  AppDeps._(this.db, this.aiConfig, this.contextConfig) {
    profiles = ProfileRepositoryImpl(db);
    memoryRepo = MemoryRepositoryImpl(db);
    conversation = ConversationRepositoryImpl(db);
    final usage = UsageRepository(db);
    quota = QuotaManager(usage, aiConfig);
    profileService = ProfileService(profiles);
    memoryService = MemoryService(memoryRepo);
    exporter = DataExportService(db);

    // Слоты части 2: сейчас пустые источники.
    assembler = ContextAssembler(
      profiles: profiles,
      memory: memoryRepo,
      conversation: conversation,
      diary: const EmptyDiarySource(),
      workouts: const EmptyWorkoutHistorySource(),
      config: contextConfig,
    );
    router = ModelRouter(GeminiClient(aiConfig), quota, aiConfig);
    chat = ChatService(
      assembler: assembler,
      router: router,
      memory: memoryService,
      conversation: conversation,
      aiConfig: aiConfig,
      contextConfig: contextConfig,
    );
  }

  factory AppDeps.create({
    AiConfig aiConfig = AiConfig.defaults,
    ContextConfig contextConfig = ContextConfig.defaults,
  }) =>
      AppDeps._(AppDatabase(openDeviceDatabase()), aiConfig, contextConfig);

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
  late final ContextAssembler assembler;
  late final ModelRouter router;
  late final ChatService chat;
}
