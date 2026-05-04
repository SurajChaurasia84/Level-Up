import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/habit_card.dart';
import '../widgets/add_habit_modal.dart';
import '../widgets/diary_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isExpandedHabits = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredHabits = provider.habits.where((habit) {
            // Only show habits created on or before the selected date
            final normalizedCreated = DateTime(habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);
            final normalizedSelected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
            return normalizedCreated.isBefore(normalizedSelected) || normalizedCreated.isAtSameMomentAs(normalizedSelected);
          }).toList();

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(provider),
                  const SizedBox(height: 20),
                  _buildTodaySection(context),
                  const SizedBox(height: 12),
                  if (filteredHabits.isEmpty)
                    _buildNoHabitsPlaceholder()
                  else
                    ...( _isExpandedHabits ? filteredHabits : filteredHabits.take(5) ).map((habit) => Dismissible(
                          key: Key(habit.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) => _showDeleteConfirmation(context, habit.name),
                          onDismissed: (direction) {
                            provider.deleteHabit(habit.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${habit.name} deleted"),
                                backgroundColor: Colors.black87,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                                Text("Delete", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          child: HabitCard(
                            habit: habit,
                            selectedDate: _selectedDate,
                          ),
                        )),
                  if (filteredHabits.length > 5)
                    const SizedBox(height: 12),
                  if (filteredHabits.length > 5)
                    _buildExpandToggle(),
                  const SizedBox(height: 12),
                  _buildAddButton(context),
                  const SizedBox(height: 20),
                  _buildDiarySection(provider),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoHabitsPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: AppTheme.premiumCardDecoration.copyWith(
        color: Colors.white.withOpacity(0.5),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_late_rounded, size: 48, color: AppTheme.subtitleColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            "No Habits Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.subtitleColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You didn't have any habits on this day.",
            style: TextStyle(color: AppTheme.subtitleColor.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(HabitProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${provider.user?.name.split(' ')[0] ?? 'Champion'}! 👋",
              style: AppTheme.lightTheme.textTheme.displayLarge,
            ),
            const SizedBox(height: 4),
            Text(
              "Let's build some great habits today.",
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/fire.png', height: 20, width: 20),
                  Text(
                    " ${provider.currentGlobalStreak}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.streakColor),
                  ),
                ],
              ),
              const Text("Day Streak", style: TextStyle(fontSize: 10, color: AppTheme.streakColor, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySection(BuildContext context) {
    final isToday = _selectedDate.year == DateTime.now().year && 
                   _selectedDate.month == DateTime.now().month && 
                   _selectedDate.day == DateTime.now().day;
                   
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isToday ? "Today" : DateFormat('EEEE').format(_selectedDate),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF14181B)),
        ),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, size: 18, color: AppTheme.subtitleColor),
                const SizedBox(width: 8),
                Text(
                  DateFormat('d MMM, yyyy').format(_selectedDate),
                  style: TextStyle(fontSize: 14, color: AppTheme.subtitleColor, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.subtitleColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandToggle() {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpandedHabits = !_isExpandedHabits;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isExpandedHabits ? "Show Less" : "Show More",
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _isExpandedHabits ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: AppTheme.primaryColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => const AddHabitModal(),
        );
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF14181B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Add New Habit",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiarySection(HabitProvider provider) {
    final entries = provider.getDiaryEntries(_selectedDate);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: AppTheme.premiumCardDecoration,
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("How was your day?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text("Track your mood & reflections", style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showDiaryModal(context, provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14181B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text("Write", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (entries.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...entries.reversed.map((entry) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notes_rounded, size: 14, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF14181B), height: 1.3),
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  void _showDiaryModal(BuildContext context, HabitProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DiaryModal(
          date: _selectedDate,
          initialEntry: "", // Always start empty for a NEW note
          onSave: (entry) {
            if (entry.trim().isNotEmpty) {
              provider.saveDiaryEntry(_selectedDate, entry);
            }
          },
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, String habitName) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Habit?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete '$habitName'? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
