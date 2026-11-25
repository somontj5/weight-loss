import 'package:drift/native.dart';
import 'package:weightloss/data/db/app_database.dart';
import 'package:weightloss/data/repositories/conversation_repository_impl.dart';
import 'package:weightloss/data/repositories/memory_repository_impl.dart';
import 'package:weightloss/data/repositories/profile_repository_impl.dart';
import 'package:weightloss/domain/entities/profile.dart';
import 'package:weightloss/domain/profile_service.dart';

AppDatabase memDb() => AppDatabase(NativeDatabase.memory());

class Env {
  Env(this.now) : db = memDb() {
    profiles = ProfileRepositoryImpl(db, clock: () => now);
    memory = MemoryRepositoryImpl(db);
    conv = ConversationRepositoryImpl(db, clock: () => now);
    service = ProfileService(profiles, clock: () => now);
  }

  DateTime now;
  final AppDatabase db;
  late final ProfileRepositoryImpl profiles;
  late final MemoryRepositoryImpl memory;
  late final ConversationRepositoryImpl conv;
  late final ProfileService service;

  Future<void> seedProfile({int weeks = 12}) => service.save(
        Profile(
          name: 'Аня',
          sex: 'female',
          birthYear: now.year - 30,
          heightCm: 165,
          weightKg: 80,
          targetWeightKg: 70,
          waistCm: 90,
          trainingMinutes: 30,
          trainingSlot: 'evening',
          onboardingDone: true,
        ),
        weeks: weeks,
      );

  Future<void> close() => db.close();
}
