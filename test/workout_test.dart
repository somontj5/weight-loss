import 'package:flutter_test/flutter_test.dart';
import 'package:weightloss/controllers/workout_controller.dart';
import 'package:weightloss/models/user_profile.dart';
import 'package:weightloss/models/workout.dart';
import 'package:weightloss/services/calorie_calc.dart';
import 'package:weightloss/services/fitness_coach_service.dart';
import 'package:weightloss/services/workout_music.dart';

Workout _w() => Workout.fromJson({
      'title': 't',
      'exercises': [
        {'id': 'squat', 'durationSec': 30, 'restSec': 10},
        {'id': 'plank', 'durationSec': 20, 'restSec': 10},
        {'id': 'zzz', 'name': 'Моё', 'durationSec': 9999, 'restSec': -5, 'met': '4'},
        {'bad': true},
      ],
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parse: fills from catalog, clamps, drops broken', () {
    final w = _w();
    expect(w.exercises.length, 3);
    expect(w.exercises[0].name, 'Приседания');
    expect(w.exercises[0].met, 5.0);
    expect(w.exercises[2].durationSec, 300);
    expect(w.exercises[2].restSec, 0);
    expect(w.exercises[2].animationId, 'generic');
    expect(w.totalSec, 30 + 10 + 20 + 10 + 300);
  });

  test('calories formula', () {
    final k = CalorieCalc.kcal(met: 8, weightKg: 80, age: 25, seconds: 3600);
    expect(k, closeTo(640, 0.01));
    expect(CalorieCalc.ageFactor(60), lessThan(1));
  });

  test('local coach: no jumps for beginner, sane length', () async {
    final w = await LocalFitnessCoach().generateWorkout(const WorkoutRequest(
        profile: UserProfile(configured: true), caloriesEaten: 0, minutes: 20));
    expect(w.exercises.length, greaterThan(4));
    expect(w.exercises.last.restSec, 0);
    expect(w.totalSec, inInclusiveRange(15 * 60, 25 * 60));
    for (final e in w.exercises) {
      expect(['jumping_jack', 'high_knees', 'burpee', 'mountain_climber'].contains(e.id), false);
    }
  });

  test('controller flow logs skip / pause / early finish', () async {
    final c = WorkoutController(
        workout: _w(), profile: const UserProfile(weightKg: 80), music: WorkoutMusic());
    c.skipReady();
    expect(c.phase, WorkoutPhase.exercise);
    c.skipExercise();
    expect(c.logs[0].status, 'skipped');
    expect(c.logs[0].restOutcome, 'omitted');
    expect(c.index, 1);
    c.pause(15);
    expect(c.paused, true);
    c.resume();
    expect(c.logs[1].pauses.length, 1);
    c.finishEarly();
    expect(c.phase, WorkoutPhase.finished);
    expect(c.session!.finishedEarly, true);
    final j = c.session!.toJson();
    expect(j['exercisesSkipped'], 2);
    expect((j['exercises'] as List).length, 3);
    c.dispose();
  });
}
