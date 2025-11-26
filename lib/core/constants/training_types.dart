class TrainingTypes {
  static const String yoga = 'Йога';
  static const String stretching = 'Растяжка';
  static const String cardio = 'Кардио';
  static const String strength = 'Силовые';
  static const String pilates = 'Пилатес';
  static const String crossfit = 'Кроссфит';
  static const String dance = 'Танцы';
  static const String swimming = 'Плавание';

  static List<String> get all => [
        yoga,
        stretching,
        cardio,
        strength,
        pilates,
        crossfit,
        dance,
        swimming,
      ];

  static String getIcon(String type) {
    switch (type) {
      case yoga:
        return '🧘';
      case stretching:
        return '🤸';
      case cardio:
        return '🏃';
      case strength:
        return '💪';
      case pilates:
        return '🧘‍♀️';
      case crossfit:
        return '🔥';
      case dance:
        return '💃';
      case swimming:
        return '🏊';
      default:
        return '🏋️';
    }
  }
}

