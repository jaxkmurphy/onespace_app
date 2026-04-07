import 'package:flutter/material.dart';

class ProfileUnlockIconOption {
  final String keyName;
  final IconData icon;
  final String label;

  const ProfileUnlockIconOption({
    required this.keyName,
    required this.icon,
    required this.label,
  });
}

const List<ProfileUnlockIconOption> profileUnlockIcons = [
  ProfileUnlockIconOption(keyName: 'star', icon: Icons.star, label: 'Star'),
  ProfileUnlockIconOption(keyName: 'car', icon: Icons.directions_car, label: 'Car'),
  ProfileUnlockIconOption(keyName: 'dog', icon: Icons.pets, label: 'Dog'),
  ProfileUnlockIconOption(keyName: 'apple', icon: Icons.apple, label: 'Apple'),
  ProfileUnlockIconOption(keyName: 'ball', icon: Icons.sports_soccer, label: 'Ball'),
  ProfileUnlockIconOption(keyName: 'music', icon: Icons.music_note, label: 'Music'),
  ProfileUnlockIconOption(keyName: 'sun', icon: Icons.wb_sunny, label: 'Sun'),
  ProfileUnlockIconOption(keyName: 'heart', icon: Icons.favorite, label: 'Heart'),
];