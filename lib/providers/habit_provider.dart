import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class HabitProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Habit> _habits = [];
  Map<String, DateTime> _unlockedAchievementDates = {};
  Map<String, List<String>> _diaryEntries = {};
  UserProfile? _user;
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;
  bool _isSmartReminderEnabled = true;

  List<Habit> get habits => _habits;
  Map<String, DateTime> get unlockedAchievementDates => _unlockedAchievementDates;
  UserProfile? get user => _user;
  Map<String, List<String>> get diaryEntries => _diaryEntries;
  bool get isLoading => _isLoading;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isSmartReminderEnabled => _isSmartReminderEnabled;

  int get totalCompletedCount => _habits.fold(0, (sum, h) => sum + h.completedDates.length);
  
  int get currentGlobalStreak {
    if (_habits.isEmpty) return 0;
    // For simplicity, returning the max streak of any habit
    return _habits.map((h) => h.currentStreak).fold(0, (max, streak) => streak > max ? streak : max);
  }

  double get completionRateThisWeek {
    if (_habits.isEmpty) return 0.0;
    
    final now = DateTime.now();
    double totalRatio = 0;
    int daysWithHabits = 0;

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final activeHabits = _habits.where((h) {
        final normalizedCreated = DateTime(h.createdAt.year, h.createdAt.month, h.createdAt.day);
        final normalizedDate = DateTime(date.year, date.month, date.day);
        return normalizedCreated.isBefore(normalizedDate) || normalizedCreated.isAtSameMomentAs(normalizedDate);
      }).toList();

      if (activeHabits.isNotEmpty) {
        daysWithHabits++;
        final completedCount = activeHabits.where((h) => h.isCompletedOn(date)).length;
        totalRatio += completedCount / activeHabits.length;
      }
    }

    return daysWithHabits > 0 ? totalRatio / daysWithHabits : 0.0;
  }
  
  int get userLevel => (totalCompletedCount ~/ 10) + 1;

  String get userRank {
    final count = totalCompletedCount;
    if (count < 10) return "Rookie";
    if (count < 25) return "Amateur";
    if (count < 50) return "Pro";
    if (count < 100) return "Elite";
    if (count < 250) return "Legend";
    if (count < 500) return "Mythic";
    if (count < 1000) return "Immortal";
    return "Grandmaster";
  }

  String get userRankSubtitle {
    final count = totalCompletedCount;
    if (count < 10) return "Just Starting";
    if (count < 25) return "Consistent";
    if (count < 50) return "Habit Hero";
    if (count < 100) return "Habit Master";
    if (count < 250) return "The Ultimate";
    if (count < 500) return "Legendary Status";
    if (count < 1000) return "Godlike Discipline";
    return "The Absolute Best";
  }

  double get completionRateThisMonth {
    if (_habits.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final daysInMonthSoFar = now.day;
    double totalRatio = 0;
    int daysWithHabits = 0;

    for (int i = 1; i <= daysInMonthSoFar; i++) {
      final date = DateTime(now.year, now.month, i);
      final activeHabits = _habits.where((h) {
        final normalizedCreated = DateTime(h.createdAt.year, h.createdAt.month, h.createdAt.day);
        final normalizedDate = DateTime(date.year, date.month, date.day);
        return normalizedCreated.isBefore(normalizedDate) || normalizedCreated.isAtSameMomentAs(normalizedDate);
      }).toList();

      if (activeHabits.isNotEmpty) {
        daysWithHabits++;
        final completedCount = activeHabits.where((h) => h.isCompletedOn(date)).length;
        totalRatio += completedCount / activeHabits.length;
      }
    }

    return daysWithHabits > 0 ? totalRatio / daysWithHabits : 0.0;
  }

  HabitProvider() {
    _init();
  }

  Future<void> _init() async {
    _habits = await _storageService.loadHabits();
    _unlockedAchievementDates = await _storageService.loadAchievementDates();
    _diaryEntries = await _storageService.loadDiaryEntries();
    _user = await _storageService.loadUser();
    
    final prefs = await SharedPreferences.getInstance();
    _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    _isSmartReminderEnabled = prefs.getBool('smart_reminders_enabled') ?? true;
    
    if (_isSmartReminderEnabled) {
      _scheduleGlobalSmartReminder();
    }

    if (_user == null && _hasSeenOnboarding) {
      _user = UserProfile(
        name: "User",
        avatarUrl: "",
        joinedDate: DateTime.now(),
        level: 1,
      );
      await _storageService.saveUser(_user!);
    }

    if (_habits.isEmpty) {
      _habits = [
        Habit(
          id: const Uuid().v4(),
          name: "Morning Exercise",
          description: "30 minutes",
          icon: "directions_run",
          colorValue: Colors.indigo.value,
          createdAt: DateTime.now(),
          completedDates: [],
        ),
        Habit(
          id: const Uuid().v4(),
          name: "Drink Water",
          description: "8 glasses",
          icon: "local_drink",
          colorValue: Colors.blue.value,
          createdAt: DateTime.now(),
          completedDates: [],
        ),
      ];
      await _storageService.saveHabits(_habits);
    }

    _isLoading = false;
    _checkAchievements();
    
    // Schedule all existing reminders on start
    for (var habit in _habits) {
      if (habit.reminderTime != null) {
        final timeOfDay = _parseTimeString(habit.reminderTime!);
        if (timeOfDay != null) {
          NotificationService().scheduleNotification(
            id: habit.id.hashCode,
            title: "Time for ${habit.name}! 🚀",
            body: habit.description.isNotEmpty ? habit.description : "Keep up the good work!",
            scheduledTime: timeOfDay,
            days: habit.reminderDays,
          );
        }
      }
    }
    
    notifyListeners();
  }

  void _checkAchievements() {
    final streak = currentGlobalStreak;
    final total = totalCompletedCount;
    bool changed = false;

    void unlock(String id) {
      if (!_unlockedAchievementDates.containsKey(id)) {
        _unlockedAchievementDates[id] = DateTime.now();
        changed = true;
      }
    }

    if (total >= 1) unlock("first_step");
    if (streak >= 3) unlock("getting_started");
    if (streak >= 7) {
      unlock("consistent");
      unlock("week_warrior");
    }
    if (total >= 50) unlock("dedicated");
    if (streak >= 30) unlock("unstoppable");
    if (total >= 100) unlock("habit_master");
    if (streak >= 100) unlock("legend");

    // On a Roll: All habits completed at least once (simplified) or all today
    if (_habits.isNotEmpty && _habits.every((h) => h.isCompletedOn(DateTime.now()))) {
      unlock("on_a_roll");
    }

    if (changed) {
      _storageService.saveAchievementDates(_unlockedAchievementDates);
    }
  }

  Future<void> addHabit(String name, String desc, String icon, int color) async {
    final habit = Habit(
      id: const Uuid().v4(),
      name: name,
      description: desc,
      icon: icon,
      colorValue: color,
      createdAt: DateTime.now(),
      completedDates: [],
    );
    _habits.add(habit);
    await _storageService.saveHabits(_habits);
    _checkAchievements();
    notifyListeners();
  }

  Future<void> toggleHabitCompletion(String habitId, {DateTime? date}) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final habit = _habits[index];
      final targetDate = date ?? DateTime.now();
      final normalizedDate = DateTime(targetDate.year, targetDate.month, targetDate.day);
      
      List<DateTime> completedDates = List.from(habit.completedDates);
      bool isCompletedOnDate = completedDates.any((d) => 
          d.year == normalizedDate.year && d.month == normalizedDate.month && d.day == normalizedDate.day);

      if (isCompletedOnDate) {
        completedDates.removeWhere((d) => 
            d.year == normalizedDate.year && d.month == normalizedDate.month && d.day == normalizedDate.day);
      } else {
        completedDates.add(normalizedDate);
      }

      _habits[index] = habit.copyWith(completedDates: completedDates);
      await _storageService.saveHabits(_habits);
      _checkAchievements();
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);
    await _storageService.saveHabits(_habits);
    _checkAchievements();
    notifyListeners();
  }

  Future<void> completeOnboarding(String name, String imagePath) async {
    _user = UserProfile(
      name: name,
      avatarUrl: imagePath,
      joinedDate: DateTime.now(),
      level: 1,
    );
    await _storageService.saveUser(_user!);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    _hasSeenOnboarding = true;
    
    notifyListeners();
  }

  Future<void> updateReminder(String habitId, String? time, {List<int>? days}) async {
    debugPrint("[HabitProvider] updateReminder called for $habitId with time: $time");
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final habit = _habits[index];
      
      // Directly creating a new object to ensure null time is respected
      _habits[index] = Habit(
        id: habit.id,
        name: habit.name,
        description: habit.description,
        icon: habit.icon,
        colorValue: habit.colorValue,
        createdAt: habit.createdAt,
        completedDates: habit.completedDates,
        reminderTime: time,
        reminderDays: days,
        frequency: habit.frequency,
      );
      
      await _storageService.saveHabits(_habits);
      
      if (time != null) {
        final timeOfDay = _parseTimeString(time);
        if (timeOfDay != null) {
          debugPrint("[HabitProvider] Time parsed successfully: ${timeOfDay.hour}:${timeOfDay.minute}");
          await NotificationService().scheduleNotification(
            id: habit.id.hashCode,
            title: "Time for ${habit.name}! 🚀",
            body: habit.description.isNotEmpty ? habit.description : "Keep the streak alive!",
            scheduledTime: timeOfDay,
            days: days,
          );
        } else {
          debugPrint("[HabitProvider] ERROR: Failed to parse time string: $time");
        }
      } else {
        debugPrint("[HabitProvider] Removing reminder for $habitId");
        await NotificationService().cancelNotification(habit.id.hashCode);
      }
      
      notifyListeners();
    }
  }

  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      // Normalize: trim, remove double spaces, and ensure no hidden characters (like non-breaking spaces)
      String cleanTime = timeStr.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
      
      debugPrint("[HabitProvider] Parsing cleaned time: '$cleanTime'");

      // 1. Try 12-hour format with AM/PM (e.g., "07:00 AM", "7:00PM", "12:30 AM")
      final amPmMatch = RegExp(r'(\d+):(\d+)\s*(AM|PM)').firstMatch(cleanTime);
      if (amPmMatch != null) {
        int hour = int.parse(amPmMatch.group(1)!);
        int minute = int.parse(amPmMatch.group(2)!);
        String period = amPmMatch.group(3)!;

        if (period == "PM" && hour < 12) hour += 12;
        if (period == "AM" && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }

      // 2. Try 24-hour format (e.g., "14:30" or "07:00")
      final twentyFourMatch = RegExp(r'(\d+):(\d+)').firstMatch(cleanTime);
      if (twentyFourMatch != null) {
        int hour = int.parse(twentyFourMatch.group(1)!);
        int minute = int.parse(twentyFourMatch.group(2)!);
        if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      debugPrint("[HabitProvider] Parse error for '$timeStr': $e");
    }
    return null;
  }

  Future<void> saveDiaryEntry(DateTime date, String entry) async {
    final dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    if (!_diaryEntries.containsKey(dateKey)) {
      _diaryEntries[dateKey] = [];
    }
    _diaryEntries[dateKey]!.add(entry);
    await _storageService.saveDiaryEntries(_diaryEntries);
    notifyListeners();
  }

  Future<void> deleteDiaryEntry(DateTime date, int index) async {
    final dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    if (_diaryEntries.containsKey(dateKey) && index >= 0 && index < _diaryEntries[dateKey]!.length) {
      _diaryEntries[dateKey]!.removeAt(index);
      await _storageService.saveDiaryEntries(_diaryEntries);
      notifyListeners();
    }
  }

  List<String> getDiaryEntries(DateTime date) {
    final dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return _diaryEntries[dateKey] ?? [];
  }

  String getLatestDiaryEntry(DateTime date) {
    final entries = getDiaryEntries(date);
    return entries.isNotEmpty ? entries.last : "";
  }
  Future<void> updateUserProfile(String name, String? imagePath) async {
    if (_user != null) {
      _user = _user!.copyWith(
        name: name,
        avatarUrl: imagePath ?? _user!.avatarUrl,
      );
      await _storageService.saveUser(_user!);
      notifyListeners();
    }
  }
  Future<void> toggleSmartReminders(bool value) async {
    _isSmartReminderEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('smart_reminders_enabled', value);
    
    if (value) {
      _scheduleGlobalSmartReminder();
    } else {
      // Cancel the global smart reminder (using a fixed ID 9999)
      NotificationService().cancelNotification(9999);
    }
    
    notifyListeners();
  }

  Future<void> _scheduleGlobalSmartReminder() async {
    if (!_isSmartReminderEnabled) return;

    // Check if there are incomplete habits for today
    final now = DateTime.now();
    final hasIncomplete = _habits.any((h) => !h.isCompletedOn(now));

    if (hasIncomplete) {
      await NotificationService().scheduleNotification(
        id: 9999,
        title: "Smart Reminder 🌙",
        body: "You still have habits to complete! Don't break your streak.",
        scheduledTime: const TimeOfDay(hour: 20, minute: 0), // 8:00 PM
      );
      debugPrint("[HabitProvider] Global smart reminder scheduled for 8:00 PM");
    } else {
      debugPrint("[HabitProvider] All habits completed, skipping smart reminder.");
      await NotificationService().cancelNotification(9999);
    }
  }
}