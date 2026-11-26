import 'package:weightloss/domain/actions/action_dispatcher.dart';
import 'package:weightloss/domain/weight/weight_service.dart';

/// update_weight: {"type":"update_weight","weight_kg":78.4,"waist_cm":88,
/// "chest_cm":100,"hips_cm":104,"date":"2026-03-10","confirmed":false}
/// Код проверяет только технически; о необычном возвращает Фитти.
class UpdateWeightHandler implements ActionHandler {
  UpdateWeightHandler(this._weight);
  final WeightService _weight;

  @override
  String get type => 'update_weight';

  @override
  Future<String?> handle(Map<String, dynamic> data, DispatchContext ctx) async {
    final o = await _weight.apply(
      weightKg: parseWeightNum(data['weight_kg']),
      waistCm: parseWeightNum(data['waist_cm']),
      chestCm: parseWeightNum(data['chest_cm']),
      hipsCm: parseWeightNum(data['hips_cm']),
      date: parseWeightDate(data['date']),
      confirmed: data['confirmed'] == true,
    );
    if (o.saved) return weightFooter(null, o);
    if (o.needConfirm) {
      // Сообщение «уточни у человека» уходит Фитти в следующем контексте
      // ([ВЕС]: ЖДЁТ ПОДТВЕРЖДЕНИЯ), а человеку показываем мягкую подпись.
      return 'Вес пока не записал: ${o.message?.split(':').first ?? 'нужно уточнить'}. Подтверди, пожалуйста, в чате.';
    }
    return null;
  }
}
