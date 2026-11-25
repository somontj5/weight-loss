import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:weightloss/domain/entities/diet_plan.dart';
import 'package:weightloss/domain/entities/profile.dart';
import 'package:weightloss/domain/repositories/repositories.dart';
import 'package:weightloss/data/db/app_database.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._db, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;
  final AppDatabase _db;
  final DateTime Function() _clock;

  @override
  Future<Profile?> getProfile() async {
    final r = await (_db.select(_db.profiles)..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (r == null) return null;
    return Profile(
      name: r.name,
      sex: r.sex,
      birthYear: r.birthYear,
      heightCm: r.heightCm,
      weightKg: r.weightKg,
      targetWeightKg: r.targetWeightKg,
      waistCm: r.waistCm,
      chestCm: r.chestCm,
      hipsCm: r.hipsCm,
      trainingMinutes: r.trainingMinutes,
      trainingSlot: r.trainingSlot,
      onboardingDone: r.onboardingDone,
    );
  }

  @override
  Future<Goal?> getGoal() async {
    final r = await (_db.select(_db.goals)
          ..where((t) => t.status.equals('active'))
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
    if (r == null) return null;
    return Goal(
      startWeightKg: r.startWeightKg,
      targetWeightKg: r.targetWeightKg,
      startDate: r.startDate,
      targetDate: r.targetDate,
      weeks: r.weeks,
    );
  }

  @override
  Future<DietPlanData?> getDietPlan() async {
    final r = await (_db.select(_db.dietPlans)
          ..where((t) => t.active.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
    if (r == null) return null;
    return DietPlanData(
      kcal: r.kcalTarget,
      proteinG: r.proteinG,
      fatG: r.fatG,
      carbsG: r.carbsG,
      toleranceKcal: r.toleranceKcal,
      bmr: r.bmr,
      tdee: r.tdee,
      deficitKcal: r.deficitKcal,
      weeklyLossKg: r.weeklyLossKg,
      notes: (jsonDecode(r.notesJson) as List).cast<String>(),
    );
  }

  @override
  Future<List<WeightPoint>> weightHistory({int limit = 10}) async {
    final rows = await (_db.select(_db.profileHistory)
          ..orderBy([
            (t) => OrderingTerm.desc(t.recordedAt),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(limit))
        .get();
    return rows.reversed.map((e) => WeightPoint(e.recordedAt, e.weightKg)).toList();
  }

  @override
  Future<void> saveProfile(Profile p,
      {required Goal goal,
      required DietPlanData plan,
      String source = 'settings'}) async {
    final now = _clock();
    await _db.transaction(() async {
      final exists = await (_db.select(_db.profiles)
            ..where((t) => t.id.equals(1)))
          .getSingleOrNull();
      final companion = ProfilesCompanion(
        id: const Value(1),
        name: Value(p.name),
        sex: Value(p.sex),
        birthYear: Value(p.birthYear),
        heightCm: Value(p.heightCm),
        weightKg: Value(p.weightKg),
        targetWeightKg: Value(p.targetWeightKg),
        waistCm: Value(p.waistCm),
        chestCm: Value(p.chestCm),
        hipsCm: Value(p.hipsCm),
        trainingMinutes: Value(p.trainingMinutes),
        trainingSlot: Value(p.trainingSlot),
        onboardingDone: Value(p.onboardingDone),
        createdAt: Value(exists?.createdAt ?? now),
        updatedAt: Value(now),
      );
      await _db.into(_db.profiles).insertOnConflictUpdate(companion);

      await _db.into(_db.profileHistory).insert(ProfileHistoryCompanion.insert(
            recordedAt: now,
            weightKg: p.weightKg,
            targetWeightKg: p.targetWeightKg,
            heightCm: p.heightCm,
            waistCm: Value(p.waistCm),
            chestCm: Value(p.chestCm),
            hipsCm: Value(p.hipsCm),
            source: Value(source),
          ));

      await (_db.update(_db.goals)..where((t) => t.status.equals('active')))
          .write(const GoalsCompanion(status: Value('archived')));
      await _db.into(_db.goals).insert(GoalsCompanion.insert(
            startWeightKg: goal.startWeightKg,
            targetWeightKg: goal.targetWeightKg,
            startDate: goal.startDate,
            targetDate: goal.targetDate,
            weeks: goal.weeks,
            createdAt: now,
          ));

      await (_db.update(_db.dietPlans)..where((t) => t.active.equals(true)))
          .write(const DietPlansCompanion(active: Value(false)));
      await _db.into(_db.dietPlans).insert(DietPlansCompanion.insert(
            createdAt: now,
            kcalTarget: plan.kcal,
            proteinG: plan.proteinG,
            fatG: plan.fatG,
            carbsG: plan.carbsG,
            bmr: plan.bmr,
            tdee: plan.tdee,
            deficitKcal: plan.deficitKcal,
            weeklyLossKg: plan.weeklyLossKg,
            toleranceKcal: Value(plan.toleranceKcal),
            notesJson: Value(jsonEncode(plan.notes)),
          ));
    });
  }
}
