import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/habit_provider.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import 'achievements_screen.dart';
import 'personal_info_screen.dart';
import 'reminder_settings_screen.dart';

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
                  _buildUserCard(context, user, provider),
                  const SizedBox(height: 24),
                  _buildStatsGrid(provider),
                  const SizedBox(height: 24),
                  _buildAchievementBanner(context),
                  const SizedBox(height: 24),
                  _buildSettingsList(),
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
        const Text("Profile", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF14181B))),
        const SizedBox(height: 4),
        Row(
          children: [
            Text("Keep going, you're doing great!", style: TextStyle(color: AppTheme.subtitleColor)),
            const Text(" 💪"),
          ],
        ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, UserProfile user, HabitProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showImagePreview(context, user),
            child: CircleAvatar(
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name, 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
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
                Text("Level ${provider.userLevel}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  provider.userRank, 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10),
                ),
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
        _buildStatCard("${(provider.completionRateThisWeek * 100).toInt()}%", "Completion Rate", "This Week", const Color(0xFF0091FF)),
        _buildStatCard(provider.userRank, "User Rank", provider.userRankSubtitle, const Color(0xFFFFB800)),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value, 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            sub, 
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: AppTheme.subtitleColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBanner(BuildContext context) {
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AchievementsScreen()),
              );
            },
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
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final packageInfo = snapshot.data;
        final version = packageInfo?.version ?? '1.0.0';
        final packageName = packageInfo?.packageName ?? 'com.levelup.habittracker.app';

        return Column(
          children: [
            _buildSettingItem(
              Icons.person_outline, 
              "Personal Information",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
                );
              },
            ),
            _buildSettingItem(
              Icons.notifications_none, 
              "Reminder Settings",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReminderSettingsScreen()),
                );
              },
            ),
            _buildSettingItem(
              Icons.shield_outlined, 
              "Privacy Policy",
              onTap: () async {
                final Uri url = Uri.parse('https://pages.flycricket.io/level-up-elite/privacy.html');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
            _buildSettingItem(
              Icons.share_outlined, 
              "Share App",
              onTap: () {
                Share.share(
                  'Check out Level Up! 🚀 The most premium habit tracker to level up your life. Download now and start your streak!\n\nDownload Link: https://play.google.com/store/apps/details?id=com.levelup.habittracker.app',
                  subject: 'Level Up - Elite Habit Tracker',
                );
              },
            ),
            _buildSettingItem(
              Icons.help_outline, 
              "Help & Support",
              onTap: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'fardeensyed63@gmail.com',
                  query: 'subject=${Uri.encodeComponent("Level Up - Elite Habit Tracker")}',
                );
                if (await canLaunchUrl(emailLaunchUri)) {
                  await launchUrl(emailLaunchUri);
                }
              },
            ),
            _buildSettingItem(
              Icons.info_outline, 
              "App Info", 
              trailing: "v$version", 
              showChevron: false
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {String? trailing, bool showChevron = true, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, size: 24, color: AppTheme.primaryColor),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title, 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF14181B)),
                ),
              ),
              if (trailing != null) ...[
                Text(trailing, style: TextStyle(color: AppTheme.subtitleColor, fontSize: 14)),
                const SizedBox(width: 10),
              ],
              if (showChevron)
                const Icon(Icons.chevron_right, size: 22, color: Color(0xFF57636C)),
            ],
          ),
        ),
      ),
    );
  }
  void _showImagePreview(BuildContext context, UserProfile user) {
    if (user.avatarUrl.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            Hero(
              tag: 'profile_pic',
              child: InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: user.avatarUrl.startsWith('http')
                      ? Image.network(user.avatarUrl, fit: BoxFit.contain)
                      : Image.file(File(user.avatarUrl), fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
