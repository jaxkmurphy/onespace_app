import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

extension BuildContextLocalizations on BuildContext {
  AppLocalizations get l10n {
    return AppLocalizations.of(this)!;
  }
}