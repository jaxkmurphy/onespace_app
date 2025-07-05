// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Irish (`ga`).
class AppLocalizationsGa extends AppLocalizations {
  AppLocalizationsGa([String locale = 'ga']) : super(locale);

  @override
  String get appTitle => 'Aip OneSpace';

  @override
  String get settings => 'Socruithe';

  @override
  String get language => 'Teanga';

  @override
  String get selectLanguage => 'Roghnaigh Teanga';

  @override
  String get pinUpdated => 'Athraíodh an PIN';

  @override
  String get savePin => 'Sábháil PIN';

  @override
  String get newPin => 'PIN Nua';

  @override
  String get confirmPin => 'Dearbhaigh an PIN';

  @override
  String get pinHint => 'Caithfidh 4 dhigit a bheith sa PIN agus caithfidh siad a bheith mar an gcéanna';
}
