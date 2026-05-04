import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import 'reminder_modal.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final isCompleted = habit.isCompletedToday();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.premiumCardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(habit.colorValue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconData(habit.icon),
              color: Color(habit.colorValue),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  habit.description,
                  style: TextStyle(color: AppTheme.subtitleColor, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF5963), size: 16),
                  Text(
                    " ${habit.currentStreak}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const Text("day streak", style: TextStyle(fontSize: 10, color: Color(0xFF57636C))),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: ReminderModal(
                    habitName: habit.name,
                    currentReminder: habit.reminderTime ?? "07:00 AM",
                    onSave: (time) {
                      context.read<HabitProvider>().updateReminder(habit.id, time);
                    },
                  ),
                ),
              );
            },
            icon: Icon(Icons.notifications_none_rounded, color: AppTheme.subtitleColor),
          ),
          GestureDetector(
            onTap: () {
              context.read<HabitProvider>().toggleHabitCompletion(habit.id);
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? AppTheme.primaryColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppTheme.primaryColor : AppTheme.subtitleColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'directions_run':
        return Icons.directions_run_rounded;
      case 'local_drink':
        return Icons.local_drink_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'self_improvement':
        return Icons.self_improvement_rounded;
      case 'book':
        return Icons.book_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}
