import 'package:flutter/material.dart';

class VoiceLine {
  final String key;
  final String labelEN;
  final String labelGA;
  final String spokenEN;
  final String spokenGA;
  final IconData icon;
  final Color color;

  const VoiceLine({
    required this.key,
    required this.labelEN,
    required this.labelGA,
    required this.spokenEN,
    required this.spokenGA,
    required this.icon,
    required this.color,
  });
}

final List<VoiceLine> voiceLines = [
  VoiceLine(
    key: 'toilet',
    labelEN: 'Toilet',
    labelGA: 'Leithreas',
    spokenEN: 'I need the toilet.',
    spokenGA: 'Tá an leithreas ag teastáil uaim.',
    icon: Icons.wc_rounded,
    color: Color(0xFF42A5F5),
  ),
  VoiceLine(
    key: 'help',
    labelEN: 'Help',
    labelGA: 'Cabhair',
    spokenEN: 'I need help.',
    spokenGA: 'Tá cabhair ag teastáil uaim.',
    icon: Icons.volunteer_activism_rounded,
    color: Color(0xFFEF5350),
  ),
  VoiceLine(
    key: 'break',
    labelEN: 'Break',
    labelGA: 'Sos',
    spokenEN: 'I need a break.',
    spokenGA: 'Tá sos ag teastáil uaim.',
    icon: Icons.self_improvement_rounded,
    color: Color(0xFF7E57C2),
  ),
  VoiceLine(
    key: 'sick',
    labelEN: 'Sick',
    labelGA: 'Tinn',
    spokenEN: 'I feel sick.',
    spokenGA: 'Tá mé tinn.',
    icon: Icons.sick_rounded,
    color: Color(0xFFFF7043),
  ),
  VoiceLine(
    key: 'hungry',
    labelEN: 'Hungry',
    labelGA: 'Ocras',
    spokenEN: 'I am hungry.',
    spokenGA: 'Tá ocras orm.',
    icon: Icons.restaurant_rounded,
    color: Color(0xFFFFB300),
  ),
  VoiceLine(
    key: 'thirsty',
    labelEN: 'Thirsty',
    labelGA: 'Tart',
    spokenEN: 'I am thirsty.',
    spokenGA: 'Tá tart orm.',
    icon: Icons.local_drink_rounded,
    color: Color(0xFF26A69A),
  ),
  VoiceLine(
    key: 'quiet',
    labelEN: 'Quiet',
    labelGA: 'Ciúnas',
    spokenEN: 'I need quiet.',
    spokenGA: 'Tá ciúnas ag teastáil uaim.',
    icon: Icons.volume_off_rounded,
    color: Color(0xFF78909C),
  ),
  VoiceLine(
    key: 'sad',
    labelEN: 'Sad',
    labelGA: 'Brónach',
    spokenEN: 'I feel sad.',
    spokenGA: 'Tá brón orm.',
    icon: Icons.sentiment_dissatisfied_rounded,
    color: Color(0xFF5C6BC0),
  ),
  VoiceLine(
    key: 'angry',
    labelEN: 'Angry',
    labelGA: 'Feargach',
    spokenEN: 'I feel angry.',
    spokenGA: 'Tá fearg orm.',
    icon: Icons.sentiment_very_dissatisfied_rounded,
    color: Color(0xFFE53935),
  ),
  VoiceLine(
    key: 'happy',
    labelEN: 'Happy',
    labelGA: 'Sásta',
    spokenEN: 'I feel happy.',
    spokenGA: 'Tá áthas orm.',
    icon: Icons.sentiment_very_satisfied_rounded,
    color: Color(0xFF66BB6A),
  ),
];