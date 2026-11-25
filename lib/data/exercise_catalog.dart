/// Каталог упражнений. `id` — это ключ, по которому позже подключится
/// 3D-анимация (см. ExerciseStage), а также список, из которого ИИ-тренер
/// в первую очередь выбирает упражнения.
class ExerciseTemplate {
  const ExerciseTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.tips,
    required this.muscle,
    required this.met,
    this.highImpact = false,
    this.stage = 'main',
  });

  final String id;
  final String name;
  final String description;
  final String tips;
  final String muscle;

  /// Метаболический эквивалент (ккал на кг веса в час).
  final double met;

  /// Прыжки/ударная нагрузка — исключаем для новичков, пожилых и при большом весе.
  final bool highImpact;

  /// warmup | main | cooldown
  final String stage;
}

const kExerciseCatalog = <ExerciseTemplate>[
  ExerciseTemplate(
    id: 'arm_circles',
    name: 'Круговые махи руками',
    description: 'Встань прямо, разведи руки в стороны и делай плавные круги.',
    tips: 'Плечи опущены, спина ровная. Через полминуты смени направление.',
    muscle: 'Плечи',
    met: 2.8,
    stage: 'warmup',
  ),
  ExerciseTemplate(
    id: 'march_in_place',
    name: 'Ходьба на месте',
    description: 'Шагай на месте, высоко поднимая колени и двигая руками.',
    tips: 'Дыши ровно, держи корпус прямо.',
    muscle: 'Всё тело',
    met: 3.5,
    stage: 'warmup',
  ),
  ExerciseTemplate(
    id: 'jumping_jack',
    name: 'Прыжки «звёздочка»',
    description: 'Прыгай, разводя ноги и руки в стороны, затем возвращайся.',
    tips: 'Приземляйся мягко, на носки. Колени слегка согнуты.',
    muscle: 'Всё тело',
    met: 8.0,
    highImpact: true,
  ),
  ExerciseTemplate(
    id: 'high_knees',
    name: 'Бег с высокими коленями',
    description: 'Быстро бегай на месте, поднимая колени до уровня таза.',
    tips: 'Работай руками, спина прямая, приземляйся на носок.',
    muscle: 'Ноги, кардио',
    met: 8.0,
    highImpact: true,
  ),
  ExerciseTemplate(
    id: 'side_step',
    name: 'Приставные шаги с руками',
    description: 'Шагай в стороны, приставляя ногу и поднимая руки вверх.',
    tips: 'Шаг широкий, колени слегка согнуты.',
    muscle: 'Ноги, кардио',
    met: 4.5,
  ),
  ExerciseTemplate(
    id: 'shadow_boxing',
    name: 'Бой с тенью',
    description: 'Наноси прямые удары руками в воздух, перемещая вес с ноги на ногу.',
    tips: 'Кулаки у подбородка, удар с поворотом корпуса.',
    muscle: 'Руки, кардио',
    met: 6.0,
  ),
  ExerciseTemplate(
    id: 'squat',
    name: 'Приседания',
    description: 'Ноги на ширине плеч, садись назад, как на стул, и вставай.',
    tips: 'Колени не выходят за носки, спина прямая, пятки на полу.',
    muscle: 'Ноги, ягодицы',
    met: 5.0,
  ),
  ExerciseTemplate(
    id: 'lunge',
    name: 'Выпады назад',
    description: 'Шагни назад, опустись до прямого угла в коленях и вернись.',
    tips: 'Корпус прямой, переднее колено над стопой.',
    muscle: 'Ноги, ягодицы',
    met: 5.0,
  ),
  ExerciseTemplate(
    id: 'wall_sit',
    name: 'Стульчик у стены',
    description: 'Обопрись спиной о стену и удерживай позу «сидя» без стула.',
    tips: 'Колени под углом 90°, спина прижата к стене.',
    muscle: 'Ноги',
    met: 3.8,
  ),
  ExerciseTemplate(
    id: 'knee_pushup',
    name: 'Отжимания с колен',
    description: 'Упор на колени и ладони, опускай грудь к полу и выжимайся.',
    tips: 'Тело от колен до головы — прямая линия.',
    muscle: 'Грудь, руки',
    met: 4.0,
  ),
  ExerciseTemplate(
    id: 'pushup',
    name: 'Отжимания',
    description: 'Упор лёжа, опускайся до касания грудью пола и выжимайся.',
    tips: 'Локти под углом 45° к корпусу, пресс напряжён.',
    muscle: 'Грудь, руки',
    met: 6.0,
  ),
  ExerciseTemplate(
    id: 'plank',
    name: 'Планка',
    description: 'Упор на предплечья, тело — прямая линия, удерживай позу.',
    tips: 'Не прогибай поясницу, напряги пресс и ягодицы.',
    muscle: 'Пресс, корпус',
    met: 3.8,
  ),
  ExerciseTemplate(
    id: 'mountain_climber',
    name: 'Скалолаз',
    description: 'В упоре лёжа поочерёдно подтягивай колени к груди.',
    tips: 'Таз не поднимай, двигайся в своём темпе.',
    muscle: 'Пресс, кардио',
    met: 8.0,
    highImpact: true,
  ),
  ExerciseTemplate(
    id: 'burpee',
    name: 'Бёрпи',
    description: 'Присед, упор лёжа, возврат и выпрыгивание вверх.',
    tips: 'Если тяжело — убери прыжок и просто вставай.',
    muscle: 'Всё тело',
    met: 10.0,
    highImpact: true,
  ),
  ExerciseTemplate(
    id: 'glute_bridge',
    name: 'Ягодичный мостик',
    description: 'Лёжа на спине, согни ноги и поднимай таз вверх.',
    tips: 'Вверху сожми ягодицы на секунду, поясницу не прогибай.',
    muscle: 'Ягодицы',
    met: 3.5,
  ),
  ExerciseTemplate(
    id: 'crunch',
    name: 'Скручивания',
    description: 'Лёжа на спине, отрывай лопатки от пола, напрягая пресс.',
    tips: 'Подбородок не прижимай к груди, шею не тяни руками.',
    muscle: 'Пресс',
    met: 3.8,
  ),
  ExerciseTemplate(
    id: 'bicycle_crunch',
    name: 'Велосипед',
    description: 'Лёжа на спине, тянись локтем к противоположному колену.',
    tips: 'Двигайся плавно, поясница прижата к полу.',
    muscle: 'Пресс',
    met: 4.5,
  ),
  ExerciseTemplate(
    id: 'superman',
    name: 'Супермен',
    description: 'Лёжа на животе, одновременно приподнимай руки и ноги.',
    tips: 'Шею не запрокидывай, смотри в пол.',
    muscle: 'Спина',
    met: 3.0,
  ),
  ExerciseTemplate(
    id: 'stretching',
    name: 'Растяжка всего тела',
    description: 'Плавные наклоны и растяжка ног, спины и плеч.',
    tips: 'Без рывков, дыши глубоко и медленно.',
    muscle: 'Всё тело',
    met: 2.3,
    stage: 'cooldown',
  ),
];

ExerciseTemplate? catalogById(String id) {
  for (final t in kExerciseCatalog) {
    if (t.id == id) return t;
  }
  return null;
}
