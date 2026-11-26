import 'package:weightloss/domain/actions/action_dispatcher.dart';
import 'package:weightloss/domain/ration/ration_models.dart';
import 'package:weightloss/domain/ration/ration_service.dart';

/// plan_meals: Фитти просит составить или обновить рацион. Сам запрос с
/// блюдами (отдельный, строгий JSON) делает RationService.
/// {"type":"plan_meals","op":"create|update","days":["2026-03-10"],
///  "reason":"...","note":"...","set_status":[{"id":12,"status":"skipped"}]}
class PlanMealsHandler implements ActionHandler {
  PlanMealsHandler(this._ration);
  final RationService _ration;

  @override
  String get type => 'plan_meals';

  @override
  Future<String?> handle(Map<String, dynamic> data, DispatchContext ctx) async {
    // Только смена статусов пунктов (пропущено и т.п.): без запроса к ИИ.
    final st = data['set_status'];
    if (st is List) {
      for (final s in st.take(10)) {
        if (s is! Map) continue;
        final id = s['id'] is num
            ? (s['id'] as num).toInt()
            : int.tryParse('${s['id']}');
        final status = '${s['status']}';
        if (id != null && PlanStatus.all.contains(status)) {
          await _ration.setStatus(id, status);
        }
      }
      if (data['days'] == null && data['op'] == null) return null;
    }

    final today = RationService.dayOf(ctx.now);
    var days = <DateTime>[];
    final raw = data['days'];
    if (raw is List) {
      for (final v in raw) {
        final d = RationValidator.parseDate(v);
        if (d == null) continue;
        final diff = d.difference(today).inDays;
        if (diff < 0 || diff >= RationService.maxDays) continue;
        days.add(d);
      }
    }
    final op = data['op'] == 'update' ? 'update' : 'create';
    if (days.isEmpty) {
      days = [
        for (var i = 0; i < RationService.horizonDays; i++)
          today.add(Duration(days: i)),
      ];
    }
    final reason = (data['reason'] ?? '').toString().trim();
    final r = await _ration.generate(
      days: days,
      reason:
          '${op == 'update' ? 'обновить рацион' : 'составить рацион'}'
          '${reason.isEmpty ? '' : ': $reason'}',
      userNote: data['note']?.toString(),
    );
    if (!r.ok) {
      return 'Не получилось обновить рацион (${r.message ?? 'ошибка'}). Попробуем ещё раз позже.';
    }
    final draft = await _ration.isDraft();
    return 'Рацион ${op == 'update' ? 'обновлён' : 'составлен'} на ${r.days.length} дн. '
        'Он во вкладке «Рацион».'
        '${draft ? ' Пока это черновик: мне нужно узнать тебя получше.' : ''}'
        '${r.marked.isNotEmpty ? ' (В части дней калории чуть отличаются от нормы, они помечены.)' : ''}';
  }
}
