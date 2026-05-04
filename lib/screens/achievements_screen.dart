import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import '../models/achievement.dart';
import '../theme/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<HabitProvider>(
          builder: (context, provider, child) {
            final achievements = _getAchievements(provider);
            final unlocked = achievements.where((a) => a.isUnlocked).toList();
            final locked = achievements.where((a) => !a.isUnlocked).toList();

            return CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildHeaderCard(unlocked.length, achievements.length, provider.currentGlobalStreak),
                  ),
                ),
                if (unlocked.isNotEmpty) ...[
                  _buildSectionTitle("UNLOCKED (${unlocked.length})"),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildAchievementItem(unlocked[index], true),
                      childCount: unlocked.length,
                    ),
                  ),
                ],
                if (locked.isNotEmpty) ...[
                  _buildSectionTitle("LOCKED (${locked.length})"),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildAchievementItem(locked[index], false),
                      childCount: locked.length,
                    ),
                  ),
                ],
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textColor, size: 20),
        onPressed: () {},
      ),
      title: Text(
        "Achievements",
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline_rounded, color: AppTheme.textColor, size: 24),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeaderCard(int unlockedCount, int totalCount, int streak) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.premiumCardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 48),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$unlockedCount",
                      style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(fontSize: 32),
                    ),
                    Text(
                      " / $totalCount",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(fontSize: 18),
                    ),
                  ],
                ),
                Text(
                  "Achievements Unlocked",
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 1,
            color: Colors.grey.shade200,
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: AppTheme.streakColor, size: 28),
              Text(
                "$streak",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "Day Streak",
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Text(
          title,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 12,
            color: AppTheme.subtitleColor.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementItem(Achievement achievement, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.premiumCardDecoration.copyWith(
        color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.7),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: achievement.color.withOpacity(isUnlocked ? 0.1 : 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: isUnlocked ? achievement.color : achievement.color.withOpacity(0.3),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    color: isUnlocked ? AppTheme.textColor : AppTheme.textColor.withOpacity(0.5),
                  ),
                ),
                Text(
                  achievement.description,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: AppTheme.subtitleColor.withOpacity(isUnlocked ? 1 : 0.5),
                  ),
                ),
                if (!isUnlocked) ...[
                  const SizedBox(height: 12),
                  _buildProgressBar(achievement),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isUnlocked)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.green, size: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Unlocked",
                  style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                Text(
                  achievement.unlockedDate != null 
                      ? DateFormat('MMM dd, yyyy').format(achievement.unlockedDate!)
                      : "Recently",
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(fontSize: 10),
                ),
              ],
            )
          else
            const Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Achievement achievement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "${achievement.progress}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryColor),
            ),
            Text(
              " / ${achievement.target} days",
              style: const TextStyle(fontSize: 12, color: AppTheme.subtitleColor),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: achievement.percent.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Achievement> _getAchievements(HabitProvider provider) {
    final streak = provider.currentGlobalStreak;
    final total = provider.totalCompletedCount;
    
    // Mocking some dates for unlocked ones
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));

    return [
      Achievement(
        id: "first_step",
        title: "First Step",
        description: "Complete your first habit",
        icon: Icons.eco_rounded,
        color: Colors.green,
        isUnlocked: total >= 1,
        unlockedDate: lastWeek,
      ),
      Achievement(
        id: "getting_started",
        title: "Getting Started",
        description: "Maintain a 3 day streak",
        icon: Icons.local_fire_department_rounded,
        color: Colors.orange,
        isUnlocked: streak >= 3,
        unlockedDate: yesterday,
      ),
      Achievement(
        id: "consistent",
        title: "Consistent",
        description: "Maintain a 7 day streak",
        icon: Icons.stars_rounded,
        color: Colors.indigo,
        isUnlocked: streak >= 7,
        unlockedDate: DateTime.now(),
      ),
      Achievement(
        id: "on_a_roll",
        title: "On a Roll",
        description: "Complete all habits in a day",
        icon: Icons.track_changes_rounded,
        color: Colors.blue,
        isUnlocked: true, // Mocked
        unlockedDate: yesterday,
      ),
      Achievement(
        id: "dedicated",
        title: "Dedicated",
        description: "Complete 50 habits total",
        icon: Icons.emoji_events_rounded,
        color: Colors.amber,
        isUnlocked: total >= 50,
        unlockedDate: total >= 50 ? DateTime.now() : null,
      ),
      Achievement(
        id: "week_warrior",
        title: "Week Warrior",
        description: "Use the app 7 days in a row",
        icon: Icons.calendar_month_rounded,
        color: Colors.pink,
        isUnlocked: streak >= 7,
        unlockedDate: streak >= 7 ? DateTime.now() : null,
      ),
      Achievement(
        id: "unstoppable",
        title: "Unstoppable",
        description: "Maintain a 30 day streak",
        icon: Icons.terrain_rounded,
        color: Colors.grey,
        isUnlocked: streak >= 30,
        progress: streak,
        target: 30,
      ),
      Achievement(
        id: "habit_master",
        title: "Habit Master",
        description: "Complete 100 habits total",
        icon: Icons.diamond_rounded,
        color: Colors.grey,
        isUnlocked: total >= 100,
        progress: total,
        target: 100,
      ),
      Achievement(
        id: "legend",
        title: "Legend",
        description: "Maintain a 100 day streak",
        icon: Icons.workspace_premium_rounded,
        color: Colors.grey,
        isUnlocked: streak >= 100,
        progress: streak,
        target: 100,
      ),
    ];
  }
}
