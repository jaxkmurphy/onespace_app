import 'app_localizations.dart';

String localizedProfileUnlockIcon(AppLocalizations l10n, String keyName) =>
    switch (keyName) {
      'star' => l10n.iconStar,
      'car' => l10n.iconCar,
      'dog' => l10n.iconDog,
      'apple' => l10n.iconApple,
      'ball' => l10n.iconBall,
      'music' => l10n.iconMusic,
      'sun' => l10n.iconSun,
      'heart' => l10n.iconHeart,
      _ => keyName,
    };