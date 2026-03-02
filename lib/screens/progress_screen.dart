import 'package:fitness_tracker_app/components/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/history_model.dart';


class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Box<HistoryModel> historyBox;

  @override
  void initState() {
    super.initState();
    historyBox = Hive.box<HistoryModel>('history');
  }

  int totalWorkouts() => historyBox.length;

  int dailyStreak() {
    if (historyBox.isEmpty) return 0;
    final sorted = historyBox.values.map((e) => e.date).toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime today = DateTime.now();
    for (var date in sorted) {
      final difference = today
          .difference(DateTime(date.year, date.month, date.day))
          .inDays;
      if (difference == streak) {
        streak++;
      } else if (difference > streak) {
        break;
      }
    }
    return streak;
  }

  int thisWeekWorkouts() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return historyBox.values.where((h) => h.date.isAfter(startOfWeek)).length;
  }

  int thisMonthWorkouts() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return historyBox.values.where((h) => h.date.isAfter(startOfMonth)).length;
  }

  Map<int, int> weeklyBarData() {
    Map<int, int> data = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    for (var h in historyBox.values) {
      final weekday = h.date.weekday % 7;
      data[weekday] = (data[weekday] ?? 0) + 1;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final weeklyData = weeklyBarData();

    return Scaffold(
      backgroundColor: AppTheme.jetBlack,

      /// 🔥 DARK RED HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            padding: const EdgeInsets.fromLTRB(20, 55, 20, 25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryRed,
                  AppTheme.darkRed,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Progress & Stats",
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Track your fitness journey",
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// STATS GRID
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.trending_up,
                      value: totalWorkouts().toString(),
                      label: "Total Workouts",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.local_fire_department,
                      value: dailyStreak().toString(),
                      label: "Day Streak",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.calendar_today,
                      value: thisWeekWorkouts().toString(),
                      label: "This Week",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.calendar_month,
                      value: thisMonthWorkouts().toString(),
                      label: "This Month",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// WEEKLY CHART CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Weekly Activity",
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: weeklyData.values.isEmpty
                              ? 5
                              : weeklyData.values.reduce((a, b) => a > b ? a : b).toDouble() + 1,
                          barGroups: weeklyData.entries.map(
                            (e) {
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value.toDouble(),
                                    width: 18,
                                    borderRadius: BorderRadius.circular(6),
                                    color: AppTheme.primaryRed,
                                  ),
                                ],
                              );
                            },
                          ).toList(),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: AppTheme.border,
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = [
                                    "Sun",
                                    "Mon",
                                    "Tue",
                                    "Wed",
                                    "Thu",
                                    "Fri",
                                    "Sat"
                                  ];
                                  return Text(
                                    days[value.toInt()],
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// MOTIVATION CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Stay Consistent 💪",
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      historyBox.isEmpty
                          ? "Complete your first workout to unlock progress tracking."
                          : "You're doing great! Keep pushing your limits.",
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔥 DARK STAT CARD
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryRed.withOpacity(.15),
            child: Icon(icon, color: AppTheme.primaryRed),
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
