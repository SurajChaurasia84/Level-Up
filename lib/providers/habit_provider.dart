import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class HabitProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Habit> _habits = [];
  Map<String, DateTime> _unlockedAchievementDates = {};
  UserProfile? _user;
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;

  List<Habit> get habits => _habits;
  Map<String, DateTime> get unlockedAchievementDates => _unlockedAchievementDates;
  UserProfile? get user => _user;
  bool get isLoading => _isLoading;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  int get totalCompletedCount => _habits.fold(0, (sum, h) => sum + h.completedDates.length);
  
  int get currentGlobalStreak {
    if (_habits.isEmpty) return 0;
    // For simplicity, returning the max streak of any habit
    return _habits.map((h) => h.currentStreak).fold(0, (max, streak) => streak > max ? streak : max);
  }

  double get completionRateThisWeek {
    // Simple mock calculation
    return 0.92;
  }

  HabitProvider() {
    _init();
  }

  Future<void> _init() async {
    _habits = await _storageService.loadHabits();
    _unlockedAchievementDates = await _storageService.loadAchievementDates();
    _user = await _storageService.loadUser();
    
    final prefs = await SharedPreferences.getInstance();
    _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

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
          completedDates: [DateTime.now()],
          reminderTime: "07:00 AM",
        ),
        Habit(
          id: const Uuid().v4(),
          name: "Drink Water",
          description: "8 glasses",
          icon: "local_drink",
          colorValue: Colors.blue.value,
          createdAt: DateTime.now(),
          completedDates: [],
          reminderTime: "08:00 AM",
        ),
      ];
      await _storageService.saveHabits(_habits);
    }

    _isLoading = false;
    _checkAchievements(); // Check for any achievements earned while offline or first run
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

  Future<void> updateReminder(String habitId, String? time) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(reminderTime: time);
      await _storageService.saveHabits(_habits);
      notifyListeners();
    }
  }
}
