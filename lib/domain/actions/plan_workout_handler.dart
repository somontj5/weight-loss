import 'package:weightloss/domain/actions/action_dispatcher.dart';
import 'package:weightloss/domain/coach/coach_service.dart';

/// plan_workout: title, intro, difficulty, scheduledFor, exercises
/// [{id, durationSec, restSec}]. Всё решает Фитти, код только проверяет
/// технически (PlanValidator).
class PlanWorkoutHandler extends ActionHandler {
  PlanWorkoutHandler(this.coach);
  final CoachService coach;

  @override
  String get type => 'plan_workout';

  @override
  Future<String?> handle(Map<String, dynamic> data, DispatchContext ctx) {
    final picks = <Map<String, dynamic>>[];
    final raw = data['exercises'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          picks.add(Map<String, dynamic>.from(e));
        } else if (e is String) {
          picks.add({'id': e});
        }
      }
    }
    return coach.savePlanFromModel(
      title: data['title']?.toString(),
      intro: data['intro']?.toString(),
      picks: picks,
      difficulty: data['difficulty'],
      scheduledFor: data['scheduledFor'] ?? data['scheduledAt'],
    );
  }
}
