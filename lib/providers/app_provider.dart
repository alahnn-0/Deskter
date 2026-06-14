import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/character.dart';
import '../models/goal.dart';

class AppProvider extends ChangeNotifier {
  late Box _box;
  Character character = Character();
  List<Task> tasks = [];
  List<Task> recurringTemplates = [];
  List<Goal> goals = [];

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('questlog');
    _loadData();
    _generateRecurringTasks();
  }

  void _loadData() {
    final rawStats = _box.get('stats', defaultValue: {
      'study': 30.0, 'health': 30.0, 'work': 30.0, 'habit': 30.0,
    });
    final stats = Map<String, double>.from(
      (rawStats as Map).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble())),
    );

    // load custom attributes
    final savedAttrs = _box.get('customAttributes', defaultValue: []);
    final customAttributes = (savedAttrs as List).map((a) {
      final map = Map<String, dynamic>.from(a);
      return Attribute(
        id: map['id'],
        name: map['name'],
        icon: map['icon'],
        color: map['color'],
        value: (map['value'] as num).toDouble(),
      );
    }).toList();

    character = Character(
      name: _box.get('name', defaultValue: 'Adventurer'),
      totalXp: _box.get('totalXp', defaultValue: 0),
      streak: _box.get('streak', defaultValue: 0),
      lastActiveDate: _box.get('lastActiveDate', defaultValue: ''),
      stats: stats,
      customAttributes: customAttributes,
    );

    final savedTasks = _box.get('tasks', defaultValue: []);
    tasks = (savedTasks as List).map((t) => _taskFromMap(t)).toList();

    final savedTemplates =
        _box.get('recurringTemplates', defaultValue: []);
    recurringTemplates =
        (savedTemplates as List).map((t) => _taskFromMap(t)).toList();

    final savedGoals = _box.get('goals', defaultValue: []);
    goals = (savedGoals as List).map((g) => _goalFromMap(g)).toList();

    if (tasks.isEmpty && recurringTemplates.isEmpty) {
      recurringTemplates = [
        Task(
          id: 'r1',
          title: 'Morning workout',
          category: 'health',
          xp: 50,
          date: DateTime.now(),
          isRecurring: true,
          recurrence: 'daily',
        ),
        Task(
          id: 'r2',
          title: 'Read 20 pages',
          category: 'study',
          xp: 25,
          date: DateTime.now(),
          isRecurring: true,
          recurrence: 'daily',
        ),
      ];
      tasks = [
        Task(id: '3', title: 'Review work emails', category: 'work', xp: 25, date: DateTime.now()),
        Task(id: '4', title: 'Meditate 10 min', category: 'habit', xp: 10, date: DateTime.now()),
      ];
      _saveData();
    }

    notifyListeners();
  }

  void _generateRecurringTasks() {
    final today = DateTime.now();
    final todayKey = _dateKey(today);
    for (final template in recurringTemplates) {
      if (!template.shouldAppearOn(today)) continue;
      final alreadyExists =
          tasks.any((t) => t.id == '${template.id}_$todayKey');
      if (!alreadyExists) {
        tasks.add(Task(
          id: '${template.id}_$todayKey',
          title: template.title,
          category: template.category,
          xp: template.xp,
          date: today,
          isRecurring: true,
          recurrence: template.recurrence,
          weekDays: template.weekDays,
          goalId: template.goalId,
        ));
      }
    }
    _saveData();
    notifyListeners();
  }

  void _updateStats(String category) {
    final todayTasks = tasksForDate(DateTime.now())
        .where((t) => t.category == category)
        .toList();
    if (todayTasks.isEmpty) return;

    final totalPossible =
        todayTasks.fold(0, (sum, t) => sum + t.xp).toDouble();
    final earned = todayTasks
        .where((t) => t.isDone)
        .fold(0, (sum, t) => sum + t.xp)
        .toDouble();

    final completionRate = earned / totalPossible;
    final current = character.stats[category]!;
    double newValue;

    if (completionRate < 0.5) {
      newValue = (current - 0.3).clamp(30.0, 100.0);
    } else {
      newValue = (current + completionRate * 2.0).clamp(30.0, 100.0);
    }
    character.stats[category] =
        double.parse(newValue.toStringAsFixed(1));
  }

  void completeTask(String id) {
    final task = tasks.firstWhere((t) => t.id == id);
    if (task.isDone) return;

    _updateStreak();
    task.isDone = true;
    character.totalXp += task.xp;
    _updateStats(task.category);

    if (task.goalId != null) {
      final goalIndex =
          goals.indexWhere((g) => g.id == task.goalId);
      if (goalIndex != -1) {
        final goal = goals[goalIndex];
        if (!goal.isCompleted) {
          goal.earnedXp += task.xp;
          if (goal.earnedXp >= goal.targetXp) {
            goal.isCompleted = true;
            final current = character.stats[goal.category]!;
            character.stats[goal.category] =
                (current + goal.statBoost).clamp(30.0, 100.0);
            character.totalXp += 200;
          }
        }
      }
    }

    _saveData();
    notifyListeners();
  }

  // delete a task
  void deleteTask(String id) {
    tasks.removeWhere((t) => t.id == id);
    _saveData();
    notifyListeners();
  }

  // delete a recurring template and today's generated instance
  void deleteRecurringTemplate(String templateId) {
    recurringTemplates.removeWhere((t) => t.id == templateId);
    final todayKey = _dateKey(DateTime.now());
    tasks.removeWhere((t) => t.id == '${templateId}_$todayKey');
    _saveData();
    notifyListeners();
  }

  // custom attributes
  void addAttribute(Attribute attr) {
    character.customAttributes.add(attr);
    _saveData();
    notifyListeners();
  }

  void deleteAttribute(String id) {
    character.customAttributes.removeWhere((a) => a.id == id);
    _saveData();
    notifyListeners();
  }

  void updateAttributeValue(String id, double value) {
    final attr = character.customAttributes
        .firstWhere((a) => a.id == id);
    attr.value = value.clamp(0.0, 100.0);
    _saveData();
    notifyListeners();
  }

  List<Task> tasksForGoal(String goalId) =>
      tasks.where((t) => t.goalId == goalId).toList();

  void addGoal(Goal goal) {
    goals.add(goal);
    _saveData();
    notifyListeners();
  }

  void deleteGoal(String id) {
    goals.removeWhere((g) => g.id == id);
    for (final task in tasks) {
      if (task.goalId == id) task.goalId = null;
    }
    _saveData();
    notifyListeners();
  }

  void addTask(Task task) {
    tasks.add(task);
    _saveData();
    notifyListeners();
  }

  void addRecurringTask(Task template) {
    recurringTemplates.add(template);
    _generateRecurringTasks();
  }

  void updateName(String name) {
    character.name = name;
    _saveData();
    notifyListeners();
  }

  List<Task> tasksForDate(DateTime date) {
    return tasks
        .where((t) =>
            t.date.year == date.year &&
            t.date.month == date.month &&
            t.date.day == date.day)
        .toList();
  }

  int get dailyXp => tasksForDate(DateTime.now())
      .where((t) => t.isDone)
      .fold(0, (sum, t) => sum + t.xp);

  int get dailyTotalXp {
    final total =
        tasksForDate(DateTime.now()).fold(0, (sum, t) => sum + t.xp);
    return total == 0 ? 100 : total;
  }

  void _updateStreak() {
    final today = _dateKey(DateTime.now());
    final yesterday =
        _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    final last = character.lastActiveDate;
    if (last == today) return;
    character.streak =
        (last == yesterday || last.isEmpty) ? character.streak + 1 : 1;
    character.lastActiveDate = today;
  }

  void _saveData() {
    _box.put('name', character.name);
    _box.put('totalXp', character.totalXp);
    _box.put('stats', character.stats);
    _box.put('streak', character.streak);
    _box.put('lastActiveDate', character.lastActiveDate);
    _box.put('tasks', tasks.map(_taskToMap).toList());
    _box.put('recurringTemplates',
        recurringTemplates.map(_taskToMap).toList());
    _box.put('goals', goals.map(_goalToMap).toList());
    _box.put(
        'customAttributes',
        character.customAttributes
            .map((a) => {
                  'id': a.id,
                  'name': a.name,
                  'icon': a.icon,
                  'color': a.color,
                  'value': a.value,
                })
            .toList());
  }

  Task _taskFromMap(dynamic t) {
    final map = Map<String, dynamic>.from(t);
    return Task(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      xp: map['xp'],
      isDone: map['isDone'],
      date: DateTime.parse(map['date']),
      isRecurring: map['isRecurring'] ?? false,
      recurrence: map['recurrence'] ?? 'none',
      weekDays: List<int>.from(map['weekDays'] ?? []),
      goalId: map['goalId'],
    );
  }

  Map<String, dynamic> _taskToMap(Task t) => {
        'id': t.id,
        'title': t.title,
        'category': t.category,
        'xp': t.xp,
        'isDone': t.isDone,
        'date': t.date.toIso8601String(),
        'isRecurring': t.isRecurring,
        'recurrence': t.recurrence,
        'weekDays': t.weekDays,
        'goalId': t.goalId,
      };

  Goal _goalFromMap(dynamic g) {
    final map = Map<String, dynamic>.from(g);
    return Goal(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      targetXp: (map['targetXp'] ?? map['targetTasks'] ?? 100) as int,
      earnedXp: (map['earnedXp'] ?? 0) as int,
      deadline: DateTime.parse(map['deadline']),
      isCompleted: map['isCompleted'] ?? false,
      statBoost: (map['statBoost'] ?? 5) as int,
    );
  }

  Map<String, dynamic> _goalToMap(Goal g) => {
        'id': g.id,
        'title': g.title,
        'category': g.category,
        'targetXp': g.targetXp,
        'earnedXp': g.earnedXp,
        'deadline': g.deadline.toIso8601String(),
        'isCompleted': g.isCompleted,
        'statBoost': g.statBoost,
      };

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}