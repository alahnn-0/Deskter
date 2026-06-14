import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';
import '../models/character.dart';
import '../constants/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final character = provider.character;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CHARACTER SHEET', style: AppText.label),
                      const SizedBox(height: 4),
                      Text('My Profile', style: AppText.title),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.textMuted),
                    onPressed: () => _showEditNameSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCharacterCard(character),
              const SizedBox(height: 20),

              Text('STATS', style: AppText.label),
              const SizedBox(height: 10),
              _buildStats(character.stats, character),
              const SizedBox(height: 20),

              // custom attributes section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CUSTOM ATTRIBUTES', style: AppText.label),
                  GestureDetector(
                    onTap: () => _showAddAttributeSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.accent.withOpacity(0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add,
                              size: 12, color: AppColors.accentLight),
                          SizedBox(width: 4),
                          Text('Add',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.accentLight)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              character.customAttributes.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text(
                          'No custom attributes yet.\nTap Add to create one.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  : _buildCustomAttributes(context, character),
              const SizedBox(height: 20),

              Text('ACHIEVEMENTS', style: AppText.label),
              const SizedBox(height: 10),
              _buildAchievements(character),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterCard(character) {
    final nameParts = character.name.trim().split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : character.name
            .substring(0, character.name.length >= 2 ? 2 : 1)
            .toUpperCase();

    final xpProgress = character.currentLevelXp / character.xpToNextLevel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppColors.accentLight, width: 2),
            ),
            child: Center(
              child: Text(initials,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(character.name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.gold),
                    const SizedBox(width: 4),
                    Text(
                      'Level ${character.level} · ${character.className}',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.gold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: xpProgress,
                    backgroundColor: AppColors.surface3,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.accent),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${character.currentLevelXp} / ${character.xpToNextLevel} XP',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      '${character.streak} day streak · ${character.streakTitle}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(Map<String, double> stats, dynamic character) {
    final statIcons = {
      'study': Icons.menu_book,
      'health': Icons.bolt,
      'work': Icons.work_outline,
      'habit': Icons.self_improvement,
    };

    return Column(
      children: stats.entries.map((entry) {
        final color = Color(Task.categoryColors[entry.key]!);
        final label = Task.categoryLabels[entry.key]!;
        final icon = statIcons[entry.key]!;
        final value = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(value.toStringAsFixed(1),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: color)),
                      Text(character.statLabel(value),
                          style:
                              TextStyle(fontSize: 9, color: color)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: value / 100,
                  backgroundColor: AppColors.surface3,
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomAttributes(
      BuildContext context, Character character) {
    return Column(
      children: character.customAttributes.map((attr) {
        final color = Color(attr.color);
        return GestureDetector(
          onLongPress: () => _confirmDeleteAttribute(context, attr),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(attr.icon,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(attr.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(attr.value.toStringAsFixed(1),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: color)),
                        Text(attr.label,
                            style:
                                TextStyle(fontSize: 9, color: color)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: attr.value / 100,
                    backgroundColor: AppColors.surface3,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                // manual slider to adjust value
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: color.withOpacity(0.6),
                    inactiveTrackColor: AppColors.surface3,
                    thumbColor: color,
                    overlayColor: color.withOpacity(0.1),
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: attr.value,
                    min: 0,
                    max: 100,
                    onChanged: (val) => context
                        .read<AppProvider>()
                        .updateAttributeValue(attr.id, val),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _confirmDeleteAttribute(BuildContext context, Attribute attr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Attribute',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Delete "${attr.name}"?',
            style: const TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<AppProvider>()
                  .deleteAttribute(attr.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddAttributeSheet(BuildContext context) {
    final nameController = TextEditingController();
    String selectedEmoji = '⚡';
    int selectedColor = 0xFF818cf8;

    final emojis = [
      '⚡','🧠','💪','🎯','🔥','✨','🌟','🛡️',
      '⚔️','🏆','💡','🎨','🎵','📚','🌿','❤️',
    ];

    final colors = [
      0xFF818cf8, 0xFF4ade80, 0xFFfb923c, 0xFFe879f9,
      0xFF60a5fa, 0xFFf87171, 0xFFfbbf24, 0xFF34d399,
    ];

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
              Text('New Attribute', style: AppText.title),
              const SizedBox(height: 16),

              // name
              TextField(
                controller: nameController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Attribute name (e.g. Creativity)...',
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
              const SizedBox(height: 16),

              // emoji picker
              Text('Icon', style: AppText.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: emojis.map((e) {
                  final isSelected = selectedEmoji == e;
                  return GestureDetector(
                    onTap: () =>
                        setModalState(() => selectedEmoji = e),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent.withOpacity(0.2)
                            : AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.border),
                      ),
                      child: Center(
                          child: Text(e,
                              style:
                                  const TextStyle(fontSize: 20))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // color picker
              Text('Color', style: AppText.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colors.map((c) {
                  final isSelected = selectedColor == c;
                  return GestureDetector(
                    onTap: () =>
                        setModalState(() => selectedColor = c),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // preview
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Text(selectedEmoji,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(
                      nameController.text.isEmpty
                          ? 'Attribute name'
                          : nameController.text,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    Text('30.0',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(selectedColor))),
                  ],
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
                    if (nameController.text.trim().isEmpty) return;
                    context.read<AppProvider>().addAttribute(
                          Attribute(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            name: nameController.text.trim(),
                            icon: selectedEmoji,
                            color: selectedColor,
                          ),
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Create Attribute',
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

  Widget _buildAchievements(character) {
    final List<Map<String, dynamic>> all = [
      {
        'icon': Icons.star,
        'label': 'First Steps',
        'desc': 'Earn 50 total XP',
        'unlocked': character.totalXp >= 50,
        'color': AppColors.gold,
      },
      {
        'icon': Icons.menu_book,
        'label': 'Scholar',
        'desc': 'Intelligence 50',
        'unlocked': character.stats['study'] >= 50,
        'color': AppColors.study,
      },
      {
        'icon': Icons.bolt,
        'label': 'Warrior',
        'desc': 'Strength 50',
        'unlocked': character.stats['health'] >= 50,
        'color': AppColors.health,
      },
      {
        'icon': Icons.work_outline,
        'label': 'Professional',
        'desc': 'Charisma 50',
        'unlocked': character.stats['work'] >= 50,
        'color': AppColors.work,
      },
      {
        'icon': Icons.self_improvement,
        'label': 'Mindful',
        'desc': 'Discipline 50',
        'unlocked': character.stats['habit'] >= 50,
        'color': AppColors.habit,
      },
      {
        'icon': Icons.local_fire_department,
        'label': 'Hot Streak',
        'desc': '7 day streak',
        'unlocked': character.streak >= 7,
        'color': AppColors.gold,
      },
      {
        'icon': Icons.workspace_premium,
        'label': 'Legendary',
        'desc': '30 day streak',
        'unlocked': character.streak >= 30,
        'color': AppColors.gold,
      },
      {
        'icon': Icons.emoji_events,
        'label': 'Veteran',
        'desc': 'Reach Level 5',
        'unlocked': character.level >= 5,
        'color': AppColors.gold,
      },
      {
        'icon': Icons.psychology,
        'label': 'Mastermind',
        'desc': 'Intelligence 90',
        'unlocked': character.stats['study'] >= 90,
        'color': AppColors.study,
      },
      {
        'icon': Icons.fitness_center,
        'label': 'Elite',
        'desc': 'Strength 90',
        'unlocked': character.stats['health'] >= 90,
        'color': AppColors.health,
      },
      {
        'icon': Icons.auto_awesome,
        'label': 'All Rounder',
        'desc': 'All stats above 50',
        'unlocked': character.stats.values
            .every((v) => (v as double) >= 50),
        'color': AppColors.accentLight,
      },
      {
        'icon': Icons.military_tech,
        'label': 'Legend',
        'desc': 'Reach Level 10',
        'unlocked': character.level >= 10,
        'color': AppColors.gold,
      },
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: all.map((a) {
        final unlocked = a['unlocked'] as bool;
        final color = a['color'] as Color;
        return Container(
          padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: unlocked
                ? color.withOpacity(0.1)
                : AppColors.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: unlocked
                  ? color.withOpacity(0.4)
                  : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(a['icon'] as IconData,
                  size: 24,
                  color: unlocked ? color : AppColors.textMuted),
              const SizedBox(height: 6),
              Text(a['label'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: unlocked ? color : AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(a['desc'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.textMuted)),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showEditNameSheet(BuildContext context) {
    final controller = TextEditingController(
        text: context.read<AppProvider>().character.name);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Character', style: AppText.title),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Your name...',
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
                  if (controller.text.trim().isNotEmpty) {
                    context
                        .read<AppProvider>()
                        .updateName(controller.text.trim());
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}