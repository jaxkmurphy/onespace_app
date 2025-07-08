import 'package:flutter/material.dart';

class SimpleLocalizations {
  final Locale locale;

  SimpleLocalizations(this.locale);

  static final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'save_pin': 'Save PIN',
      'select_language': 'Select Language',
      'pin_set': 'PIN is set',
      'pin_not_set': 'No PIN set',
      'new_pin': 'New PIN',
      'confirm_pin': 'Confirm PIN',
      'overwrite_pin_title': 'Overwrite existing PIN?',
      'overwrite_pin_content': 'This will replace your current PIN. Continue?',
      'cancel': 'Cancel',
      'ok': 'OK',
      'add_profile': 'Add Profile',
      'staff_profiles': 'Staff Profiles',
      'child_profiles': 'Child Profiles',
      'age': 'Age',
      'delete': 'Delete',
      'access_denied': 'Access denied: incorrect PIN',
      'zones_regulation': 'Zones of Regulation',
      'points_overview': 'Points Overview',
      'view_schedule': 'View Schedule',
      'create_quiz': 'Create Quiz',
      'manage_quizzes': 'Manage Quizzes',
      'welcome': 'Welcome',
      'my_points': 'My Points',
      'my_schedule': 'My Schedule',
      'calming_sounds': 'Calming Sounds',
      'take_quiz': 'Take a Quiz',
      'change_background': 'Change Background Color'
    },
    'ga': {
      'save_pin': 'Sábháil PIN',
      'select_language': 'Roghnaigh Teanga',
      'pin_set': 'Tá PIN socraithe',
      'pin_not_set': 'Níl PIN socraithe',
      'new_pin': 'PIN Nua',
      'confirm_pin': 'Deimhnigh PIN',
      'overwrite_pin_title': 'An scríobhfaidh tú thar an PIN atá ann?',
      'overwrite_pin_content': 'Athróidh sé seo do PIN reatha. Lean ar aghaidh?',
      'cancel': 'Cealaigh',
      'ok': 'OK',
      'add_profile': 'Cuir Próifíl leis',
      'staff_profiles': 'Próifílí Foirne',
      'child_profiles': 'Próifílí Páistí',
      'age': 'Aois',
      'delete': 'Scrios',
      'access_denied': 'Rochtain diúltaithe: PIN mícheart',
      'zones_regulation': 'Zóin Rialaithe',
      'points_overview': 'Forbhreathnú Pointí',
      'view_schedule': 'Féach ar an Sceideal',
      'create_quiz': 'Cruthaigh Tástáil',
      'manage_quizzes': 'Bainistigh Tástálacha',
      'welcome': 'Fáilte',
      'my_points': 'Mo Phointí',
      'my_schedule': 'Mo Sceideal',
      'calming_sounds': 'Fuaimeanna Ciúine',
      'take_quiz': 'Glac Tráth na gCeist',
      'change_background': 'Athraigh Dath an Chúlra'
    },
  };

  String getString(String key) {
    return _localizedStrings[locale.languageCode]?[key] ??
        _localizedStrings['en']![key] ??
        key;
  }
}