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
}
