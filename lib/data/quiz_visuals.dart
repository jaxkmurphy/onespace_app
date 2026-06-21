import 'package:flutter/material.dart';

class QuizVisualStyle {
  final String key;
  final String label;
  final IconData icon;
  final String colorHex;

  const QuizVisualStyle({
    required this.key,
    required this.label,
    required this.icon,
    required this.colorHex,
  });

  Color get color => quizColorFromHex(colorHex);
}

const List<QuizVisualStyle> quizVisualStyles = [
  QuizVisualStyle(
    key: 'quiz',
    label: 'General',
    icon: Icons.help_center_rounded,
    colorHex: '#7E57C2',
  ),
  QuizVisualStyle(
    key: 'numbers',
    label: 'Numbers',
    icon: Icons.calculate_rounded,
    colorHex: '#42A5F5',
  ),
  QuizVisualStyle(
    key: 'words',
    label: 'Words',
    icon: Icons.abc_rounded,
    colorHex: '#26A69A',
  ),
  QuizVisualStyle(
    key: 'science',
    label: 'Science',
    icon: Icons.science_rounded,
    colorHex: '#FF7043',
  ),
  QuizVisualStyle(
    key: 'world',
    label: 'Our World',
    icon: Icons.public_rounded,
    colorHex: '#66BB6A',
  ),
  QuizVisualStyle(
    key: 'memory',
    label: 'Memory',
    icon: Icons.psychology_rounded,
    colorHex: '#5C6BC0',
  ),
  QuizVisualStyle(
    key: 'fun',
    label: 'Fun',
    icon: Icons.celebration_rounded,
    colorHex: '#EC407A',
  ),
];

QuizVisualStyle quizStyleFor(String key) {
  return quizVisualStyles.firstWhere(
    (style) => style.key == key,
    orElse: () => quizVisualStyles.first,
  );
}

Color quizColorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');

  final value = cleaned.length == 6
      ? int.tryParse('FF$cleaned', radix: 16)
      : int.tryParse(cleaned, radix: 16);

  return Color(value ?? 0xFF7E57C2);
}