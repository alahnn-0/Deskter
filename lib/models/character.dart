class Attribute {
  String id;
  String name;
  String icon;   // emoji
  int color;     // hex color value
  double value;

  Attribute({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.value = 30,
  });

  String get label {
    if (value >= 90) return 'Legendary';
    if (value >= 75) return 'Expert';
    if (value >= 60) return 'Advanced';
    if (value >= 45) return 'Intermediate';
    if (value >= 30) return 'Normal';
    return 'Below Average';
  }
}

class Character {
  String name;
  int totalXp;
  Map<String, double> stats;
  int streak;
  String lastActiveDate;
  List<Attribute> customAttributes;

  Character({
    this.name = 'Adventurer',
    this.totalXp = 0,
    Map<String, double>? stats,
    this.streak = 0,
    this.lastActiveDate = '',
    List<Attribute>? customAttributes,
  })  : stats = stats ?? {
          'study': 30,
          'health': 30,
          'work': 30,
          'habit': 30,
        },
        customAttributes = customAttributes ?? [];

  int get level {
    int l = 1, x = totalXp;
    while (x >= l * 100) { x -= l * 100; l++; }
    return l;
  }

  int get currentLevelXp {
    int l = 1, x = totalXp;
    while (x >= l * 100) { x -= l * 100; l++; }
    return x;
  }

  int get xpToNextLevel => level * 100;

  String get className {
    if (level >= 50) return 'Legend';
    if (level >= 35) return 'Master';
    if (level >= 20) return 'Expert';
    if (level >= 10) return 'Journeyman';
    if (level >= 5)  return 'Apprentice';
    return 'Novice';
  }

  int get streakBonus {
    if (streak >= 30) return 100;
    if (streak >= 14) return 50;
    if (streak >= 7)  return 25;
    return 0;
  }

  String get streakTitle {
    if (streak >= 30) return '👑 Legendary';
    if (streak >= 14) return '🔥 On Fire';
    if (streak >= 7)  return '⚡ Hot Streak';
    if (streak >= 3)  return '✨ Building';
    if (streak >= 1)  return '🌱 Started';
    return 'No streak yet';
  }

  String statLabel(double value) {
    if (value >= 90) return 'Legendary';
    if (value >= 75) return 'Expert';
    if (value >= 60) return 'Advanced';
    if (value >= 45) return 'Intermediate';
    if (value >= 30) return 'Normal';
    return 'Below Average';
  }
}