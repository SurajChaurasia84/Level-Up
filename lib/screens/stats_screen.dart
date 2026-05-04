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
                  _buildMonthlySummary(provider),
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

  Widget _buildMonthlySummary(HabitProvider provider) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 (Mon) to 7 (Sun)
    
    // We need to pad the start of the month to align with weekdays
    // Since our grid starts on Monday, we need (firstWeekday - 1) empty slots
    final paddingSlots = firstWeekday - 1;
    final totalSlots = paddingSlots + daysInMonth;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(now),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "${(provider.completionRateThisMonth * 100).toInt()}%",
                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Weekday Headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(fontSize: 10, color: AppTheme.subtitleColor, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: totalSlots,
            itemBuilder: (context, index) {
              if (index < paddingSlots) {
                return const SizedBox.shrink();
              }
              
              final dayNum = index - paddingSlots + 1;
              final date = DateTime(now.year, now.month, dayNum);
              final isToday = dayNum == now.day;
              
              // Calculate completion ratio for this day
              final habitsActiveOnThisDay = provider.habits.where((h) {
                final normalizedCreated = DateTime(h.createdAt.year, h.createdAt.month, h.createdAt.day);
                final normalizedDate = DateTime(date.year, date.month, date.day);
                return normalizedCreated.isBefore(normalizedDate) || normalizedCreated.isAtSameMomentAs(normalizedDate);
              }).toList();

              int completedOnThisDay = 0;
              for (var h in habitsActiveOnThisDay) {
                if (h.completedDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day)) {
                  completedOnThisDay++;
                }
              }

              final totalHabits = habitsActiveOnThisDay.length;
              final completionRatio = totalHabits > 0 ? completedOnThisDay / totalHabits : 0.0;
              
              // Determine color intensity based on ratio (GitHub style)
              Color cellColor;
              if (completionRatio == 0) {
                cellColor = AppTheme.subtitleColor.withOpacity(0.1);
              } else if (completionRatio <= 0.25) {
                cellColor = AppTheme.primaryColor.withOpacity(0.3);
              } else if (completionRatio <= 0.5) {
                cellColor = AppTheme.primaryColor.withOpacity(0.5);
              } else if (completionRatio <= 0.75) {
                cellColor = AppTheme.primaryColor.withOpacity(0.75);
              } else {
                cellColor = AppTheme.primaryColor;
              }

              return InkWell(
                onTap: () => _showDayDetails(context, provider, date),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cellColor,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday 
                      ? Border.all(color: AppTheme.primaryColor, width: 2)
                      : null,
                  ),
                  child: Text(
                    "$dayNum",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday || completionRatio > 0 ? FontWeight.bold : FontWeight.normal,
                      color: completionRatio > 0.5 
                          ? Colors.white 
                          : (isToday ? AppTheme.primaryColor : AppTheme.textColor),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDayDetails(BuildContext context, HabitProvider provider, DateTime date) {
    final habitsActiveOnThisDay = provider.habits.where((h) {
      final normalizedCreated = DateTime(h.createdAt.year, h.createdAt.month, h.createdAt.day);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      return normalizedCreated.isBefore(normalizedDate) || normalizedCreated.isAtSameMomentAs(normalizedDate);
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM dd').format(date),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Habit performance for this day",
                        style: TextStyle(color: AppTheme.subtitleColor, fontSize: 13),
                      ),
                    ],
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 20),
              if (habitsActiveOnThisDay.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text("No habits were active on this day.")),
                )
              else
                ...habitsActiveOnThisDay.map((h) {
                  final completed = h.isCompletedOn(date);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(h.colorValue).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconData(h.icon),
                            color: Color(h.colorValue),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            h.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              decoration: completed ? null : TextDecoration.lineThrough,
                              color: completed ? AppTheme.textColor : AppTheme.subtitleColor.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Icon(
                          completed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: completed ? Colors.green : Colors.red.shade300,
                          size: 20,
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'directions_run': return Icons.directions_run_rounded;
      case 'local_drink': return Icons.local_drink_rounded;
      case 'menu_book': return Icons.menu_book_rounded;
      case 'fitness_center': return Icons.fitness_center_rounded;
      case 'self_improvement': return Icons.self_improvement_rounded;
      case 'nightlight_round': return Icons.nightlight_round_rounded;
      case 'restaurant': return Icons.restaurant_rounded;
      case 'code': return Icons.code_rounded;
      case 'payments': return Icons.payments_rounded;
      case 'pool': return Icons.pool_rounded;
      case 'pedal_bike': return Icons.pedal_bike_rounded;
      case 'brush': return Icons.brush_rounded;
      case 'language': return Icons.language_rounded;
      case 'spa': return Icons.spa_rounded;
      case 'work': return Icons.work_rounded;
      case 'pets': return Icons.pets_rounded;
      case 'sunny': return Icons.sunny;
      case 'music_note': return Icons.music_note_rounded;
      case 'hiking': return Icons.hiking_rounded;
      default: return Icons.star_rounded;
    }
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
}
