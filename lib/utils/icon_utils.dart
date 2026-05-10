import 'package:flutter/material.dart';

class IconUtils {
  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star_rounded;
      case 'directions_run':
        return Icons.directions_run_rounded;
      case 'local_drink':
        return Icons.local_drink_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'self_improvement':
        return Icons.self_improvement_rounded;
      case 'nightlight_round':
        return Icons.nightlight_round_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'payments':
        return Icons.payments_rounded;
      case 'pool':
        return Icons.pool_rounded;
      case 'pedal_bike':
        return Icons.pedal_bike_rounded;
      case 'brush':
        return Icons.brush_rounded;
      case 'language':
        return Icons.language_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'pets':
        return Icons.pets_rounded;
      case 'sunny':
        return Icons.sunny;
      case 'music_note':
        return Icons.music_note_rounded;
      case 'hiking':
        return Icons.hiking_rounded;
      case 'book':
        return Icons.book_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  static const List<String> availableIcons = [
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
    'pool',
    'pedal_bike',
    'brush',
    'language',
    'spa',
    'work',
    'pets',
    'sunny',
    'music_note',
    'hiking',
    'book',
  ];
}
