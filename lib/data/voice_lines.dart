import 'package:flutter/material.dart';
import '../models/managed_voice_line.dart';

class VoiceLine {
  final String key;
  final String labelEN;
  final String labelGA;
  final String spokenEN;
  final String spokenGA;
  final String iconName;
  final IconData icon;
  final Color color;

  const VoiceLine({
    required this.key,
    required this.labelEN,
    required this.labelGA,
    required this.spokenEN,
    required this.spokenGA,
    required this.iconName,
    required this.icon,
    required this.color,
  });

  ManagedVoiceLine toManaged({
    required String createdByStaffId,
    required String createdByStaffName,
    int sortOrder = 0,
  }) {
    return ManagedVoiceLine(
      id: '',
      presetKey: key,
      labelEN: labelEN,
      labelGA: labelGA,
      spokenEN: spokenEN,
      spokenGA: spokenGA,
      iconName: iconName,
      colorHex: voiceLineHexFromColor(color),
      active: true,
      sortOrder: sortOrder,
      createdByStaffId: createdByStaffId,
      createdByStaffName: createdByStaffName,
    );
  }
}

IconData voiceLineIconForName(String iconName) {
  return switch (iconName) {
    'toilet' => Icons.wc_rounded,
    'help' => Icons.volunteer_activism_rounded,
    'hurt' => Icons.healing_rounded,
    'break' => Icons.self_improvement_rounded,
    'food' => Icons.restaurant_rounded,
    'drink' => Icons.local_drink_rounded,
    'quiet' => Icons.volume_off_rounded,
    'sick' => Icons.sick_rounded,
    'hot' => Icons.wb_sunny_rounded,
    'cold' => Icons.ac_unit_rounded,
    'happy' => Icons.sentiment_very_satisfied_rounded,
    'sad' => Icons.sentiment_dissatisfied_rounded,
    'angry' => Icons.sentiment_very_dissatisfied_rounded,
    'worried' => Icons.sentiment_neutral_rounded,
    'tired' => Icons.bedtime_rounded,
    'finished' => Icons.check_circle_rounded,
    'yes' => Icons.thumb_up_rounded,
    'no' => Icons.thumb_down_rounded,
    'again' => Icons.replay_rounded,
    'home' => Icons.home_rounded,
    'outside' => Icons.park_rounded,
    'teacher' => Icons.school_rounded,
    _ => Icons.record_voice_over_rounded,
  };
}

Color voiceLineColorFromHex(String hex) {
  final normalized = hex.trim().replaceFirst('#', '');
  final value = int.tryParse('FF$normalized', radix: 16);

  if (value == null || normalized.length != 6) {
    return const Color(0xFF7E57C2);
  }

  return Color(value);
}

String voiceLineHexFromColor(Color color) {
  final value = color.toARGB32();
  final red = ((value >> 16) & 0xFF).toRadixString(16).padLeft(2, '0');
  final green = ((value >> 8) & 0xFF).toRadixString(16).padLeft(2, '0');
  final blue = (value & 0xFF).toRadixString(16).padLeft(2, '0');
  return '#$red$green$blue'.toUpperCase();
}

VoiceLine voiceLineFromManaged(ManagedVoiceLine line) {
  final color = voiceLineColorFromHex(line.colorHex);
  final icon = voiceLineIconForName(line.iconName);

  return VoiceLine(
    key: 'custom_${line.id}',
    labelEN: line.labelEN.trim().isEmpty ? line.spokenEN : line.labelEN,
    labelGA: line.labelGA.trim().isEmpty ? line.labelEN : line.labelGA,
    spokenEN: line.spokenEN.trim().isEmpty ? line.labelEN : line.spokenEN,
    spokenGA: line.spokenGA.trim().isEmpty ? line.spokenEN : line.spokenGA,
    iconName: line.iconName,
    icon: icon,
    color: color,
  );
}

const List<VoiceLine> defaultVoiceLines = [
  VoiceLine(
    key: 'toilet',
    labelEN: 'Toilet',
    labelGA: 'Leithreas',
    spokenEN: 'I need the toilet.',
    spokenGA: 'Tá an leithreas ag teastáil uaim.',
    iconName: 'toilet',
    icon: Icons.wc_rounded,
    color: Color(0xFF42A5F5),
  ),
  VoiceLine(
    key: 'help',
    labelEN: 'Help',
    labelGA: 'Cabhair',
    spokenEN: 'I need help.',
    spokenGA: 'Tá cabhair ag teastáil uaim.',
    iconName: 'help',
    icon: Icons.volunteer_activism_rounded,
    color: Color(0xFFEF5350),
  ),
  VoiceLine(
    key: 'hurt',
    labelEN: 'Hurt',
    labelGA: 'Gortaithe',
    spokenEN: 'I am hurt.',
    spokenGA: 'Tá mé gortaithe.',
    iconName: 'hurt',
    icon: Icons.healing_rounded,
    color: Color(0xFFE53935),
  ),
  VoiceLine(
    key: 'break',
    labelEN: 'Break',
    labelGA: 'Sos',
    spokenEN: 'I need a break.',
    spokenGA: 'Tá sos ag teastáil uaim.',
    iconName: 'break',
    icon: Icons.self_improvement_rounded,
    color: Color(0xFF7E57C2),
  ),
  VoiceLine(
    key: 'hungry',
    labelEN: 'Hungry',
    labelGA: 'Ocras',
    spokenEN: 'I am hungry.',
    spokenGA: 'Tá ocras orm.',
    iconName: 'food',
    icon: Icons.restaurant_rounded,
    color: Color(0xFFFFB300),
  ),
  VoiceLine(
    key: 'thirsty',
    labelEN: 'Thirsty',
    labelGA: 'Tart',
    spokenEN: 'I am thirsty.',
    spokenGA: 'Tá tart orm.',
    iconName: 'drink',
    icon: Icons.local_drink_rounded,
    color: Color(0xFF26A69A),
  ),
];

const List<VoiceLine> addableVoiceLinePresets = [
  VoiceLine(
    key: 'quiet',
    labelEN: 'Quiet',
    labelGA: 'Ciúnas',
    spokenEN: 'I need quiet.',
    spokenGA: 'Tá ciúnas ag teastáil uaim.',
    iconName: 'quiet',
    icon: Icons.volume_off_rounded,
    color: Color(0xFF78909C),
  ),
  VoiceLine(
    key: 'sick',
    labelEN: 'Sick',
    labelGA: 'Tinn',
    spokenEN: 'I feel sick.',
    spokenGA: 'Tá mé tinn.',
    iconName: 'sick',
    icon: Icons.sick_rounded,
    color: Color(0xFFFF7043),
  ),
  VoiceLine(
    key: 'happy',
    labelEN: 'Happy',
    labelGA: 'Sásta',
    spokenEN: 'I feel happy.',
    spokenGA: 'Tá áthas orm.',
    iconName: 'happy',
    icon: Icons.sentiment_very_satisfied_rounded,
    color: Color(0xFF66BB6A),
  ),
  VoiceLine(
    key: 'sad',
    labelEN: 'Sad',
    labelGA: 'Brónach',
    spokenEN: 'I feel sad.',
    spokenGA: 'Tá brón orm.',
    iconName: 'sad',
    icon: Icons.sentiment_dissatisfied_rounded,
    color: Color(0xFF5C6BC0),
  ),
  VoiceLine(
    key: 'angry',
    labelEN: 'Angry',
    labelGA: 'Feargach',
    spokenEN: 'I feel angry.',
    spokenGA: 'Tá fearg orm.',
    iconName: 'angry',
    icon: Icons.sentiment_very_dissatisfied_rounded,
    color: Color(0xFFE53935),
  ),
  VoiceLine(
    key: 'worried',
    labelEN: 'Worried',
    labelGA: 'Buartha',
    spokenEN: 'I feel worried.',
    spokenGA: 'Tá imní orm.',
    iconName: 'worried',
    icon: Icons.sentiment_neutral_rounded,
    color: Color(0xFFAB47BC),
  ),
  VoiceLine(
    key: 'tired',
    labelEN: 'Tired',
    labelGA: 'Tuirseach',
    spokenEN: 'I am tired.',
    spokenGA: 'Tá mé tuirseach.',
    iconName: 'tired',
    icon: Icons.bedtime_rounded,
    color: Color(0xFF5D6D7E),
  ),
  VoiceLine(
    key: 'hot',
    labelEN: 'Hot',
    labelGA: 'Te',
    spokenEN: 'I am too hot.',
    spokenGA: 'Tá mé ró-the.',
    iconName: 'hot',
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFFFFA726),
  ),
  VoiceLine(
    key: 'cold',
    labelEN: 'Cold',
    labelGA: 'Fuar',
    spokenEN: 'I am too cold.',
    spokenGA: 'Tá mé rófhuar.',
    iconName: 'cold',
    icon: Icons.ac_unit_rounded,
    color: Color(0xFF29B6F6),
  ),
  VoiceLine(
    key: 'finished',
    labelEN: 'Finished',
    labelGA: 'Críochnaithe',
    spokenEN: 'I am finished.',
    spokenGA: 'Tá mé críochnaithe.',
    iconName: 'finished',
    icon: Icons.check_circle_rounded,
    color: Color(0xFF43A047),
  ),
  VoiceLine(
    key: 'more_time',
    labelEN: 'More time',
    labelGA: 'Níos mó ama',
    spokenEN: 'I need more time.',
    spokenGA: 'Tá níos mó ama ag teastáil uaim.',
    iconName: 'again',
    icon: Icons.more_time_rounded,
    color: Color(0xFF5E7CE2),
  ),
  VoiceLine(
    key: 'again',
    labelEN: 'Again',
    labelGA: 'Arís',
    spokenEN: 'Can I do it again?',
    spokenGA: 'An féidir liom é a dhéanamh arís?',
    iconName: 'again',
    icon: Icons.replay_rounded,
    color: Color(0xFF26A69A),
  ),
  VoiceLine(
    key: 'yes',
    labelEN: 'Yes',
    labelGA: 'Tá',
    spokenEN: 'Yes.',
    spokenGA: 'Tá.',
    iconName: 'yes',
    icon: Icons.thumb_up_rounded,
    color: Color(0xFF66BB6A),
  ),
  VoiceLine(
    key: 'no',
    labelEN: 'No',
    labelGA: 'Níl',
    spokenEN: 'No.',
    spokenGA: 'Níl.',
    iconName: 'no',
    icon: Icons.thumb_down_rounded,
    color: Color(0xFFEF5350),
  ),
  VoiceLine(
    key: 'dont_know',
    labelEN: "I don't know",
    labelGA: 'Níl a fhios agam',
    spokenEN: "I don't know.",
    spokenGA: 'Níl a fhios agam.',
    iconName: 'voice',
    icon: Icons.question_mark_rounded,
    color: Color(0xFF7E57C2),
  ),
  VoiceLine(
    key: 'teacher',
    labelEN: 'Teacher',
    labelGA: 'Múinteoir',
    spokenEN: 'I need a teacher.',
    spokenGA: 'Tá múinteoir ag teastáil uaim.',
    iconName: 'teacher',
    icon: Icons.school_rounded,
    color: Color(0xFF3949AB),
  ),
  VoiceLine(
    key: 'outside',
    labelEN: 'Outside',
    labelGA: 'Amuigh',
    spokenEN: 'I want to go outside.',
    spokenGA: 'Ba mhaith liom dul amach.',
    iconName: 'outside',
    icon: Icons.park_rounded,
    color: Color(0xFF2E7D32),
  ),
  VoiceLine(
    key: 'home',
    labelEN: 'Home',
    labelGA: 'Abhaile',
    spokenEN: 'I want to go home.',
    spokenGA: 'Ba mhaith liom dul abhaile.',
    iconName: 'home',
    icon: Icons.home_rounded,
    color: Color(0xFF6D4C41),
  ),
  VoiceLine(
    key: 'too_loud',
    labelEN: 'Too loud',
    labelGA: 'Ró-ard',
    spokenEN: 'It is too loud.',
    spokenGA: 'Tá sé ró-ard.',
    iconName: 'quiet',
    icon: Icons.volume_down_rounded,
    color: Color(0xFF78909C),
  ),
  VoiceLine(
    key: 'safe_space',
    labelEN: 'Safe space',
    labelGA: 'Spás sábháilte',
    spokenEN: 'I need my safe space.',
    spokenGA: 'Tá mo spás sábháilte ag teastáil uaim.',
    iconName: 'break',
    icon: Icons.shield_rounded,
    color: Color(0xFF00897B),
  ),
];

@Deprecated('Use defaultVoiceLines instead.')
const List<VoiceLine> voiceLines = defaultVoiceLines;
