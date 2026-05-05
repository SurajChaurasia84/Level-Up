import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReminderModal extends StatefulWidget {
  final String habitName;
  final String habitIcon;
  final int habitColor;
  final String currentReminder;
  final String currentFrequency;
  final List<int>? currentDays;
  final Function(String?, String, List<int>) onSave;

  const ReminderModal({
    super.key,
    required this.habitName,
    required this.habitIcon,
    required this.habitColor,
    required this.currentReminder,
    required this.onSave,
    this.currentFrequency = "Everyday",
    this.currentDays,
  });

  @override
  State<ReminderModal> createState() => _ReminderModalState();
}

class _ReminderModalState extends State<ReminderModal> {
  late TimeOfDay _selectedTime;
  late String _selectedFrequency;
  late List<int> _selectedDays;
  bool _smartReminder = true;

  @override
  void initState() {
    super.initState();
    _selectedTime = _parseTimeString(widget.currentReminder);
    _selectedFrequency = widget.currentFrequency;
    _selectedDays = widget.currentDays != null ? List<int>.from(widget.currentDays!) : [1, 2, 3, 4, 5, 6, 7];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
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
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.notifications_active_rounded, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Set Reminder", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Get reminded to complete your habit on time.", style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
      ],
    );
  }

  Widget _buildHabitSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(widget.habitColor).withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(10)
            ),
            child: Icon(_getIconData(widget.habitIcon), color: Color(widget.habitColor), size: 20),
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
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
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
            _buildRepeatChip("Everyday", Icons.sync, _selectedFrequency == "Everyday"),
            const SizedBox(width: 12),
            _buildRepeatChip("Custom", Icons.calendar_month, _selectedFrequency == "Custom"),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final dayIndex = index + 1; // 1 = Mon, 7 = Sun
            final days = ["M", "T", "W", "T", "F", "S", "S"];
            final isSelected = _selectedDays.contains(dayIndex);
            
            return GestureDetector(
              onTap: _selectedFrequency == "Custom" ? () {
                setState(() {
                  if (isSelected) {
                    if (_selectedDays.length > 1) _selectedDays.remove(dayIndex);
                  } else {
                    _selectedDays.add(dayIndex);
                  }
                });
              } : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    days[index], 
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.subtitleColor, 
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500
                    )
                  )
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRepeatChip(String label, IconData icon, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFrequency = label;
            if (label == "Everyday") {
              _selectedDays = [1, 2, 3, 4, 5, 6, 7];
            } else {
              _selectedDays = []; // Start with unselected for Custom
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppTheme.primaryColor : Colors.black.withValues(alpha: 0.05)),
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
      ),
    );
  }



  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.currentReminder.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                widget.onSave(null, _selectedFrequency, _selectedDays);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
              label: const Text("Remove Reminder", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: AppTheme.subtitleColor.withValues(alpha: 0.1)),
                ),
                child: const Text("Cancel", style: TextStyle(color: Color(0xFF14181B))),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final timeStr = _selectedTime.format(context);
                  widget.onSave(timeStr, _selectedFrequency, _selectedDays);
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
      ],
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

  TimeOfDay _parseTimeString(String timeStr) {
    try {
      final format12 = RegExp(r'(\d+):(\d+)\s*(AM|PM|am|pm)', caseSensitive: false);
      final match12 = format12.firstMatch(timeStr);
      if (match12 != null) {
        int hour = int.parse(match12.group(1)!);
        int minute = int.parse(match12.group(2)!);
        String period = match12.group(3)!.toUpperCase();
        if (period == "PM" && hour < 12) hour += 12;
        if (period == "AM" && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
      final format24 = RegExp(r'(\d+):(\d+)');
      final match24 = format24.firstMatch(timeStr);
      if (match24 != null) {
        return TimeOfDay(hour: int.parse(match24.group(1)!), minute: int.parse(match24.group(2)!));
      }
    } catch (e) {
      debugPrint("Error parsing time string '$timeStr': $e");
    }
    return const TimeOfDay(hour: 7, minute: 0);
  }
}
