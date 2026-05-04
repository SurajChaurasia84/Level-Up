import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import '../models/habit.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildWeeklySummary(provider),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Habit History"),
                  const SizedBox(height: 16),
                  _buildHistoryList(provider),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Stats",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF14181B)),
        ),
        const SizedBox(height: 4),
        Text(
          "Track your progress and consistency",
          style: TextStyle(color: AppTheme.subtitleColor, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildWeeklySummary(HabitProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Weekly Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "${(provider.completionRateThisWeek * 100).toInt()}% Success",
                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = DateTime.now().subtract(Duration(days: 6 - index));
              final isToday = index == 6;
              final dayName = DateFormat('E').format(date)[0];
              
              // Check if any habit was completed on this day
              bool anyCompleted = provider.habits.any((h) => h.completedDates.any((d) => 
                d.year == date.year && d.month == date.month && d.day == date.day));

              return Column(
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isToday ? AppTheme.primaryColor : AppTheme.subtitleColor,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: anyCompleted ? AppTheme.primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: anyCompleted ? AppTheme.primaryColor : AppTheme.subtitleColor.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: anyCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF14181B)),
    );
  }

  Widget _buildHistoryList(HabitProvider provider) {
    if (provider.habits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text("No habits yet. Start by adding one!", style: TextStyle(color: AppTheme.subtitleColor)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.habits.length,
      itemBuilder: (context, index) {
        final habit = provider.habits[index];
        return _buildHabitHistoryItem(habit);
      },
    );
  }

  Widget _buildHabitHistoryItem(Habit habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.premiumCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(habit.colorValue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconData(habit.icon),
                  color: Color(habit.colorValue),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      "${habit.completedDates.length} total completions",
                      style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.streakColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/fire.png', height: 14, width: 14),
                    Text(
                      " ${habit.currentStreak}",
                      style: const TextStyle(color: AppTheme.streakColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text("Last 7 Days", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF57636C))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = DateTime.now().subtract(Duration(days: 6 - index));
              final completed = habit.completedDates.any((d) => 
                d.year == date.year && d.month == date.month && d.day == date.day);

              return Container(
                width: 36,
                height: 8,
                decoration: BoxDecoration(
                  color: completed ? Color(habit.colorValue) : AppTheme.subtitleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'directions_run': return Icons.directions_run_rounded;
      case 'local_drink': return Icons.local_drink_rounded;
      case 'menu_book': return Icons.menu_book_rounded;
      case 'self_improvement': return Icons.self_improvement_rounded;
      case 'book': return Icons.book_rounded;
      default: return Icons.star_rounded;
    }
  }
}
