import 'app_localizations.dart';

String localizedBodyPart(AppLocalizations l10n, String value) =>
    switch (value) {
      'Head' => l10n.bodyPartHead,
      'Throat' => l10n.bodyPartThroat,
      'Chest' => l10n.bodyPartChest,
      'Tummy' => l10n.bodyPartTummy,
      'Left arm' => l10n.bodyPartLeftArm,
      'Right arm' => l10n.bodyPartRightArm,
      'Left hand' => l10n.bodyPartLeftHand,
      'Right hand' => l10n.bodyPartRightHand,
      'Left leg' => l10n.bodyPartLeftLeg,
      'Right leg' => l10n.bodyPartRightLeg,
      'Left foot' => l10n.bodyPartLeftFoot,
      'Right foot' => l10n.bodyPartRightFoot,
      'Back of head' => l10n.bodyPartBackOfHead,
      'Neck' => l10n.bodyPartNeck,
      'Upper back' => l10n.bodyPartUpperBack,
      'Lower back' => l10n.bodyPartLowerBack,
      _ => value,
    };

String localizedPainType(AppLocalizations l10n, String value) =>
    switch (value) {
      'Sore / Aching' => l10n.painSoreAching,
      'Sharp' => l10n.painSharp,
      'Burning / Hot' => l10n.painBurningHot,
      'Itchy' => l10n.painItchy,
      'Throbbing' => l10n.painThrobbing,
      'Tingly / Numb' => l10n.painTinglyNumb,
      'Sick / Nauseous' => l10n.painSick,
      'Not sure' => l10n.painNotSure,
      _ => value,
    };

String localizedPainTypeDescription(AppLocalizations l10n, String value) =>
    switch (value) {
      'Sore / Aching' => l10n.painSoreAchingDescription,
      'Sharp' => l10n.painSharpDescription,
      'Burning / Hot' => l10n.painBurningHotDescription,
      'Itchy' => l10n.painItchyDescription,
      'Throbbing' => l10n.painThrobbingDescription,
      'Tingly / Numb' => l10n.painTinglyNumbDescription,
      'Sick / Nauseous' => l10n.painSickDescription,
      'Not sure' => l10n.painNotSureDescription,
      _ => value,
    };

String localizedPainLevel(AppLocalizations l10n, int level) => switch (level) {
  1 => l10n.painLittleSore,
  2 => l10n.painHurts,
  3 => l10n.painHurtsALot,
  _ => l10n.painUnknown,
};

String localizedPainLevelDescription(AppLocalizations l10n, int level) =>
    switch (level) {
      1 => l10n.painLittleSoreDescription,
      2 => l10n.painHurtsDescription,
      3 => l10n.painHurtsALotDescription,
      _ => l10n.painUnknown,
    };