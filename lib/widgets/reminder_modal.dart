import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReminderModal extends StatefulWidget {
  final String habitName;
  final String currentReminder;
  final Function(String) onSave;

  const ReminderModal({
    super.key,
    required this.habitName,
    required this.currentReminder,
    required this.onSave,
  });

  @override
  State<ReminderModal> createState() => _ReminderModalState();
}

class _ReminderModalState extends State<ReminderModal> {
  late TimeOfDay _selectedTime;
  String _selectedFrequency = "Everyday";
  bool _smartReminder = true;

  @override
  void initState() {
    super.initState();
    // Parse currentReminder if possible, else default to 07:00 AM
    _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.notifications_active_rounded, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Set Reminder", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Get reminded to complete your habit on time.", style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          _buildHabitSelector(),
          const SizedBox(height: 24),
          const Text("Time", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildTimePicker(),
          const SizedBox(height: 24),
          const Text("Repeat", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildRepeatOptions(),
          const SizedBox(height: 24),
          _buildSmartReminderToggle(),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: AppTheme.subtitleColor.withOpacity(0.1)),
                  ),
                  child: const Text("Cancel", style: TextStyle(color: Color(0xFF14181B))),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final timeStr = _selectedTime.format(context);
                    widget.onSave(timeStr);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Save Reminder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHabitSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.directions_run_rounded, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Habit", style: TextStyle(fontSize: 10, color: Color(0xFF57636C))),
              Text(widget.habitName, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: _selectedTime);
        if (time != null) setState(() => _selectedTime = time);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 12),
                Text(_selectedTime.format(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatOptions() {
    return Column(
      children: [
        Row(
          children: [
            _buildRepeatChip("Everyday", Icons.sync, true),
            const SizedBox(width: 12),
            _buildRepeatChip("Custom", Icons.calendar_month, false),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ["M", "T", "W", "T", "F", "S", "S"].map((day) {
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Center(child: Text(day, style: TextStyle(color: AppTheme.subtitleColor, fontWeight: FontWeight.w500))),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRepeatChip(String label, IconData icon, bool selected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppTheme.primaryColor : Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : AppTheme.subtitleColor, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: selected ? Colors.white : AppTheme.subtitleColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartReminderToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("Smart Reminder", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Text("NEW", style: TextStyle(fontSize: 8, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text("Remind me if I haven't completed by 8:00 PM", style: TextStyle(fontSize: 10, color: Color(0xFF57636C))),
              ],
            ),
          ),
          Switch(
            value: _smartReminder,
            onChanged: (v) => setState(() => _smartReminder = v),
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}
