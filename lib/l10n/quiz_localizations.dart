import 'app_localizations.dart';

String localizedQuizStyle(AppLocalizations l10n, String key) => switch (key) {
  'quiz' => l10n.quizStyleGeneral,
  'numbers' => l10n.quizStyleNumbers,
  'words' => l10n.quizStyleWords,
  'science' => l10n.quizStyleScience,
  'world' => l10n.quizStyleWorld,
  'memory' => l10n.quizStyleMemory,
  'fun' => l10n.quizStyleFun,
  _ => l10n.quizStyleGeneral,
};
