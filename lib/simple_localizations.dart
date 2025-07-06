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
      // add other keys here...
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
      // add other keys here...
    },
  };

  String getString(String key) {
    return _localizedStrings[locale.languageCode]?[key] ??
        _localizedStrings['en']![key] ??
        key;
  }
}