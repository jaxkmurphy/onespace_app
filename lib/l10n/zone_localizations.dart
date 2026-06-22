import 'app_localizations.dart';

String localizedZoneName(AppLocalizations l10n, String value) => switch (value
    .toLowerCase()) {
  'blue' => l10n.zoneBlue,
  'green' => l10n.zoneGreen,
  'yellow' => l10n.zoneYellow,
  'red' => l10n.zoneRed,
  _ => l10n.noZone,
};

String localizedZoneChildDescription(AppLocalizations l10n, String value) =>
    switch (value.toLowerCase()) {
      'blue' => l10n.zoneBlueChildDescription,
      'green' => l10n.zoneGreenChildDescription,
      'yellow' => l10n.zoneYellowChildDescription,
      'red' => l10n.zoneRedChildDescription,
      _ => '',
    };

String localizedZoneStaffDescription(AppLocalizations l10n, String value) =>
    switch (value.toLowerCase()) {
      'blue' => l10n.zoneBlueStaffDescription,
      'green' => l10n.zoneGreenStaffDescription,
      'yellow' => l10n.zoneYellowStaffDescription,
      'red' => l10n.zoneRedStaffDescription,
      _ => '',
    };

List<String> localizedZoneFeelings(AppLocalizations l10n, String value) =>
    switch (value.toLowerCase()) {
      'blue' => [
        l10n.feelingTired,
        l10n.feelingSad,
        l10n.feelingBored,
        l10n.feelingUnwell,
        l10n.feelingSlow,
      ],
      'green' => [
        l10n.feelingCalm,
        l10n.feelingFocused,
        l10n.feelingHappy,
        l10n.feelingContent,
        l10n.feelingReady,
      ],
      'yellow' => [
        l10n.feelingWorried,
        l10n.feelingExcited,
        l10n.feelingFrustrated,
        l10n.feelingSilly,
        l10n.feelingRestless,
      ],
      'red' => [
        l10n.feelingAngry,
        l10n.feelingPanicked,
        l10n.feelingTerrified,
        l10n.feelingOverwhelmed,
        l10n.feelingOutOfControl,
      ],
      _ => const [],
    };
