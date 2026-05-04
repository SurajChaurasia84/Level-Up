import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData? icon;
  final String? assetPath;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final int progress;
  final int target;
  final String unit;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.icon,
    this.assetPath,
    required this.color,
    this.isUnlocked = false,
    this.unlockedDate,
    this.progress = 0,
    this.target = 1,
    this.unit = "days",
  });

  double get percent => progress / target;
}
