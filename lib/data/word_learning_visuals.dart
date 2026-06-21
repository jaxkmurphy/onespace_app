import 'package:flutter/material.dart';

class WordPackVisualStyle {
  final String key;
  final String label;
  final IconData icon;
  final String colorHex;

  const WordPackVisualStyle({
    required this.key,
    required this.label,
    required this.icon,
    required this.colorHex,
  });

  Color get color => wordPackColorFromHex(colorHex);
}

const List<WordPackVisualStyle> wordPackVisualStyles = [
  WordPackVisualStyle(
    key: 'words',
    label: 'Words',
    icon: Icons.abc_rounded,
    colorHex: '#66BB6A',
  ),
  WordPackVisualStyle(
    key: 'school',
    label: 'School',
    icon: Icons.school_rounded,
    colorHex: '#42A5F5',
  ),
  WordPackVisualStyle(
    key: 'home',
    label: 'Home',
    icon: Icons.home_rounded,
    colorHex: '#FFA726',
  ),
  WordPackVisualStyle(
    key: 'animals',
    label: 'Animals',
    icon: Icons.pets_rounded,
    colorHex: '#8D6E63',
  ),
  WordPackVisualStyle(
    key: 'feelings',
    label: 'Feelings',
    icon: Icons.emoji_emotions_rounded,
    colorHex: '#EC407A',
  ),
  WordPackVisualStyle(
    key: 'world',
    label: 'Our World',
    icon: Icons.public_rounded,
    colorHex: '#26A69A',
  ),
  WordPackVisualStyle(
    key: 'fun',
    label: 'Fun',
    icon: Icons.celebration_rounded,
    colorHex: '#7E57C2',
  ),
];

WordPackVisualStyle wordPackStyleFor(String key) {
  return wordPackVisualStyles.firstWhere(
    (style) => style.key == key,
    orElse: () => wordPackVisualStyles.first,
  );
}

Color wordPackColorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');

  final value = cleaned.length == 6
      ? int.tryParse('FF$cleaned', radix: 16)
      : int.tryParse(cleaned, radix: 16);

  return Color(value ?? 0xFF66BB6A);
}