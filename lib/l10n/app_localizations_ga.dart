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
  String get pinUpdated => 'Nuashonraíodh an PIN';

  @override
  String get savePin => 'Sábháil PIN';

  @override
  String get newPin => 'PIN Nua';

  @override
  String get confirmPin => 'Deimhnigh PIN';

  @override
  String get pinHint =>
      'Caithfidh na PINanna a bheith mar an gcéanna agus 4 dhigit ar fad';

  @override
  String get cancel => 'Cealaigh';

  @override
  String get save => 'Sábháil';

  @override
  String get delete => 'Scrios';

  @override
  String get edit => 'Cuir in Eagar';

  @override
  String get add => 'Cuir Leis';

  @override
  String get create => 'Cruthaigh';

  @override
  String get close => 'Dún';

  @override
  String get done => 'Déanta';

  @override
  String get retry => 'Bain Triail Eile As';

  @override
  String get loading => 'Á Lódáil...';

  @override
  String get error => 'Chuaigh rud éigin mícheart';

  @override
  String get all => 'Uile';

  @override
  String get everyone => 'Gach Duine';

  @override
  String get viewOnly => 'Amharc amháin';

  @override
  String get untitled => 'Gan Teideal';

  @override
  String get low => 'Íseal';

  @override
  String get medium => 'Meánach';

  @override
  String get high => 'Ard';

  @override
  String get zones_regulation => 'Zóin Rialaithe';

  @override
  String get points_overview => 'Forbhreathnú Pointí';

  @override
  String get view_schedule => 'Féach ar an Sceideal';

  @override
  String get create_quiz => 'Cruthaigh Tráth na gCeist';

  @override
  String get manage_quizzes => 'Bainistigh Tráthanna na gCeist';

  @override
  String get welcome => 'Fáilte';

  @override
  String get my_points => 'Mo Phointí';

  @override
  String get my_schedule => 'Mo Sceideal';

  @override
  String get calming_sounds => 'Fuaimeanna Suaimhneacha';

  @override
  String get take_quiz => 'Déan Tráth na gCeist';

  @override
  String get change_background => 'Athraigh Dath an Chúlra';

  @override
  String get handoverHub => 'Mol Aistrithe Eolais';

  @override
  String get handoverStartHereTab => 'Tosaigh Anseo';

  @override
  String get handoverStaffDocumentsTab => 'Doiciméid Foirne';

  @override
  String get handoverQuickNotesTab => 'Nótaí Tapa';

  @override
  String get readThisFirst => 'Léigh é seo ar dtús';

  @override
  String get startHereDescription =>
      'Ba cheart an t-eolas is tábhachtaí atá de dhíth láithreach ar mhúinteoir ionaid nó ar CRS a bheith sa rannóg seo.';

  @override
  String get noStartHereInformation => 'Níl aon eolas curtha leis anseo fós.';

  @override
  String get editStartHere => 'Cuir Tosaigh Anseo in Eagar';

  @override
  String get editStartHereTitle => 'Cuir Tosaigh Anseo in Eagar';

  @override
  String get startHereHint => 'Scríobh an t-eolas ranga is tábhachtaí anseo...';

  @override
  String get noStaffProfilesFound => 'Níor aimsíodh aon phróifíl foirne.';

  @override
  String staffDocumentTitle(String staffName) {
    return 'Doiciméad $staffName';
  }

  @override
  String editStaffDocument(String staffName) {
    return 'Cuir Doiciméad $staffName in Eagar';
  }

  @override
  String get aboutThisClass => 'Maidir leis an Rang Seo';

  @override
  String get whatWorksWell => 'Na Rudaí a Oibríonn go Maith';

  @override
  String get commonTriggers => 'Spreagthaí Coitianta';

  @override
  String get successfulStrategies => 'Straitéisí Rathúla';

  @override
  String get communicationTips => 'Leideanna Cumarsáide';

  @override
  String get otherNotes => 'Nótaí Eile';

  @override
  String get nothingAddedYet => 'Níl aon rud curtha leis fós.';

  @override
  String get editQuickNote => 'Cuir Nóta Tapa in Eagar';

  @override
  String get addQuickNote => 'Cuir Nóta Tapa Leis';

  @override
  String get titleLabel => 'Teideal';

  @override
  String get noteLabel => 'Nóta';

  @override
  String get deleteNoteTitle => 'Scrios an nóta?';

  @override
  String get deleteNoteMessage =>
      'An bhfuil tú cinnte gur mhaith leat an nóta seo a scriosadh?';

  @override
  String get noQuickNotes => 'Níl aon nótaí tapa ann fós.';

  @override
  String quickNoteBy(String staffName) {
    return 'Le: $staffName';
  }

  @override
  String get addNote => 'Cuir Nóta Leis';

  @override
  String get handoverLoadError =>
      'Níorbh fhéidir an t-eolas aistrithe a lódáil.';

  @override
  String get handoverSaveError =>
      'Níorbh fhéidir an t-eolas aistrithe a shábháil.';

  @override
  String get handoverDeleteError => 'Níorbh fhéidir an nóta a scriosadh.';

  @override
  String lastUpdated(String date) {
    return 'Nuashonraithe go deireanach $date';
  }

  @override
  String get incidentLog => 'Loga Teagmhas';

  @override
  String incidentLogClassroom(String classroomName) {
    return 'Loga Teagmhas — $classroomName';
  }

  @override
  String get incidentLogIntro =>
      'Cruthaigh agus athbhreithnigh taifid ar theagmhais sa seomra ranga.';

  @override
  String get createIncident => 'Cruthaigh Teagmhas';

  @override
  String get viewIncidents => 'Féach ar Theagmhais';

  @override
  String get selectChild => 'Roghnaigh Páiste';

  @override
  String get severity => 'Tromchúis';

  @override
  String get useCurrentTime => 'Úsáid an tAm Reatha (Réamhshocrú)';

  @override
  String manualTime(String date) {
    return 'Am de Láimh: $date';
  }

  @override
  String get resetToCurrentTime => 'Athshocraigh go dtí an t-am reatha';

  @override
  String get description => 'Cur Síos';

  @override
  String get actionTaken => 'Gníomh a Rinneadh';

  @override
  String get saveIncident => 'Sábháil an Teagmhas';

  @override
  String get saving => 'Á Shábháil...';

  @override
  String get pleaseSelectChild => 'Roghnaigh páiste.';

  @override
  String get enterIncidentDetails =>
      'Cuir isteach cur síos agus an gníomh a rinneadh.';

  @override
  String get incidentSaved => 'Sábháladh an teagmhas.';

  @override
  String get incidentUpdated => 'Nuashonraíodh an teagmhas.';

  @override
  String get incidentSaveFailed => 'Níorbh fhéidir an teagmhas a shábháil.';

  @override
  String get editIncident => 'Cuir an Teagmhas in Eagar';

  @override
  String get archiveIncident => 'Cuir an Teagmhas sa Chartlann';

  @override
  String get archiveIncidentQuestion => 'Cuir an teagmhas seo sa chartlann?';

  @override
  String archiveIncidentMessage(String childName) {
    return 'Cuir an teagmhas do $childName sa chartlann? Fanfaidh sé sa stair iniúchta.';
  }

  @override
  String get archiveReason => 'Cúis leis an gcartlannú';

  @override
  String get incidentArchived => 'Cuireadh an teagmhas sa chartlann.';

  @override
  String get incidentArchiveFailed =>
      'Níorbh fhéidir an teagmhas a chur sa chartlann.';

  @override
  String get noIncidents => 'Níl aon teagmhas logáilte fós.';

  @override
  String get filterByChild => 'Scag de réir páiste';

  @override
  String incidentsShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tá $count teagmhas á dtaispeáint',
      one: 'Tá 1 teagmhas á thaispeáint',
      zero: 'Níl aon teagmhas á thaispeáint',
    );
    return '$_temp0';
  }

  @override
  String get noMatchingIncidents =>
      'Ní mheaitseálann aon teagmhas na scagairí seo.';

  @override
  String severityLabel(String severity) {
    return 'Tromchúis: $severity';
  }

  @override
  String loggedBy(String staffName) {
    return 'Logáilte ag $staffName';
  }

  @override
  String get incidentCategory => 'Catagóir Teagmhais';

  @override
  String get behaviour => 'Iompar';

  @override
  String get injury => 'Gortú';

  @override
  String get safety => 'Sábháilteacht';

  @override
  String get emotional => 'Mothúchánach';

  @override
  String get other => 'Eile';

  @override
  String get followUp => 'Obair Leantach';

  @override
  String get noFollowUp => 'Níl obair leantach de dhíth';

  @override
  String get followUpRequired => 'Tá obair leantach de dhíth';

  @override
  String get followUpCompleted => 'Tá an obair leantach críochnaithe';

  @override
  String get followUpNotes => 'Nótaí Leantacha';

  @override
  String get archivedIncidents => 'Teagmhais sa Chartlann';

  @override
  String get wordLearning => 'Foghlaim Focal';

  @override
  String get wordPractice => 'Cleachtadh Focal';

  @override
  String get wordProgress => 'Dul Chun Cinn Focal';

  @override
  String get createWordPack => 'Cruthaigh Pacáiste Focal';

  @override
  String get editWordPack => 'Cuir Pacáiste Focal in Eagar';

  @override
  String get deleteWordPack => 'Scrios Pacáiste Focal';

  @override
  String deleteWordPackMessage(String packName) {
    return 'Scrios “$packName”? Scriosfar na focail atá ann freisin.';
  }

  @override
  String get packName => 'Ainm an Phacáiste';

  @override
  String get packDescription => 'Cur Síos ar an bPacáiste';

  @override
  String get packDescriptionHint =>
      'Cad a chleachtfaidh na páistí sa phacáiste seo?';

  @override
  String createdBy(String staffName) {
    return 'Cruthaithe ag $staffName';
  }

  @override
  String wordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count focal',
      one: '1 fhocal',
      zero: 'Gan focail',
    );
    return '$_temp0';
  }

  @override
  String assignedChildCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sannta do $count páiste',
      one: 'Sannta do pháiste amháin',
      zero: 'Gan sannadh',
    );
    return '$_temp0';
  }

  @override
  String get noWordPacks => 'Níl aon phacáiste focal ann fós.';

  @override
  String get createFirstWordPack =>
      'Cruthaigh do chéad phacáiste focal chun tosú.';

  @override
  String get addWord => 'Cuir Focal Leis';

  @override
  String get editWord => 'Cuir Focal in Eagar';

  @override
  String get deleteWord => 'Scrios Focal';

  @override
  String deleteWordMessage(String word) {
    return 'Scrios an focal “$word”?';
  }

  @override
  String get word => 'Focal';

  @override
  String get emoji => 'Emoji';

  @override
  String get difficulty => 'Deacracht';

  @override
  String get easy => 'Éasca';

  @override
  String get hard => 'Deacair';

  @override
  String get assignChildren => 'Sann Páistí';

  @override
  String get saveAssignments => 'Sábháil na Sannacháin';

  @override
  String get noChildrenAvailable => 'Níl aon phróifíl páiste ar fáil.';

  @override
  String get noWords => 'Níl aon fhocal curtha leis fós.';

  @override
  String get addFirstWord =>
      'Cuir dhá fhocal ar a laghad leis sula sannann tú an pacáiste seo.';

  @override
  String get tapToPractise => 'Tapáil chun cleachtadh';

  @override
  String get noAssignedWordPacks =>
      'Níl aon phacáiste focal sannta faoi láthair.';

  @override
  String get packNeedsTwoWords =>
      'Teastaíonn dhá fhocal ar a laghad sa phacáiste seo sular féidir é a chleachtadh.';

  @override
  String get practiceComplete => 'Cleachtadh Críochnaithe!';

  @override
  String practisedWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Chleacht tú $count focal.',
      one: 'Chleacht tú 1 fhocal.',
    );
    return '$_temp0';
  }

  @override
  String get practiseAgain => 'Cleachtaigh Arís';

  @override
  String get backToPacks => 'Ar Ais chuig na Pacáistí';

  @override
  String get selectChildForProgress =>
      'Roghnaigh páiste chun a ndul chun cinn a fheiceáil.';

  @override
  String get noWordAttempts => 'Níl aon iarracht cleachtaidh focal ann fós.';

  @override
  String totalAttempts(int count) {
    return 'Iarrachtaí iomlána: $count';
  }

  @override
  String correctAnswers(int count) {
    return 'Freagraí cearta: $count';
  }

  @override
  String accuracy(String percentage) {
    return 'Cruinneas: $percentage%';
  }

  @override
  String get wordBreakdown => 'Miondealú Focal';

  @override
  String attemptSummary(int attempts, int correct, String accuracy) {
    return 'Iarrachtaí: $attempts • Ceart: $correct • Cruinneas: $accuracy%';
  }

  @override
  String get chooseMatchingWord => 'Roghnaigh an focal a oireann don phictiúr.';

  @override
  String get greatJob => 'Maith thú!';

  @override
  String get goodTry => 'Iarracht mhaith!';

  @override
  String correctAnswerWas(String answer) {
    return 'Ba é $answer an freagra ceart.';
  }

  @override
  String get nextWord => 'An Chéad Fhocal Eile';

  @override
  String get finishPractice => 'Críochnaigh an Cleachtadh';

  @override
  String get loadingWords => 'Tá do chuid focal á n-ullmhú...';

  @override
  String get couldNotLoadWords =>
      'Níorbh fhéidir an pacáiste focal seo a lódáil.';

  @override
  String get packStyle => 'Stíl an Phacáiste';

  @override
  String get words => 'Focail';

  @override
  String get school => 'Scoil';

  @override
  String get home => 'Baile';

  @override
  String get animals => 'Ainmhithe';

  @override
  String get feelings => 'Mothúcháin';

  @override
  String get ourWorld => 'An Domhan';

  @override
  String get fun => 'Spraoi';

  @override
  String get selectedChildren => 'Páistí Roghnaithe';

  @override
  String get availableToEveryone => 'Ar Fáil do Gach Duine';

  @override
  String get couldNotLoadWordPacks =>
      'Níorbh fhéidir na pacáistí focal a lódáil.';

  @override
  String get wordPackCreated => 'Cruthaíodh an pacáiste focal.';

  @override
  String get wordPackDeleted => 'Scriosadh an pacáiste focal.';

  @override
  String get wordPackSaveFailed =>
      'Níorbh fhéidir an pacáiste focal a shábháil.';

  @override
  String get wordPackDeleteFailed =>
      'Níorbh fhéidir an pacáiste focal a scriosadh.';

  @override
  String get editPackDetails => 'Cuir Sonraí an Phacáiste in Eagar';

  @override
  String get wordPackUpdated => 'Nuashonraíodh an pacáiste focal.';

  @override
  String get assignmentsSaved => 'Sábháladh na sannacháin.';

  @override
  String get hint => 'Leid';

  @override
  String get hintOptional => 'Leid chabhrach (roghnach)';

  @override
  String get wordSaved => 'Sábháladh an focal.';

  @override
  String get wordDeleted => 'Scriosadh an focal.';

  @override
  String get wordSaveFailed => 'Níorbh fhéidir an focal a shábháil.';

  @override
  String get wordDeleteFailed => 'Níorbh fhéidir an focal a scriosadh.';

  @override
  String wordProgressCount(int current, int total) {
    return 'Focal $current as $total';
  }

  @override
  String practiceScore(int score, int total) {
    return '$score as $total ceart';
  }

  @override
  String get showHint => 'Taispeáin Leid';

  @override
  String get profiles => 'Próifílí';

  @override
  String staffHubTitle(String staffName) {
    return 'Mol $staffName';
  }

  @override
  String get staffFeatureHub => 'Mol Gnéithe Foirne';

  @override
  String get staffHubIntro =>
      'Roghnaigh uirlis chun tacú leis an seomra ranga inniu.';

  @override
  String get dailyTools => 'Uirlisí Laethúla';

  @override
  String get todayOverview => 'Forbhreathnú an Lae';

  @override
  String get todayOverviewSubtitle =>
      'Féach ar na zóin, tuairiscí, sceideal agus eachtraí go tapa.';

  @override
  String get staffZonesSubtitle => 'Féach ar zóin reatha na bpáistí.';

  @override
  String get staffPointsSubtitle =>
      'Féach ar phointí na bpáistí agus nuashonraigh iad.';

  @override
  String get staffScheduleSubtitle =>
      'Cruthaigh agus cuir an sceideal laethúil in eagar.';

  @override
  String get whenThenSetup => 'Socrú Nuair–Ansin';

  @override
  String get staffWhenThenSubtitle =>
      'Cruthaigh gníomhaíochtaí agus luaíochtaí Nuair–Ansin.';

  @override
  String get visualTimer => 'Amadóir Amhairc';

  @override
  String get staffTimerSubtitle => 'Oscail amadóir an tseomra ranga.';

  @override
  String get communication => 'Cumarsáid';

  @override
  String get bodyCheckReports => 'Tuairiscí Seiceála Coirp';

  @override
  String get bodyCheckReportsSubtitle =>
      'Athbhreithnigh teachtaireachtaí seiceála coirp ó pháistí.';

  @override
  String get circleTime => 'Am Ciorcail';

  @override
  String get staffCircleTimeSubtitle =>
      'Bog páistí idir an baile agus an scoil.';

  @override
  String get learning => 'Foghlaim';

  @override
  String get quizzes => 'Tráthanna na gCeist';

  @override
  String get staffQuizzesSubtitle =>
      'Cruthaigh, réamhamharc agus bainistigh tráthanna na gceist.';

  @override
  String get staffWordLearningSubtitle =>
      'Cruthaigh pacáistí focal agus féach ar dhul chun cinn.';

  @override
  String get staffAdmin => 'Foireann / Riarachán';

  @override
  String get staffIncidentLogSubtitle =>
      'Taifead agus athbhreithnigh eachtraí sa seomra ranga.';

  @override
  String get staffHandoverSubtitle =>
      'Féach ar nótaí forbhreathnaithe agus ar cháipéisí foirne.';

  @override
  String get iconReset => 'Athshocrú Deilbhíní';

  @override
  String get iconResetSubtitle =>
      'Féach ar dheilbhíní díghlasála próifílí páistí nó athshocraigh iad.';

  @override
  String childSpaceTitle(String childName) {
    return 'Spás $childName';
  }

  @override
  String welcomeChild(String childName) {
    return 'Fáilte, $childName!';
  }

  @override
  String get whatWouldYouLikeToDo => 'Cad ba mhaith leat a dhéanamh?';

  @override
  String get childCircleTimeSubtitle => 'Cuir tús leis an lá le chéile.';

  @override
  String get childScheduleSubtitle => 'Féach cad atá ag tarlú inniu.';

  @override
  String get whenThen => 'Nuair–Ansin';

  @override
  String get childWhenThenSubtitle =>
      'Féach ar do chéad ghníomhaíocht agus luaíocht eile.';

  @override
  String get childZonesSubtitle => 'Inis dúinn conas atá tú.';

  @override
  String get bodyCheck => 'Seiceáil Coirp';

  @override
  String get childBodyCheckSubtitle => 'Taispeáin cá bhfuil pian i do chorp.';

  @override
  String get childCalmingSoundsSubtitle =>
      'Éist agus glac nóiméad suaimhneach.';

  @override
  String get voiceLines => 'Línte Gutha';

  @override
  String get childVoiceLinesSubtitle => 'Éist le focail agus frásaí cabhracha.';

  @override
  String get childPointsSubtitle => 'Féach ar do chuid pointí agus luaíochtaí.';

  @override
  String get childQuizSubtitle => 'Imir tráth na gceist agus foghlaim rud nua.';

  @override
  String get childWordPracticeSubtitle => 'Cleachtaigh focail ar do luas féin.';

  @override
  String get childTimerSubtitle => 'Féach cé mhéad ama atá fágtha.';

  @override
  String get myDay => 'Mo Lá';

  @override
  String get myDaySubtitle => 'Féach cad atá ag tarlú ina dhiaidh seo.';

  @override
  String get howIFeel => 'Conas a Mhothaím';

  @override
  String get howIFeelSubtitle =>
      'Déan seiceáil ar do chorp agus ar do mhothúcháin.';

  @override
  String get learnAndPlay => 'Foghlaim agus Spraoi';

  @override
  String get learnAndPlaySubtitle =>
      'Cleachtaigh, fiosraigh agus bain sult as.';

  @override
  String get timeFinished => 'Tá an t-am críochnaithe';

  @override
  String get timerCountingDown => 'Tá an t-am ag comhaireamh síos';

  @override
  String get chooseTimeAndStart => 'Roghnaigh am agus brúigh Tosaigh';

  @override
  String get minutesShort => 'nóim';

  @override
  String get chooseTimerLength => 'Roghnaigh fad ama';

  @override
  String get customTime => 'Am saincheaptha';

  @override
  String timerMinutes(int minutes) {
    return '$minutes nóim';
  }

  @override
  String get start => 'Tosaigh';

  @override
  String get pause => 'Cuir ar sos';

  @override
  String get reset => 'Athshocraigh';

  @override
  String get calmingSoundsIntro =>
      'Roghnaigh fuaim shuaimhneach le héisteacht léi';

  @override
  String get soundPlaybackFailed =>
      'Níorbh fhéidir an fhuaim seo a sheinm. Seiceáil an comhad.';

  @override
  String get paused => 'Ar Sos';

  @override
  String get nowPlaying => 'Á Sheinm Anois';

  @override
  String get volume => 'Airde Fuaime';

  @override
  String get play => 'Seinn';

  @override
  String get stop => 'Stop';

  @override
  String get pausedTapToPlay => 'Ar sos - tapáil chun seinm';

  @override
  String get playingTapToPause => 'Á sheinm - tapáil chun sos';

  @override
  String get tapToPlay => 'Tapáil chun seinm';

  @override
  String get whenThenChoiceSaveFailed =>
      'Níorbh fhéidir an rogha sin a shábháil. Bain triail eile as.';

  @override
  String get gettingPlanReady => 'Tá do phlean á ullmhú...';

  @override
  String get planLoadFailed => 'Níorbh fhéidir do phlean a lódáil';

  @override
  String get waitAndTryAgain => 'Fan nóiméad agus bain triail eile as.';

  @override
  String get allCaughtUp => 'Tá gach rud déanta agat!';

  @override
  String get noActiveWhenThen => 'Níl aon bhord Nuair–Ansin gníomhach anois';

  @override
  String get newPlanWillAppear =>
      'Beidh plean nua le feiceáil anseo nuair a bheidh sé réidh.';

  @override
  String get whenLabel => 'NUAIR A';

  @override
  String get thenLabel => 'ANSIN';

  @override
  String childPlanGreeting(String childName) {
    return 'Seo do phlean, $childName!';
  }

  @override
  String get oneStepAtATime =>
      'Céim amháin ag an am — is féidir leat é seo a dhéanamh!';

  @override
  String get greatChoice => 'Rogha iontach!';

  @override
  String get thisComesNext => 'Seo an chéad rud eile';

  @override
  String get chooseYourReward => 'Roghnaigh do luaíocht';

  @override
  String get tapRewardYouWouldLike => 'Tapáil an ceann ba mhaith leat.';

  @override
  String get finishWhenEnjoyReward =>
      'Críochnaigh do ghníomhaíocht NUAIR A, ansin bain sult as do luaíocht!';

  @override
  String get brilliantChoice => 'Rogha thar barr!';

  @override
  String get pleaseChooseChild => 'Roghnaigh páiste, le do thoil.';

  @override
  String get chooseAtLeastOneChild =>
      'Roghnaigh páiste amháin ar a laghad, le do thoil.';

  @override
  String get noChildProfilesFound => 'Níor aimsíodh aon phróifílí páistí.';

  @override
  String get chooseWhenActivityFirst =>
      'Roghnaigh an ghníomhaíocht NUAIR A ar dtús.';

  @override
  String get chooseOneToThreeRewards =>
      'Roghnaigh idir 1 agus 3 luaíocht ANSIN.';

  @override
  String get selectedRewardUnavailable =>
      'Níl ceann de na luaíochtaí roghnaithe ar fáil a thuilleadh.';

  @override
  String get whenThenBoardCreated => 'Cruthaíodh an bord Nuair–Ansin';

  @override
  String whenThenCreateFailed(String error) {
    return 'Níorbh fhéidir an bord Nuair–Ansin a chruthú: $error';
  }

  @override
  String get editActivity => 'Cuir gníomhaíocht in eagar';

  @override
  String get addActivity => 'Cuir gníomhaíocht leis';

  @override
  String get editReward => 'Cuir luaíocht in eagar';

  @override
  String get addReward => 'Cuir luaíocht leis';

  @override
  String get nameLabel => 'Ainm';

  @override
  String get shortClearNameHint => 'Cuir isteach ainm gearr soiléir';

  @override
  String get chooseIcon => 'Roghnaigh deilbhín';

  @override
  String optionSaveFailed(String error) {
    return 'Níorbh fhéidir an rogha seo a shábháil: $error';
  }

  @override
  String get deleteOptionQuestion => 'Scrios an rogha?';

  @override
  String deleteOptionMessage(String optionName) {
    return 'An bhfuil tú cinnte gur mhaith leat “$optionName” a scriosadh?';
  }

  @override
  String optionDeleteFailed(String error) {
    return 'Níorbh fhéidir an rogha seo a scriosadh: $error';
  }

  @override
  String get whoLabel => 'CÉ';

  @override
  String get whoShouldSeeBoard => 'Cé ba cheart an bord seo a fheiceáil?';

  @override
  String get one => 'Duine amháin';

  @override
  String get some => 'Roinnt';

  @override
  String boardSentToAllChildren(int count) {
    return 'Seolfar an bord seo chuig gach ceann de na $count próifíl páistí.';
  }

  @override
  String get noChildProfilesAvailable => 'Níl aon phróifílí páistí ar fáil.';

  @override
  String get whatHappensFirst => 'Cad is gá a dhéanamh ar dtús?';

  @override
  String get noActivitiesManageOptions =>
      'Níl aon ghníomhaíochtaí ann fós. Cuir ceann leis i mBainistigh Roghanna.';

  @override
  String get possibleRewardsInstruction =>
      'Roghnaigh idir 1 agus 3 luaíocht fhéideartha.';

  @override
  String get noRewardsManageOptions =>
      'Níl aon luaíochtaí ann fós. Cuir ceann leis i mBainistigh Roghanna.';

  @override
  String rewardsSelectedCount(int count) {
    return '$count as 3 luaíocht roghnaithe';
  }

  @override
  String get boardPreview => 'Réamhamharc ar an mbord';

  @override
  String get chooseActivity => 'Roghnaigh gníomhaíocht';

  @override
  String get chooseRewards => 'Roghnaigh luaíochtaí';

  @override
  String rewardChoicesCount(int count) {
    return '$count rogha luaíochta';
  }

  @override
  String get boardOptionsLoadFailed =>
      'Tharla fadhb agus roghanna an bhoird á lódáil.';

  @override
  String get createClearVisualBoard => 'Cruthaigh bord amhairc soiléir';

  @override
  String get createBoardIntro =>
      'Roghnaigh cé dó atá sé, cad a tharlaíonn NUAIR A, agus cad is féidir leo taitneamh a bhaint as ANSIN.';

  @override
  String get creatingBoard => 'Bord á chruthú...';

  @override
  String get createWhenThenBoard => 'Cruthaigh Bord Nuair–Ansin';

  @override
  String get childProfilesLoadFailed =>
      'Níorbh fhéidir próifílí páistí a lódáil.';

  @override
  String get activeBoards => 'Boird Ghníomhacha';

  @override
  String get activeBoardsIntro =>
      'Féach ar bhord reatha gach páiste agus glan é nuair atá sé críochnaithe.';

  @override
  String optionsLoadFailed(String title) {
    return 'Níorbh fhéidir $title a lódáil.';
  }

  @override
  String get noOptionsAdded => 'Níor cuireadh aon roghanna leis fós.';

  @override
  String get manageOptions => 'Bainistigh Roghanna';

  @override
  String get manageOptionsIntro =>
      'Coinnigh ainmneacha gearr agus soiléir ionas gur féidir le páistí iad a thuiscint go tapa.';

  @override
  String get whenActivities => 'Gníomhaíochtaí NUAIR A';

  @override
  String get whenActivitiesDescription =>
      'Tascanna agus gníomhaíochtaí le déanamh.';

  @override
  String get thenRewards => 'Luaíochtaí ANSIN';

  @override
  String get thenRewardsDescription =>
      'Roghanna dearfacha a thairgtear ina dhiaidh sin.';

  @override
  String get options => 'Roghanna';

  @override
  String get noActiveBoard => 'Níl aon bhord gníomhach';

  @override
  String whenActivitySummary(String activity) {
    return 'NUAIR A: $activity';
  }

  @override
  String get thenWaitingForReward => 'ANSIN: Ag fanacht le rogha luaíochta';

  @override
  String thenRewardSummary(String reward) {
    return 'ANSIN: $reward';
  }

  @override
  String childBoardCleared(String childName) {
    return 'Glanadh bord $childName.';
  }

  @override
  String boardClearFailed(String error) {
    return 'Níorbh fhéidir an bord a ghlanadh: $error';
  }

  @override
  String get complete => 'Críochnaithe';

  @override
  String get myCircleTime => 'M\'Am Ciorcail';

  @override
  String weatherSaveFailed(String error) {
    return 'Níorbh fhéidir an aimsir a shábháil: $error';
  }

  @override
  String get todaysMessage => 'Teachtaireacht an Lae Inniu';

  @override
  String get todaysMessageHint =>
      'Sampla: Táimid ag dul go dtí an leabharlann inniu!';

  @override
  String messageSaveFailed(String error) {
    return 'Níorbh fhéidir teachtaireacht an lae inniu a shábháil: $error';
  }

  @override
  String get circleTimeLoadFailed =>
      'Níorbh fhéidir eolas Am Ciorcail an lae inniu a lódáil.';

  @override
  String get today => 'Inniu';

  @override
  String get winter => 'Geimhreadh';

  @override
  String get spring => 'Earrach';

  @override
  String get summer => 'Samhradh';

  @override
  String get autumn => 'Fómhar';

  @override
  String get weatherTodayQuestion => 'Cén sórt aimsire atá ann inniu?';

  @override
  String get sunny => 'Grianmhar';

  @override
  String get cloudy => 'Scamallach';

  @override
  String get rainy => 'Fliuch';

  @override
  String get windy => 'Gaofar';

  @override
  String get snowy => 'Sneachtúil';

  @override
  String get foggy => 'Ceomhar';

  @override
  String get weatherNotSelected => 'Níor roghnaíodh an aimsir fós.';

  @override
  String get noMessageToday => 'Níl aon teachtaireacht ann don lá inniu fós.';

  @override
  String get addMessageToday =>
      'Cuir teachtaireacht ghearr nó gníomhaíocht speisialta leis don lá inniu.';

  @override
  String get editMessage => 'Cuir an teachtaireacht in eagar';

  @override
  String get addMessage => 'Cuir teachtaireacht leis';

  @override
  String get staffProfilesLoadFailed =>
      'Níorbh fhéidir próifílí foirne a lódáil.';

  @override
  String get homeLabel => 'Baile';

  @override
  String get schoolLabel => 'Scoil';

  @override
  String get childLabel => 'Páiste';

  @override
  String get staffLabel => 'Ball Foirne';

  @override
  String personPositionSaveFailed(String personName) {
    return 'Níorbh fhéidir suíomh $personName a shábháil.';
  }

  @override
  String get pointsLoadFailed => 'Níorbh fhéidir do chuid pointí a lódáil.';

  @override
  String get pointsHistoryLoadFailed =>
      'Níorbh fhéidir stair do chuid pointí a lódáil.';

  @override
  String wellDoneChild(String childName) {
    return 'Maith thú, $childName!';
  }

  @override
  String get pointsCelebrateEffort =>
      'Déanann do chuid pointí ceiliúradh ar d\'iarracht agus ar do chuid éachtaí.';

  @override
  String pointLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pointí',
      one: 'Pointe',
    );
    return '$_temp0';
  }

  @override
  String get nextStarMilestone => 'An Chéad Chloch Mhíle Réalta Eile';

  @override
  String milestoneProgress(int current, int target) {
    return '$current as 10 bpointe i dtreo $target';
  }

  @override
  String milestonesCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cloch mhíle críochnaithe!',
      one: '1 chloch mhíle críochnaithe!',
    );
    return '$_temp0';
  }

  @override
  String get recentAchievements => 'Na hÉachtaí is Déanaí Agam';

  @override
  String get achievementsWillAppear =>
      'Beidh do chuid éachtaí le feiceáil anseo.';

  @override
  String get justNow => 'Díreach anois';

  @override
  String todayAt(String time) {
    return 'Inniu ag $time';
  }

  @override
  String get rewardsToWorkToward =>
      'Luaíochtaí ar Féidir Liom Oibriú Ina dTreo';

  @override
  String get rewardsChildIntro =>
      'Lean ort ag tuilleamh pointí agus iarr ar bhall foirne nuair atá tú réidh le luaíocht a roghnú.';

  @override
  String get readyToChoose => 'Réidh le roghnú!';

  @override
  String pointsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pointe eile de dhíth',
      one: '1 phointe eile de dhíth',
    );
    return '$_temp0';
  }

  @override
  String updateChildPoints(String childName) {
    return 'Nuashonraigh Pointí $childName';
  }

  @override
  String get earnPoints => 'Tuill Pointí';

  @override
  String get removePoints => 'Bain Pointí';

  @override
  String get howManyPoints => 'Cé mhéad pointe?';

  @override
  String get reason => 'Cúis';

  @override
  String get reasonRequiredInfo => 'Tá cúis riachtanach do stair na bpointí.';

  @override
  String get optionalNote => 'Nóta roghnach';

  @override
  String get pointNoteHint =>
      'Cuir aon sonra úsáideach faoin iontráil seo leis.';

  @override
  String get pointsCannotBelowZero =>
      'Ní féidir le pointí titim faoi bhun náid.';

  @override
  String get selectReason => 'Roghnaigh cúis, le do thoil.';

  @override
  String childPointsBalanceUpdated(String childName, int balance) {
    return 'Tá $balance pointe ag $childName anois.';
  }

  @override
  String get awardPoints => 'Bronn Pointí';

  @override
  String get childAlreadyZeroPoints =>
      'Tá náid pointe ag an bpáiste seo cheana féin.';

  @override
  String get currentBalance => 'Iarmhéid reatha';

  @override
  String childPointsHistory(String childName) {
    return 'Stair Pointí $childName';
  }

  @override
  String get pointsHistoryLoadError =>
      'Níorbh fhéidir stair na bpointí a lódáil.';

  @override
  String get noPointsHistory => 'Níl aon stair pointí ann fós.';

  @override
  String balanceValue(int balance) {
    return 'Iarmhéid: $balance';
  }

  @override
  String get manageRewards => 'Bainistigh luaíochtaí';

  @override
  String get childPointsLoadFailed =>
      'Níorbh fhéidir pointí na bpáistí a lódáil.';

  @override
  String get classroomPoints => 'Pointí an tSeomra Ranga';

  @override
  String get classroomPointsIntro =>
      'Aithin iarracht, dul chun cinn agus éachtaí dearfacha.';

  @override
  String get children => 'Páistí';

  @override
  String get totalPoints => 'Pointí iomlána';

  @override
  String get updatePoints => 'Nuashonraigh Pointí';

  @override
  String get viewHistory => 'Féach ar an Stair';

  @override
  String get createChildBeforePoints =>
      'Cruthaigh próifíl páiste sula mbronntar pointí.';

  @override
  String get reasonGreatEffort => 'Sárobair';

  @override
  String get reasonCompletedActivity => 'Gníomhaíocht críochnaithe';

  @override
  String get reasonKindness => 'Cineáltas';

  @override
  String get reasonHelpingOthers => 'Ag cabhrú le daoine eile';

  @override
  String get reasonGoodListening => 'Éisteacht mhaith';

  @override
  String get reasonPersonalGoal => 'Sprioc phearsanta';

  @override
  String get reasonOther => 'Eile';

  @override
  String get reasonRewardRedeemed => 'Luaíocht fuascailte';

  @override
  String get reasonCorrectEntry => 'Ceartaigh iontráil roimhe seo';

  @override
  String get scheduleMonday => 'Dé Luain';

  @override
  String get scheduleTuesday => 'Dé Máirt';

  @override
  String get scheduleWednesday => 'Dé Céadaoin';

  @override
  String get scheduleThursday => 'Déardaoin';

  @override
  String get scheduleFriday => 'Dé hAoine';

  @override
  String scheduleMinutes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nóiméad',
      one: '1 nóiméad',
    );
    return '$_temp0';
  }

  @override
  String scheduleHours(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uair',
      one: '1 uair',
    );
    return '$_temp0';
  }

  @override
  String scheduleHoursMinutes(Object hours, Object minutes) {
    return '${hours}u ${minutes}n';
  }

  @override
  String scheduleActivityCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ghníomhaíocht',
      one: '1 ghníomhaíocht',
      zero: 'Gan aon ghníomhaíocht',
    );
    return '$_temp0';
  }

  @override
  String scheduleActivityCountToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ghníomhaíocht',
      one: '1 ghníomhaíocht',
      zero: 'Gan aon ghníomhaíocht inniu',
    );
    return '$_temp0';
  }

  @override
  String classroomScheduleTitle(Object classroomName) {
    return 'Sceideal $classroomName';
  }

  @override
  String get staffScheduleTitle => 'Sceideal Foirne';

  @override
  String get scheduleLoadFailed => 'Níorbh fhéidir an sceideal a lódáil.';

  @override
  String get classroomScheduleLoadFailed =>
      'Níorbh fhéidir sceideal an tseomra ranga a lódáil.';

  @override
  String get fillTimeSlot => 'Líon an Bearna Ama';

  @override
  String get duration => 'Fad';

  @override
  String get activityName => 'Ainm na gníomhaíochta';

  @override
  String get activityNameHint => 'Sampla: Léitheoireacht na maidine';

  @override
  String get activityType => 'Cineál gníomhaíochta';

  @override
  String get enterActivityName => 'Cuir ainm gníomhaíochta isteach.';

  @override
  String get activityOverlap =>
      'Forluíonn an fad seo le gníomhaíocht eile sa sceideal.';

  @override
  String get activitySaveFailed =>
      'Níorbh fhéidir an ghníomhaíocht a shábháil.';

  @override
  String get fillSlot => 'Líon an Bhearna';

  @override
  String get saveChanges => 'Sábháil Athruithe';

  @override
  String get clearThisSlot => 'Glan an Bhearna Seo?';

  @override
  String removeActivityFromDay(Object activity, Object day) {
    return 'Bain \"$activity\" de $day?';
  }

  @override
  String get clearSlot => 'Glan an Bhearna';

  @override
  String get activityRemoveFailed =>
      'Níorbh fhéidir an ghníomhaíocht a bhaint.';

  @override
  String get copySchedule => 'Cóipeáil an Sceideal';

  @override
  String copyActivitiesToDay(Object sourceDay) {
    return 'Cóipeáil gach gníomhaíocht ó $sourceDay go:';
  }

  @override
  String get targetDay => 'Sprioclá';

  @override
  String get continueLabel => 'Lean ar aghaidh';

  @override
  String get replaceExistingSchedule => 'Ionadaigh an Sceideal Reatha?';

  @override
  String dayExistingActivityCount(num count, Object day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ghníomhaíocht',
      one: '1 ghníomhaíocht',
    );
    return 'Tá $_temp0 ag $day cheana féin.';
  }

  @override
  String get replace => 'Ionadaigh';

  @override
  String scheduleCopied(Object sourceDay, Object targetDay) {
    return 'Cóipeáladh $sourceDay go $targetDay.';
  }

  @override
  String get scheduleCopyFailed => 'Níorbh fhéidir an sceideal a chóipeáil.';

  @override
  String get copyThisDay => 'Cóipeáil an lá seo';

  @override
  String get copyDay => 'Cóipeáil an Lá';

  @override
  String get tapBlankSlot => 'Tapáil bearna fholamh chun tosú';

  @override
  String get addFifteenMinuteActivity => 'Cuir gníomhaíocht 15 nóiméad leis';

  @override
  String get tapToAddActivity => 'Tapáil chun gníomhaíocht a chur leis';

  @override
  String get editActivityTooltip => 'Cuir an ghníomhaíocht in eagar';

  @override
  String get clearSlotTooltip => 'Glan an bhearna';

  @override
  String get happeningNow => 'Ar Siúl Anois';

  @override
  String get comingNext => 'Ag Teacht Aníos';

  @override
  String nextActivity(Object activity) {
    return 'Ar aghaidh: $activity';
  }

  @override
  String startsAt(Object time) {
    return 'Tosaíonn ag $time';
  }

  @override
  String get todaysActivitiesFinished =>
      'Tá gníomhaíochtaí uile an lae inniu críochnaithe.';

  @override
  String dayToday(Object day) {
    return '$day • Inniu';
  }

  @override
  String get statusNow => 'ANOIS';

  @override
  String get statusNext => 'AR AGHAIDH';

  @override
  String get statusFinished => 'CRÍOCHNAITHE';

  @override
  String nothingScheduledForDay(Object day) {
    return 'Níl aon rud sa sceideal do $day';
  }

  @override
  String get enjoyYourDay => 'Bain sult as do lá!';

  @override
  String get activityTypeLearning => 'Foghlaim';

  @override
  String get activityTypeBreak => 'Sos';

  @override
  String get activityTypeFood => 'Bia';

  @override
  String get activityTypeMovement => 'Gluaiseacht';

  @override
  String get activityTypeTherapy => 'Teiripe';

  @override
  String get activityTypeCreative => 'Cruthaitheacht';

  @override
  String get activityTypeArrival => 'Teacht';

  @override
  String get activityTypeHome => 'Am Dul Abhaile';

  @override
  String get activityTypeOther => 'Eile';
}
