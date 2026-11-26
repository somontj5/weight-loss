import 'package:weightloss/domain/actions/action_dispatcher.dart';
import 'package:weightloss/domain/profile_service.dart';

/// Действие set_activity: level = sedentary | light | moderate | high.
class SetActivityHandler implements ActionHandler {
  SetActivityHandler(this._profiles);
  final ProfileService _profiles;

  @override
  String get type => 'set_activity';

  @override
  Future<String?> handle(Map<String, dynamic> data, DispatchContext ctx) async {
    final level = data['level']?.toString().trim().toLowerCase();
    if (!ActivityLevel.valid(level)) return null;
    final c = await _profiles.applyActivity(level!);
    if (c == null) return null;
    if (c.oldKcal == null || c.oldKcal == c.newKcal) return null;
    return 'Пересчитал норму: было ${c.oldKcal}, стало ${c.newKcal} ккал';
  }
}
