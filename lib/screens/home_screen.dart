import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/habit_card.dart';
import '../widgets/add_habit_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                  _buildHeader(provider),
                  const SizedBox(height: 30),
                  _buildTodaySection(),
                  const SizedBox(height: 20),
                  ...provider.habits.map((habit) => HabitCard(habit: habit)),
                  const SizedBox(height: 20),
                  _buildAddButton(context),
                  const SizedBox(height: 30),
                  _buildDiarySection(),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          );
        },
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
              "Good morning, ${provider.user?.name.split(' ')[0] ?? 'User'}! 👋",
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF5963), size: 28),
                  Text(
                    " ${provider.currentGlobalStreak}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF14181B)),
                  ),
                ],
              ),
              const Text("Day Streak", style: TextStyle(fontSize: 12, color: Color(0xFFFF5963), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Today",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF14181B)),
        ),
        Container(
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
                DateFormat('d MMM, yyyy').format(DateTime.now()),
                style: TextStyle(fontSize: 14, color: AppTheme.subtitleColor, fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ),
        ),
      ],
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
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
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

  Widget _buildDiarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("How was your day?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Reflect on your day and track your mood", style: TextStyle(color: AppTheme.subtitleColor)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.edit_note_rounded, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text("Write Diary", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                Icon(Icons.chevron_right, color: AppTheme.primaryColor, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
