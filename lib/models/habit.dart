import 'dart:convert';

class Habit {
  final String id;
  final String name;
  final String description;
  final String icon; // Icon name string
  final int colorValue;
  final DateTime createdAt;
  final List<DateTime> completedDates;
  final String? reminderTime; // e.g., "07:00 AM"
  final String frequency; // e.g., "Everyday"

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.colorValue,
    required this.createdAt,
    required this.completedDates,
    this.reminderTime,
    this.frequency = "Everyday",
  });

  bool isCompletedToday() {
    final now = DateTime.now();
    return completedDates.any((date) =>
        date.year == now.year && date.month == now.month && date.day == now.day);
  }

  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    
    final sortedDates = List<DateTime>.from(completedDates)..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    // Normalize checkDate to midnight
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    // If not completed today, check from yesterday
    if (!isCompletedToday()) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    for (var date in sortedDates) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (normalizedDate == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (normalizedDate.isBefore(checkDate)) {
        break;
      }
    }
    return streak;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
      'reminderTime': reminderTime,
      'frequency': frequency,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
      colorValue: map['colorValue'],
      createdAt: DateTime.parse(map['createdAt']),
      completedDates: (map['completedDates'] as List)
          .map((d) => DateTime.parse(d))
          .toList(),
      reminderTime: map['reminderTime'],
      frequency: map['frequency'] ?? "Everyday",
    );
  }

  String toJson() => json.encode(toMap());

  factory Habit.fromJson(String source) => Habit.fromMap(json.decode(source));

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? colorValue,
    DateTime? createdAt,
    List<DateTime>? completedDates,
    String? reminderTime,
    String? frequency,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
      reminderTime: reminderTime ?? this.reminderTime,
      frequency: frequency ?? this.frequency,
    );
  }
}
