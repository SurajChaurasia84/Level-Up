import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class AddHabitModal extends StatefulWidget {
  const AddHabitModal({super.key});

  @override
  State<AddHabitModal> createState() => _AddHabitModalState();
}

class _AddHabitModalState extends State<AddHabitModal> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedIcon = 'star';
  Color _selectedColor = AppTheme.primaryColor;

  final List<String> _icons = [
    'star',
    'directions_run',
    'local_drink',
    'menu_book',
    'fitness_center',
    'self_improvement',
    'nightlight_round',
    'restaurant',
    'code',
    'payments',
  ];

  final List<Color> _colors = [
    AppTheme.primaryColor,
    const Color(0xFF39D2C0),
    const Color(0xFFEE8B60),
    const Color(0xFF24D1E3),
    const Color(0xFF616161),
    const Color(0xFFD9D9D9),
    const Color(0xFF4B39EF),
    const Color(0xFFFF5963),
  ];

  IconData _getIconData(String name) {
    switch (name) {
      case 'directions_run': return Icons.directions_run;
      case 'local_drink': return Icons.local_drink;
      case 'menu_book': return Icons.menu_book;
      case 'fitness_center': return Icons.fitness_center;
      case 'self_improvement': return Icons.self_improvement;
      case 'nightlight_round': return Icons.nightlight_round;
      case 'restaurant': return Icons.restaurant;
      case 'code': return Icons.code;
      case 'payments': return Icons.payments;
      default: return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add New Habit",
                style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(fontSize: 24),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Habit Name",
              hintText: "e.g. Read for 20 mins",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: "Goal/Description",
              hintText: "e.g. Daily progress",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          const Text("Select Icon", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _icons.length,
              itemBuilder: (context, index) {
                final iconName = _icons[index];
                final isSelected = _selectedIcon == iconName;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = iconName),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconData(iconName),
                      color: isSelected ? AppTheme.primaryColor : Colors.black54,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text("Select Color", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _colors.length,
              itemBuilder: (context, index) {
                final color = _colors[index];
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  context.read<HabitProvider>().addHabit(
                    _nameController.text,
                    _descController.text,
                    _selectedIcon,
                    _selectedColor.value,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Create Habit", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
