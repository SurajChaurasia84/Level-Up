import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import 'reminder_modal.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final DateTime? selectedDate;

  const HabitCard({super.key, required this.habit, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final dateToCheck = selectedDate ?? DateTime.now();
    final isCompleted = habit.isCompletedOn(dateToCheck);
    final isToday = dateToCheck.year == DateTime.now().year && 
                   dateToCheck.month == DateTime.now().month && 
                   dateToCheck.day == DateTime.now().day;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: AppTheme.premiumCardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(habit.colorValue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconData(habit.icon),
              color: Color(habit.colorValue),
              size: 24,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  habit.description,
                  style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Row(
                children: [
                  Image.asset('assets/fire.png', height: 16, width: 16),
                  Text(
                    " ${habit.currentStreak}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.streakColor),
                  ),
                ],
              ),
              const Text("day streak", style: TextStyle(fontSize: 9, color: AppTheme.streakColor)),
            ],
          ),
          const SizedBox(width: 4),
          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
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
                    habitIcon: habit.icon,
                    habitColor: habit.colorValue,
                    currentReminder: habit.reminderTime ?? "",
                    currentFrequency: habit.frequency,
                    currentDays: habit.reminderDays,
                    onSave: (time, freq, days) {
                      context.read<HabitProvider>().updateReminder(
                        habit.id, 
                        time, 
                        days: days,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(time == null ? "Reminder removed!" : "Reminder set for $time"),
                          backgroundColor: time == null ? Colors.redAccent : AppTheme.primaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            icon: Icon(
              habit.reminderTime != null ? Icons.notifications_active_rounded : Icons.notifications_none_rounded, 
              color: AppTheme.subtitleColor, 
              size: 24
            ),
          ),
          GestureDetector(
            onTap: () {
              // Prevent toggling for future dates
              if (dateToCheck.isAfter(DateTime.now()) && 
                  (dateToCheck.day != DateTime.now().day || 
                   dateToCheck.month != DateTime.now().month || 
                   dateToCheck.year != DateTime.now().year)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cannot log habits for future dates!")),
                );
                return;
              }
              context.read<HabitProvider>().toggleHabitCompletion(habit.id, date: dateToCheck);
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted ? Color(habit.colorValue) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(habit.colorValue).withOpacity(isCompleted ? 1.0 : 0.3),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
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
