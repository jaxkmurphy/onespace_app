import 'package:flutter/material.dart';

class WhenThenIconStyle {
  final String key;
  final IconData icon;
  final Color color;

  const WhenThenIconStyle({
    required this.key,
    required this.icon,
    required this.color,
  });
}

const List<WhenThenIconStyle> whenThenIconStyles = [
  WhenThenIconStyle(
    key: 'task',
    icon: Icons.task_alt_rounded,
    color: Color(0xFF5C6BC0),
  ),
  WhenThenIconStyle(
    key: 'quiz',
    icon: Icons.quiz_rounded,
    color: Color(0xFF7E57C2),
  ),
  WhenThenIconStyle(
    key: 'book',
    icon: Icons.menu_book_rounded,
    color: Color(0xFF42A5F5),
  ),
  WhenThenIconStyle(
    key: 'clean',
    icon: Icons.cleaning_services_rounded,
    color: Color(0xFF26A69A),
  ),
  WhenThenIconStyle(
    key: 'music',
    icon: Icons.music_note_rounded,
    color: Color(0xFFEC407A),
  ),
  WhenThenIconStyle(
    key: 'toys',
    icon: Icons.toys_rounded,
    color: Color(0xFFFFA726),
  ),
  WhenThenIconStyle(
    key: 'outside',
    icon: Icons.park_rounded,
    color: Color(0xFF66BB6A),
  ),
  WhenThenIconStyle(
    key: 'break',
    icon: Icons.free_breakfast_rounded,
    color: Color(0xFF8D6E63),
  ),
];

String _normaliseWhenThenIconKey(String key) {
  switch (key) {
    case 'homework':
      return 'book';
    case 'clean_up':
      return 'clean';
    case 'finish_work':
      return 'task';
    case 'calming_sounds':
      return 'music';
    case 'playtime':
      return 'toys';
    case 'outside_time':
      return 'outside';
    default:
      return key;
  }
}

WhenThenIconStyle whenThenStyleFor(String key) {
  final normalisedKey = _normaliseWhenThenIconKey(key);

  return whenThenIconStyles.firstWhere(
    (style) => style.key == normalisedKey,
    orElse: () => whenThenIconStyles.first,
  );
}

IconData whenThenIconFor(String key) {
  return whenThenStyleFor(key).icon;
}

Color whenThenColorFor(String key) {
  return whenThenStyleFor(key).color;
}