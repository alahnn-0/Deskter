import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/goal.dart';
import '../models/task.dart';
import '../constants/theme.dart';

class AchieverScreen extends StatelessWidget {
  const AchieverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final activeGoals =
        provider.goals.where((g) => !g.isCompleted).toList();
    final completedGoals =
        provider.goals.where((g) => g.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GOALS', style: AppText.label),
                      const SizedBox(height: 4),
                      Text('Achiever', style: AppText.title),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showAddGoalSheet(context),
                    icon: const Icon(Icons.add,
                        size: 16, color: Colors.white),
                    label: const Text('New Goal',
                        style: TextStyle(
                            fontSize: 13, color: Colors.white)),
                  ),


                ],
              ),
            ),
            Expanded(
              child: provider.goals.isEmpty
                  ? _buildEmpty()
                  : ListView(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        if (activeGoals.isNotEmpty) ...[
                          Text('ACTIVE', style: AppText.label),
                          const SizedBox(height: 8),
                          ...activeGoals.map((g) =>
                              _buildGoalCard(context, g, provider)),
                        ],
                        if (completedGoals.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text('COMPLETED', style: AppText.label),
                          const SizedBox(height: 8),
                          ...completedGoals.map((g) =>
                              _buildGoalCard(context, g, provider)),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(
      BuildContext context, Goal goal, AppProvider provider) {
    final color = Color(Task.categoryColors[goal.category]!);
    final label = Task.categoryLabels[goal.category]!;
    final linkedTasks = provider.tasksForGoal(goal.id);
    final doneTasks = linkedTasks.where((t) => t.isDone).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: goal.isCompleted
            ? AppColors.surface.withOpacity(0.5)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: goal.isCompleted
              ? AppColors.gold.withOpacity(0.4)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // goal header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: goal.isCompleted
                              ? AppColors.gold
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (goal.isCompleted)
                      const Icon(Icons.emoji_events,
                          color: AppColors.gold, size: 20),
                    if (!goal.isCompleted)
                      GestureDetector(
                        onTap: () => context
                            .read<AppProvider>()
                            .deleteGoal(goal.id),
                        child: const Icon(Icons.close,
                            size: 18, color: AppColors.textMuted),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(label,
                          style:
                              TextStyle(fontSize: 10, color: color)),
                    ),
                    const SizedBox(width: 8),
                    // stat boost badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.gold.withOpacity(0.3)),
                      ),
                      child: Text(
                        '+${goal.statBoost} $label boost',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.gold),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      goal.isCompleted
                          ? '✅ Done'
                          : goal.isOverdue
                              ? '⚠️ Overdue'
                              : '📅 ${goal.daysLeft}d left',
                      style: TextStyle(
                        fontSize: 11,
                        color: goal.isOverdue
                            ? AppColors.red
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // XP progress bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: goal.progress,
                          backgroundColor: AppColors.surface3,
                          valueColor: AlwaysStoppedAnimation(
                              goal.isCompleted
                                  ? AppColors.gold
                                  : color),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${goal.earnedXp}/${goal.targetXp} XP',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // linked tasks section
          if (linkedTasks.isNotEmpty) ...[
            Container(
              height: 1,
              color: AppColors.border,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
              child: Row(
                children: [
                  Text('TASKS', style: AppText.label),
                  const SizedBox(width: 8),
                  Text(
                    '${doneTasks.length}/${linkedTasks.length} done',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            ...linkedTasks.map((task) => _buildLinkedTask(task)),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildLinkedTask(Task task) {
    final color = Color(Task.categoryColors[task.category]!);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isDone ? AppColors.accent : Colors.transparent,
              border: Border.all(
                color: task.isDone ? AppColors.accent : AppColors.border,
                width: 2,
              ),
            ),
            child: task.isDone
                ? const Icon(Icons.check, size: 11, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 13,
                color: task.isDone
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
                decoration: task.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          Text(
            '+${task.xp} XP',
            style: TextStyle(
              fontSize: 11,
              color: task.isDone ? AppColors.textMuted : color,
            ),
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
          Icon(Icons.flag_outlined,
              size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text(
            'No goals yet.\nTap New Goal to create one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    final titleController = TextEditingController();
    final targetXpController = TextEditingController();
    String selectedCategory = 'study';
    int statBoost = 5;
    DateTime deadline =
        DateTime.now().add(const Duration(days: 7));

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
              Text('New Goal', style: AppText.title),
              const SizedBox(height: 16),

              // goal name
              TextField(
                controller: titleController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Goal name...',
                  hintStyle:
                      const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // target XP
              TextField(
                controller: targetXpController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Target XP (e.g. 500)...',
                  hintStyle:
                      const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // linked stat
              Text('Linked Stat', style: AppText.label),
              const SizedBox(height: 8),
              Row(
                children:
                    ['study', 'health', 'work', 'habit'].map((cat) {
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
              const SizedBox(height: 12),

              // stat boost
              Text('Stat Boost on Completion', style: AppText.label),
              const SizedBox(height: 8),
              Row(
                children: [5, 10, 15].map((b) {
                  final isSelected = statBoost == b;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => statBoost = b),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.gold.withOpacity(0.15)
                              : AppColors.surface2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.gold
                                  : AppColors.border),
                        ),
                        child: Text(
                          '+$b pts',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? AppColors.gold
                                  : AppColors.textMuted),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // deadline
              Text('Deadline', style: AppText.label),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: deadline,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now()
                        .add(const Duration(days: 365)),
                    builder: (context, child) => Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppColors.accent,
                          surface: AppColors.surface,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setModalState(() => deadline = picked);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month,
                          size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Text(
                        '${deadline.day}/${deadline.month}/${deadline.year}',
                        style: const TextStyle(
                            color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    final targetXp = int.tryParse(
                            targetXpController.text.trim()) ??
                        0;
                    if (targetXp <= 0) return;

                    context.read<AppProvider>().addGoal(Goal(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          title: titleController.text.trim(),
                          category: selectedCategory,
                          targetXp: targetXp,
                          deadline: deadline,
                          statBoost: statBoost,
                        ));
                    Navigator.pop(context);
                  },
                  child: const Text('Create Goal',
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