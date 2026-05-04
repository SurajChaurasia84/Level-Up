import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          final user = provider.user;
          if (user == null) return const Center(child: CircularProgressIndicator());

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildUserCard(user),
                  const SizedBox(height: 24),
                  _buildStatsGrid(provider),
                  const SizedBox(height: 24),
                  _buildAchievementBanner(),
                  const SizedBox(height: 24),
                  _buildSettingsList(),
                  const SizedBox(height: 24),
                  _buildSignOutButton(),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Profile", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text("Keep going, you're doing great!", style: TextStyle(color: AppTheme.subtitleColor)),
                const Text(" 💪"),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration,
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                backgroundImage: user.avatarUrl.isNotEmpty 
                    ? (user.avatarUrl.startsWith('http') 
                        ? NetworkImage(user.avatarUrl) as ImageProvider
                        : FileImage(File(user.avatarUrl)))
                    : null,
                child: user.avatarUrl.isEmpty 
                    ? const Icon(Icons.person, size: 40, color: AppTheme.primaryColor)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Habit Builder", style: TextStyle(color: AppTheme.subtitleColor)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 14, color: Color(0xFF57636C)),
                    const SizedBox(width: 4),
                    Text(
                      "Joined on ${DateFormat('d MMM yyyy').format(user.joinedDate)}",
                      style: const TextStyle(fontSize: 12, color: Color(0xFF57636C)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.stars_rounded, color: AppTheme.primaryColor),
                Text("Level ${user.level}", style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text("Elite", style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(HabitProvider provider) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard("${provider.currentGlobalStreak}", "Day Streak", "Best: ${provider.currentGlobalStreak} days", const Color(0xFF6F61EF)),
        _buildStatCard("${provider.totalCompletedCount}", "Habits Completed", "All Time", const Color(0xFF39D2C0)),
        _buildStatCard("92%", "Completion Rate", "This Week", const Color(0xFF0091FF)),
        _buildStatCard("Elite", "User Rank", "Habit Master", const Color(0xFFFFB800)),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.premiumCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(sub, style: TextStyle(fontSize: 10, color: AppTheme.subtitleColor)),
        ],
      ),
    );
  }

  Widget _buildAchievementBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, size: 48, color: Colors.amber),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("You're on a roll! 🥳", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Keep your streak alive and unlock more achievements.", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("View"),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Column(
      children: [
        _buildSettingItem(Icons.person_outline, "Personal Information"),
        _buildSettingItem(Icons.notifications_none, "Reminder Settings"),
        _buildSettingItem(Icons.palette_outlined, "App Appearance", trailing: "Light"),
        _buildSettingItem(Icons.shield_outlined, "Privacy & Security"),
        _buildSettingItem(Icons.cloud_upload_outlined, "Backup & Restore"),
        _buildSettingItem(Icons.help_outline, "Help & Support"),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {String? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
          if (trailing != null) ...[
            Text(trailing, style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12)),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF57636C)),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text("Sign Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
