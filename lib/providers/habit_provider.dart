import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class HabitProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Habit> _habits = [];
  UserProfile? _user;
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;

  List<Habit> get habits => _habits;
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
    notifyListeners();
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
    notifyListeners();
  }

  Future<void> toggleHabitCompletion(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final habit = _habits[index];
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      List<DateTime> completedDates = List.from(habit.completedDates);
      bool isCompletedToday = completedDates.any((d) => 
          d.year == today.year && d.month == today.month && d.day == today.day);

      if (isCompletedToday) {
        completedDates.removeWhere((d) => 
            d.year == today.year && d.month == today.month && d.day == today.day);
      } else {
        completedDates.add(today);
      }

      _habits[index] = habit.copyWith(completedDates: completedDates);
      await _storageService.saveHabits(_habits);
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
