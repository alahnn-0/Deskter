class Task {
  final String id;
  String title;
  String category;
  int xp;
  bool isDone;
  DateTime date;
  bool isRecurring;
  String recurrence;
  List<int> weekDays;
  String? goalId;      // optional — links task to a goal

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.xp,
    this.isDone = false,
    required this.date,
    this.isRecurring = false,
    this.recurrence = 'none',
    this.weekDays = const [],
    this.goalId,
  });

  static Map<String, String> categoryLabels = {
    'study': 'Intelligence',
    'health': 'Strength',
    'work': 'Charisma',
    'habit': 'Discipline',
  };

  static Map<String, int> categoryColors = {
    'study': 0xFF818cf8,
    'health': 0xFF4ade80,
    'work': 0xFFfb923c,
    'habit': 0xFFe879f9,
  };

  bool shouldAppearOn(DateTime date) {
    if (!isRecurring) return false;
    if (recurrence == 'daily') return true;
    if (recurrence == 'weekly') return weekDays.contains(date.weekday);
    return false;
  }
}