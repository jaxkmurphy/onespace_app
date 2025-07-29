import 'package:flutter/material.dart';

class VoiceLine {
  final String key;
  final String labelEN;
  final String labelGA;
  final String audioEN;
  final String audioGA;
  final IconData icon;

  VoiceLine({
    required this.key,
    required this.labelEN,
    required this.labelGA,
    required this.audioEN,
    required this.audioGA,
    required this.icon,
  });
}

final List<VoiceLine> voiceLines = [
  VoiceLine(
    key: 'toilet',
    labelEN: 'Toilet',
    labelGA: 'Leithreas',
    audioEN: 'assets/audio/en/toilet.mp3',
    audioGA: 'assets/audio/ga/toilet.mp3',
    icon: Icons.wc,
  ),
  
];