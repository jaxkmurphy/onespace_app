import 'package:flutter/material.dart';

class LocaleNotifier extends ValueNotifier<Locale> {
  LocaleNotifier(super.value);

  void changeLocale(Locale newLocale) {
    value = newLocale;
    notifyListeners();
  }
}