class Goal {
  final String id;
  String title;
  String category;
  int targetXp;        // total XP to complete the goal
  int earnedXp;        // XP earned from linked tasks
  DateTime deadline;
  bool isCompleted;
  int statBoost;

  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.targetXp,
    this.earnedXp = 0,
    required this.deadline,
    this.isCompleted = false,
    this.statBoost = 5,
  });

  double get progress =>
      targetXp == 0 ? 0 : (earnedXp / targetXp).clamp(0.0, 1.0);

  int get daysLeft => deadline.difference(DateTime.now()).inDays;

  bool get isOverdue => daysLeft < 0 && !isCompleted;

  int get remainingXp => (targetXp - earnedXp).clamp(0, targetXp);
}