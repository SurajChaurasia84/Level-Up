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
            final achievements = _getAchievements(provider, provider.unlockedAchievementDates);
            final unlocked = achievements.where((a) => a.isUnlocked).toList();
            final locked = achievements.where((a) => !a.isUnlocked).toList();

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Achievements",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF14181B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Celebrate your milestones and progress",
                          style: TextStyle(color: AppTheme.subtitleColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
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


  Widget _buildHeaderCard(int unlockedCount, int totalCount, int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: AppTheme.premiumCardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          // Left: Trophy
          Image.asset('assets/trophy-star.png', height: 50, width: 50),
          
          const SizedBox(width: 16),
          // Middle: Achievements Unlocked
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$unlockedCount ",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF14181B)),
                      ),
                      TextSpan(
                        text: "/ $totalCount",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.subtitleColor),
                      ),
                    ],
                  ),
                ),
                const Text(
                  "Achievements\nUnlocked",
                  style: TextStyle(color: Color(0xFF57636C), fontSize: 13, height: 1.2, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Vertical Divider
          Container(
            height: 40,
            width: 1,
            color: Colors.black12,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // Right: Streak Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/fire.png', height: 24, width: 24),
                  const SizedBox(width: 4),
                  Text(
                    "$streak",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF14181B)),
                  ),
                ],
              ),
              const Text(
                "Day Streak",
                style: TextStyle(color: Color(0xFF57636C), fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(width: 24), // Add some space at the end
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
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Row 1: Icon, Info, Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: achievement.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: achievement.assetPath != null
                    ? Image.asset(
                        achievement.assetPath!,
                        height: 28,
                        width: 28,
                        color: isUnlocked ? null : Colors.black.withOpacity(0.3),
                        colorBlendMode: isUnlocked ? null : BlendMode.srcIn,
                      )
                    : Icon(
                        achievement.icon,
                        color: isUnlocked ? achievement.color : achievement.color.withOpacity(0.4),
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
                        color: isUnlocked ? AppTheme.textColor : AppTheme.textColor.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      achievement.description,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: AppTheme.subtitleColor.withOpacity(isUnlocked ? 1 : 0.6),
                      ),
                    ),
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
                Icon(Icons.lock_outline_rounded, color: Colors.grey.withOpacity(0.6), size: 20),
            ],
          ),
          
          // Row 2: Progress (Only for Locked)
          if (!isUnlocked && achievement.target > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: achievement.percent.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${achievement.progress}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: achievement.progress > 0 
                              ? AppTheme.primaryColor 
                              : AppTheme.textColor.withOpacity(0.7),
                        ),
                      ),
                      TextSpan(
                        text: " / ${achievement.target} ${achievement.unit}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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

  List<Achievement> _getAchievements(HabitProvider provider, Map<String, DateTime> unlockedDates) {
    final streak = provider.currentGlobalStreak;
    final total = provider.totalCompletedCount;
    
    return [
      Achievement(
        id: "first_step",
        title: "First Step",
        description: "Complete your first habit",
        icon: Icons.eco_rounded,
        color: Colors.green,
        isUnlocked: total >= 1,
        progress: total,
        target: 1,
        unit: "",
        unlockedDate: unlockedDates["first_step"],
      ),
      Achievement(
        id: "getting_started",
        title: "Getting Started",
        description: "Maintain a 3 day streak",
        assetPath: "assets/fire.png",
        color: Colors.orange,
        isUnlocked: streak >= 3,
        progress: streak,
        target: 3,
        unlockedDate: unlockedDates["getting_started"],
      ),
      Achievement(
        id: "consistent",
        title: "Consistent",
        description: "Maintain a 7 day streak",
        icon: Icons.stars_rounded,
        color: Colors.indigo,
        isUnlocked: streak >= 7,
        progress: streak,
        target: 7,
        unlockedDate: unlockedDates["consistent"],
      ),
      Achievement(
        id: "on_a_roll",
        title: "On a Roll",
        description: "Complete all habits in a day",
        icon: Icons.track_changes_rounded,
        color: Colors.blue,
        isUnlocked: unlockedDates.containsKey("on_a_roll"),
        progress: unlockedDates.containsKey("on_a_roll") ? 1 : 0,
        target: 1,
        unlockedDate: unlockedDates["on_a_roll"],
      ),
      Achievement(
        id: "dedicated",
        title: "Dedicated",
        description: "Complete 50 habits total",
        icon: Icons.emoji_events_rounded,
        color: Colors.amber,
        isUnlocked: total >= 50,
        progress: total,
        target: 50,
        unit: "",
        unlockedDate: unlockedDates["dedicated"],
      ),
      Achievement(
        id: "week_warrior",
        title: "Week Warrior",
        description: "Use the app 7 days in a row",
        icon: Icons.calendar_month_rounded,
        color: Colors.pink,
        isUnlocked: streak >= 7,
        progress: streak,
        target: 7,
        unlockedDate: unlockedDates["week_warrior"],
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
        unlockedDate: unlockedDates["unstoppable"],
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
        unit: "",
        unlockedDate: unlockedDates["habit_master"],
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
        unlockedDate: unlockedDates["legend"],
      ),
    ];
  }
}
