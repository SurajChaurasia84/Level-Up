import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _habitsKey = 'habits_data';
  static const String _userKey = 'user_profile_data';
  static const String _achievementsKey = 'achievement_dates_data';

  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(habits.map((h) => h.toMap()).toList());
    await prefs.setString(_habitsKey, encodedData);
  }

  Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_habitsKey);
    if (encodedData == null) return [];

    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((item) => Habit.fromMap(item)).toList();
  }

  Future<void> saveUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toJson());
  }

  Future<UserProfile?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_userKey);
    if (encodedData == null) return null;
    return UserProfile.fromJson(encodedData);
  }

  Future<void> saveAchievementDates(Map<String, DateTime> dates) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> encodedDates = dates.map((key, value) => MapEntry(key, value.toIso8601String()));
    await prefs.setString(_achievementsKey, json.encode(encodedDates));
  }

  Future<Map<String, DateTime>> loadAchievementDates() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_achievementsKey);
    if (encodedData == null) return {};

    final Map<String, dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((key, value) => MapEntry(key, DateTime.parse(value)));
  }
}
