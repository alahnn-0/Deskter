import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';
import '../constants/theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final selectedTasks = provider.tasksForDate(_selectedDay);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildCalendar(provider),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TASKS FOR ${_formatDayLabel(_selectedDay)}',
                    style: AppText.label,
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddTaskSheet(context),
                    icon: const Icon(Icons.add,
                        size: 16, color: AppColors.accentLight),
                    label: const Text('Add',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.accentLight)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: selectedTasks.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: selectedTasks.length,
                      itemBuilder: (context, index) =>
                          _buildTaskRow(context, selectedTasks[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SCHEDULE', style: AppText.label),
              const SizedBox(height: 4),
              Text(_monthLabel(_focusedMonth), style: AppText.title),
            ],
          ),
          Row(
            children: [
              _navButton(Icons.chevron_left, () {
                setState(() {
                  _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                });
              }),
              const SizedBox(width: 8),
              _navButton(Icons.chevron_right, () {
                setState(() {
                  _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildCalendar(AppProvider provider) {
    final firstDay =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0 = Sunday

    final dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // day labels row
          Row(
            children: dayLabels
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          // calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday) {
                return const SizedBox();
              }
              final day = index - startWeekday + 1;
              final date = DateTime(
                  _focusedMonth.year, _focusedMonth.month, day);
              final isToday = _isSameDay(date, DateTime.now());
              final isSelected = _isSameDay(date, _selectedDay);
              final hasTasks =
                  provider.tasksForDate(date).isNotEmpty;

              return GestureDetector(
                onTap: () => setState(() => _selectedDay = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.accent
                        : isSelected
                            ? AppColors.surface3
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected && !isToday
                        ? Border.all(color: AppColors.accent)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 13,
                          color: isToday
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: isToday || isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (hasTasks && !isToday)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.accentLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskRow(BuildContext context, Task task) {
    final color = Color(Task.categoryColors[task.category]!);
    final label = Task.categoryLabels[task.category]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
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
                color:
                    task.isDone ? AppColors.accent : Colors.transparent,
                border: Border.all(
                  color:
                      task.isDone ? AppColors.accent : AppColors.border,
                  width: 2,
                ),
              ),
              child: task.isDone
                  ? const Icon(Icons.check,
                      size: 14, color: Colors.white)
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
                const SizedBox(height: 4),
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
              ],
            ),
          ),
          Text(
            '+${task.xp} XP',
            style: TextStyle(
              fontSize: 13,
              color:
                  task.isDone ? AppColors.textMuted : AppColors.gold,
              fontWeight: FontWeight.w600,
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
          Icon(Icons.calendar_month_outlined,
              size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text('No quests for this day.\nTap Add to create one.',
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

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Quest — ${_formatDayLabel(_selectedDay)}',
                  style: AppText.title),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Task name...',
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
                            color:
                                isSelected ? color : AppColors.border,
                          ),
                        ),
                        child: Text(
                          Task.categoryLabels[cat]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? color
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
                                : AppColors.border,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              d['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? AppColors.accentLight
                                    : AppColors.textMuted,
                              ),
                            ),
                            Text(
                              '+${d['xp']} XP',
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? AppColors.gold
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    context.read<AppProvider>().addTask(Task(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          title: titleController.text.trim(),
                          category: selectedCategory,
                          xp: selectedXp,
                          date: _selectedDay,
                        ));
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

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthLabel(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  String _formatDayLabel(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}