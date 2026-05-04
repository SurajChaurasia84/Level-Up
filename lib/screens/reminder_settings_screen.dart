import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class ReminderSettingsScreen extends StatelessWidget {
  const ReminderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Reminder Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Global Notifications",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.subtitleColor),
            ),
            const SizedBox(height: 16),
            _buildTestNotificationButton(context),
            const SizedBox(height: 16),
            _buildSmartReminderTile(context),
            const SizedBox(height: 32),
            const Text(
              "Information",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.subtitleColor),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              "Daily Reminders",
              "Individual habit reminders can be set within each habit card. These will trigger according to your selected time and days.",
              Icons.notifications_active_rounded,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              "Smart Nudges",
              "Smart Reminders are sent at 8:00 PM only if you haven't completed your habit. This ensures you never miss a day without unnecessary alerts.",
              Icons.auto_awesome_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestNotificationButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        await NotificationService().showTestNotification();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Test notification sent! Check your status bar. 🚀")),
          );
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
        ),
        child: const Row(
          children: [
            Icon(Icons.science_rounded, color: AppTheme.primaryColor),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                "Send Test Notification",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartReminderTile(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Smart Reminder",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Evening nudge at 8:00 PM for incomplete habits",
                      style: TextStyle(fontSize: 12, color: AppTheme.subtitleColor),
                    ),
                  ],
                ),
              ),
              Switch(
                value: provider.isSmartReminderEnabled,
                onChanged: (value) => provider.toggleSmartReminders(value),
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.subtitleColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: AppTheme.subtitleColor, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
