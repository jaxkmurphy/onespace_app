// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OneSpace App';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get pinUpdated => 'PIN updated';

  @override
  String get savePin => 'Save PIN';

  @override
  String get newPin => 'New PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get pinHint => 'PINs must be 4 digits and match';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get create => 'Create';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get retry => 'Try Again';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Something went wrong';

  @override
  String get all => 'All';

  @override
  String get everyone => 'Everyone';

  @override
  String get viewOnly => 'View only';

  @override
  String get untitled => 'Untitled';

  @override
  String get low => 'Low';

  @override
  String get medium => 'Medium';

  @override
  String get high => 'High';

  @override
  String get zones_regulation => 'Zones of Regulation';

  @override
  String get points_overview => 'Points Overview';

  @override
  String get view_schedule => 'View Schedule';

  @override
  String get create_quiz => 'Create Quiz';

  @override
  String get manage_quizzes => 'Manage Quizzes';

  @override
  String get welcome => 'Welcome';

  @override
  String get my_points => 'My Points';

  @override
  String get my_schedule => 'My Schedule';

  @override
  String get calming_sounds => 'Calming Sounds';

  @override
  String get take_quiz => 'Take a Quiz';

  @override
  String get change_background => 'Change Background Colour';

  @override
  String get handoverHub => 'Handover Hub';

  @override
  String get handoverStartHereTab => 'Start Here';

  @override
  String get handoverStaffDocumentsTab => 'Staff Documents';

  @override
  String get handoverQuickNotesTab => 'Quick Notes';

  @override
  String get readThisFirst => 'Read this first';

  @override
  String get startHereDescription =>
      'This section should contain the most important things a substitute teacher or SNA needs to know immediately.';

  @override
  String get noStartHereInformation =>
      'No Start Here information has been added yet.';

  @override
  String get editStartHere => 'Edit Start Here';

  @override
  String get editStartHereTitle => 'Edit Start Here';

  @override
  String get startHereHint =>
      'Write the most important classroom information here...';

  @override
  String get noStaffProfilesFound => 'No staff profiles found.';

  @override
  String staffDocumentTitle(String staffName) {
    return '$staffName Document';
  }

  @override
  String editStaffDocument(String staffName) {
    return 'Edit $staffName Document';
  }

  @override
  String get aboutThisClass => 'About This Class';

  @override
  String get whatWorksWell => 'What Works Well';

  @override
  String get commonTriggers => 'Common Triggers';

  @override
  String get successfulStrategies => 'Successful Strategies';

  @override
  String get communicationTips => 'Communication Tips';

  @override
  String get otherNotes => 'Other Notes';

  @override
  String get nothingAddedYet => 'Nothing added yet.';

  @override
  String get editQuickNote => 'Edit Quick Note';

  @override
  String get addQuickNote => 'Add Quick Note';

  @override
  String get titleLabel => 'Title';

  @override
  String get noteLabel => 'Note';

  @override
  String get deleteNoteTitle => 'Delete note?';

  @override
  String get deleteNoteMessage => 'Are you sure you want to delete this note?';

  @override
  String get noQuickNotes => 'No quick notes yet.';

  @override
  String quickNoteBy(String staffName) {
    return 'By: $staffName';
  }

  @override
  String get addNote => 'Add Note';

  @override
  String get handoverLoadError => 'Could not load handover information.';

  @override
  String get handoverSaveError => 'Could not save the handover information.';

  @override
  String get handoverDeleteError => 'Could not delete the note.';

  @override
  String lastUpdated(String date) {
    return 'Last updated $date';
  }

  @override
  String get incidentLog => 'Incident Log';

  @override
  String incidentLogClassroom(String classroomName) {
    return '$classroomName Incident Log';
  }

  @override
  String get incidentLogIntro =>
      'Create and review classroom incident records.';

  @override
  String get createIncident => 'Create Incident';

  @override
  String get viewIncidents => 'View Incidents';

  @override
  String get selectChild => 'Select Child';

  @override
  String get severity => 'Severity';

  @override
  String get useCurrentTime => 'Use Current Time (Default)';

  @override
  String manualTime(String date) {
    return 'Manual Time: $date';
  }

  @override
  String get resetToCurrentTime => 'Reset to current time';

  @override
  String get description => 'Description';

  @override
  String get actionTaken => 'Action Taken';

  @override
  String get saveIncident => 'Save Incident';

  @override
  String get saving => 'Saving...';

  @override
  String get pleaseSelectChild => 'Please select a child.';

  @override
  String get enterIncidentDetails =>
      'Please enter a description and the action taken.';

  @override
  String get incidentSaved => 'Incident saved.';

  @override
  String get incidentUpdated => 'Incident updated.';

  @override
  String get incidentSaveFailed => 'Failed to save the incident.';

  @override
  String get editIncident => 'Edit Incident';

  @override
  String get archiveIncident => 'Archive Incident';

  @override
  String get archiveIncidentQuestion => 'Archive this incident?';

  @override
  String archiveIncidentMessage(String childName) {
    return 'Archive the incident for $childName? It will remain in the audit history.';
  }

  @override
  String get archiveReason => 'Reason for archiving';

  @override
  String get incidentArchived => 'Incident archived.';

  @override
  String get incidentArchiveFailed => 'Failed to archive the incident.';

  @override
  String get noIncidents => 'No incidents logged yet.';

  @override
  String get filterByChild => 'Filter by child';

  @override
  String incidentsShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count incidents shown',
      one: '1 incident shown',
      zero: 'No incidents shown',
    );
    return '$_temp0';
  }

  @override
  String get noMatchingIncidents => 'No incidents match these filters.';

  @override
  String severityLabel(String severity) {
    return '$severity severity';
  }

  @override
  String loggedBy(String staffName) {
    return 'Logged by $staffName';
  }

  @override
  String get incidentCategory => 'Incident Category';

  @override
  String get behaviour => 'Behaviour';

  @override
  String get injury => 'Injury';

  @override
  String get safety => 'Safety';

  @override
  String get emotional => 'Emotional';

  @override
  String get other => 'Other';

  @override
  String get followUp => 'Follow-up';

  @override
  String get noFollowUp => 'No follow-up needed';

  @override
  String get followUpRequired => 'Follow-up required';

  @override
  String get followUpCompleted => 'Follow-up completed';

  @override
  String get followUpNotes => 'Follow-up Notes';

  @override
  String get archivedIncidents => 'Archived Incidents';

  @override
  String get wordLearning => 'Word Learning';

  @override
  String get wordPractice => 'Word Practice';

  @override
  String get wordProgress => 'Word Progress';

  @override
  String get createWordPack => 'Create Word Pack';

  @override
  String get editWordPack => 'Edit Word Pack';

  @override
  String get deleteWordPack => 'Delete Word Pack';

  @override
  String deleteWordPackMessage(String packName) {
    return 'Delete “$packName”? Its words will also be deleted.';
  }

  @override
  String get packName => 'Pack Name';

  @override
  String get packDescription => 'Pack Description';

  @override
  String get packDescriptionHint => 'What will children practise in this pack?';

  @override
  String createdBy(String staffName) {
    return 'Created by $staffName';
  }

  @override
  String wordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
      zero: 'No words',
    );
    return '$_temp0';
  }

  @override
  String assignedChildCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Assigned to $count children',
      one: 'Assigned to 1 child',
      zero: 'Not assigned',
    );
    return '$_temp0';
  }

  @override
  String get noWordPacks => 'No word packs yet.';

  @override
  String get createFirstWordPack =>
      'Create your first word pack to get started.';

  @override
  String get addWord => 'Add Word';

  @override
  String get editWord => 'Edit Word';

  @override
  String get deleteWord => 'Delete Word';

  @override
  String deleteWordMessage(String word) {
    return 'Delete the word “$word”?';
  }

  @override
  String get word => 'Word';

  @override
  String get emoji => 'Emoji';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get easy => 'Easy';

  @override
  String get hard => 'Hard';

  @override
  String get assignChildren => 'Assign Children';

  @override
  String get saveAssignments => 'Save Assignments';

  @override
  String get noChildrenAvailable => 'No child profiles are available.';

  @override
  String get noWords => 'No words have been added yet.';

  @override
  String get addFirstWord =>
      'Add at least two words before assigning this pack.';

  @override
  String get tapToPractise => 'Tap to practise';

  @override
  String get noAssignedWordPacks => 'No word packs are assigned right now.';

  @override
  String get packNeedsTwoWords =>
      'This pack needs at least two words before it can be practised.';

  @override
  String get practiceComplete => 'Practice Complete!';

  @override
  String practisedWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You practised $count words.',
      one: 'You practised 1 word.',
    );
    return '$_temp0';
  }

  @override
  String get practiseAgain => 'Practise Again';

  @override
  String get backToPacks => 'Back to Packs';

  @override
  String get selectChildForProgress => 'Select a child to view their progress.';

  @override
  String get noWordAttempts => 'No word practice attempts yet.';

  @override
  String totalAttempts(int count) {
    return 'Total attempts: $count';
  }

  @override
  String correctAnswers(int count) {
    return 'Correct answers: $count';
  }

  @override
  String accuracy(String percentage) {
    return 'Accuracy: $percentage%';
  }

  @override
  String get wordBreakdown => 'Word Breakdown';

  @override
  String attemptSummary(int attempts, int correct, String accuracy) {
    return 'Attempts: $attempts • Correct: $correct • Accuracy: $accuracy%';
  }

  @override
  String get chooseMatchingWord => 'Choose the word that matches the picture.';

  @override
  String get greatJob => 'Great job!';

  @override
  String get goodTry => 'Good try!';

  @override
  String correctAnswerWas(String answer) {
    return 'The correct answer was $answer.';
  }

  @override
  String get nextWord => 'Next Word';

  @override
  String get finishPractice => 'Finish Practice';

  @override
  String get loadingWords => 'Getting your words ready...';

  @override
  String get couldNotLoadWords => 'Could not load this word pack.';

  @override
  String get packStyle => 'Pack Style';

  @override
  String get words => 'Words';

  @override
  String get school => 'School';

  @override
  String get home => 'Home';

  @override
  String get animals => 'Animals';

  @override
  String get feelings => 'Feelings';

  @override
  String get ourWorld => 'Our World';

  @override
  String get fun => 'Fun';

  @override
  String get selectedChildren => 'Selected Children';

  @override
  String get availableToEveryone => 'Available to Everyone';

  @override
  String get couldNotLoadWordPacks => 'Could not load word packs.';

  @override
  String get wordPackCreated => 'Word pack created.';

  @override
  String get wordPackDeleted => 'Word pack deleted.';

  @override
  String get wordPackSaveFailed => 'Could not save the word pack.';

  @override
  String get wordPackDeleteFailed => 'Could not delete the word pack.';

  @override
  String get editPackDetails => 'Edit Pack Details';

  @override
  String get wordPackUpdated => 'Word pack updated.';

  @override
  String get assignmentsSaved => 'Assignments saved.';

  @override
  String get hint => 'Hint';

  @override
  String get hintOptional => 'Helpful hint (optional)';

  @override
  String get wordSaved => 'Word saved.';

  @override
  String get wordDeleted => 'Word deleted.';

  @override
  String get wordSaveFailed => 'Could not save the word.';

  @override
  String get wordDeleteFailed => 'Could not delete the word.';

  @override
  String wordProgressCount(int current, int total) {
    return 'Word $current of $total';
  }

  @override
  String practiceScore(int score, int total) {
    return '$score of $total correct';
  }

  @override
  String get showHint => 'Show Hint';
}
