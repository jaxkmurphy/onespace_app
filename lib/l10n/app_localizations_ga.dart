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
  String get edit => 'Cuir in eagar';

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
  String get loading => 'Á lódáil...';

  @override
  String get error => 'Chuaigh rud éigin mícheart';

  @override
  String get all => 'Gach Ceann';

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
  String get handoverStaffDocumentsTab => 'Treoir Foirne';

  @override
  String get handoverQuickNotesTab => 'Meabhrúcháin Ranga';

  @override
  String get readThisFirst => 'Léigh é seo ar dtús';

  @override
  String get startHereDescription =>
      'An treoir riachtanach ranga do mhúinteoirí ionaid, CRSanna, múinteoirí agus baill foirne a bhfuil an t-eolas is tábhachtaí de dhíth orthu go tapa.';

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
    return 'Treoir $staffName';
  }

  @override
  String editStaffDocument(String staffName) {
    return 'Cuir Treoir $staffName in eagar';
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
  String get editQuickNote => 'Cuir Meabhrúchán Ranga in eagar';

  @override
  String get addQuickNote => 'Cuir Meabhrúchán Ranga leis';

  @override
  String get titleLabel => 'Teideal';

  @override
  String get noteLabel => 'Nóta';

  @override
  String get deleteNoteTitle => 'Scrios meabhrúchán?';

  @override
  String get deleteNoteMessage =>
      'An bhfuil tú cinnte gur mhaith leat an meabhrúchán ranga seo a scriosadh?';

  @override
  String get noQuickNotes => 'Níl aon mheabhrúcháin ranga fós.';

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
  String get description => 'Cur síos';

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
  String get selectedChildren => 'Páistí roghnaithe';

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
  String dayExistingActivityCount(Object day, num count) {
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

  @override
  String get schoolName => 'Ainm na Scoile';

  @override
  String get schoolNameHint => 'Sampla: Bunscoil Mhuire';

  @override
  String get schoolCode => 'Cód Scoile';

  @override
  String get schoolCodeHint => 'Sampla: STM123';

  @override
  String get schoolSetupCode => 'Cód Socraithe';

  @override
  String get schoolSetupCodeHint => 'Cód socraithe príobháideach';

  @override
  String get schoolSetupCodeIncorrect => 'Tá an cód socraithe mícheart.';

  @override
  String get adminOnlyArea =>
      'Níl an chuid seo ar fáil ach do riarthóir scoile.';

  @override
  String get schoolRegistrationAlreadyExists =>
      'Tá an cód scoile nó ríomhphost an riarthóra sin in úsáid cheana féin.';

  @override
  String get adminEmail => 'Ríomhphost an Riarthóra';

  @override
  String get password => 'Focal Faire';

  @override
  String get showPassword => 'Taispeáin an focal faire';

  @override
  String get hidePassword => 'Folaigh an focal faire';

  @override
  String get pleaseWait => 'Fan go fóill...';

  @override
  String get createSchoolAdminAccount => 'Cruthaigh Cuntas Riarthóra Scoile';

  @override
  String get adminLogin => 'Logáil Isteach mar Riarthóir';

  @override
  String get existingAdminLogin =>
      'An bhfuil cuntas riarthóra agat? Logáil isteach';

  @override
  String get registerSchoolPrompt => 'Gan cuntas riarthóra? Cláraigh scoil';

  @override
  String get classroomCode => 'Cód Seomra Ranga';

  @override
  String get classroomCodeHint => 'Sampla: ASD1';

  @override
  String get classroomPin => 'PIN an tSeomra Ranga';

  @override
  String get checking => 'Á sheiceáil...';

  @override
  String get enterClassroom => 'Téigh Isteach sa Seomra Ranga';

  @override
  String get createSchoolAdminIntro => 'Cruthaigh cuntas riarthóra scoile';

  @override
  String get adminLoginIntro => 'Logáil isteach mar riarthóir';

  @override
  String get classroomLoginIntro => 'Logáil isteach sa seomra ranga';

  @override
  String get admin => 'Riarthóir';

  @override
  String get classroom => 'Seomra Ranga';

  @override
  String get enterSchoolDetails =>
      'Cuir ainm scoile, cód scoile agus cód socraithe isteach.';

  @override
  String get adminAccountCreateFailed =>
      'Níorbh fhéidir cuntas riarthóra a chruthú.';

  @override
  String get loginFailed => 'Níorbh fhéidir logáil isteach.';

  @override
  String get enterClassroomDetails =>
      'Cuir cód scoile, cód seomra ranga agus PIN isteach.';

  @override
  String get classroomLoginIncorrect =>
      'Tá sonraí logála isteach an tseomra ranga mícheart.';

  @override
  String get classroomLoginTooManyAttempts =>
      'An iomarca iarrachtaí logála isteach. Fan cúpla nóiméad agus bain triail eile as.';

  @override
  String get checkLoginFields => 'Seiceáil na réimsí logála isteach go léir.';

  @override
  String get adminLoginIncorrect =>
      'Tá ríomhphost nó focal faire an riarthóra mícheart.';

  @override
  String get logout => 'Logáil Amach';

  @override
  String get logoutConfirmation =>
      'An bhfuil tú cinnte gur mhaith leat logáil amach?';

  @override
  String get accessDeniedIncorrectPin => 'Diúltaíodh rochtain: PIN mícheart';

  @override
  String get staffProfileDeleted => 'Scriosadh próifíl na foirne';

  @override
  String get childProfileDeleted => 'Scriosadh próifíl an pháiste';

  @override
  String staffProfileDeleteFailed(Object error) {
    return 'Níorbh fhéidir próifíl na foirne a scriosadh: $error';
  }

  @override
  String childProfileDeleteFailed(Object error) {
    return 'Níorbh fhéidir próifíl an pháiste a scriosadh: $error';
  }

  @override
  String get chooseProfile => 'Roghnaigh próifíl chun leanúint ar aghaidh';

  @override
  String get staffProfiles => 'Próifílí Foirne';

  @override
  String get childProfiles => 'Próifílí Páistí';

  @override
  String get staffProfile => 'Próifíl foirne';

  @override
  String get noChildProfilesShort => 'Níor aimsíodh próifílí páistí';

  @override
  String ageValue(Object age) {
    return 'Aois: $age';
  }

  @override
  String get adminActions => 'Gníomhartha Riaracháin';

  @override
  String get addProfile => 'Cuir Próifíl Leis';

  @override
  String get createProfilesIntro => 'Cruthaigh próifílí foirne nó páistí';

  @override
  String get appSettings => 'Socruithe Aipe';

  @override
  String get accountSettings => 'Socruithe Cuntais';

  @override
  String get languageAppOptions => 'Teanga agus roghanna aipe';

  @override
  String get managePinAccountOptions => 'Bainistigh PIN agus roghanna cuntais';

  @override
  String get manageAppSettings => 'Bainistigh socruithe na haipe';

  @override
  String get manageYourAccount => 'Bainistigh do chuntas';

  @override
  String get appSettingsDescription =>
      'Roghnaigh teanga na haipe agus roghanna ginearálta.';

  @override
  String get accountSettingsDescription =>
      'Socraigh do PIN agus roghnaigh teanga na haipe.';

  @override
  String get overwriteExistingPinQuestion => 'Forscríobh an PIN reatha?';

  @override
  String get overwriteExistingPinMessage =>
      'Cuirfidh sé seo PIN nua in áit do PIN reatha. Lean ar aghaidh?';

  @override
  String get pinIsSet => 'Tá PIN socraithe';

  @override
  String get noPinSet => 'Níl PIN socraithe';

  @override
  String get accountPinProtectsStaffAreas =>
      'Cosnaíonn PIN an chuntais limistéir don fhoireann amháin.';

  @override
  String get changePin => 'Athraigh PIN';

  @override
  String get newPinInstructions => 'Cuir PIN nua 4 dhigit isteach.';

  @override
  String get chooseAppLanguage => 'Roghnaigh teanga na haipe.';

  @override
  String staffLoadError(Object error) {
    return 'Earráid agus an fhoireann á lódáil: $error';
  }

  @override
  String childrenLoadError(Object error) {
    return 'Earráid agus páistí á lódáil: $error';
  }

  @override
  String get deleteProfile => 'Scrios próifíl';

  @override
  String get enterPin => 'Cuir PIN isteach';

  @override
  String get pin => 'PIN';

  @override
  String get incorrectPin => 'PIN mícheart';

  @override
  String get submit => 'Cuir isteach';

  @override
  String get clear => 'Glan';

  @override
  String get next => 'Ar Aghaidh';

  @override
  String get startOver => 'Tosaigh Arís';

  @override
  String get success => 'D\'éirigh leis';

  @override
  String get ok => 'Ceart go leor';

  @override
  String get role => 'Ról';

  @override
  String get age => 'Aois';

  @override
  String get nameRequired => 'Tá ainm riachtanach';

  @override
  String get roleRequired => 'Tá ról riachtanach';

  @override
  String get ageRequired => 'Tá aois riachtanach';

  @override
  String get ageNumberRequired => 'Caithfidh an aois a bheith ina huimhir';

  @override
  String get addStaffProfile => 'Cuir Próifíl Foirne Leis';

  @override
  String get addChildProfile => 'Cuir Próifíl Páiste Leis';

  @override
  String get profilesSavedToClassroom =>
      'Sábhálfar próifílí nua sa seomra ranga seo.';

  @override
  String get createStaffProfile => 'Cruthaigh próifíl foirne';

  @override
  String get createChildProfile => 'Cruthaigh próifíl páiste';

  @override
  String get staffProfileAccessInfo =>
      'Úsáideann próifílí foirne PIN an chuntais nó an tseomra ranga chun rochtain a fháil.';

  @override
  String get childProfileAccessInfo =>
      'Is féidir le próifílí páistí seicheamh simplí 3 dheilbhín a úsáid.';

  @override
  String get staffDetails => 'Sonraí Foirne';

  @override
  String get childDetails => 'Sonraí an Pháiste';

  @override
  String get confirmChildUnlock => 'Deimhnigh Seicheamh Díghlasála an Pháiste';

  @override
  String get setChildUnlock => 'Socraigh Seicheamh Díghlasála an Pháiste';

  @override
  String get tapSameIconsConfirm =>
      'Tapáil na 3 dheilbhín chéanna arís lena ndeimhniú.';

  @override
  String get askChildPickIcons =>
      'Iarr ar an bpáiste 3 dheilbhín a roghnú in ord.';

  @override
  String get chooseThreeIconsFirst => 'Roghnaigh 3 dheilbhín ar dtús';

  @override
  String get chooseUnlockSequence =>
      'Roghnaigh seicheamh díghlasála 3 dheilbhín';

  @override
  String get confirmChildUnlockPrompt =>
      'Deimhnigh seicheamh díghlasála an pháiste';

  @override
  String get confirmThreeIconsPrompt =>
      'Tapáil na 3 dheilbhín chéanna arís lena ndeimhniú';

  @override
  String get sequencesDoNotMatch =>
      'Níor mheaitseáil na seichimh. Bain triail eile as.';

  @override
  String profileCreated(Object name) {
    return 'Cruthaíodh próifíl \"$name\" go rathúil.';
  }

  @override
  String profileSaveError(Object error) {
    return 'Earráid agus an phróifíl á sábháil: $error';
  }

  @override
  String get saveStaffProfile => 'Sábháil Próifíl Foirne';

  @override
  String get saveChildProfile => 'Sábháil Próifíl Páiste';

  @override
  String get selectedNone => 'Roghnaithe: Dada';

  @override
  String selectedIcons(Object icons) {
    return 'Roghnaithe: $icons';
  }

  @override
  String selectedCount(Object selected, Object required) {
    return '$selected/$required roghnaithe';
  }

  @override
  String get wrongIconSequence => 'Seicheamh mícheart, bain triail eile as';

  @override
  String unlockChild(Object childName) {
    return 'Díghlasáil $childName';
  }

  @override
  String get tapPicturesInOrder => 'Tapáil do 3 phictiúr in ord';

  @override
  String enteredCount(Object entered, Object required) {
    return 'Curtha isteach: $entered/$required';
  }

  @override
  String resetUnlockForChild(Object childName) {
    return 'Athshocraigh díghlasáil do $childName';
  }

  @override
  String get chooseIconsInOrder => 'Roghnaigh 3 dheilbhín in ord';

  @override
  String get confirmIconSequence => 'Deimhnigh an seicheamh 3 dheilbhín';

  @override
  String get iconSequencesDoNotMatch =>
      'Níor mheaitseáil na seichimh. Bain triail eile as.';

  @override
  String get iconStar => 'Réalta';

  @override
  String get iconCar => 'Carr';

  @override
  String get iconDog => 'Madra';

  @override
  String get iconApple => 'Úll';

  @override
  String get iconBall => 'Liathróid';

  @override
  String get iconMusic => 'Ceol';

  @override
  String get iconSun => 'Grian';

  @override
  String get iconHeart => 'Croí';

  @override
  String schoolAdminTitle(Object schoolName) {
    return 'Riarthóir $schoolName';
  }

  @override
  String get schoolAdminStaffName => 'Riarthóir Scoile';

  @override
  String get schoolSettings => 'Socruithe Scoile';

  @override
  String schoolCodeValue(Object code) {
    return 'Cód Scoile: $code';
  }

  @override
  String classroomsUsed(Object used, Object limit) {
    return 'Seomraí Ranga Úsáidte: $used / $limit';
  }

  @override
  String statusValue(Object status) {
    return 'Stádas: $status';
  }

  @override
  String get active => 'Gníomhach';

  @override
  String get inactive => 'Neamhghníomhach';

  @override
  String classroomsLoadError(Object error) {
    return 'Earráid agus seomraí ranga á lódáil: $error';
  }

  @override
  String get noClassroomsYet =>
      'Níl aon seomra ranga ann fós.\nTapáil + Cuir Seomra Ranga Leis chun ceann a chruthú.';

  @override
  String classroomListSummary(Object code, Object active) {
    return 'Cód: $code • Gníomhach: $active';
  }

  @override
  String get yes => 'Tá';

  @override
  String get no => 'Níl';

  @override
  String get addClassroom => 'Cuir Seomra Ranga Leis';

  @override
  String get classroomCreated => 'Cruthaíodh an seomra ranga';

  @override
  String classroomCreateError(Object error) {
    return 'Earráid agus an seomra ranga á chruthú: $error';
  }

  @override
  String get createClassroom => 'Cruthaigh Seomra Ranga';

  @override
  String get classroomDetails => 'Sonraí an tSeomra Ranga';

  @override
  String get classroomName => 'Ainm an tSeomra Ranga';

  @override
  String get classroomNameHint => 'Sampla: Aonad ASD 1';

  @override
  String get enterClassroomName => 'Cuir ainm seomra ranga isteach';

  @override
  String get enterClassroomCode => 'Cuir cód seomra ranga isteach';

  @override
  String get classroomCodeMinLength =>
      'Caithfidh 3 charachtar ar a laghad a bheith sa chód seomra ranga';

  @override
  String get classroomPinHint => 'Sampla: 1234';

  @override
  String get enterClassroomPin => 'Cuir PIN seomra ranga isteach';

  @override
  String get classroomPinMinLength =>
      'Caithfidh 4 dhigit ar a laghad a bheith sa PIN';

  @override
  String get classroomNotFound => 'Níor aimsíodh an seomra ranga';

  @override
  String classroomLoadError(Object error) {
    return 'Earráid agus an seomra ranga á lódáil: $error';
  }

  @override
  String get classroomUpdated => 'Nuashonraíodh an seomra ranga';

  @override
  String get deleteClassroom => 'Scrios an Seomra Ranga';

  @override
  String get deleteClassroomConfirmation =>
      'An bhfuil tú cinnte gur mhaith leat an seomra ranga seo a scriosadh? Ní féidir é seo a chealú.';

  @override
  String get classroomDeleted => 'Scriosadh an seomra ranga';

  @override
  String classroomDeleteError(Object error) {
    return 'Earráid agus an seomra ranga á scriosadh: $error';
  }

  @override
  String get classroomInformation => 'Eolas faoin Seomra Ranga';

  @override
  String get classroomAccessInfo =>
      'Rialaíonn na sonraí seo conas a fhaigheann an fhoireann rochtain ar an seomra ranga seo.';

  @override
  String get classroomCodeChangeInfo =>
      'Má athraítear an cód seo, athrófar an méid a chuireann an fhoireann isteach ar scáileán logála isteach an tseomra ranga.';

  @override
  String get classroomActive => 'Seomra Ranga Gníomhach';

  @override
  String get classroomInactiveInfo =>
      'Má dhíchumasaítear é, cuirfear bac ar logáil isteach sa seomra ranga seo.';

  @override
  String get saveClassroom => 'Sábháil an Seomra Ranga';

  @override
  String get schoolNotFound => 'Níor aimsíodh an scoil';

  @override
  String schoolSettingsLoadError(Object error) {
    return 'Earráid agus socruithe scoile á lódáil: $error';
  }

  @override
  String get schoolSettingsUpdated => 'Nuashonraíodh socruithe na scoile';

  @override
  String get schoolInformation => 'Eolas faoin Scoil';

  @override
  String get schoolAccountInfo =>
      'Rialaíonn na sonraí seo cuntas na scoile agus logáil isteach an tseomra ranga.';

  @override
  String get enterSchoolName => 'Cuir ainm scoile isteach';

  @override
  String get enterSchoolCode => 'Cuir cód scoile isteach';

  @override
  String get schoolCodeMinLength =>
      'Caithfidh 3 charachtar ar a laghad a bheith sa chód scoile';

  @override
  String get schoolCodeChangeInfo =>
      'Má athraítear cód na scoile, athrófar an méid a chuireann an fhoireann isteach ar scáileán logála isteach an tseomra ranga.';

  @override
  String get classroomLimit => 'Teorainn Seomraí Ranga';

  @override
  String get enterClassroomLimit => 'Cuir teorainn seomraí ranga isteach';

  @override
  String get enterValidNumber => 'Cuir uimhir bhailí isteach';

  @override
  String get classroomLimitMinimum =>
      'Caithfidh teorainn na seomraí ranga a bheith 1 ar a laghad';

  @override
  String get contactDetails => 'Sonraí Teagmhála';

  @override
  String get principalName => 'Ainm an Phríomhoide';

  @override
  String get vicePrincipalName => 'Ainm an Leas-Phríomhoide';

  @override
  String get schoolEmail => 'Ríomhphost na Scoile';

  @override
  String get phoneNumber => 'Uimhir Theileafóin';

  @override
  String get schoolAddress => 'Seoladh na Scoile';

  @override
  String get schoolActive => 'Scoil Ghníomhach';

  @override
  String get schoolInactiveInfo =>
      'Má dhíchumasaítear í amach anseo, is féidir bac a chur ar logáil isteach do sheomraí ranga na scoile seo.';

  @override
  String get saveSchoolSettings => 'Sábháil Socruithe Scoile';

  @override
  String get schoolCodeInUse => 'Tá an cód scoile sin in úsáid cheana féin.';

  @override
  String get classroomCodeInUse =>
      'Tá an cód seomra ranga sin in úsáid cheana féin.';

  @override
  String get classroomLimitReached =>
      'Sroicheadh teorainn na seomraí ranga. Méadaigh an teorainn i Socruithe Scoile.';

  @override
  String get classroomUpdateError =>
      'Níorbh fhéidir an seomra ranga a nuashonrú.';

  @override
  String get schoolSettingsUpdateError =>
      'Níorbh fhéidir socruithe na scoile a nuashonrú.';

  @override
  String get bodyPartHead => 'Ceann';

  @override
  String get bodyPartThroat => 'Scornach';

  @override
  String get bodyPartChest => 'Cliabhrach';

  @override
  String get bodyPartTummy => 'Bolg';

  @override
  String get bodyPartLeftArm => 'Lámh chlé';

  @override
  String get bodyPartRightArm => 'Lámh dheas';

  @override
  String get bodyPartLeftHand => 'Bos chlé';

  @override
  String get bodyPartRightHand => 'Bos dheas';

  @override
  String get bodyPartLeftLeg => 'Cos chlé';

  @override
  String get bodyPartRightLeg => 'Cos dheas';

  @override
  String get bodyPartLeftFoot => 'Crúb chlé';

  @override
  String get bodyPartRightFoot => 'Crúb dheas';

  @override
  String get bodyPartBackOfHead => 'Cúl an chinn';

  @override
  String get bodyPartNeck => 'Muineál';

  @override
  String get bodyPartUpperBack => 'Uachtar an droma';

  @override
  String get bodyPartLowerBack => 'Íochtar an droma';

  @override
  String get bodyMapFront => 'Aghaidh';

  @override
  String get bodyMapBack => 'Cúl';

  @override
  String bodyDiagramSemantics(Object side) {
    return 'Léaráid choirp ón $side. Tapáil an áit a bhfuil pian uirthi.';
  }

  @override
  String get tapSoreBodyPart =>
      'Tapáil an corp san áit a bhfuil pian nó míchompord ort.';

  @override
  String bodyPartSelected(Object bodyPart) {
    return 'Roghnaigh tú: $bodyPart';
  }

  @override
  String get chooseBodyPartList => 'Roghnaigh ó liosta ina ionad';

  @override
  String get painLittleSore => 'Beagán pianmhar';

  @override
  String get painLittleSoreDescription =>
      'Tugaim faoi deara é, ach níl ach beagán pian orm.';

  @override
  String get painHurts => 'Tá pian orm';

  @override
  String get painHurtsShort => 'Pianmhar';

  @override
  String get painHurtsDescription =>
      'Tá sé míchompordach agus teastaíonn cabhair uaim.';

  @override
  String get painHurtsALot => 'Tá go leor pian orm';

  @override
  String get painHurtsALotShort => 'An-phianmhar';

  @override
  String get painHurtsALotDescription =>
      'Tá sé an-phianmhar agus teastaíonn duine fásta uaim anois.';

  @override
  String get painUnknown => 'Anaithnid';

  @override
  String get painSoreAching => 'Tinn nó pianmhar';

  @override
  String get painSoreAchingDescription => 'Pian mhaol nó throm.';

  @override
  String get painSharp => 'Géar';

  @override
  String get painSharpDescription => 'Pian thobann nó ghéar.';

  @override
  String get painBurningHot => 'Dó nó te';

  @override
  String get painBurningHotDescription => 'Mothaíonn sé te nó ar dhó.';

  @override
  String get painItchy => 'Tochasach';

  @override
  String get painItchyDescription => 'Ba mhaith liom é a scríobadh.';

  @override
  String get painThrobbing => 'Ag preabadh';

  @override
  String get painThrobbingDescription => 'Preabann nó buaileann sé.';

  @override
  String get painTinglyNumb => 'Griofadach nó marbhánta';

  @override
  String get painTinglyNumbDescription =>
      'Mothaíonn sé ina chodladh nó aisteach.';

  @override
  String get painSick => 'Tinn';

  @override
  String get painSickDescription => 'Mothaím go mb\'fhéidir go mbeinn tinn.';

  @override
  String get painNotSure => 'Nílim cinnte';

  @override
  String get painNotSureDescription => 'Ní féidir liom an mothúchán a mhíniú.';

  @override
  String get chooseSoreLocation => 'Roghnaigh an áit a bhfuil pian ort.';

  @override
  String get choosePainAmount => 'Roghnaigh cé mhéad pian atá ort.';

  @override
  String get choosePainFeeling => 'Roghnaigh conas a mhothaíonn sé.';

  @override
  String get bodyCheckSendFailed =>
      'Níorbh fhéidir do Sheiceáil Coirp a sheoladh. Inis do dhuine fásta anois.';

  @override
  String get staffHaveBeenTold => 'Cuireadh an Fhoireann ar an Eolas';

  @override
  String get bodyCheckSentMessage =>
      'Seoladh do Sheiceáil Coirp.\n\nInis do dhuine fásta anois má theastaíonn cabhair uait.';

  @override
  String get okay => 'Ceart go leor';

  @override
  String get bodyCheckWhere => 'Cá háit?';

  @override
  String get bodyCheckHowMuch => 'Cé mhéad?';

  @override
  String get bodyCheckWhatFeeling => 'Cén mothúchán?';

  @override
  String get review => 'Athbhreithniú';

  @override
  String bodyCheckStep(Object current, Object total, Object name) {
    return 'Céim $current as $total: $name';
  }

  @override
  String get whereDoesItHurt => 'Cá bhfuil an phian?';

  @override
  String get howMuchDoesItHurt => 'Cé mhéad pian atá ort?';

  @override
  String get choosePainFace =>
      'Roghnaigh an aghaidh is fearr a léiríonn conas a mhothaíonn tú.';

  @override
  String get whatDoesItFeelLike => 'Conas a mhothaíonn sé?';

  @override
  String get choosePainDescription =>
      'Roghnaigh an cur síos is gaire don mhothúchán. Tá sé ceart go leor mura bhfuil tú cinnte.';

  @override
  String get checkYourBodyCheck => 'Seiceáil do Sheiceáil Coirp';

  @override
  String get reviewBodyCheckMessage =>
      'Cinntigh go léiríonn sé seo conas a mhothaíonn tú sula n-insíonn tú don fhoireann.';

  @override
  String get tellAdultBodyCheck =>
      'Má theastaíonn cabhair uait anois, inis do dhuine fásta chomh maith leis an tSeiceáil Coirp seo a sheoladh.';

  @override
  String changeBodyCheckAnswer(Object label) {
    return 'Athraigh $label';
  }

  @override
  String get back => 'Siar';

  @override
  String get sending => 'Á sheoladh...';

  @override
  String get tellStaff => 'Inis don Fhoireann';

  @override
  String get continueButton => 'Lean ar aghaidh';

  @override
  String checkChildReport(Object childName) {
    return 'Seiceáil Tuairisc $childName';
  }

  @override
  String get optionalStaffNote => 'Nóta roghnach foirne';

  @override
  String get staffNoteHint =>
      'Taifead an méid a seiceáladh nó an tacaíocht a tugadh.';

  @override
  String get markChecked => 'Marcáil mar Seiceáilte';

  @override
  String reportMarkedChecked(Object childName) {
    return 'Marcáladh tuairisc $childName mar sheiceáilte.';
  }

  @override
  String get reportUpdateFailed => 'Níorbh fhéidir an tuairisc a nuashonrú.';

  @override
  String get deleteReportQuestion => 'Scrios an Tuairisc?';

  @override
  String deleteBodyCheckReport(Object childName) {
    return 'Scrios an tuairisc Seiceáil Coirp seo do $childName?\n\nNí féidir é seo a chealú.';
  }

  @override
  String get reportDeleteFailed => 'Níorbh fhéidir an tuairisc a scriosadh.';

  @override
  String get classroomBodyChecks => 'Seiceálacha Coirp an tSeomra Ranga';

  @override
  String get classroomBodyChecksIntro =>
      'Athbhreithnigh tuairiscí agus taifead nuair a tugadh tacaíocht.';

  @override
  String get urgent => 'Práinneach';

  @override
  String get unchecked => 'Gan Seiceáil';

  @override
  String get checked => 'Seiceáilte';

  @override
  String get reports => 'Tuairiscí';

  @override
  String get urgentBodyCheckMessage =>
      'Roghnaigh an páiste seo “An-phianmhar” agus níor seiceáladh an tuairisc fós.';

  @override
  String get checkedByStaff => 'Seiceáilte ag an bhfoireann';

  @override
  String checkedAt(Object time) {
    return 'Seiceáilte $time';
  }

  @override
  String get deleteReport => 'Scrios tuairisc';

  @override
  String get needsChecking => 'Le seiceáil';

  @override
  String get noBodyCheckReports => 'Níl aon tuairisc Seiceáil Coirp ann fós';

  @override
  String get bodyCheckReportsAppearHere =>
      'Beidh tuairiscí a sheolann páistí le feiceáil anseo.';

  @override
  String get noReportsMatchFilters =>
      'Ní mheaitseálann aon tuairisc na scagairí seo.';

  @override
  String get bodyCheckReportsLoadFailed =>
      'Tharla earráid agus tuairiscí Seiceáil Coirp á lódáil.';

  @override
  String dateTimeAt(Object date, Object time) {
    return '$date ag $time';
  }

  @override
  String get quizStyleGeneral => 'Ginearálta';

  @override
  String get quizStyleNumbers => 'Uimhreacha';

  @override
  String get quizStyleWords => 'Focail';

  @override
  String get quizStyleScience => 'Eolaíocht';

  @override
  String get quizStyleWorld => 'Ár nDomhan';

  @override
  String get quizStyleMemory => 'Cuimhne';

  @override
  String get quizStyleFun => 'Spraoi';

  @override
  String get enterQuizTitle => 'Cuir teideal tráth na gceist isteach.';

  @override
  String get chooseQuizAudience =>
      'Roghnaigh páiste amháin ar a laghad nó cuir an tráth na gceist ar fáil do chách.';

  @override
  String get addAtLeastOneQuestion => 'Cuir ceist amháin ar a laghad leis.';

  @override
  String get quizUpdatedSuccess => 'Nuashonraíodh an tráth na gceist!';

  @override
  String get quizCreatedSuccess => 'Cruthaíodh an tráth na gceist!';

  @override
  String quizSaveFailed(Object error) {
    return 'Níorbh fhéidir an tráth na gceist a shábháil: $error';
  }

  @override
  String get editYourQuiz => 'Cuir do thráth na gceist in eagar';

  @override
  String get createNewQuiz => 'Cruthaigh tráth na gceist nua';

  @override
  String get quizEditorIntro =>
      'Coinnigh na ceisteanna soiléir, spreagúil agus éasca le tuiscint.';

  @override
  String get quizDetails => 'Sonraí an tráth na gceist';

  @override
  String get quizDetailsIntro =>
      'Tabhair ainm soiléir agus cur síos gairid don tráth na gceist.';

  @override
  String get quizTitle => 'Teideal an tráth na gceist';

  @override
  String get quizTitleHint => 'Mar shampla: Fuaimeanna Ainmhithe';

  @override
  String get quizDescriptionHint =>
      'Cad a chleachtfaidh páistí sa tráth na gceist seo?';

  @override
  String get quizStyle => 'Stíl an tráth na gceist';

  @override
  String get quizStyleIntro => 'Roghnaigh téama cairdiúil amhairc.';

  @override
  String get whoCanPlay => 'Cé atá in ann imirt?';

  @override
  String get quizAudienceIntro =>
      'Cuir ar fáil do chách nó do pháistí roghnaithe é.';

  @override
  String get questions => 'Ceisteanna';

  @override
  String questionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ceist',
      one: '1 cheist',
    );
    return '$_temp0';
  }

  @override
  String get addQuestion => 'Cuir ceist leis';

  @override
  String get addAnotherQuestion => 'Cuir ceist eile leis';

  @override
  String get editQuiz => 'Cuir Tráth na gCeist in Eagar';

  @override
  String get createQuiz => 'Cruthaigh Tráth na gCeist';

  @override
  String questionNumber(Object number) {
    return 'Ceist $number';
  }

  @override
  String get moveUp => 'Bog suas';

  @override
  String get moveDown => 'Bog síos';

  @override
  String get deleteQuestion => 'Scrios an cheist';

  @override
  String get question => 'Ceist';

  @override
  String get questionHint => 'Cad ba mhaith leat a fhiafraí?';

  @override
  String get answers => 'Freagraí';

  @override
  String get correctAnswerInstruction =>
      'Tapáil an ciorcal in aice leis an bhfreagra ceart.';

  @override
  String get correctAnswer => 'Freagra ceart';

  @override
  String get markAsCorrect => 'Marcáil mar cheart';

  @override
  String answerLabel(Object letter) {
    return 'Freagra $letter';
  }

  @override
  String get removeAnswer => 'Bain an freagra';

  @override
  String get addAnswer => 'Cuir freagra leis';

  @override
  String get helpfulExplanation => 'Míniú cabhrach (roghnach)';

  @override
  String get helpfulExplanationHint =>
      'Taispeántar é tar éis don pháiste an cheist a fhreagairt.';

  @override
  String questionNeedsText(Object number) {
    return 'Teastaíonn téacs ó cheist $number.';
  }

  @override
  String questionNeedsAnswers(Object number) {
    return 'Teastaíonn dhá fhreagra ar a laghad ó cheist $number.';
  }

  @override
  String completeQuestionAnswers(Object number) {
    return 'Comhlánaigh gach freagra do cheist $number.';
  }

  @override
  String questionDuplicateAnswers(Object number) {
    return 'Tá freagraí dúblacha i gceist $number.';
  }

  @override
  String chooseCorrectAnswer(Object number) {
    return 'Roghnaigh an freagra ceart do cheist $number.';
  }

  @override
  String get previewNeedsQuestion =>
      'Cuir ceist amháin ar a laghad leis roimh réamhamharc.';

  @override
  String quizCopyTitle(Object title) {
    return 'Cóip de $title';
  }

  @override
  String get quizDuplicated => 'Dúbláladh an tráth na gceist.';

  @override
  String quizDuplicateFailed(Object error) {
    return 'Níorbh fhéidir an tráth na gceist a dhúbláil: $error';
  }

  @override
  String get deleteQuizQuestion => 'Scrios an tráth na gceist?';

  @override
  String deleteQuizConfirmation(Object title) {
    return 'An bhfuil tú cinnte gur mhaith leat “$title” a scriosadh? Coinneofar stair na dtorthaí reatha.';
  }

  @override
  String get quizDeleted => 'Scriosadh an tráth na gceist.';

  @override
  String quizDeleteFailed(Object error) {
    return 'Níorbh fhéidir an tráth na gceist a scriosadh: $error';
  }

  @override
  String get quizzesLoadFailed => 'Níorbh fhéidir tráthanna na gceist a lódáil';

  @override
  String get quizLibraryEmpty =>
      'Tá leabharlann na dtráthanna na gceist folamh';

  @override
  String get createFirstQuiz => 'Cruthaigh do chéad tráth na gceist chun tosú.';

  @override
  String get quizResultsLoadFailed => 'Níorbh fhéidir torthaí a lódáil';

  @override
  String get childProfilesLoadFailedShort =>
      'Níorbh fhéidir próifílí páistí a lódáil.';

  @override
  String get noChildProfiles => 'Níl aon phróifíl páiste ann';

  @override
  String get quizResultsAfterProfiles =>
      'Beidh torthaí tráth na gceist le feiceáil tar éis próifílí a chur leis.';

  @override
  String get quizResults => 'Torthaí tráth na gceist';

  @override
  String get quizResultsIntro =>
      'Iarrachtaí agus scóir le déanaí do gach páiste.';

  @override
  String get quizLibrary => 'Leabharlann Tráth na gCeist';

  @override
  String get results => 'Torthaí';

  @override
  String audienceSelectedCount(Object count) {
    return '$count roghnaithe';
  }

  @override
  String get moreOptions => 'Tuilleadh roghanna';

  @override
  String get duplicate => 'Dúblaigh';

  @override
  String get noDescriptionAdded => 'Níor cuireadh cur síos leis.';

  @override
  String get preview => 'Réamhamharc';

  @override
  String get loadingAttempts => 'Iarrachtaí á lódáil...';

  @override
  String get noQuizAttempts => 'Níl aon iarracht déanta fós';

  @override
  String attemptCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count iarracht',
      one: '1 iarracht',
    );
    return '$_temp0';
  }

  @override
  String get attemptsLoadFailed => 'Níorbh fhéidir iarrachtaí a lódáil.';

  @override
  String get resultsAfterQuiz =>
      'Beidh torthaí le feiceáil tar éis don pháiste tráth na gceist a chríochnú.';

  @override
  String get deletedQuiz => 'Tráth na gceist scriosta';

  @override
  String scoreSummary(Object score, Object total, Object percentage) {
    return '$score/$total • $percentage%';
  }

  @override
  String pointsValue(Object score) {
    return '$score pointe';
  }

  @override
  String get noQuizzesNow => 'Níl aon tráth na gceist ann anois';

  @override
  String get quizWillAppear =>
      'Beidh tráth na gceist nua le feiceáil anseo nuair a bheidh sé réidh duit.';

  @override
  String get childQuizzesLoadFailed =>
      'Níorbh fhéidir do thráthanna na gceist a lódáil';

  @override
  String readyToPlay(Object childName) {
    return 'Réidh le himirt, $childName?';
  }

  @override
  String quizzesToExplore(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tá $count tráth na gceist agat le fiosrú.',
      one: 'Tá 1 tráth na gceist agat le fiosrú.',
    );
    return '$_temp0';
  }

  @override
  String quizzesPlayed(Object count) {
    return '$count imeartha';
  }

  @override
  String get myQuizzes => 'Mo Thráthanna na gCeist';

  @override
  String quizCardSemantics(Object title, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ceist',
      one: '1 cheist',
    );
    return '$title, $_temp0';
  }

  @override
  String get played => 'Imeartha';

  @override
  String get tapToStartQuiz => 'Tapáil chun an tráth na gceist seo a thosú!';

  @override
  String get playAgain => 'Imir Arís';

  @override
  String get letsPlay => 'Imrímis!';

  @override
  String get resultSaveFailed =>
      'Níorbh fhéidir do thoradh a shábháil. Bain triail eile as.';

  @override
  String get leaveQuizQuestion => 'Fág an tráth na gceist?';

  @override
  String get closeQuizPreview => 'Dún réamhamharc an tráth na gceist?';

  @override
  String get unsavedQuizAnswers =>
      'Ní shábhálfar do chuid freagraí san iarracht seo.';

  @override
  String get keepPlaying => 'Lean den Imirt';

  @override
  String get leave => 'Fág';

  @override
  String get quizHasNoQuestions => 'Níl aon cheist sa tráth na gceist seo fós';

  @override
  String get goBack => 'Téigh Siar';

  @override
  String get staffPreviewBanner => 'Réamhamharc Foirne — ní shábhálfar torthaí';

  @override
  String get questionUppercase => 'CEIST';

  @override
  String questionProgress(Object current, Object total) {
    return '$current as $total';
  }

  @override
  String get tapCorrectAnswer => 'Tapáil an freagra a cheapann tú atá ceart.';

  @override
  String get brilliant => 'Thar barr!';

  @override
  String answerIs(Object answer) {
    return 'Is é $answer an freagra.';
  }

  @override
  String get savingResult => 'Do thoradh á shábháil...';

  @override
  String get seeMyResult => 'Féach ar mo Thoradh';

  @override
  String get nextQuestion => 'An Chéad Cheist Eile';

  @override
  String get resultAmazing => 'Iontach!';

  @override
  String get resultPerfectMessage => 'Fuair tú gach ceist ceart!';

  @override
  String get resultGreatWork => 'Obair den scoth!';

  @override
  String get resultGreatMessage => 'Rinne tú jab iontach!';

  @override
  String get resultWellDone => 'Maith thú!';

  @override
  String get resultWellDoneMessage =>
      'Lean tú ort ag iarraidh agus d\'fhoghlaim tú rud nua!';

  @override
  String get resultGoodEffort => 'Iarracht mhaith!';

  @override
  String get resultGoodEffortMessage =>
      'Cuidíonn gach iarracht le d\'intinn fás!';

  @override
  String get previewComplete => 'Réamhamharc críochnaithe';

  @override
  String get previewResultMessage =>
      'Seo mar a bheidh scáileán torthaí an pháiste.';

  @override
  String get closePreview => 'Dún an Réamhamharc';

  @override
  String get backToMyQuizzes => 'Ar Ais chuig Mo Thráthanna na gCeist';

  @override
  String answerSemantics(Object letter, Object answer) {
    return 'Freagra $letter: $answer';
  }

  @override
  String get zoneBlue => 'Crios Gorm';

  @override
  String get zoneGreen => 'Crios Glas';

  @override
  String get zoneYellow => 'Crios Buí';

  @override
  String get zoneRed => 'Crios Dearg';

  @override
  String get zoneBlueChildDescription =>
      'Tá mo chorp ag obair go mall. B\'fhéidir go dteastaíonn scíth, compord nó gluaiseacht shéimh uaim.';

  @override
  String get zoneGreenChildDescription =>
      'Mothaíonn mo chorp socair agus compordach. B\'fhéidir go bhfuilim réidh le foghlaim nó le himirt.';

  @override
  String get zoneYellowChildDescription =>
      'Tá mo chuid fuinnimh ag ardú. B\'fhéidir go dteastaíonn cabhair uaim chun moilliú nó díriú.';

  @override
  String get zoneRedChildDescription =>
      'Tá mo mhothúcháin an-láidir. B\'fhéidir go dteastaíonn spás, sábháilteacht agus tacaíocht uaim.';

  @override
  String get zoneBlueStaffDescription =>
      'Fuinneamh íseal, tuirseach, brónach nó tinn.';

  @override
  String get zoneGreenStaffDescription =>
      'Socair, dírithe, compordach agus réidh.';

  @override
  String get zoneYellowStaffDescription =>
      'Buartha, ar bís, frustrach nó corraitheach.';

  @override
  String get zoneRedStaffDescription =>
      'Mothúcháin an-láidir a dteastaíonn tacaíocht uathu.';

  @override
  String get feelingTired => 'Tuirseach';

  @override
  String get feelingSad => 'Brónach';

  @override
  String get feelingBored => 'Leamh';

  @override
  String get feelingUnwell => 'Tinn';

  @override
  String get feelingSlow => 'Mall';

  @override
  String get feelingCalm => 'Socair';

  @override
  String get feelingFocused => 'Dírithe';

  @override
  String get feelingHappy => 'Sásta';

  @override
  String get feelingContent => 'Sásta compordach';

  @override
  String get feelingReady => 'Réidh';

  @override
  String get feelingWorried => 'Buartha';

  @override
  String get feelingExcited => 'Ar bís';

  @override
  String get feelingFrustrated => 'Frustrach';

  @override
  String get feelingSilly => 'Amaideach';

  @override
  String get feelingRestless => 'Corraitheach';

  @override
  String get feelingAngry => 'Feargach';

  @override
  String get feelingPanicked => 'Scanraithe';

  @override
  String get feelingTerrified => 'An-scanraithe';

  @override
  String get feelingOverwhelmed => 'Faoi léigear';

  @override
  String get feelingOutOfControl => 'As smacht';

  @override
  String zoneSelected(Object zoneName) {
    return 'Roghnaigh tú an $zoneName.';
  }

  @override
  String zoneUpdateFailed(Object error) {
    return 'Níorbh fhéidir do chrios a nuashonrú: $error';
  }

  @override
  String get howAreYouFeeling => 'Conas atá Tú ag Mothú?';

  @override
  String helloChild(Object childName) {
    return 'Dia duit, $childName';
  }

  @override
  String get chooseCurrentZone =>
      'Roghnaigh an crios is cosúla le conas a mhothaíonn tú anois.';

  @override
  String get everyZoneOkay => 'Tá gach crios ceart go leor.';

  @override
  String get thisIsMyZone => 'Seo é mo chrios';

  @override
  String chooseZone(Object zoneName) {
    return 'Roghnaigh $zoneName';
  }

  @override
  String get noBadZones =>
      'Níl aon droch-chrios ann. Tugann ár mothúcháin eolas dúinn faoin méid a d\'fhéadfadh a bheith ag teastáil ónár gcorp.';

  @override
  String get zonesOverview => 'Forbhreathnú ar na Criosanna';

  @override
  String get classroomZonesLoadFailed =>
      'Níorbh fhéidir criosanna an tseomra ranga a lódáil.';

  @override
  String get classroomZones => 'Criosanna an tSeomra Ranga';

  @override
  String get classroomZonesIntro =>
      'Léargas beo ar conas atá na páistí ag mothú.';

  @override
  String get checkedIn => 'Seiceáilte isteach';

  @override
  String get noChildrenInZone => 'Níl aon pháiste sa chrios seo faoi láthair.';

  @override
  String get allChildrenCheckedIn =>
      'Tá a seiceáil isteach criosanna déanta ag gach páiste.';

  @override
  String get notCheckedIn => 'Gan seiceáil isteach';

  @override
  String get noChildProfilesFoundShort => 'Níor aimsíodh próifílí páistí';

  @override
  String get createChildBeforeZones =>
      'Cruthaigh próifíl páiste sula n-úsáideann tú Forbhreathnú na gCriosanna.';

  @override
  String get viewBodyCheckReports => 'Féach ar Thuairiscí Seiceáil Coirp';

  @override
  String get openIncidentLog => 'Oscail Loga na dTeagmhas';

  @override
  String get openSchedule => 'Oscail an Sceideal';

  @override
  String get openZonesOverview => 'Oscail Forbhreathnú na gCriosanna';

  @override
  String get totalChildProfiles => 'Próifílí páistí san iomlán';

  @override
  String get zonesCheckedIn => 'Criosanna seiceáilte isteach';

  @override
  String get childrenWithSelectedZone => 'Páistí a bhfuil crios roghnaithe acu';

  @override
  String get noChildProfilesYet => 'Níl aon phróifíl páiste ann fós.';

  @override
  String get noZone => 'Gan chrios';

  @override
  String childZoneSummary(Object childName, Object zone) {
    return '$childName: $zone';
  }

  @override
  String get noUncheckedBodyChecks =>
      'Níl aon tuairisc Seiceáil Coirp gan seiceáil';

  @override
  String get nothingNeedsReview =>
      'Níl aon rud le hathbhreithniú faoi láthair.';

  @override
  String get uncheckedBodyChecksIntro =>
      'Tuairiscí gan seiceáil a dteastaíonn athbhreithniú foirne uathu';

  @override
  String bodyCheckSummary(Object bodyPart, Object painType, Object date) {
    return '$bodyPart • $painType • $date';
  }

  @override
  String viewAllBodyChecks(Object count) {
    return 'Féach ar gach ceann de na $count tuairisc Seiceáil Coirp';
  }

  @override
  String get scheduleSaturday => 'Dé Sathairn';

  @override
  String get scheduleSunday => 'Dé Domhnaigh';

  @override
  String noScheduleEntriesForDay(Object day) {
    return 'Níl aon iontráil sceidil do $day';
  }

  @override
  String get nothingScheduledTodayYet =>
      'Níor cuireadh aon rud leis don lá inniu fós.';

  @override
  String get noImportantIncidents => 'Níl aon teagmhas tábhachtach le déanaí';

  @override
  String get noImportantIncidentsIntro =>
      'Níor aimsíodh aon teagmhas meánach/ard le hathbhreithniú.';

  @override
  String get severityHigh => 'Ard';

  @override
  String get severityMedium => 'Meánach';

  @override
  String get severityLow => 'Íseal';

  @override
  String incidentSummary(Object severity, Object date, Object description) {
    return '$severity • $date\n$description';
  }

  @override
  String todayOverviewForStaff(Object staffName) {
    return 'Forbhreathnú tapa ar an seomra ranga do $staffName.';
  }

  @override
  String get quickActions => 'Gníomhartha Tapa';

  @override
  String get zonesSnapshot => 'Léargas ar na Criosanna';

  @override
  String get bodyCheckAttention => 'Aird ar Sheiceáil Coirp';

  @override
  String get todaysSchedule => 'Sceideal an Lae Inniu';

  @override
  String get recentImportantIncidents => 'Teagmhais Tábhachtacha / le Déanaí';

  @override
  String get chooseMyBackground => 'Roghnaigh Mo Chúlra';

  @override
  String get makeItYours => 'Déan Duit Féin É';

  @override
  String get chooseComfortableDashboardColour =>
      'Roghnaigh dath compordach do do dheais.';

  @override
  String get myZones => 'Mo Chriosanna';

  @override
  String get colourChoices => 'Roghanna Datha';

  @override
  String get useThisBackground => 'Úsáid an Cúlra Seo';

  @override
  String get backgroundColourUpdated => 'Nuashonraíodh dath an chúlra.';

  @override
  String get backgroundColourUpdateFailed =>
      'Níorbh fhéidir dath an chúlra a nuashonrú.';

  @override
  String get backgroundClassicWhite => 'Bán Scamaill';

  @override
  String get backgroundClassicWhiteDescription => 'Geal agus simplí';

  @override
  String get backgroundSoftRose => 'Bándearg Guma Bolgáin';

  @override
  String get backgroundSoftRoseDescription => 'Sona agus te';

  @override
  String get backgroundClearSky => 'Gorm Spéire';

  @override
  String get backgroundClearSkyDescription => 'Socair agus soiléir';

  @override
  String get backgroundFreshMint => 'Glas Miontais';

  @override
  String get backgroundFreshMintDescription => 'Úr agus séimh';

  @override
  String get backgroundWarmSunshine => 'Buí Grianmhar';

  @override
  String get backgroundWarmSunshineDescription => 'Geal agus sona';

  @override
  String get backgroundSoftLavender => 'Corcra Labhandair';

  @override
  String get backgroundSoftLavenderDescription => 'Bog agus cluthar';

  @override
  String get backgroundGentleGrey => 'Téal Aigéin';

  @override
  String get backgroundGentleGreyDescription => 'Fionnuar agus dírithe';

  @override
  String get backgroundWarmPeach => 'Oráiste Péitseoige';

  @override
  String get backgroundWarmPeachDescription => 'Te agus cairdiúil';

  @override
  String unlockSequenceResetFor(Object childName) {
    return 'Athshocraíodh seicheamh díghlasála do $childName';
  }

  @override
  String unlockSequenceResetFailed(Object error) {
    return 'Níorbh fhéidir an seicheamh a athshocrú: $error';
  }

  @override
  String scheduleTimeRange(Object start, Object end) {
    return '$start - $end';
  }

  @override
  String get missingAdminDashboardDetails =>
      'Tá sonraí an deais riaracháin ar iarraidh.';

  @override
  String get missingChildProfile => 'Tá próifíl an pháiste ar iarraidh.';

  @override
  String get missingStaffProfile => 'Tá próifíl foirne ar iarraidh.';

  @override
  String get missingQuizCreator =>
      'Tá cruthaitheoir an tráth na gceist ar iarraidh.';

  @override
  String get missingTeacherId => 'Tá aitheantas an mhúinteora ar iarraidh.';

  @override
  String get missingQuiz => 'Tá an tráth na gceist ar iarraidh.';

  @override
  String get missingStudentQuizDetails =>
      'Tá sonraí thráth na gceist an dalta ar iarraidh.';

  @override
  String get missingWhenThenChildDetails =>
      'Tá sonraí páiste When–Then ar iarraidh.';

  @override
  String get missingCircleTimeDetails => 'Tá sonraí Circle Time ar iarraidh.';

  @override
  String get missingBodyCheckDetails => 'Tá sonraí Seiceáil Coirp ar iarraidh.';

  @override
  String get missingBodyCheckOverviewDetails =>
      'Tá sonraí fhorbhreathnú Seiceáil Coirp ar iarraidh.';

  @override
  String get invalidRouteOrMissingArguments =>
      'Bealach neamhbhailí nó argóintí ar iarraidh.';

  @override
  String get missingSchoolId => 'Tá aitheantas na scoile ar iarraidh';

  @override
  String get missingClassroomDetails =>
      'Tá sonraí an tseomra ranga ar iarraidh';

  @override
  String get staffProfileNotFound => 'Níor aimsíodh an Phróifíl Foirne';

  @override
  String get childProfileNotFound => 'Níor aimsíodh Próifíl an Pháiste';

  @override
  String get returnToProfiles => 'Fill ar Phróifílí';

  @override
  String get iMightFeel => 'B\'fhéidir go mothóinn:';

  @override
  String get activeClassrooms => 'Seomraí ranga gníomhacha';

  @override
  String get inactiveClassrooms => 'Seomraí ranga neamhghníomhacha';

  @override
  String get deactivate => 'Díghníomhachtaigh';

  @override
  String get deactivateClassroom => 'Díghníomhachtaigh Seomra Ranga';

  @override
  String get deactivateClassroomConfirmation =>
      'Díghníomhachtaigh an seomra ranga seo? Ní bheidh foireann in ann logáil isteach a thuilleadh, ach coinneofar na sonraí.';

  @override
  String get classroomDeactivated => 'Díghníomhachtaíodh an seomra ranga.';

  @override
  String classroomDeactivateError(Object error) {
    return 'Níorbh fhéidir an seomra ranga a dhíghníomhachtú: $error';
  }

  @override
  String get reactivate => 'Athghníomhachtaigh';

  @override
  String get reactivateClassroom => 'Athghníomhachtaigh Seomra Ranga';

  @override
  String get reactivateClassroomConfirmation =>
      'Athghníomhachtaigh an seomra ranga seo? Beidh foireann in ann logáil isteach arís.';

  @override
  String get classroomReactivated => 'Athghníomhachtaíodh an seomra ranga.';

  @override
  String classroomReactivateError(Object error) {
    return 'Níorbh fhéidir an seomra ranga a athghníomhachtú: $error';
  }

  @override
  String get accessDetails => 'Sonraí Rochtana';

  @override
  String get copy => 'Cóipeáil';

  @override
  String get schoolCodeCopied => 'Cóipeáladh cód na scoile.';

  @override
  String get classroomCodeCopied => 'Cóipeáladh cód an tseomra ranga.';

  @override
  String get classroomPinCopied => 'Cóipeáladh PIN an tseomra ranga.';

  @override
  String get copyAllLoginDetails => 'Cóipeáil Gach Sonra Logála Isteach';

  @override
  String get classroomAccessDetailsCopied =>
      'Cóipeáladh sonraí logála isteach an tseomra ranga.';

  @override
  String get calmPlan => 'Plean Suaimhnis';

  @override
  String get calmRequests => 'Iarratais';

  @override
  String get calmTools => 'Uirlisí';

  @override
  String calmRequestResolved(Object name) {
    return 'Réitíodh iarratas suaimhnis $name.';
  }

  @override
  String calmRequestResolveError(Object error) {
    return 'Níorbh fhéidir an t-iarratas a réiteach: $error';
  }

  @override
  String get calmDefaultsAdded =>
      'Cuireadh na huirlisí suaimhnis réamhshocraithe leis.';

  @override
  String calmDefaultsAddError(Object error) {
    return 'Níorbh fhéidir na réamhshocruithe a chur leis: $error';
  }

  @override
  String get calmToolAdded => 'Cuireadh uirlis suaimhnis leis.';

  @override
  String calmToolAddError(Object error) {
    return 'Níorbh fhéidir an uirlis a chur leis: $error';
  }

  @override
  String get calmToolUpdated => 'Nuashonraíodh an uirlis suaimhnis.';

  @override
  String calmToolUpdateError(Object error) {
    return 'Níorbh fhéidir an uirlis a nuashonrú: $error';
  }

  @override
  String get deleteCalmToolQuestion => 'Scrios uirlis suaimhnis?';

  @override
  String deleteCalmToolMessage(Object name) {
    return 'Bainfidh sé seo “$name” den liosta uirlisí suaimhnis do pháistí.';
  }

  @override
  String get calmToolDeleted => 'Scriosadh an uirlis suaimhnis.';

  @override
  String calmToolDeleteError(Object error) {
    return 'Níorbh fhéidir an uirlis a scriosadh: $error';
  }

  @override
  String get calmRequestsLoadFailed =>
      'Níorbh fhéidir iarratais suaimhnis a lódáil.';

  @override
  String get calmSupportRequestsTitle => 'Iarratais tacaíochta suaimhnis';

  @override
  String get calmSupportRequestsSubtitle =>
      'Féach cé a d’iarr cabhair, cad a roghnaigh siad, agus cé a réitigh é.';

  @override
  String get activeRequests => 'Iarratais ghníomhacha';

  @override
  String get noActiveCalmRequests =>
      'Níl aon iarratas tacaíochta suaimhnis gníomhach.';

  @override
  String calmRequestsWaiting(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'iarratas',
      one: 'iarratas',
    );
    return '$count $_temp0 ag fanacht';
  }

  @override
  String get allCalmRequestsResolved =>
      'Tá gach iarratas tacaíochta suaimhnis réitithe.';

  @override
  String get recentSupportHistory => 'Stair tacaíochta le déanaí';

  @override
  String get resolvedRequestsAppearHere =>
      'Beidh iarratais réitithe le feiceáil anseo.';

  @override
  String resolvedCalmRequestCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'iarratas réitithe',
      one: 'iarratas réitithe',
    );
    return '$count $_temp0';
  }

  @override
  String get noResolvedCalmRequests =>
      'Níl aon iarratas tacaíochta suaimhnis réitithe fós.';

  @override
  String get calmToolsLoadFailed =>
      'Níorbh fhéidir uirlisí suaimhnis a lódáil.';

  @override
  String get calmToolsTitle => 'Uirlisí suaimhnis';

  @override
  String get calmToolsSubtitle =>
      'Roghnaigh na roghanna suaimhnis is féidir le páistí a úsáid nuair a theastaíonn tacaíocht uathu.';

  @override
  String get addCalmTool => 'Cuir uirlis leis';

  @override
  String get saveDefaultsToClassroom => 'Sábháil réamhshocruithe don seomra';

  @override
  String get addDefaultsIfEmpty => 'Cuir réamhshocruithe leis má tá sé folamh';

  @override
  String get previewDefaultsTitle => 'Réamhamharc ar uirlisí réamhshocraithe';

  @override
  String get previewDefaultsMessage =>
      'Tá na huirlisí réamhshocraithe seo á dtaispeáint mar réamhamharc. Sábháil iad don seomra ranga seo sula gcuirtear in eagar, sula ndíchumasaítear, nó sula scriostar iad.';

  @override
  String get noCalmTools =>
      'Níl aon uirlis suaimhnis fós. Cuir ceann leis nó síolraigh na réamhshocruithe.';

  @override
  String get aChild => 'Páiste';

  @override
  String get calmSupport => 'tacaíocht suaimhnis';

  @override
  String get notResolvedYet => 'Níl sé réitithe fós';

  @override
  String childAskedForHelp(Object name) {
    return 'D’iarr $name cabhair';
  }

  @override
  String get resolved => 'Réitithe';

  @override
  String resolvedBy(Object name) {
    return 'Réitithe ag $name';
  }

  @override
  String get markResolved => 'Marcáil mar réitithe';

  @override
  String get oneMinuteAgo => '1 nóim ó shin';

  @override
  String minutesAgo(int count) {
    return '$count nóim ó shin';
  }

  @override
  String get oneHourAgo => '1 uair ó shin';

  @override
  String hoursAgo(int count) {
    return '$count uair ó shin';
  }

  @override
  String get oneDayAgo => '1 lá ó shin';

  @override
  String daysAgo(Object count) {
    return '$count lá ó shin';
  }

  @override
  String get editCalmTool => 'Cuir uirlis suaimhnis in eagar';

  @override
  String get calmToolName => 'Ainm na huirlise';

  @override
  String get calmToolNameHint => 'Sampla: Áit chiúin';

  @override
  String get calmToolDescriptionHint =>
      'Sampla: Téigh go háit chiúin agus shuaimhneach.';

  @override
  String get chooseCalmToolIcon => 'Roghnaigh deilbhín don uirlis suaimhnis';

  @override
  String get enable => 'Cumasaigh';

  @override
  String get disable => 'Díchumasaigh';

  @override
  String get classroomHelper => 'Cúntóir Seomra Ranga';

  @override
  String get childClassroomHelperSubtitle =>
      'Roghnaigh jab ranga agus taispeáin conas a chabhraigh tú.';

  @override
  String get staffClassroomHelperSubtitle =>
      'Bainistigh jabanna cúntóra agus chuimhneacháin chabhracha le déanaí.';

  @override
  String get classroomHelperStaffTitle => 'Cúntóir Seomra Ranga';

  @override
  String get classroomHelperStaffIntro =>
      'Roghnaigh na jabanna cúntóra atá ar fáil agus féach ar chuimhneacháin chabhracha le déanaí.';

  @override
  String classroomHelperChildTitle(Object name) {
    return 'Conas is féidir leat cabhrú inniu, $name?';
  }

  @override
  String get classroomHelperChildIntro =>
      'Roghnaigh jab nuair a chabhraigh tú leis an rang.';

  @override
  String get classroomHelperStarterJobsPreview =>
      'Tá na jabanna tosaithe seo réidh le húsáid. Sábháil iad sula ndéanann tú eagarthóireacht, díchumasú nó scriosadh.';

  @override
  String get classroomHelperSaveStarterJobs => 'Sábháil jabanna tosaithe';

  @override
  String get classroomHelperStarterJobsSaved => 'Sábháladh jabanna tosaithe.';

  @override
  String classroomHelperSaveFailed(Object error) {
    return 'Níorbh fhéidir jabanna cúntóra a shábháil: $error';
  }

  @override
  String get classroomHelperThankYouTitle => 'Go raibh maith agat as cabhrú!';

  @override
  String get classroomHelperThankYouMessage =>
      'Feicfidh múinteoir gur chabhraigh tú leis an rang.';

  @override
  String get classroomHelperAddJob => 'Cuir jab leis';

  @override
  String get classroomHelperEditJob => 'Cuir jab in eagar';

  @override
  String get classroomHelperDescriptionLabel =>
      'Cad ba chóir don chúntóir a dhéanamh?';

  @override
  String get classroomHelperChooseIcon => 'Roghnaigh deilbhín don jab';

  @override
  String get classroomHelperActiveJob => 'Ar fáil do pháistí';

  @override
  String get classroomHelperJobSaved => 'Sábháladh an jab cúntóra.';

  @override
  String get classroomHelperDeleteJob => 'Scrios jab cúntóra';

  @override
  String classroomHelperDeleteJobMessage(Object title) {
    return 'Scrios “$title”?\n\nNí féidir é seo a chealú.';
  }

  @override
  String get classroomHelperJobDeleted => 'Scriosadh an jab cúntóra.';

  @override
  String get classroomHelperNoJobs => 'Níl aon jab cúntóra ann fós';

  @override
  String get classroomHelperNoJobsSubtitle =>
      'Is féidir leis an bhfoireann jabanna cúntóra a chur leis don seomra ranga.';

  @override
  String get classroomHelperIHelped => 'Chabhraigh mé';

  @override
  String get classroomHelperRecentHelp => 'Cabhair le déanaí';

  @override
  String get classroomHelperNoRecentHelp => 'Níor taifeadadh aon chabhair fós.';

  @override
  String classroomHelperCompletionLine(Object childName, Object jobTitle) {
    return 'Chabhraigh $childName le $jobTitle';
  }

  @override
  String get classroomHelperLoadFailed =>
      'Níorbh fhéidir Cúntóir Seomra Ranga a lódáil.';

  @override
  String get classroomHelperJustNow => 'Anois díreach';

  @override
  String get classroomHelperMinuteAgo => '1 nóim ó shin';

  @override
  String classroomHelperMinutesAgo(Object count) {
    return '$count nóim ó shin';
  }

  @override
  String get classroomHelperHourAgo => '1 uair ó shin';

  @override
  String classroomHelperHoursAgo(Object count) {
    return '$count uair ó shin';
  }

  @override
  String get classroomHelperDayAgo => '1 lá ó shin';

  @override
  String classroomHelperDaysAgo(Object count) {
    return '$count lá ó shin';
  }

  @override
  String classroomHelperAssignJob(Object title) {
    return 'Sann $title';
  }

  @override
  String get classroomHelperAllChildren => 'Gach páiste';

  @override
  String get classroomHelperAssign => 'Sann';

  @override
  String get classroomHelperAssigned => 'Sannadh an jab cúntóra.';

  @override
  String get classroomHelperRequestSent => 'Seiceálfaidh múinteoir do jab.';

  @override
  String get classroomHelperConfirmed => 'Deimhníodh an jab cúntóra.';

  @override
  String get classroomHelperRequestCleared => 'Glanadh an t-iarratas.';

  @override
  String get classroomHelperAssignmentCleared => 'Glanadh an jab cúntóra.';

  @override
  String classroomHelperNoAssignedJobTitle(Object name) {
    return 'Níl jab cúntóra agat anois, $name';
  }

  @override
  String get classroomHelperNoAssignedJobMessage =>
      'Is féidir le múinteoir jab cúntóra ranga a thabhairt duit nuair atá sé do sheal.';

  @override
  String get classroomHelperMyJobToday => 'Mo jab cúntóra inniu';

  @override
  String get classroomHelperWaitingForTeacher =>
      'Ag fanacht le múinteoir é a sheiceáil';

  @override
  String get classroomHelperDidIFinish => 'Ar chríochnaigh mé mo jab?';

  @override
  String get classroomHelperPendingRequests => 'Le seiceáil';

  @override
  String get classroomHelperPendingRequestsSubtitle =>
      'Páistí ag fiafraí an bhfuil a jab cúntóra críochnaithe.';

  @override
  String get classroomHelperNoPendingRequests =>
      'Níl aon jab cúntóra ag fanacht le seiceáil.';

  @override
  String classroomHelperFinishRequestLine(Object childName, Object jobTitle) {
    return 'Fiafraíonn $childName: ar chríochnaigh mé $jobTitle?';
  }

  @override
  String get classroomHelperNotYet => 'Ní fós';

  @override
  String get classroomHelperConfirm => 'Deimhnigh';

  @override
  String get classroomHelperCurrentAssignments => 'Sannacháin reatha';

  @override
  String get classroomHelperOneJobPerChild =>
      'Cruann jabanna do gach páiste. Taispeántar an jab neamhchríochnaithe is sine ar dtús.';

  @override
  String classroomHelperQueuedJobs(Object count) {
    return '$count ag fanacht';
  }

  @override
  String get classroomHelperNoJobAssigned => 'Níl jab sannta';

  @override
  String get classroomHelperClearJob => 'Glan jab';

  @override
  String get classroomHelperJobLibrary => 'Leabharlann jabanna';

  @override
  String get classroomHelperJobLibrarySubtitle =>
      'Cruthaigh jabanna, ansin sann iad do pháiste amháin, roinnt páistí nó gach duine.';

  @override
  String get classroomHelperCompletedLog => 'Log jabanna críochnaithe';

  @override
  String get classroomHelperCompletedLogSubtitle =>
      'Jabanna cúntóra deimhnithe a chríochnaigh páistí.';

  @override
  String get classroomHelperFilterByChild => 'Scag de réir páiste';

  @override
  String classroomHelperConfirmedBy(Object staffName) {
    return 'Deimhnithe ag $staffName';
  }

  @override
  String get staffAlertsLoadFailed =>
      'Níorbh fhéidir foláirimh an tseomra ranga a lódáil.';

  @override
  String get staffAlertsNeedsAttention => 'Teastaíonn aird';

  @override
  String staffAlertsActiveCount(num count) {
    return '$count foláireamh gníomhach';
  }

  @override
  String staffAlertsMoreCount(num count) {
    return '+$count foláireamh eile';
  }

  @override
  String staffAlertsBodyCheckSubmitted(Object childName) {
    return 'Sheol $childName seiceáil coirp';
  }

  @override
  String get staffAlertsUnknownChild => 'Páiste';

  @override
  String staffAlertsCalmRequestResolved(Object childName) {
    return 'Réitíodh iarratas suaimhnis $childName.';
  }

  @override
  String staffAlertsCalmResolveFailed(Object error) {
    return 'Níorbh fhéidir an t-iarratas suaimhnis a réiteach: $error';
  }

  @override
  String staffAlertsCalmNeedsSupport(Object childName) {
    return 'Teastaíonn tacaíocht suaimhnis ó $childName';
  }

  @override
  String staffAlertsCalmSelected(Object toolName, Object time) {
    return 'Roghnaithe: $toolName • $time';
  }

  @override
  String get handoverStaffGuidanceDescription =>
      'Treoir phraiticiúil ranga ó bhaill foirne a bhfuil aithne mhaith acu ar an seomra seo.';

  @override
  String get handoverClassroomRemindersDescription =>
      'Meabhrúcháin ghearra don rang iomlán do bhaill foirne, múinteoirí ionaid agus CRSanna.';

  @override
  String get childNotes => 'Nótaí Páistí';

  @override
  String get childNotesSubtitle =>
      'Nótaí foirne comhroinnte agus príobháideacha do gach páiste.';

  @override
  String get staffChildNotesSubtitle =>
      'Scríobh nótaí foirne comhroinnte nó príobháideacha do pháistí.';

  @override
  String get addChildProfilesBeforeNotes =>
      'Cuir próifílí páistí leis sula gcruthaíonn tú nótaí páistí.';

  @override
  String couldNotLoadChildren(String error) {
    return 'Níorbh fhéidir na páistí a luchtú: $error';
  }

  @override
  String couldNotLoadNotes(String error) {
    return 'Níorbh fhéidir na nótaí a luchtú: $error';
  }

  @override
  String couldNotSaveNote(String error) {
    return 'Níorbh fhéidir an nóta a shábháil: $error';
  }

  @override
  String get noteAdded => 'Cuireadh an nóta leis.';

  @override
  String get noteUpdated => 'Nuashonraíodh an nóta.';

  @override
  String visibleNoteCount(int count) {
    return '$count le feiceáil';
  }

  @override
  String sharedNoteCount(int count) {
    return '$count comhroinnte';
  }

  @override
  String privateNoteCount(int count) {
    return '$count príobháideach';
  }

  @override
  String get child => 'Páiste';

  @override
  String get allChildren => 'Gach páiste';

  @override
  String get allCategories => 'Gach catagóir';

  @override
  String get category => 'Catagóir';

  @override
  String get allVisible => 'Gach ceann le feiceáil';

  @override
  String get myNotes => 'Mo nótaí';

  @override
  String get shared => 'Comhroinnte';

  @override
  String get private => 'Príobháideach';

  @override
  String get general => 'Ginearálta';

  @override
  String get sensory => 'Céadfach';

  @override
  String get health => 'Sláinte';

  @override
  String get parent => 'Tuismitheoir';

  @override
  String get noNotesForChildYet => 'Níl aon nótaí don pháiste seo fós.';

  @override
  String get chooseChildOrAddFirstNote =>
      'Roghnaigh páiste nó cuir do chéad nóta leis.';

  @override
  String get chooseChildToAddNote =>
      'Chun nóta a chur leis, roghnaigh páiste ón roghchlár anuas ar dtús.';

  @override
  String addNoteForChild(String childName) {
    return 'Cuir nóta le $childName';
  }

  @override
  String get editNote => 'Cuir nóta in eagar';

  @override
  String get saveNote => 'Sábháil nóta';

  @override
  String get pleaseWriteNoteFirst => 'Scríobh nóta ar dtús le do thoil.';

  @override
  String get privateNoteStaffOnly =>
      'Nóta príobháideach - le feiceáil agatsa amháin sa radharc foirne seo.';

  @override
  String get privateNoteExplanation =>
      'Tá nótaí príobháideacha i bhfolach ó bhaill foirne eile san aip. Tá siad réidh don todhchaí do rialacha níos láidre ag leibhéal foirne.';

  @override
  String get sharedNoteExplanation =>
      'Is féidir le baill foirne sa seomra ranga seo nótaí comhroinnte a fheiceáil.';

  @override
  String get classroomSnapshot => 'Léargas ar an seomra ranga';

  @override
  String get classroomSnapshotHint =>
      'Cé atá sa seomra, conas atá an rang, agus an gearrléargas ba chóir do mhúinteoir ionaid a léamh ar dtús.';

  @override
  String get todayRoutine => 'Príomhghnáthamh an lae inniu';

  @override
  String get todayRoutineHint =>
      'Sonraí tábhachtacha faoin ngnáthamh, aistrithe, nótaí ama, nó athruithe don lá inniu.';

  @override
  String get mustKnow => 'Eolas riachtanach';

  @override
  String get mustKnowHint =>
      'Rudaí nach féidir a scipeáil, comhthéacs tábhachtach, agus na rudaí nár chóir don fhoireann a chailleadh.';

  @override
  String get safetySupports => 'Nótaí sábháilteachta agus tacaíochta';

  @override
  String get safetySupportsHint =>
      'Treoir sábháilteachta don rang iomlán, riachtanais tacaíochta, riachtanais chéadfacha, nó nótaí ardaithe. Seachain sonraí príobháideacha nach bhfuil riachtanach.';

  @override
  String get checkFirst => 'Seice?il ar dtús in OneSpace';

  @override
  String get checkFirstHint =>
      'Na codanna den aip ba chóir don fhoireann a sheiceáil ar dtús, mar shampla Forbhreathnú an Lae, Nótaí Páistí, Body Check, nó Calm Plan.';

  @override
  String get urgentGuidance => 'Treoir phráinneach';

  @override
  String get urgentGuidanceHint =>
      'Cad ba chóir don fhoireann a dhéanamh láithreach má tá rud éigin práinneach nó doiléir.';

  @override
  String get relatedStaffTools => 'Uirlisí foirne gaolmhara';

  @override
  String get relatedStaffToolsDescription =>
      'Téigh díreach chuig na huirlisí is úsáidí le linn aistrithe eolais ranga.';

  @override
  String get todayOverviewShortcutSubtitle => 'Féach ar phictiúr beo an ranga.';

  @override
  String get childNotesShortcutSubtitle => 'Léigh nótaí foirne faoi pháistí.';

  @override
  String get calmPlanShortcutSubtitle =>
      'Seice?il uirlisí calma agus iarratais.';

  @override
  String get bodyCheckShortcutSubtitle => 'Seice?il tuairiscí coirp ó pháistí.';

  @override
  String get classroomHelperShortcutSubtitle =>
      'Seice?il poist chabhrach agus iarratais.';

  @override
  String get guidanceAdded => 'Cuireadh treoir leis';

  @override
  String get guidanceNeeded => 'Treoir de dhíth';

  @override
  String get priority => 'Tosaíocht';

  @override
  String get normalPriority => 'Gnáth';

  @override
  String get important => 'Tábhachtach';

  @override
  String get pinReminder => 'Pionnáil meabhrúchán';

  @override
  String get pinReminderDescription =>
      'Fanann meabhrúcháin phionnáilte os cionn meabhrúcháin eile an ranga.';

  @override
  String get pinned => 'Pionnáilte';

  @override
  String get contactDirectory => 'Eolaire Teagmhálaithe';

  @override
  String get contactDirectoryAdminSubtitle =>
      'Bainistigh teagmhálaithe ríomhphoist foirne agus tuismitheoirí/caomhnóirí le haghaidh tuairiscí agus cumarsáide.';

  @override
  String get staffContacts => 'Teagmhálaithe Foirne';

  @override
  String get guardianContacts => 'Teagmhálaithe Tuismitheora / Caomhnóra';

  @override
  String get staffContactsDescription =>
      'Teagmhálaithe ríomhphoist foirne scoile. Is féidir iad seo a nascadh le huirlisí cumarsáide níos déanaí.';

  @override
  String get guardianContactsDescription =>
      'Teagmhálaithe tuismitheora agus caomhnóra sannta do phróifíl pháiste ar leith.';

  @override
  String contactCount(int count) {
    return '$count teagmháil';
  }

  @override
  String get addContact => 'Cuir teagmháil leis';

  @override
  String get addStaffContact => 'Cuir teagmháil foirne leis';

  @override
  String get addGuardianContact => 'Cuir teagmháil caomhnóra leis';

  @override
  String get editContact => 'Cuir teagmháil in eagar';

  @override
  String get deleteContact => 'Scrios teagmháil';

  @override
  String deleteContactMessage(String name) {
    return 'Scrios ?$name? ón eolaire teagmhálaithe?';
  }

  @override
  String get contactAdded => 'Cuireadh an teagmháil leis.';

  @override
  String get contactUpdated => 'Nuashonraíodh an teagmháil.';

  @override
  String get contactDeleted => 'Scriosadh an teagmháil.';

  @override
  String contactSaveFailed(String error) {
    return 'Níorbh fhéidir an teagmháil a shábháil: $error';
  }

  @override
  String contactDeleteFailed(String error) {
    return 'Níorbh fhéidir an teagmháil a scriosadh: $error';
  }

  @override
  String contactsLoadFailed(String error) {
    return 'Níorbh fhéidir na teagmhálaithe a luchtú: $error';
  }

  @override
  String get noStaffContacts => 'Níl aon teagmhálaithe foirne fós.';

  @override
  String get noStaffContactsDescription =>
      'Cuir ríomhphoist foirne leis a d’fhéadfadh a bheith úsáideach do chumarsáid scoile níos déanaí.';

  @override
  String get noGuardianContacts =>
      'Níl aon teagmhálaithe tuismitheora nó caomhnóra fós.';

  @override
  String get noGuardianContactsDescription =>
      'Cuir ríomhphoist chaomhnóra leis agus sann iad don phróifíl pháiste cheart.';

  @override
  String get assignedChild => 'Páiste sannta';

  @override
  String get relationship => 'Gaol';

  @override
  String get relationshipHint => 'Tuismitheoir, caomhnóir, cúramóir...';

  @override
  String get staffContactRoleHint => 'Múinteoir, CRS, príomhoide...';

  @override
  String get canReceiveReports => 'Is féidir tuairiscí a fháil';

  @override
  String get cannotReceiveReports => 'Ní féidir tuairiscí a fháil';

  @override
  String get canReceiveReportsDescription =>
      'Níor chóir ach teagmhálaithe caomhnóra cumasaithe tuairiscí páiste-shonracha a fháil.';

  @override
  String get contactActiveDescription =>
      'Fanann teagmhálaithe neamhghníomhacha sábháilte ach níor chóir iad a úsáid le haghaidh cumarsáide.';

  @override
  String get contactNameEmailRequired =>
      'Cuir ainm agus seoladh ríomhphoist bailí isteach le do thoil.';

  @override
  String get guardianChildRequired =>
      'Sann an caomhnóir seo do phróifíl pháiste le do thoil.';

  @override
  String get childNotAssigned => 'Níl páiste sannta';

  @override
  String get name => 'Ainm';

  @override
  String get email => 'Ríomhphost';

  @override
  String get selectClassroomFirst => 'Roghnaigh seomra ranga ar dtús.';

  @override
  String get noChildrenInSelectedClassroom =>
      'Níl aon phróifílí páistí ar fáil sa seomra ranga seo.';

  @override
  String get searchContacts => 'Cuardaigh teagmhálaithe';

  @override
  String get noMatchingContacts => 'Níl aon teagmhálaithe comhoiriúnacha ann';

  @override
  String get noMatchingContactsDescription =>
      'Bain triail as ainm, ríomhphost, seomra ranga, páiste nó ról eile.';

  @override
  String get staffProfileNotLinked => 'Níl próifíl foirne nasctha';

  @override
  String get assignedStaffProfile => 'Próifíl foirne sannta';

  @override
  String get noStaffInSelectedClassroom =>
      'Níl aon phróifílí foirne ar fáil sa seomra ranga seo.';

  @override
  String get staffProfileRequired =>
      'Nasc an ríomhphost seo le próifíl foirne le do thoil.';

  @override
  String get duplicateEmailWarning =>
      'Tá teagmháil leis an ríomhphost seo ann cheana.';

  @override
  String duplicateEmailExistingContact(String name) {
    return 'Tá an ríomhphost seo in úsáid cheana ag $name.';
  }

  @override
  String get prepareParentReport => 'Ullmhaigh tuairisc do thuismitheoir';

  @override
  String get parentReportPrivacyNotice =>
      'Seiceáil an réamhamharc seo sula gcóipeálann tú é. Ní chuimsíonn sé ach eolas don pháiste seo agus don tuairisc roghnaithe seo.';

  @override
  String get selectGuardianRecipient => 'Roghnaigh faighteoir caomhnóra';

  @override
  String get parentReportEmailSubject => 'Ábhar ríomhphoist';

  @override
  String get parentReportPreview => 'Réamhamharc na tuairisce';

  @override
  String get copyRecipientEmail => 'Cóipeáil ríomhphost an fhaighteora';

  @override
  String get copySubject => 'Cóipeáil an t-ábhar';

  @override
  String get copyEmailBody => 'Cóipeáil corp an ríomhphoist';

  @override
  String get parentReportBodyCopied =>
      'Cóipeáladh corp an ríomhphoist agus logáladh an t-ullmhúchán.';

  @override
  String get parentReportRecipientCopied =>
      'Cóipeáladh ríomhphost an fhaighteora.';

  @override
  String get parentReportSubjectCopied => 'Cóipeáladh ábhar an ríomhphoist.';

  @override
  String get parentReportGreeting => 'Dia duit,';

  @override
  String parentReportBodyCheckIntro(String childName) {
    return 'Seo nuashonrú seiceála coirp do $childName.';
  }

  @override
  String parentReportIncidentIntro(String childName) {
    return 'Seo nuashonrú teagmhais do $childName.';
  }

  @override
  String parentReportLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get reportDate => 'Dáta';

  @override
  String get bodyArea => 'Limistéar coirp';

  @override
  String get painLevel => 'Leibhéal pian';

  @override
  String get painType => 'Cineál pian';

  @override
  String get status => 'Stádas';

  @override
  String get checkedAtLabel => 'Seiceáilte ag';

  @override
  String get staffNote => 'Nóta foirne';

  @override
  String get loggedByLabel => 'Logáilte ag';

  @override
  String get followUpStatusLabel => 'Stádas leantach';

  @override
  String get parentReportFooter =>
      'Déan teagmháil leis an scoil má tá aon cheist agat.';

  @override
  String bodyCheckParentReportSubject(String childName) {
    return 'Nuashonrú seiceála coirp do $childName';
  }

  @override
  String incidentParentReportSubject(String childName) {
    return 'Nuashonrú teagmhais do $childName';
  }

  @override
  String get parentReportsNeedClassroom =>
      'Níl tuairiscí tuismitheora ar fáil ach laistigh de sheisiún seomra ranga.';

  @override
  String get noGuardianReportContacts =>
      'Níl aon teagmhálaithe caomhnóra gníomhacha nasctha leis an bpáiste seo le haghaidh tuairiscí.';

  @override
  String get parentReportPrepareFailed =>
      'Níorbh fhéidir an tuairisc do thuismitheoir a ullmhú.';

  @override
  String get mediaLibrary => 'Leabharlann Meán';

  @override
  String get staffMediaLibrarySubtitle =>
      'Uaslódáil agus bainistigh íomhánna, fuaim agus cáipéisí an tseomra ranga.';

  @override
  String get mediaLibraryDescription =>
      'Acmhainní seomra ranga do thacaíochtaí amhairc, gníomhaíochtaí foghlama, fuaim shuaimhneach agus cáipéisí foirne.';

  @override
  String get uploadMedia => 'Uaslódáil meáin';

  @override
  String get upload => 'Uaslódáil';

  @override
  String get chooseFile => 'Roghnaigh comhad';

  @override
  String get mediaImages => 'Íomhánna';

  @override
  String get mediaAudio => 'Fuaim';

  @override
  String get mediaDocuments => 'Cáipéisí';

  @override
  String get mediaType => 'Cineál meáin';

  @override
  String get mediaActiveOnly => 'Gníomhach amháin';

  @override
  String get mediaCopyLink => 'Cóipeáil nasc';

  @override
  String get mediaLinkCopied => 'Cóipeáladh nasc na meán.';

  @override
  String get mediaAssetUploaded => 'Uaslódáladh na meáin.';

  @override
  String get mediaAssetUpdated => 'Nuashonraíodh na meáin.';

  @override
  String get mediaAssetEnabled => 'Cumasaíodh na meáin.';

  @override
  String get mediaAssetDisabled => 'Díchumasaíodh na meáin.';

  @override
  String get mediaAssetDeleted => 'Scriosadh na meáin.';

  @override
  String get mediaNoFileSelected => 'Níor roghnaíodh aon chomhad.';

  @override
  String get mediaNameRequired => 'Cuir ainm isteach le do thoil.';

  @override
  String mediaLoadFailed(String error) {
    return 'Níorbh fhéidir na meáin a lódáil: $error';
  }

  @override
  String mediaUploadFailed(String error) {
    return 'Níorbh fhéidir na meáin a uaslódáil: $error';
  }

  @override
  String mediaAssetUpdateFailed(String error) {
    return 'Níorbh fhéidir na meáin a nuashonrú: $error';
  }

  @override
  String mediaAssetDeleteFailed(String error) {
    return 'Níorbh fhéidir na meáin a scriosadh: $error';
  }

  @override
  String get deleteMediaAsset => 'Scrios na meáin?';

  @override
  String deleteMediaAssetMessage(String name) {
    return 'Scrios $name? Níor cheart é seo a úsáid ach do chomhaid nach bhfuil ag teastáil a thuilleadh.';
  }

  @override
  String get editMediaAsset => 'Cuir meáin in eagar';

  @override
  String get noMediaAssetsYet => 'Níl aon mheáin uaslódáilte fós';

  @override
  String get noMediaAssetsYetDescription =>
      'Uaslódáil íomhánna, fuaim nó cáipéisí PDF don seomra ranga seo.';

  @override
  String get mediaUploadPickerHint =>
      'Tar éis duit na sonraí seo a roghnú, roghnóidh tú an comhad ó do ghléas.';

  @override
  String get mediaPreviewFailed =>
      'Níorbh fhéidir réamhamharc a dhéanamh ar na meáin seo.';

  @override
  String get mediaPreviewNotAvailableYet =>
      'Níl réamhamharc ar fáil don chineál comhaid seo fós. Is féidir leat nasc an chomhaid a chóipeáil ina ionad.';

  @override
  String get mediaCategoryVisualSupport => 'Tacaíocht amhairc';

  @override
  String get mediaCategoryWordLearningImage => 'Íomhá foghlama focal';

  @override
  String get mediaCategoryLearningGameImage => 'Íomhá cluiche foghlama';

  @override
  String get mediaCategoryScheduleImage => 'Íomhá sceidil';

  @override
  String get mediaCategoryRewardImage => 'Íomhá luaíochta';

  @override
  String get mediaCategoryCalmingSound => 'Fuaim shuaimhneach';

  @override
  String get mediaCategoryClassroomCue => 'Leid seomra ranga';

  @override
  String get mediaCategoryGuideline => 'Treoirlíne';

  @override
  String get mediaCategoryClassroomDocument => 'Cáipéis seomra ranga';

  @override
  String get mediaCategoryOther => 'Eile';

  @override
  String get staffGuidelines => 'Treoirlínte';

  @override
  String get staffGuidelinesDashboardSubtitle =>
      'Féach ar cháipéisí tábhachtacha treorach don seomra ranga.';

  @override
  String get staffGuidelinesDescription =>
      'Cáipéisí treorach reatha don seomra ranga do bhaill foirne, ionadaithe agus CRSanna.';

  @override
  String get manageGuidelines => 'Bainistigh treoirlínte';

  @override
  String get openMediaLibrary => 'Oscail Leabharlann Meán';

  @override
  String get copyGuidelineLink => 'Cóipeáil nasc na treoirlíne';

  @override
  String get guidelineLinkCopied => 'Cóipeáladh nasc na treoirlíne.';

  @override
  String get guidelineOpenHint =>
      'Cóipeáil an nasc agus oscail é i gcluaisín brabhsálaí chun an PDF seo a fheiceáil. Cuirfear féachaint PDF san aip leis níos déanaí.';

  @override
  String guidelineUpdated(String date, String size) {
    return 'Nuashonraithe $date • $size';
  }

  @override
  String get noGuidelinesYet => 'Níl aon treoirlínte uaslódáilte fós';

  @override
  String get noGuidelinesYetDescription =>
      'Uaslódáil treoirlínte PDF sa Leabharlann Meán leis an gcatagóir Treoirlíne.';

  @override
  String guidelinesLoadFailed(String error) {
    return 'Níorbh fhéidir na treoirlínte a lódáil: $error';
  }

  @override
  String get staffCalmingSoundsSubtitle =>
      'Bainistigh an fhuaim shuaimhneach is féidir le páistí a úsáid.';

  @override
  String get manageCalmingSounds => 'Bainistigh Fuaimeanna Suaimhneacha';

  @override
  String get manageCalmingSoundsSubtitle =>
      'Roghnaigh cén fhuaim shuaimhneach uaslódáilte atá ar fáil ar dheais an pháiste.';

  @override
  String get classroomCalmingSounds => 'Fuaimeanna an tSeomra Ranga';

  @override
  String get classroomCalmingSoundsSubtitle =>
      'Fuaimeanna roghnaithe ag an bhfoireann don seomra ranga seo.';

  @override
  String get addCalmingSound => 'Cuir fuaim shuaimhneach leis';

  @override
  String get totalSounds => 'Fuaimeanna iomlána';

  @override
  String get activeSounds => 'Fuaimeanna gníomhacha';

  @override
  String get calmingSoundEnabled => 'Cumasaíodh an fhuaim shuaimhneach.';

  @override
  String get calmingSoundDisabled => 'Díchumasaíodh an fhuaim shuaimhneach.';

  @override
  String get noCalmingSoundsYet =>
      'Níl aon fhuaimeanna suaimhneacha uaslódáilte fós';

  @override
  String get noCalmingSoundsYetDescription =>
      'Uaslódáil fuaim sa Leabharlann Meán agus roghnaigh an chatagóir Fuaim Shuaimhneach.';

  @override
  String get categories => 'Catagóirí';

  @override
  String get sounds => 'fuaimeanna';

  @override
  String get starterSound => 'Fuaim thosaithe';

  @override
  String get uploadedSound => 'Fuaim uaslódáilte';

  @override
  String get addCalmingCategory => 'Cuir catagóir leis';

  @override
  String get editCalmingCategory => 'Cuir catagóir in eagar';

  @override
  String get defaultCalmingCategoryCannotDelete =>
      'Ní féidir catagóirí réamhshocraithe a scriosadh. Is féidir iad a mhúchadh ina ionad.';

  @override
  String get moveSoundsBeforeDeletingCategory =>
      'Bog fuaimeanna amach as an gcatagóir seo sula scriosann tú í.';

  @override
  String get deleteCalmingCategory => 'Scrios catagóir';

  @override
  String get deleteCalmingCategoryMessage =>
      'Bainfear an chatagóir seo de leabharlann fuaimeanna an tseomra ranga.';

  @override
  String get noSoundsInCategory => 'Níl aon fhuaimeanna sa chatagóir seo fós.';

  @override
  String get englishName => 'Ainm Béarla';

  @override
  String get irishName => 'Ainm Gaeilge';

  @override
  String get icon => 'Deilbhín';

  @override
  String get calmingSoundCategory => 'Catagóir fuaime suaimhní';

  @override
  String get noCalmingSoundsAvailable =>
      'Níl aon fhuaimeanna suaimhneacha ar fáil faoi láthair. Iarr ar mhúinteoir ceann a chur leis.';

  @override
  String get deleteCalmingSound => 'Scrios fuaim shuaimhneach';

  @override
  String deleteCalmingSoundMessage(String name) {
    return 'Scrios \"$name\" ón seomra ranga seo? Bainfear an comhad uaslódáilte freisin.';
  }
}
