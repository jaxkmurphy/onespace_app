import 'package:flutter/widgets.dart';

class LearningGameLocalizations {
  final bool isIrish;

  const LearningGameLocalizations._(this.isIrish);

  static LearningGameLocalizations of(BuildContext context) {
    return LearningGameLocalizations._(
      Localizations.localeOf(context).languageCode == 'ga',
    );
  }

  String get associationPairs =>
      isIrish ? 'Péirí Ceangailte' : 'Association Pairs';
  String get numberSequence => isIrish ? 'Ord Uimhreacha' : 'Number Sequence';
  String get oddOneOut => isIrish ? 'An Ceann Corr' : 'Odd One Out';
  String get emotionDetective =>
      isIrish ? 'Bleachtaire Mothúchán' : 'Emotion Detective';

  String get choosePack => isIrish ? 'Roghnaigh pacáiste' : 'Choose a pack';
  String get chooseChallenge =>
      isIrish ? 'Roghnaigh dúshlán' : 'Choose a challenge';
  String get createPack => isIrish ? 'Cruthaigh pacáiste' : 'Create pack';
  String get createChallenge =>
      isIrish ? 'Cruthaigh dúshlán' : 'Create challenge';
  String get editPack => isIrish ? 'Cuir pacáiste in eagar' : 'Edit pack';
  String get deletePack => isIrish ? 'Scrios pacáiste' : 'Delete pack';
  String get deletePackQuestion =>
      isIrish ? 'Scrios pacáiste?' : 'Delete pack?';
  String get audience => isIrish ? 'Lucht féachana' : 'Audience';
  String get chooseAudience =>
      isIrish ? 'Roghnaigh lucht féachana' : 'Choose audience';
  String get everyone => isIrish ? 'Gach duine' : 'Everyone';
  String selectedCount(int count) =>
      isIrish ? '$count roghnaithe' : '$count selected';
  String assignedCount(int count) =>
      isIrish ? '$count sannta' : '$count assigned';
  String get active => isIrish ? 'Gníomhach' : 'Active';
  String get inactive => isIrish ? 'Neamhghníomhach' : 'Inactive';
  String get setActive => isIrish ? 'Cuir gníomhach' : 'Set active';
  String get setInactive => isIrish ? 'Cuir neamhghníomhach' : 'Set inactive';
  String get availableToEveryone =>
      isIrish ? 'Ar fáil do chách' : 'Available to everyone';

  String get playAgain => isIrish ? 'Arís' : 'Play again';
  String get tapToPlay => isIrish ? 'Tapáil le himirt' : 'Tap to play';
  String get back => isIrish ? 'Ar ais' : 'Back';
  String get finish => isIrish ? 'Críochnaigh' : 'Finish';
  String get restart => isIrish ? 'Atosaigh' : 'Restart';
  String get packs => isIrish ? 'Pacáistí' : 'Packs';
  String get challenges => isIrish ? 'Dúshláin' : 'Challenges';
  String get chooseAnotherPack =>
      isIrish ? 'Roghnaigh pacáiste eile' : 'Choose another pack';
  String get anotherPack => isIrish ? 'Pacáiste eile' : 'Another pack';
  String get anotherChallenge => isIrish ? 'Dúshlán eile' : 'Another challenge';
  String get starterPack => isIrish ? 'Pacáiste Tosaithe' : 'Starter Pack';
  String get starterPairs => isIrish ? 'Péirí Tosaithe' : 'Starter Pairs';
  String get starterFeelings =>
      isIrish ? 'Mothúcháin Tosaithe' : 'Starter Feelings';

  String get matchThings =>
      isIrish
          ? 'Meaitseáil rudaí a théann le chéile.'
          : 'Match things that go together.';
  String get tapNumbersInOrder =>
      isIrish
          ? 'Tapáil na huimhreacha san ord ceart.'
          : 'Tap the numbers in the right order.';
  String get findOddOne =>
      isIrish
          ? 'Aimsigh an ceann nach mbaineann leis.'
          : 'Find the one that does not belong.';
  String get thinkAboutFeelings =>
      isIrish
          ? 'Smaoinigh ar conas a mhothaíonn daoine.'
          : 'Think about how people might feel.';
  String get solveSocialCases =>
      isIrish
          ? 'Réitigh cásanna faoi mhothúcháin agus cabhair.'
          : 'Solve social-emotional cases.';
  String get whatMightTheyFeel =>
      isIrish ? 'Cad a d’fhéadfadh siad a mhothú?' : 'What might they feel?';
  String get whatClueMightShow =>
      isIrish
          ? 'Cén leid a d’fhéadfadh é sin a thaispeáint?'
          : 'What clue might show that?';
  String get whatCouldHelp =>
      isIrish ? 'Cad a d’fhéadfadh cabhrú?' : 'What could help?';

  String get usingStarterPairs =>
      isIrish
          ? 'Úsáidtear péirí tosaithe mar níor lódáladh na pacáistí.'
          : 'Using starter pairs because packs could not be loaded.';
  String get usingStarterChallenges =>
      isIrish
          ? 'Úsáidtear dúshláin tosaithe mar níor lódáladh dúshláin an tseomra ranga.'
          : 'Using starter challenges because classroom challenges could not be loaded.';
  String get usingStarterRounds =>
      isIrish
          ? 'Úsáidtear babhtaí tosaithe mar níor lódáladh na pacáistí.'
          : 'Using starter rounds because packs could not be loaded.';
  String get usingStarterScenarios =>
      isIrish
          ? 'Úsáidtear cásanna tosaithe mar níor lódáladh na pacáistí.'
          : 'Using starter scenarios because packs could not be loaded.';

  String get noPlayablePairs =>
      isIrish
          ? 'Tá dhá phéire in-seinm ar a laghad ag teastáil ón bpacáiste seo.'
          : 'This pack needs at least two playable pairs.';
  String get noPlayableRounds =>
      isIrish
          ? 'Níl aon bhabhta in-seinm sa phacáiste seo fós.'
          : 'This pack has no playable rounds yet.';
  String get noPlayableScenarios =>
      isIrish
          ? 'Níl aon chás in-seinm sa phacáiste seo fós.'
          : 'This pack has no playable scenarios yet.';
  String get couldNotLoadPack =>
      isIrish
          ? 'Níorbh fhéidir an pacáiste sin a lódáil.'
          : 'Could not load that pack.';
  String get couldNotLoadPacks =>
      isIrish ? 'Níorbh fhéidir pacáistí a lódáil.' : 'Could not load packs.';
  String get couldNotLoadChallenges =>
      isIrish
          ? 'Níorbh fhéidir dúshláin a lódáil.'
          : 'Could not load challenges.';

  String get greatJob => isIrish ? 'Maith thú!' : 'Great job!';
  String get greatChoice => isIrish ? 'Rogha iontach!' : 'Great choice!';
  String get goodTry => isIrish ? 'Iarracht mhaith!' : 'Good try!';
  String get goodThinking => isIrish ? 'Smaoineamh maith.' : 'Good thinking.';
  String get thatMakesSense =>
      isIrish ? 'Tá ciall leis sin.' : 'That makes sense.';
  String get gameComplete =>
      isIrish ? 'Tá an cluiche críochnaithe!' : 'Game complete!';
  String get detectiveComplete =>
      isIrish
          ? 'Tá obair an bhleachtaire críochnaithe!'
          : 'Detective work complete!';
  String get caseSolved =>
      isIrish ? 'Tá na cásanna réitithe!' : 'Cases solved!';

  String pairsFound(int moves) =>
      isIrish ? 'Fuair tú na péirí ar fad.' : 'You found all the pairs.';
  String get movesLabel => isIrish ? 'Iarrachtaí' : 'Moves';
  String get pairsLabel => isIrish ? 'Péirí' : 'Pairs';
  String get nextLabel => isIrish ? 'Ar aghaidh' : 'Next';
  String get timeLabel => isIrish ? 'Am' : 'Time';
  String get mistakesLabel => isIrish ? 'Botúin' : 'Mistakes';
  String scoreLabel(int score) => isIrish ? 'Scór $score' : 'Score $score';

  String roundProgress(int current, int total, int score) =>
      isIrish
          ? 'Babhta $current as $total • Scór $score'
          : 'Round $current of $total • Score $score';
  String scenarioProgress(int current, int total, int score) =>
      isIrish
          ? 'Cás $current as $total • Scór $score'
          : 'Scenario $current of $total • Score $score';
  String caseProgress(int current, int total, int step, int score) =>
      isIrish
          ? 'Cás $current as $total • Céim $step as 3 • Scór $score'
          : 'Case $current of $total • Step $step of 3 • Score $score';
  String foundOddOnes(int score, int total) =>
      isIrish
          ? 'D’aimsigh tú $score as $total cinn chorr.'
          : 'You found $score out of $total odd ones.';
  String matchedFeelings(int score, int total) =>
      isIrish
          ? 'Mheaitseáil tú $score as $total mothúchán.'
          : 'You matched $score out of $total feelings.';
  String solvedClues(int score, int total) =>
      isIrish
          ? 'Réitigh tú $score as $total leid.'
          : 'You solved $score out of $total clues.';
  String correctOddWas(String label) =>
      isIrish ? 'Ba é $label an ceann corr.' : 'The odd one out was $label.';
  String answerFits(String answer) =>
      isIrish
          ? 'Oireann $answer don chás seo.'
          : '$answer fits this situation.';
  String anotherFeelingCouldBe(String answer) =>
      isIrish
          ? 'D’fhéadfadh $answer a bheith ina mhothúchán eile.'
          : 'Another feeling could be $answer.';
  String anotherAnswerCouldBe(String answer) =>
      isIrish
          ? 'D’fhéadfadh $answer a bheith ina fhreagra eile.'
          : 'Another answer could be $answer.';

  String get addPair => isIrish ? 'Cuir péire leis' : 'Add pair';
  String get editPair => isIrish ? 'Cuir péire in eagar' : 'Edit pair';
  String get deletePair => isIrish ? 'Scrios péire' : 'Delete pair';
  String get addRound => isIrish ? 'Cuir babhta leis' : 'Add round';
  String get editRound => isIrish ? 'Cuir babhta in eagar' : 'Edit round';
  String get deleteRound => isIrish ? 'Scrios babhta' : 'Delete round';
  String get addScenario => isIrish ? 'Cuir cás leis' : 'Add scenario';
  String get editScenario => isIrish ? 'Cuir cás in eagar' : 'Edit scenario';
  String get deleteScenario => isIrish ? 'Scrios cás' : 'Delete scenario';

  String packCount(int count) =>
      isIrish ? '$count pacáiste' : '$count pack${count == 1 ? '' : 's'}';
  String pairCount(int count) =>
      isIrish ? '$count péire' : '$count pair${count == 1 ? '' : 's'}';
  String roundCount(int count) =>
      isIrish ? '$count babhta' : '$count round${count == 1 ? '' : 's'}';
  String scenarioCount(int count) =>
      isIrish ? '$count cás' : '$count scenario${count == 1 ? '' : 's'}';

  String get packName => isIrish ? 'Ainm an phacáiste' : 'Pack name';
  String get packTitle => isIrish ? 'Teideal an phacáiste' : 'Pack title';
  String get description => isIrish ? 'Cur síos' : 'Description';
  String get chooseIcon => isIrish ? 'Roghnaigh deilbhín' : 'Choose icon';
  String get choosePackIcon =>
      isIrish ? 'Roghnaigh deilbhín pacáiste' : 'Choose pack icon';
  String get chooseItemIcon =>
      isIrish ? 'Roghnaigh deilbhín míre' : 'Choose item icon';
  String get prompt => isIrish ? 'Leid' : 'Prompt';
  String itemNumber(int number) => isIrish ? 'Mír $number' : 'Item $number';
  String choiceNumber(int number) =>
      isIrish ? 'Rogha $number' : 'Choice $number';
}
