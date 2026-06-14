import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';
import '../constants/theme.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('INSIGHTS', style: AppText.label),
              const SizedBox(height: 4),
              Text('Analysis', style: AppText.title),
              const SizedBox(height: 20),

              // snapshot cards
              _buildSnapshotCards(provider),
              const SizedBox(height: 24),

              // weekly completion bar chart
              Text('WEEKLY COMPLETION', style: AppText.label),
              const SizedBox(height: 10),
              _buildWeeklyChart(provider),
              const SizedBox(height: 24),

              // stat growth line chart
              Text('STAT GROWTH', style: AppText.label),
              const SizedBox(height: 10),
              _buildStatChart(provider),
              const SizedBox(height: 24),

              // category breakdown pie chart
              Text('CATEGORY BREAKDOWN', style: AppText.label),
              const SizedBox(height: 10),
              _buildPieChart(provider),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Snapshot Cards ──────────────────────────────────────────
  Widget _buildSnapshotCards(AppProvider provider) {
    final character = provider.character;
    final allTasks = provider.tasks;
    final doneTasks = allTasks.where((t) => t.isDone).length;
    final completionRate = allTasks.isEmpty
        ? 0
        : (doneTasks / allTasks.length * 100).round();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _snapshotCard('Total XP', '${character.totalXp}',
            Icons.bolt, AppColors.accent),
        _snapshotCard('Level', '${character.level}',
            Icons.star, AppColors.gold),
        _snapshotCard('Streak', '${character.streak} days',
            Icons.local_fire_department, AppColors.work),
        _snapshotCard('Completion', '$completionRate%',
            Icons.check_circle_outline, AppColors.health),
      ],
    );
  }

  Widget _snapshotCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 18, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Weekly Bar Chart ─────────────────────────────────────────
  Widget _buildWeeklyChart(AppProvider provider) {
    final now = DateTime.now();
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // build data for last 7 days
    final List<BarChartGroupData> bars = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayTasks = provider.tasksForDate(date);
      final total = dayTasks.length.toDouble();
      final done =
          dayTasks.where((t) => t.isDone).length.toDouble();
      final rate = total == 0 ? 0.0 : done / total;

      bars.add(BarChartGroupData(
        x: 6 - i,
        barRods: [
          BarChartRodData(
            toY: rate * 100,
            color: rate >= 0.8
                ? AppColors.health
                : rate >= 0.5
                    ? AppColors.accent
                    : AppColors.surface3,
            width: 22,
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: AppColors.surface2,
            ),
          ),
        ],
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: 100,
                barGroups: bars,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final now = DateTime.now();
                        final date = now.subtract(
                            Duration(days: 6 - value.toInt()));
                        final isToday = value.toInt() == 6;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            isToday
                                ? 'Today'
                                : dayLabels[date.weekday - 1],
                            style: TextStyle(
                              fontSize: 9,
                              color: isToday
                                  ? AppColors.accentLight
                                  : AppColors.textMuted,
                              fontWeight: isToday
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        BarTooltipItem(
                      '${rod.toY.toInt()}%',
                      const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.health, '≥80%'),
              const SizedBox(width: 16),
              _legendDot(AppColors.accent, '50–79%'),
              const SizedBox(width: 16),
              _legendDot(AppColors.surface3, '<50%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  // ── Stat Line Chart ──────────────────────────────────────────
  Widget _buildStatChart(AppProvider provider) {
    final stats = provider.character.stats;
    final categories = ['study', 'health', 'work', 'habit'];

    // generate fake history points leading to current value
    // in v0.0.4 this will use real historical data
    List<LineChartBarData> lines = categories.map((cat) {
      final current = stats[cat]!;
      final color = Color(Task.categoryColors[cat]!);

      // simulate 7 data points trending toward current value
      final spots = List.generate(7, (i) {
        final fraction = i / 6;
        final value = 30 + (current - 30) * fraction;
        return FlSpot(i.toDouble(), value);
      });

      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 2,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, bar, index) =>
              FlDotCirclePainter(
            radius: index == 6 ? 4 : 2,
            color: color,
            strokeWidth: 0,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: color.withOpacity(0.05),
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        'D${value.toInt() + 1}',
                        style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: lines,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                              s.y.toStringAsFixed(1),
                              TextStyle(
                                color: s.bar.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // legend
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: categories.map((cat) {
              final color = Color(Task.categoryColors[cat]!);
              final label = Task.categoryLabels[cat]!;
              return _legendDot(color, label);
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Pie Chart ────────────────────────────────────────────────
  Widget _buildPieChart(AppProvider provider) {
    final categories = ['study', 'health', 'work', 'habit'];

    // count completed tasks per category
    final Map<String, int> counts = {
      'study': 0, 'health': 0, 'work': 0, 'habit': 0,
    };
    for (final task in provider.tasks) {
      if (task.isDone && counts.containsKey(task.category)) {
        counts[task.category] = counts[task.category]! + 1;
      }
    }

    final total = counts.values.fold(0, (a, b) => a + b);

    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'Complete tasks to see\ncategory breakdown.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    final sections = categories.map((cat) {
      final count = counts[cat]!;
      final color = Color(Task.categoryColors[cat]!);
      final pct = count / total * 100;
      return PieChartSectionData(
        value: count.toDouble(),
        color: color,
        radius: 60,
        title: pct >= 10 ? '${pct.toInt()}%' : '',
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        badgeWidget: pct < 10
            ? null
            : null,
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 3,
                pieTouchData: PieTouchData(
                  touchCallback:
                      (FlTouchEvent event, pieTouchResponse) {},
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // legend with counts
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: categories.map((cat) {
              final color = Color(Task.categoryColors[cat]!);
              final label = Task.categoryLabels[cat]!;
              final count = counts[cat]!;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$label ($count)',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}