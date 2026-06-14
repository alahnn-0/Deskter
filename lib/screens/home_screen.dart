import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';
import '../constants/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final todayTasks = provider.tasksForDate(DateTime.now());
    final activeTasks = todayTasks.where((t) => !t.isDone).toList();
    final completedTasks = todayTasks.where((t) => t.isDone).toList();
    final progress = provider.dailyXp / provider.dailyTotalXp;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, progress, provider.dailyXp,
                provider.character),
            Expanded(
              child: todayTasks.isEmpty
                  ? _buildEmpty()
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // active tasks
                        if (activeTasks.isNotEmpty) ...[
                          _sectionLabel('ACTIVE QUESTS (${activeTasks.length})'),
                          ...activeTasks.map((t) =>
                              _buildTaskCard(context, t)),
                        ],

                        // completed tasks
                        if (completedTasks.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _sectionLabel(
                              'COMPLETED (${completedTasks.length})'),
                          ...completedTasks.map((t) =>
                              _buildTaskCard(context, t)),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _showAddTaskSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(text, style: AppText.label),
    );
  }

  Widget _buildHeader(BuildContext context, double progress, int dailyXp,
      character) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QUEST LOG', style: AppText.label),
          const SizedBox(height: 4),
          Text("Today's Tasks", style: AppText.title),
          const SizedBox(height: 12),

          // streak banner
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: character.streak >= 7
                    ? AppColors.gold.withOpacity(0.5)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${character.streak} Day Streak',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      character.streakTitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                if (character.streakBonus > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.gold.withOpacity(0.4)),
                    ),
                    child: Text(
                      '+${character.streakBonus} XP bonus',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // XP bar
          Row(
            children: [
              Text('Daily XP  ', style: AppText.muted),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.surface3,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.accent),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$dailyXp XP',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.accentLight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
  final color = Color(Task.categoryColors[task.category]!);
  final label = Task.categoryLabels[task.category]!;

  return GestureDetector(
    onLongPress: () => _showDeleteDialog(context, task),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: task.isDone
            ? AppColors.surface.withOpacity(0.5)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isDone
              ? AppColors.border.withOpacity(0.5)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<AppProvider>().completeTask(task.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isDone ? AppColors.accent : Colors.transparent,
                border: Border.all(
                  color: task.isDone ? AppColors.accent : AppColors.border,
                  width: 2,
                ),
              ),
              child: task.isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: task.isDone
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    decoration: task.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(label,
                          style: TextStyle(fontSize: 10, color: color)),
                    ),
                    if (task.isRecurring) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surface3,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.repeat,
                                size: 9, color: AppColors.textMuted),
                            const SizedBox(width: 3),
                            Text(
                              task.recurrence == 'daily'
                                  ? 'Daily'
                                  : 'Weekly',
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            '+${task.xp} XP',
            style: TextStyle(
              fontSize: 13,
              color: task.isDone ? AppColors.textMuted : AppColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

void _showDeleteDialog(BuildContext context, Task task) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
      title: const Text('Delete Task',
          style: TextStyle(color: AppColors.textPrimary)),
      content: Text(
        'Delete "${task.title}"?${task.isRecurring ? '\n\nThis will also remove all future recurring instances.' : ''}',
        style: const TextStyle(color: AppColors.textMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel',
              style: TextStyle(color: AppColors.textMuted)),
        ),
        TextButton(
          onPressed: () {
            final provider = context.read<AppProvider>();
            if (task.isRecurring) {
              // find the template id from the task id
              final templateId = task.id.contains('_')
                  ? task.id.split('_').first
                  : task.id;
              provider.deleteRecurringTemplate(templateId);
            } else {
              provider.deleteTask(task.id);
            }
            Navigator.pop(ctx);
          },
          child: const Text('Delete',
              style: TextStyle(color: AppColors.red)),
        ),
      ],
    ),
  );
}

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined,
              size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text('No quests today.\nTap + to add one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    final titleController = TextEditingController();
    String selectedCategory = 'study';
    int selectedXp = 25;
    String recurrence = 'none';
    List<int> selectedWeekDays = [];
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    String? selectedGoalId;

    





    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Quest', style: AppText.title),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Task name...',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Category', style: AppText.label),
              const SizedBox(height: 8),
              Row(
                children: ['study', 'health', 'work', 'habit'].map((cat) {
                  final color = Color(Task.categoryColors[cat]!);
                  final isSelected = selectedCategory == cat;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setModalState(() => selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding:
                            const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.2)
                              : AppColors.surface2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: isSelected
                                  ? color
                                  : AppColors.border),
                        ),




                        child: Text(
                          Task.categoryLabels[cat]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? color
                                  : AppColors.textMuted),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),




            // goal picker
                  const SizedBox(height: 12),
                  Text('Link to Goal (optional)', style: AppText.label),
                  const SizedBox(height: 8),
                  Consumer<AppProvider>(
                    builder: (context, provider, _) {
                      final activeGoals =
                          provider.goals.where((g) => !g.isCompleted).toList();
                      if (activeGoals.isEmpty) {
                        return Text('No goals yet — create one in Achiever',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted));
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // no goal option
                          GestureDetector(
                            onTap: () => setModalState(() => selectedGoalId = null),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selectedGoalId == null
                                    ? AppColors.accent.withOpacity(0.2)
                                    : AppColors.surface2,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: selectedGoalId == null
                                        ? AppColors.accent
                                        : AppColors.border),
                              ),
                              child: Text('None',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: selectedGoalId == null
                                          ? AppColors.accentLight
                                          : AppColors.textMuted)),
                            ),
                          ),
                          ...activeGoals.map((g) {
                            final isSelected = selectedGoalId == g.id;
                            final color = Color(Task.categoryColors[g.category]!);
                            return GestureDetector(
                              onTap: () =>
                                  setModalState(() => selectedGoalId = g.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color.withOpacity(0.2)
                                      : AppColors.surface2,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color:
                                          isSelected ? color : AppColors.border),
                                ),
                                child: Text(g.title,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                            ? color
                                            : AppColors.textMuted)),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),







              const SizedBox(height: 12),
              Text('Difficulty', style: AppText.label),
              const SizedBox(height: 8),
              Row(
                children: [
                  {'label': 'Easy', 'xp': 10},
                  {'label': 'Medium', 'xp': 25},
                  {'label': 'Hard', 'xp': 50},
                ].map((d) {
                  final isSelected = selectedXp == d['xp'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(
                          () => selectedXp = d['xp'] as int),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding:
                            const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent.withOpacity(0.2)
                              : AppColors.surface2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Text(d['label'] as String,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? AppColors.accentLight
                                        : AppColors.textMuted)),
                            Text('+${d['xp']} XP',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? AppColors.gold
                                        : AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text('Repeat', style: AppText.label),
              const SizedBox(height: 8),
              Row(
                children: [
                  {'label': 'None', 'value': 'none'},
                  {'label': 'Daily', 'value': 'daily'},
                  {'label': 'Weekly', 'value': 'weekly'},
                ].map((r) {
                  final isSelected = recurrence == r['value'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setModalState(() => recurrence = r['value']!),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent.withOpacity(0.2)
                              : AppColors.surface2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.border),
                        ),
                        child: Text(r['label']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? AppColors.accentLight
                                    : AppColors.textMuted)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (recurrence == 'weekly') ...[
                const SizedBox(height: 12),
                Text('Repeat on', style: AppText.label),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(7, (i) {
                    final day = i + 1;
                    final isSelected = selectedWeekDays.contains(day);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => isSelected
                            ? selectedWeekDays.remove(day)
                            : selectedWeekDays.add(day)),
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent.withOpacity(0.2)
                                : AppColors.surface2,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.border),
                          ),
                          child: Text(dayNames[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 9,
                                  color: isSelected
                                      ? AppColors.accentLight
                                      : AppColors.textMuted)),
                        ),
                      ),
                    );
                  }),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    if (recurrence == 'weekly' &&
                        selectedWeekDays.isEmpty) return;
                    final provider = context.read<AppProvider>();
                    final id = DateTime.now()
                        .millisecondsSinceEpoch
                        .toString();
                    if (recurrence == 'none') {
                      provider.addTask(Task(
                        id: id,
                        title: titleController.text.trim(),
                        category: selectedCategory,
                        xp: selectedXp,
                        date: DateTime.now(),
                        goalId: selectedGoalId, 
                      ));
                      
                    } else {
                      provider.addRecurringTask(Task(
                        id: id,
                        title: titleController.text.trim(),
                        category: selectedCategory,
                        xp: selectedXp,
                        date: DateTime.now(),
                        isRecurring: true,
                        recurrence: recurrence,
                        weekDays: selectedWeekDays,
                        goalId: selectedGoalId, 
                      ));
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Add Quest',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}