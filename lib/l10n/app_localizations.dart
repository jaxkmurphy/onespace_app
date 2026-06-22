import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ga.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ga'),
  ];

  /// Text used in the app for app title.
  ///
  /// In en, this message translates to:
  /// **'OneSpace App'**
  String get appTitle;

  /// Text used in the app for settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Text used in the app for language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Text used in the app for select language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Text used in the app for pin updated.
  ///
  /// In en, this message translates to:
  /// **'PIN updated'**
  String get pinUpdated;

  /// Text used in the app for save pin.
  ///
  /// In en, this message translates to:
  /// **'Save PIN'**
  String get savePin;

  /// Text used in the app for new pin.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPin;

  /// Text used in the app for confirm pin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// Text used in the app for pin hint.
  ///
  /// In en, this message translates to:
  /// **'PINs must be 4 digits and match'**
  String get pinHint;

  /// Text used in the app for cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Text used in the app for save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Text used in the app for delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Text used in the app for edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Text used in the app for add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Text used in the app for create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Text used in the app for close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Text used in the app for done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Text used in the app for retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

  /// Text used in the app for loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Text used in the app for error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// Text used in the app for all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Text used in the app for everyone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get everyone;

  /// Text used in the app for view only.
  ///
  /// In en, this message translates to:
  /// **'View only'**
  String get viewOnly;

  /// Text used in the app for untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// Text used in the app for low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// Text used in the app for medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Text used in the app for high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// Text used in the app for zones regulation.
  ///
  /// In en, this message translates to:
  /// **'Zones of Regulation'**
  String get zones_regulation;

  /// Text used in the app for points overview.
  ///
  /// In en, this message translates to:
  /// **'Points Overview'**
  String get points_overview;

  /// Text used in the app for view schedule.
  ///
  /// In en, this message translates to:
  /// **'View Schedule'**
  String get view_schedule;

  /// Text used in the app for create quiz.
  ///
  /// In en, this message translates to:
  /// **'Create Quiz'**
  String get create_quiz;

  /// Text used in the app for manage quizzes.
  ///
  /// In en, this message translates to:
  /// **'Manage Quizzes'**
  String get manage_quizzes;

  /// Text used in the app for welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Text used in the app for my points.
  ///
  /// In en, this message translates to:
  /// **'My Points'**
  String get my_points;

  /// Text used in the app for my schedule.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get my_schedule;

  /// Text used in the app for calming sounds.
  ///
  /// In en, this message translates to:
  /// **'Calming Sounds'**
  String get calming_sounds;

  /// Text used in the app for take quiz.
  ///
  /// In en, this message translates to:
  /// **'Take a Quiz'**
  String get take_quiz;

  /// Text used in the app for change background.
  ///
  /// In en, this message translates to:
  /// **'Change Background Colour'**
  String get change_background;

  /// Text used in the app for handover hub.
  ///
  /// In en, this message translates to:
  /// **'Handover Hub'**
  String get handoverHub;

  /// Text used in the app for handover start here tab.
  ///
  /// In en, this message translates to:
  /// **'Start Here'**
  String get handoverStartHereTab;

  /// Text used in the app for handover staff documents tab.
  ///
  /// In en, this message translates to:
  /// **'Staff Documents'**
  String get handoverStaffDocumentsTab;

  /// Text used in the app for handover quick notes tab.
  ///
  /// In en, this message translates to:
  /// **'Quick Notes'**
  String get handoverQuickNotesTab;

  /// Text used in the app for read this first.
  ///
  /// In en, this message translates to:
  /// **'Read this first'**
  String get readThisFirst;

  /// Text used in the app for start here description.
  ///
  /// In en, this message translates to:
  /// **'This section should contain the most important things a substitute teacher or SNA needs to know immediately.'**
  String get startHereDescription;

  /// Text used in the app for no start here information.
  ///
  /// In en, this message translates to:
  /// **'No Start Here information has been added yet.'**
  String get noStartHereInformation;

  /// Text used in the app for edit start here.
  ///
  /// In en, this message translates to:
  /// **'Edit Start Here'**
  String get editStartHere;

  /// Text used in the app for edit start here title.
  ///
  /// In en, this message translates to:
  /// **'Edit Start Here'**
  String get editStartHereTitle;

  /// Text used in the app for start here hint.
  ///
  /// In en, this message translates to:
  /// **'Write the most important classroom information here...'**
  String get startHereHint;

  /// Text used in the app for no staff profiles found.
  ///
  /// In en, this message translates to:
  /// **'No staff profiles found.'**
  String get noStaffProfilesFound;

  /// Text used in the app for staff document title.
  ///
  /// In en, this message translates to:
  /// **'{staffName} Document'**
  String staffDocumentTitle(String staffName);

  /// Text used in the app for edit staff document.
  ///
  /// In en, this message translates to:
  /// **'Edit {staffName} Document'**
  String editStaffDocument(String staffName);

  /// Text used in the app for about this class.
  ///
  /// In en, this message translates to:
  /// **'About This Class'**
  String get aboutThisClass;

  /// Text used in the app for what works well.
  ///
  /// In en, this message translates to:
  /// **'What Works Well'**
  String get whatWorksWell;

  /// Text used in the app for common triggers.
  ///
  /// In en, this message translates to:
  /// **'Common Triggers'**
  String get commonTriggers;

  /// Text used in the app for successful strategies.
  ///
  /// In en, this message translates to:
  /// **'Successful Strategies'**
  String get successfulStrategies;

  /// Text used in the app for communication tips.
  ///
  /// In en, this message translates to:
  /// **'Communication Tips'**
  String get communicationTips;

  /// Text used in the app for other notes.
  ///
  /// In en, this message translates to:
  /// **'Other Notes'**
  String get otherNotes;

  /// Text used in the app for nothing added yet.
  ///
  /// In en, this message translates to:
  /// **'Nothing added yet.'**
  String get nothingAddedYet;

  /// Text used in the app for edit quick note.
  ///
  /// In en, this message translates to:
  /// **'Edit Quick Note'**
  String get editQuickNote;

  /// Text used in the app for add quick note.
  ///
  /// In en, this message translates to:
  /// **'Add Quick Note'**
  String get addQuickNote;

  /// Text used in the app for title label.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// Text used in the app for note label.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// Text used in the app for delete note title.
  ///
  /// In en, this message translates to:
  /// **'Delete note?'**
  String get deleteNoteTitle;

  /// Text used in the app for delete note message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get deleteNoteMessage;

  /// Text used in the app for no quick notes.
  ///
  /// In en, this message translates to:
  /// **'No quick notes yet.'**
  String get noQuickNotes;

  /// Text used in the app for quick note by.
  ///
  /// In en, this message translates to:
  /// **'By: {staffName}'**
  String quickNoteBy(String staffName);

  /// Text used in the app for add note.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// Text used in the app for handover load error.
  ///
  /// In en, this message translates to:
  /// **'Could not load handover information.'**
  String get handoverLoadError;

  /// Text used in the app for handover save error.
  ///
  /// In en, this message translates to:
  /// **'Could not save the handover information.'**
  String get handoverSaveError;

  /// Text used in the app for handover delete error.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the note.'**
  String get handoverDeleteError;

  /// Text used in the app for last updated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {date}'**
  String lastUpdated(String date);

  /// Text used in the app for incident log.
  ///
  /// In en, this message translates to:
  /// **'Incident Log'**
  String get incidentLog;

  /// Text used in the app for incident log classroom.
  ///
  /// In en, this message translates to:
  /// **'{classroomName} Incident Log'**
  String incidentLogClassroom(String classroomName);

  /// Text used in the app for incident log intro.
  ///
  /// In en, this message translates to:
  /// **'Create and review classroom incident records.'**
  String get incidentLogIntro;

  /// Text used in the app for create incident.
  ///
  /// In en, this message translates to:
  /// **'Create Incident'**
  String get createIncident;

  /// Text used in the app for view incidents.
  ///
  /// In en, this message translates to:
  /// **'View Incidents'**
  String get viewIncidents;

  /// Text used in the app for select child.
  ///
  /// In en, this message translates to:
  /// **'Select Child'**
  String get selectChild;

  /// Text used in the app for severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// Text used in the app for use current time.
  ///
  /// In en, this message translates to:
  /// **'Use Current Time (Default)'**
  String get useCurrentTime;

  /// Text used in the app for manual time.
  ///
  /// In en, this message translates to:
  /// **'Manual Time: {date}'**
  String manualTime(String date);

  /// Text used in the app for reset to current time.
  ///
  /// In en, this message translates to:
  /// **'Reset to current time'**
  String get resetToCurrentTime;

  /// Text used in the app for description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Text used in the app for action taken.
  ///
  /// In en, this message translates to:
  /// **'Action Taken'**
  String get actionTaken;

  /// Text used in the app for save incident.
  ///
  /// In en, this message translates to:
  /// **'Save Incident'**
  String get saveIncident;

  /// Text used in the app for saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Text used in the app for please select child.
  ///
  /// In en, this message translates to:
  /// **'Please select a child.'**
  String get pleaseSelectChild;

  /// Text used in the app for enter incident details.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description and the action taken.'**
  String get enterIncidentDetails;

  /// Text used in the app for incident saved.
  ///
  /// In en, this message translates to:
  /// **'Incident saved.'**
  String get incidentSaved;

  /// Text used in the app for incident updated.
  ///
  /// In en, this message translates to:
  /// **'Incident updated.'**
  String get incidentUpdated;

  /// Text used in the app for incident save failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save the incident.'**
  String get incidentSaveFailed;

  /// Text used in the app for edit incident.
  ///
  /// In en, this message translates to:
  /// **'Edit Incident'**
  String get editIncident;

  /// Text used in the app for archive incident.
  ///
  /// In en, this message translates to:
  /// **'Archive Incident'**
  String get archiveIncident;

  /// Text used in the app for archive incident question.
  ///
  /// In en, this message translates to:
  /// **'Archive this incident?'**
  String get archiveIncidentQuestion;

  /// Text used in the app for archive incident message.
  ///
  /// In en, this message translates to:
  /// **'Archive the incident for {childName}? It will remain in the audit history.'**
  String archiveIncidentMessage(String childName);

  /// Text used in the app for archive reason.
  ///
  /// In en, this message translates to:
  /// **'Reason for archiving'**
  String get archiveReason;

  /// Text used in the app for incident archived.
  ///
  /// In en, this message translates to:
  /// **'Incident archived.'**
  String get incidentArchived;

  /// Text used in the app for incident archive failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to archive the incident.'**
  String get incidentArchiveFailed;

  /// Text used in the app for no incidents.
  ///
  /// In en, this message translates to:
  /// **'No incidents logged yet.'**
  String get noIncidents;

  /// Text used in the app for filter by child.
  ///
  /// In en, this message translates to:
  /// **'Filter by child'**
  String get filterByChild;

  /// Text used in the app for incidents shown.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No incidents shown} one{1 incident shown} other{{count} incidents shown}}'**
  String incidentsShown(int count);

  /// Text used in the app for no matching incidents.
  ///
  /// In en, this message translates to:
  /// **'No incidents match these filters.'**
  String get noMatchingIncidents;

  /// Text used in the app for severity label.
  ///
  /// In en, this message translates to:
  /// **'{severity} severity'**
  String severityLabel(String severity);

  /// Text used in the app for logged by.
  ///
  /// In en, this message translates to:
  /// **'Logged by {staffName}'**
  String loggedBy(String staffName);

  /// Text used in the app for incident category.
  ///
  /// In en, this message translates to:
  /// **'Incident Category'**
  String get incidentCategory;

  /// Text used in the app for behaviour.
  ///
  /// In en, this message translates to:
  /// **'Behaviour'**
  String get behaviour;

  /// Text used in the app for injury.
  ///
  /// In en, this message translates to:
  /// **'Injury'**
  String get injury;

  /// Text used in the app for safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// Text used in the app for emotional.
  ///
  /// In en, this message translates to:
  /// **'Emotional'**
  String get emotional;

  /// Text used in the app for other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Text used in the app for follow up.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get followUp;

  /// Text used in the app for no follow up.
  ///
  /// In en, this message translates to:
  /// **'No follow-up needed'**
  String get noFollowUp;

  /// Text used in the app for follow up required.
  ///
  /// In en, this message translates to:
  /// **'Follow-up required'**
  String get followUpRequired;

  /// Text used in the app for follow up completed.
  ///
  /// In en, this message translates to:
  /// **'Follow-up completed'**
  String get followUpCompleted;

  /// Text used in the app for follow up notes.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Notes'**
  String get followUpNotes;

  /// Text used in the app for archived incidents.
  ///
  /// In en, this message translates to:
  /// **'Archived Incidents'**
  String get archivedIncidents;

  /// Text used in the app for word learning.
  ///
  /// In en, this message translates to:
  /// **'Word Learning'**
  String get wordLearning;

  /// Text used in the app for word practice.
  ///
  /// In en, this message translates to:
  /// **'Word Practice'**
  String get wordPractice;

  /// Text used in the app for word progress.
  ///
  /// In en, this message translates to:
  /// **'Word Progress'**
  String get wordProgress;

  /// Text used in the app for create word pack.
  ///
  /// In en, this message translates to:
  /// **'Create Word Pack'**
  String get createWordPack;

  /// Text used in the app for edit word pack.
  ///
  /// In en, this message translates to:
  /// **'Edit Word Pack'**
  String get editWordPack;

  /// Text used in the app for delete word pack.
  ///
  /// In en, this message translates to:
  /// **'Delete Word Pack'**
  String get deleteWordPack;

  /// Text used in the app for delete word pack message.
  ///
  /// In en, this message translates to:
  /// **'Delete “{packName}”? Its words will also be deleted.'**
  String deleteWordPackMessage(String packName);

  /// Text used in the app for pack name.
  ///
  /// In en, this message translates to:
  /// **'Pack Name'**
  String get packName;

  /// Text used in the app for pack description.
  ///
  /// In en, this message translates to:
  /// **'Pack Description'**
  String get packDescription;

  /// Text used in the app for pack description hint.
  ///
  /// In en, this message translates to:
  /// **'What will children practise in this pack?'**
  String get packDescriptionHint;

  /// Text used in the app for created by.
  ///
  /// In en, this message translates to:
  /// **'Created by {staffName}'**
  String createdBy(String staffName);

  /// Text used in the app for word count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No words} one{1 word} other{{count} words}}'**
  String wordCount(int count);

  /// Text used in the app for assigned child count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Not assigned} one{Assigned to 1 child} other{Assigned to {count} children}}'**
  String assignedChildCount(int count);

  /// Text used in the app for no word packs.
  ///
  /// In en, this message translates to:
  /// **'No word packs yet.'**
  String get noWordPacks;

  /// Text used in the app for create first word pack.
  ///
  /// In en, this message translates to:
  /// **'Create your first word pack to get started.'**
  String get createFirstWordPack;

  /// Text used in the app for add word.
  ///
  /// In en, this message translates to:
  /// **'Add Word'**
  String get addWord;

  /// Text used in the app for edit word.
  ///
  /// In en, this message translates to:
  /// **'Edit Word'**
  String get editWord;

  /// Text used in the app for delete word.
  ///
  /// In en, this message translates to:
  /// **'Delete Word'**
  String get deleteWord;

  /// Text used in the app for delete word message.
  ///
  /// In en, this message translates to:
  /// **'Delete the word “{word}”?'**
  String deleteWordMessage(String word);

  /// Text used in the app for word.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get word;

  /// Text used in the app for emoji.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get emoji;

  /// Text used in the app for difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// Text used in the app for easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// Text used in the app for hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// Text used in the app for assign children.
  ///
  /// In en, this message translates to:
  /// **'Assign Children'**
  String get assignChildren;

  /// Text used in the app for save assignments.
  ///
  /// In en, this message translates to:
  /// **'Save Assignments'**
  String get saveAssignments;

  /// Text used in the app for no children available.
  ///
  /// In en, this message translates to:
  /// **'No child profiles are available.'**
  String get noChildrenAvailable;

  /// Text used in the app for no words.
  ///
  /// In en, this message translates to:
  /// **'No words have been added yet.'**
  String get noWords;

  /// Text used in the app for add first word.
  ///
  /// In en, this message translates to:
  /// **'Add at least two words before assigning this pack.'**
  String get addFirstWord;

  /// Text used in the app for tap to practise.
  ///
  /// In en, this message translates to:
  /// **'Tap to practise'**
  String get tapToPractise;

  /// Text used in the app for no assigned word packs.
  ///
  /// In en, this message translates to:
  /// **'No word packs are assigned right now.'**
  String get noAssignedWordPacks;

  /// Text used in the app for pack needs two words.
  ///
  /// In en, this message translates to:
  /// **'This pack needs at least two words before it can be practised.'**
  String get packNeedsTwoWords;

  /// Text used in the app for practice complete.
  ///
  /// In en, this message translates to:
  /// **'Practice Complete!'**
  String get practiceComplete;

  /// Text used in the app for practised words.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{You practised 1 word.} other{You practised {count} words.}}'**
  String practisedWords(int count);

  /// Text used in the app for practise again.
  ///
  /// In en, this message translates to:
  /// **'Practise Again'**
  String get practiseAgain;

  /// Text used in the app for back to packs.
  ///
  /// In en, this message translates to:
  /// **'Back to Packs'**
  String get backToPacks;

  /// Text used in the app for select child for progress.
  ///
  /// In en, this message translates to:
  /// **'Select a child to view their progress.'**
  String get selectChildForProgress;

  /// Text used in the app for no word attempts.
  ///
  /// In en, this message translates to:
  /// **'No word practice attempts yet.'**
  String get noWordAttempts;

  /// Text used in the app for total attempts.
  ///
  /// In en, this message translates to:
  /// **'Total attempts: {count}'**
  String totalAttempts(int count);

  /// Text used in the app for correct answers.
  ///
  /// In en, this message translates to:
  /// **'Correct answers: {count}'**
  String correctAnswers(int count);

  /// Text used in the app for accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy: {percentage}%'**
  String accuracy(String percentage);

  /// Text used in the app for word breakdown.
  ///
  /// In en, this message translates to:
  /// **'Word Breakdown'**
  String get wordBreakdown;

  /// Text used in the app for attempt summary.
  ///
  /// In en, this message translates to:
  /// **'Attempts: {attempts} • Correct: {correct} • Accuracy: {accuracy}%'**
  String attemptSummary(int attempts, int correct, String accuracy);

  /// Text used in the app for choose matching word.
  ///
  /// In en, this message translates to:
  /// **'Choose the word that matches the picture.'**
  String get chooseMatchingWord;

  /// Text used in the app for great job.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get greatJob;

  /// Text used in the app for good try.
  ///
  /// In en, this message translates to:
  /// **'Good try!'**
  String get goodTry;

  /// Text used in the app for correct answer was.
  ///
  /// In en, this message translates to:
  /// **'The correct answer was {answer}.'**
  String correctAnswerWas(String answer);

  /// Text used in the app for next word.
  ///
  /// In en, this message translates to:
  /// **'Next Word'**
  String get nextWord;

  /// Text used in the app for finish practice.
  ///
  /// In en, this message translates to:
  /// **'Finish Practice'**
  String get finishPractice;

  /// Text used in the app for loading words.
  ///
  /// In en, this message translates to:
  /// **'Getting your words ready...'**
  String get loadingWords;

  /// Text used in the app for could not load words.
  ///
  /// In en, this message translates to:
  /// **'Could not load this word pack.'**
  String get couldNotLoadWords;

  /// Text used in the app for pack style.
  ///
  /// In en, this message translates to:
  /// **'Pack Style'**
  String get packStyle;

  /// Text used in the app for words.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get words;

  /// Text used in the app for school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// Text used in the app for home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Text used in the app for animals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get animals;

  /// Text used in the app for feelings.
  ///
  /// In en, this message translates to:
  /// **'Feelings'**
  String get feelings;

  /// Text used in the app for our world.
  ///
  /// In en, this message translates to:
  /// **'Our World'**
  String get ourWorld;

  /// Text used in the app for fun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get fun;

  /// Text used in the app for selected children.
  ///
  /// In en, this message translates to:
  /// **'Selected Children'**
  String get selectedChildren;

  /// Text used in the app for available to everyone.
  ///
  /// In en, this message translates to:
  /// **'Available to Everyone'**
  String get availableToEveryone;

  /// Text used in the app for could not load word packs.
  ///
  /// In en, this message translates to:
  /// **'Could not load word packs.'**
  String get couldNotLoadWordPacks;

  /// Text used in the app for word pack created.
  ///
  /// In en, this message translates to:
  /// **'Word pack created.'**
  String get wordPackCreated;

  /// Text used in the app for word pack deleted.
  ///
  /// In en, this message translates to:
  /// **'Word pack deleted.'**
  String get wordPackDeleted;

  /// Text used in the app for word pack save failed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the word pack.'**
  String get wordPackSaveFailed;

  /// Text used in the app for word pack delete failed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the word pack.'**
  String get wordPackDeleteFailed;

  /// Text used in the app for edit pack details.
  ///
  /// In en, this message translates to:
  /// **'Edit Pack Details'**
  String get editPackDetails;

  /// Text used in the app for word pack updated.
  ///
  /// In en, this message translates to:
  /// **'Word pack updated.'**
  String get wordPackUpdated;

  /// Text used in the app for assignments saved.
  ///
  /// In en, this message translates to:
  /// **'Assignments saved.'**
  String get assignmentsSaved;

  /// Text used in the app for hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// Text used in the app for hint optional.
  ///
  /// In en, this message translates to:
  /// **'Helpful hint (optional)'**
  String get hintOptional;

  /// Text used in the app for word saved.
  ///
  /// In en, this message translates to:
  /// **'Word saved.'**
  String get wordSaved;

  /// Text used in the app for word deleted.
  ///
  /// In en, this message translates to:
  /// **'Word deleted.'**
  String get wordDeleted;

  /// Text used in the app for word save failed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the word.'**
  String get wordSaveFailed;

  /// Text used in the app for word delete failed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the word.'**
  String get wordDeleteFailed;

  /// Text used in the app for word progress count.
  ///
  /// In en, this message translates to:
  /// **'Word {current} of {total}'**
  String wordProgressCount(int current, int total);

  /// Text used in the app for practice score.
  ///
  /// In en, this message translates to:
  /// **'{score} of {total} correct'**
  String practiceScore(int score, int total);

  /// Text used in the app for show hint.
  ///
  /// In en, this message translates to:
  /// **'Show Hint'**
  String get showHint;

  /// Text used in the app for profiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get profiles;

  /// Text used in the app for staff hub title.
  ///
  /// In en, this message translates to:
  /// **'{staffName} Hub'**
  String staffHubTitle(String staffName);

  /// Text used in the app for staff feature hub.
  ///
  /// In en, this message translates to:
  /// **'Staff Feature Hub'**
  String get staffFeatureHub;

  /// Text used in the app for staff hub intro.
  ///
  /// In en, this message translates to:
  /// **'Choose a tool for today\'s classroom support.'**
  String get staffHubIntro;

  /// Text used in the app for daily tools.
  ///
  /// In en, this message translates to:
  /// **'Daily Tools'**
  String get dailyTools;

  /// Text used in the app for today overview.
  ///
  /// In en, this message translates to:
  /// **'Today Overview'**
  String get todayOverview;

  /// Text used in the app for today overview subtitle.
  ///
  /// In en, this message translates to:
  /// **'See zones, reports, schedule and incidents at a glance.'**
  String get todayOverviewSubtitle;

  /// Text used in the app for staff zones subtitle.
  ///
  /// In en, this message translates to:
  /// **'View children\'s current zones.'**
  String get staffZonesSubtitle;

  /// Text used in the app for staff points subtitle.
  ///
  /// In en, this message translates to:
  /// **'View and update child points.'**
  String get staffPointsSubtitle;

  /// Text used in the app for staff schedule subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create and edit the daily schedule.'**
  String get staffScheduleSubtitle;

  /// Text used in the app for when then setup.
  ///
  /// In en, this message translates to:
  /// **'When–Then Setup'**
  String get whenThenSetup;

  /// Text used in the app for staff when then subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create When–Then activities and rewards.'**
  String get staffWhenThenSubtitle;

  /// Text used in the app for visual timer.
  ///
  /// In en, this message translates to:
  /// **'Visual Timer'**
  String get visualTimer;

  /// Text used in the app for staff timer subtitle.
  ///
  /// In en, this message translates to:
  /// **'Open the classroom timer.'**
  String get staffTimerSubtitle;

  /// Text used in the app for communication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get communication;

  /// Text used in the app for body check reports.
  ///
  /// In en, this message translates to:
  /// **'Body Check Reports'**
  String get bodyCheckReports;

  /// Text used in the app for body check reports subtitle.
  ///
  /// In en, this message translates to:
  /// **'Review body check messages from children.'**
  String get bodyCheckReportsSubtitle;

  /// Text used in the app for circle time.
  ///
  /// In en, this message translates to:
  /// **'Circle Time'**
  String get circleTime;

  /// Text used in the app for staff circle time subtitle.
  ///
  /// In en, this message translates to:
  /// **'Move children between home and school.'**
  String get staffCircleTimeSubtitle;

  /// Text used in the app for learning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learning;

  /// Text used in the app for quizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzes;

  /// Text used in the app for staff quizzes subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, preview and manage quizzes.'**
  String get staffQuizzesSubtitle;

  /// Text used in the app for staff word learning subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create word packs and view progress.'**
  String get staffWordLearningSubtitle;

  /// Text used in the app for staff admin.
  ///
  /// In en, this message translates to:
  /// **'Staff / Admin'**
  String get staffAdmin;

  /// Text used in the app for staff incident log subtitle.
  ///
  /// In en, this message translates to:
  /// **'Record and review classroom incidents.'**
  String get staffIncidentLogSubtitle;

  /// Text used in the app for staff handover subtitle.
  ///
  /// In en, this message translates to:
  /// **'View overview notes and staff documents.'**
  String get staffHandoverSubtitle;

  /// Text used in the app for icon reset.
  ///
  /// In en, this message translates to:
  /// **'Icon Reset'**
  String get iconReset;

  /// Text used in the app for icon reset subtitle.
  ///
  /// In en, this message translates to:
  /// **'View or reset child profile unlock icons.'**
  String get iconResetSubtitle;

  /// Text used in the app for child space title.
  ///
  /// In en, this message translates to:
  /// **'{childName}\'s Space'**
  String childSpaceTitle(String childName);

  /// Text used in the app for welcome child.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {childName}!'**
  String welcomeChild(String childName);

  /// Text used in the app for what would you like to do.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get whatWouldYouLikeToDo;

  /// Text used in the app for child circle time subtitle.
  ///
  /// In en, this message translates to:
  /// **'Start the day together.'**
  String get childCircleTimeSubtitle;

  /// Text used in the app for child schedule subtitle.
  ///
  /// In en, this message translates to:
  /// **'See what is happening today.'**
  String get childScheduleSubtitle;

  /// Text used in the app for when then.
  ///
  /// In en, this message translates to:
  /// **'When–Then'**
  String get whenThen;

  /// Text used in the app for child when then subtitle.
  ///
  /// In en, this message translates to:
  /// **'See your next activity and reward.'**
  String get childWhenThenSubtitle;

  /// Text used in the app for child zones subtitle.
  ///
  /// In en, this message translates to:
  /// **'Share how you are feeling.'**
  String get childZonesSubtitle;

  /// Text used in the app for body check.
  ///
  /// In en, this message translates to:
  /// **'Body Check'**
  String get bodyCheck;

  /// Text used in the app for child body check subtitle.
  ///
  /// In en, this message translates to:
  /// **'Show where your body feels sore.'**
  String get childBodyCheckSubtitle;

  /// Text used in the app for child calming sounds subtitle.
  ///
  /// In en, this message translates to:
  /// **'Listen and take a calm moment.'**
  String get childCalmingSoundsSubtitle;

  /// Text used in the app for voice lines.
  ///
  /// In en, this message translates to:
  /// **'Voice Lines'**
  String get voiceLines;

  /// Text used in the app for child voice lines subtitle.
  ///
  /// In en, this message translates to:
  /// **'Listen to helpful words and phrases.'**
  String get childVoiceLinesSubtitle;

  /// Text used in the app for child points subtitle.
  ///
  /// In en, this message translates to:
  /// **'See your points and rewards.'**
  String get childPointsSubtitle;

  /// Text used in the app for child quiz subtitle.
  ///
  /// In en, this message translates to:
  /// **'Play a quiz and learn something new.'**
  String get childQuizSubtitle;

  /// Text used in the app for child word practice subtitle.
  ///
  /// In en, this message translates to:
  /// **'Practise words at your own pace.'**
  String get childWordPracticeSubtitle;

  /// Text used in the app for child timer subtitle.
  ///
  /// In en, this message translates to:
  /// **'See how much time is left.'**
  String get childTimerSubtitle;

  /// Text used in the app for my day.
  ///
  /// In en, this message translates to:
  /// **'My Day'**
  String get myDay;

  /// Text used in the app for my day subtitle.
  ///
  /// In en, this message translates to:
  /// **'See what is happening next.'**
  String get myDaySubtitle;

  /// Text used in the app for how ifeel.
  ///
  /// In en, this message translates to:
  /// **'How I Feel'**
  String get howIFeel;

  /// Text used in the app for how ifeel subtitle.
  ///
  /// In en, this message translates to:
  /// **'Check in with your body and feelings.'**
  String get howIFeelSubtitle;

  /// Text used in the app for learn and play.
  ///
  /// In en, this message translates to:
  /// **'Learn & Play'**
  String get learnAndPlay;

  /// Text used in the app for learn and play subtitle.
  ///
  /// In en, this message translates to:
  /// **'Practise, explore and have some fun.'**
  String get learnAndPlaySubtitle;

  /// Message shown when the visual timer finishes.
  ///
  /// In en, this message translates to:
  /// **'Time Finished'**
  String get timeFinished;

  /// Status shown while the visual timer is running.
  ///
  /// In en, this message translates to:
  /// **'The timer is counting down'**
  String get timerCountingDown;

  /// Instruction shown before the visual timer starts.
  ///
  /// In en, this message translates to:
  /// **'Choose a time and press start'**
  String get chooseTimeAndStart;

  /// Short label for minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// Heading above the visual timer duration choices.
  ///
  /// In en, this message translates to:
  /// **'Choose a timer length'**
  String get chooseTimerLength;

  /// Label for the custom visual timer duration.
  ///
  /// In en, this message translates to:
  /// **'Custom time'**
  String get customTime;

  /// Selected visual timer duration in minutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String timerMinutes(int minutes);

  /// Button that starts the timer.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Button that pauses the timer.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Button that resets the current feature.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Instruction at the top of the calming sounds page.
  ///
  /// In en, this message translates to:
  /// **'Choose a relaxing sound to listen to'**
  String get calmingSoundsIntro;

  /// Error shown when a calming sound cannot be played.
  ///
  /// In en, this message translates to:
  /// **'Could not play this sound. Check the asset file.'**
  String get soundPlaybackFailed;

  /// Status shown when media is paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// Heading above the currently playing sound.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// Label for the audio volume control.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// Button that starts or resumes audio.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Button that stops audio.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// Instruction for a paused calming sound.
  ///
  /// In en, this message translates to:
  /// **'Paused - tap to play'**
  String get pausedTapToPlay;

  /// Instruction for a playing calming sound.
  ///
  /// In en, this message translates to:
  /// **'Playing - tap to pause'**
  String get playingTapToPause;

  /// Instruction for starting a calming sound.
  ///
  /// In en, this message translates to:
  /// **'Tap to play'**
  String get tapToPlay;

  /// Error shown when a child's When–Then reward choice cannot be saved.
  ///
  /// In en, this message translates to:
  /// **'That choice could not be saved. Please try again.'**
  String get whenThenChoiceSaveFailed;

  /// Loading message on the child When–Then page.
  ///
  /// In en, this message translates to:
  /// **'Getting your plan ready...'**
  String get gettingPlanReady;

  /// Heading shown when a child's When–Then plan cannot load.
  ///
  /// In en, this message translates to:
  /// **'We could not load your plan'**
  String get planLoadFailed;

  /// Instruction shown after a temporary loading error.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment and try again.'**
  String get waitAndTryAgain;

  /// Positive heading shown when a child has no active plan.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get allCaughtUp;

  /// Message shown when a child has no active When–Then board.
  ///
  /// In en, this message translates to:
  /// **'No active When–Then board right now'**
  String get noActiveWhenThen;

  /// Explanation shown when a child has no active plan.
  ///
  /// In en, this message translates to:
  /// **'A new plan will appear here when it is ready.'**
  String get newPlanWillAppear;

  /// Heading for the activity side of a When–Then board.
  ///
  /// In en, this message translates to:
  /// **'WHEN'**
  String get whenLabel;

  /// Heading for the reward side of a When–Then board.
  ///
  /// In en, this message translates to:
  /// **'THEN'**
  String get thenLabel;

  /// Greeting above a child's When–Then plan.
  ///
  /// In en, this message translates to:
  /// **'Here\'s your plan, {childName}!'**
  String childPlanGreeting(String childName);

  /// Encouragement above a child's When–Then plan.
  ///
  /// In en, this message translates to:
  /// **'One step at a time — you\'ve got this!'**
  String get oneStepAtATime;

  /// Message shown after selecting a reward.
  ///
  /// In en, this message translates to:
  /// **'Great choice!'**
  String get greatChoice;

  /// Message shown when a board has one automatic reward.
  ///
  /// In en, this message translates to:
  /// **'This is what comes next'**
  String get thisComesNext;

  /// Instruction asking a child to choose a reward.
  ///
  /// In en, this message translates to:
  /// **'Choose your reward'**
  String get chooseYourReward;

  /// Instruction below the reward heading.
  ///
  /// In en, this message translates to:
  /// **'Tap the one you would like.'**
  String get tapRewardYouWouldLike;

  /// Encouragement shown before a child finishes their activity.
  ///
  /// In en, this message translates to:
  /// **'Finish your WHEN activity, then enjoy your reward!'**
  String get finishWhenEnjoyReward;

  /// Celebration shown for a selected reward.
  ///
  /// In en, this message translates to:
  /// **'Brilliant choice!'**
  String get brilliantChoice;

  /// Validation asking staff to choose one child.
  ///
  /// In en, this message translates to:
  /// **'Please choose a child.'**
  String get pleaseChooseChild;

  /// Validation asking staff to choose children.
  ///
  /// In en, this message translates to:
  /// **'Please choose at least one child.'**
  String get chooseAtLeastOneChild;

  /// Message shown when there are no child profiles.
  ///
  /// In en, this message translates to:
  /// **'No child profiles were found.'**
  String get noChildProfilesFound;

  /// Validation for creating a When–Then board.
  ///
  /// In en, this message translates to:
  /// **'Choose the WHEN activity first.'**
  String get chooseWhenActivityFirst;

  /// Validation for selecting When–Then rewards.
  ///
  /// In en, this message translates to:
  /// **'Choose between 1 and 3 THEN rewards.'**
  String get chooseOneToThreeRewards;

  /// Error shown when a selected reward was removed.
  ///
  /// In en, this message translates to:
  /// **'One of the selected rewards is no longer available.'**
  String get selectedRewardUnavailable;

  /// Confirmation after creating a When–Then board.
  ///
  /// In en, this message translates to:
  /// **'When–Then board created successfully'**
  String get whenThenBoardCreated;

  /// Error after creating a When–Then board.
  ///
  /// In en, this message translates to:
  /// **'Failed to create the When–Then board: {error}'**
  String whenThenCreateFailed(String error);

  /// Title for editing a When–Then activity.
  ///
  /// In en, this message translates to:
  /// **'Edit activity'**
  String get editActivity;

  /// Title for adding a When–Then activity.
  ///
  /// In en, this message translates to:
  /// **'Add activity'**
  String get addActivity;

  /// Title for editing a When–Then reward.
  ///
  /// In en, this message translates to:
  /// **'Edit reward'**
  String get editReward;

  /// Title for adding a When–Then reward.
  ///
  /// In en, this message translates to:
  /// **'Add reward'**
  String get addReward;

  /// Label for a name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// Hint for naming a visual option.
  ///
  /// In en, this message translates to:
  /// **'Enter a clear, short name'**
  String get shortClearNameHint;

  /// Instruction for choosing an icon.
  ///
  /// In en, this message translates to:
  /// **'Choose an icon'**
  String get chooseIcon;

  /// Error saving a When–Then option.
  ///
  /// In en, this message translates to:
  /// **'Could not save this option: {error}'**
  String optionSaveFailed(String error);

  /// Title for deleting a When–Then option.
  ///
  /// In en, this message translates to:
  /// **'Delete option?'**
  String get deleteOptionQuestion;

  /// Confirmation for deleting a When–Then option.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete “{optionName}”?'**
  String deleteOptionMessage(String optionName);

  /// Error deleting a When–Then option.
  ///
  /// In en, this message translates to:
  /// **'Could not delete this option: {error}'**
  String optionDeleteFailed(String error);

  /// Heading for choosing recipients of a When–Then board.
  ///
  /// In en, this message translates to:
  /// **'WHO'**
  String get whoLabel;

  /// Instruction for choosing board recipients.
  ///
  /// In en, this message translates to:
  /// **'Who should see this board?'**
  String get whoShouldSeeBoard;

  /// Single-recipient choice.
  ///
  /// In en, this message translates to:
  /// **'One'**
  String get one;

  /// Multiple-recipient choice.
  ///
  /// In en, this message translates to:
  /// **'Some'**
  String get some;

  /// Summary for an all-children board.
  ///
  /// In en, this message translates to:
  /// **'This board will be sent to all {count} child profiles.'**
  String boardSentToAllChildren(int count);

  /// Message shown when no child profiles are available.
  ///
  /// In en, this message translates to:
  /// **'No child profiles are available.'**
  String get noChildProfilesAvailable;

  /// Instruction for choosing the WHEN activity.
  ///
  /// In en, this message translates to:
  /// **'What needs to happen first?'**
  String get whatHappensFirst;

  /// Empty state for When–Then activities.
  ///
  /// In en, this message translates to:
  /// **'No activities yet. Add one in Manage Options.'**
  String get noActivitiesManageOptions;

  /// Instruction for choosing THEN rewards.
  ///
  /// In en, this message translates to:
  /// **'Choose between 1 and 3 possible rewards.'**
  String get possibleRewardsInstruction;

  /// Empty state for When–Then rewards.
  ///
  /// In en, this message translates to:
  /// **'No rewards yet. Add one in Manage Options.'**
  String get noRewardsManageOptions;

  /// Number of selected When–Then rewards.
  ///
  /// In en, this message translates to:
  /// **'{count} of 3 rewards selected'**
  String rewardsSelectedCount(int count);

  /// Heading for the When–Then board preview.
  ///
  /// In en, this message translates to:
  /// **'Board preview'**
  String get boardPreview;

  /// Empty text in the WHEN preview.
  ///
  /// In en, this message translates to:
  /// **'Choose an activity'**
  String get chooseActivity;

  /// Empty text in the THEN preview.
  ///
  /// In en, this message translates to:
  /// **'Choose rewards'**
  String get chooseRewards;

  /// Number of reward choices in the preview.
  ///
  /// In en, this message translates to:
  /// **'{count} reward choices'**
  String rewardChoicesCount(int count);

  /// Error loading When–Then setup data.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading the board options.'**
  String get boardOptionsLoadFailed;

  /// Heading on the board creation tab.
  ///
  /// In en, this message translates to:
  /// **'Create a clear visual board'**
  String get createClearVisualBoard;

  /// Introduction to creating a When–Then board.
  ///
  /// In en, this message translates to:
  /// **'Choose who it is for, what happens WHEN, and what they can enjoy THEN.'**
  String get createBoardIntro;

  /// Progress label while creating a board.
  ///
  /// In en, this message translates to:
  /// **'Creating board...'**
  String get creatingBoard;

  /// Button for creating a When–Then board.
  ///
  /// In en, this message translates to:
  /// **'Create When–Then Board'**
  String get createWhenThenBoard;

  /// Error loading child profiles.
  ///
  /// In en, this message translates to:
  /// **'Could not load child profiles.'**
  String get childProfilesLoadFailed;

  /// Tab and heading for active When–Then boards.
  ///
  /// In en, this message translates to:
  /// **'Active Boards'**
  String get activeBoards;

  /// Introduction to active When–Then boards.
  ///
  /// In en, this message translates to:
  /// **'See each child\'s current board and clear it when complete.'**
  String get activeBoardsIntro;

  /// Error loading an option list.
  ///
  /// In en, this message translates to:
  /// **'Could not load {title}.'**
  String optionsLoadFailed(String title);

  /// Empty state for a When–Then option list.
  ///
  /// In en, this message translates to:
  /// **'No options have been added yet.'**
  String get noOptionsAdded;

  /// Heading for managing When–Then options.
  ///
  /// In en, this message translates to:
  /// **'Manage Options'**
  String get manageOptions;

  /// Guidance for naming When–Then options.
  ///
  /// In en, this message translates to:
  /// **'Keep names short and clear so children can understand them quickly.'**
  String get manageOptionsIntro;

  /// Heading for managed WHEN activities.
  ///
  /// In en, this message translates to:
  /// **'WHEN Activities'**
  String get whenActivities;

  /// Description of WHEN activities.
  ///
  /// In en, this message translates to:
  /// **'Tasks and activities to complete.'**
  String get whenActivitiesDescription;

  /// Heading for managed THEN rewards.
  ///
  /// In en, this message translates to:
  /// **'THEN Rewards'**
  String get thenRewards;

  /// Description of THEN rewards.
  ///
  /// In en, this message translates to:
  /// **'Positive choices offered afterwards.'**
  String get thenRewardsDescription;

  /// Tab for managing feature options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// Status for a child without an active board.
  ///
  /// In en, this message translates to:
  /// **'No active board'**
  String get noActiveBoard;

  /// Activity summary on an active board.
  ///
  /// In en, this message translates to:
  /// **'WHEN: {activity}'**
  String whenActivitySummary(String activity);

  /// Status before a child chooses a reward.
  ///
  /// In en, this message translates to:
  /// **'THEN: Waiting for reward choice'**
  String get thenWaitingForReward;

  /// Selected reward summary.
  ///
  /// In en, this message translates to:
  /// **'THEN: {reward}'**
  String thenRewardSummary(String reward);

  /// Confirmation after clearing a child's board.
  ///
  /// In en, this message translates to:
  /// **'{childName}\'s board was cleared.'**
  String childBoardCleared(String childName);

  /// Error clearing a child's board.
  ///
  /// In en, this message translates to:
  /// **'Could not clear the board: {error}'**
  String boardClearFailed(String error);

  /// Button marking an item complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Child title for Circle Time.
  ///
  /// In en, this message translates to:
  /// **'My Circle Time'**
  String get myCircleTime;

  /// Error saving Circle Time weather.
  ///
  /// In en, this message translates to:
  /// **'Could not save the weather: {error}'**
  String weatherSaveFailed(String error);

  /// Heading for the daily Circle Time message.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Message'**
  String get todaysMessage;

  /// Example for the daily Circle Time message.
  ///
  /// In en, this message translates to:
  /// **'Example: Today we are going to the library!'**
  String get todaysMessageHint;

  /// Error saving the Circle Time message.
  ///
  /// In en, this message translates to:
  /// **'Could not save today\'s message: {error}'**
  String messageSaveFailed(String error);

  /// Error loading daily Circle Time information.
  ///
  /// In en, this message translates to:
  /// **'Could not load today\'s Circle Time information.'**
  String get circleTimeLoadFailed;

  /// Label for the current day.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Winter season.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get winter;

  /// Spring season.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get spring;

  /// Summer season.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get summer;

  /// Autumn season.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get autumn;

  /// Circle Time weather question.
  ///
  /// In en, this message translates to:
  /// **'What is the weather like today?'**
  String get weatherTodayQuestion;

  /// Sunny weather.
  ///
  /// In en, this message translates to:
  /// **'Sunny'**
  String get sunny;

  /// Cloudy weather.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get cloudy;

  /// Rainy weather.
  ///
  /// In en, this message translates to:
  /// **'Rainy'**
  String get rainy;

  /// Windy weather.
  ///
  /// In en, this message translates to:
  /// **'Windy'**
  String get windy;

  /// Snowy weather.
  ///
  /// In en, this message translates to:
  /// **'Snowy'**
  String get snowy;

  /// Foggy weather.
  ///
  /// In en, this message translates to:
  /// **'Foggy'**
  String get foggy;

  /// Weather empty state.
  ///
  /// In en, this message translates to:
  /// **'The weather has not been selected yet.'**
  String get weatherNotSelected;

  /// Child empty state for today's message.
  ///
  /// In en, this message translates to:
  /// **'There is no message for today yet.'**
  String get noMessageToday;

  /// Staff prompt to add today's message.
  ///
  /// In en, this message translates to:
  /// **'Add a short message or special activity for today.'**
  String get addMessageToday;

  /// Tooltip for editing a message.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get editMessage;

  /// Tooltip for adding a message.
  ///
  /// In en, this message translates to:
  /// **'Add message'**
  String get addMessage;

  /// Error loading staff profiles.
  ///
  /// In en, this message translates to:
  /// **'Could not load staff profiles.'**
  String get staffProfilesLoadFailed;

  /// Home side of the Circle Time board.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// School side of the Circle Time board.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get schoolLabel;

  /// Accessibility label for a child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get childLabel;

  /// Accessibility label for a staff member.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffLabel;

  /// Error saving a Circle Time position.
  ///
  /// In en, this message translates to:
  /// **'Could not save {personName}\'s position.'**
  String personPositionSaveFailed(String personName);

  /// Error loading a child's points.
  ///
  /// In en, this message translates to:
  /// **'Could not load your points.'**
  String get pointsLoadFailed;

  /// Error loading a child's point history.
  ///
  /// In en, this message translates to:
  /// **'Could not load your points history.'**
  String get pointsHistoryLoadFailed;

  /// Points-page greeting.
  ///
  /// In en, this message translates to:
  /// **'Well done, {childName}!'**
  String wellDoneChild(String childName);

  /// Explanation of a child's points.
  ///
  /// In en, this message translates to:
  /// **'Your points celebrate your effort and achievements.'**
  String get pointsCelebrateEffort;

  /// Singular or plural points label.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Point} other{Points}}'**
  String pointLabel(int count);

  /// Heading for the next points milestone.
  ///
  /// In en, this message translates to:
  /// **'Next Star Milestone'**
  String get nextStarMilestone;

  /// Progress toward the next points milestone.
  ///
  /// In en, this message translates to:
  /// **'{current} of 10 points toward {target}'**
  String milestoneProgress(int current, int target);

  /// Completed points milestones.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 milestone completed!} other{{count} milestones completed!}}'**
  String milestonesCompleted(int count);

  /// Heading for a child's recent point history.
  ///
  /// In en, this message translates to:
  /// **'My Recent Achievements'**
  String get recentAchievements;

  /// Empty point-history message.
  ///
  /// In en, this message translates to:
  /// **'Your achievements will appear here.'**
  String get achievementsWillAppear;

  /// Timestamp for a new entry.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Timestamp for an entry from today.
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String todayAt(String time);

  /// Heading for child-visible rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards I Can Work Toward'**
  String get rewardsToWorkToward;

  /// Explanation above child-visible rewards.
  ///
  /// In en, this message translates to:
  /// **'Keep earning points and ask a staff member when you are ready to choose a reward.'**
  String get rewardsChildIntro;

  /// Message when a child can afford a reward.
  ///
  /// In en, this message translates to:
  /// **'Ready to choose!'**
  String get readyToChoose;

  /// Points still needed for a reward.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more point needed} other{{count} more points needed}}'**
  String pointsNeeded(int count);

  /// Point-update dialog title.
  ///
  /// In en, this message translates to:
  /// **'Update {childName}\'s Points'**
  String updateChildPoints(String childName);

  /// Option for adding points.
  ///
  /// In en, this message translates to:
  /// **'Earn Points'**
  String get earnPoints;

  /// Option for removing points.
  ///
  /// In en, this message translates to:
  /// **'Remove Points'**
  String get removePoints;

  /// Point amount question.
  ///
  /// In en, this message translates to:
  /// **'How many points?'**
  String get howManyPoints;

  /// Point-entry reason label.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// Point reason explanation.
  ///
  /// In en, this message translates to:
  /// **'A reason is required for the points history.'**
  String get reasonRequiredInfo;

  /// Optional note field.
  ///
  /// In en, this message translates to:
  /// **'Optional note'**
  String get optionalNote;

  /// Point note hint.
  ///
  /// In en, this message translates to:
  /// **'Add any useful detail about this entry.'**
  String get pointNoteHint;

  /// Point balance restriction.
  ///
  /// In en, this message translates to:
  /// **'Points cannot fall below zero.'**
  String get pointsCannotBelowZero;

  /// Point reason validation.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason.'**
  String get selectReason;

  /// Point balance confirmation.
  ///
  /// In en, this message translates to:
  /// **'{childName} now has {balance} points.'**
  String childPointsBalanceUpdated(String childName, int balance);

  /// Award points button.
  ///
  /// In en, this message translates to:
  /// **'Award Points'**
  String get awardPoints;

  /// Zero point warning.
  ///
  /// In en, this message translates to:
  /// **'This child already has zero points.'**
  String get childAlreadyZeroPoints;

  /// Current balance label.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get currentBalance;

  /// Point history title.
  ///
  /// In en, this message translates to:
  /// **'{childName}\'s Points History'**
  String childPointsHistory(String childName);

  /// Point history error.
  ///
  /// In en, this message translates to:
  /// **'Could not load points history.'**
  String get pointsHistoryLoadError;

  /// Empty point history.
  ///
  /// In en, this message translates to:
  /// **'No points history yet.'**
  String get noPointsHistory;

  /// Balance after entry.
  ///
  /// In en, this message translates to:
  /// **'Balance: {balance}'**
  String balanceValue(int balance);

  /// Reward management tooltip.
  ///
  /// In en, this message translates to:
  /// **'Manage rewards'**
  String get manageRewards;

  /// Staff points loading error.
  ///
  /// In en, this message translates to:
  /// **'Could not load child points.'**
  String get childPointsLoadFailed;

  /// Staff points heading.
  ///
  /// In en, this message translates to:
  /// **'Classroom Points'**
  String get classroomPoints;

  /// Staff points introduction.
  ///
  /// In en, this message translates to:
  /// **'Recognise effort, progress and positive achievements.'**
  String get classroomPointsIntro;

  /// Children count label.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get children;

  /// Total points label.
  ///
  /// In en, this message translates to:
  /// **'Total points'**
  String get totalPoints;

  /// Update points button.
  ///
  /// In en, this message translates to:
  /// **'Update Points'**
  String get updatePoints;

  /// History button.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// Empty staff points instruction.
  ///
  /// In en, this message translates to:
  /// **'Create a child profile before awarding points.'**
  String get createChildBeforePoints;

  /// Point reason.
  ///
  /// In en, this message translates to:
  /// **'Great effort'**
  String get reasonGreatEffort;

  /// Point reason.
  ///
  /// In en, this message translates to:
  /// **'Completed an activity'**
  String get reasonCompletedActivity;

  /// Point reason.
  ///
  /// In en, this message translates to:
  /// **'Kindness'**
  String get reasonKindness;

  /// Point reason.
  ///
  /// In en, this message translates to:
  /// **'Helping others'**
  String get reasonHelpingOthers;

  /// Point reason.
  ///
  /// In en, this message translates to:
  /// **'Good listening'**
  String get reasonGoodListening;

  /// Point reason.
  ///
  /// In en, this message translates to:
  /// **'Personal goal'**
  String get reasonPersonalGoal;

  /// Point reason.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// Point reason.
  ///
  /// In en, this message translates to:
  /// **'Reward redeemed'**
  String get reasonRewardRedeemed;

  /// Point reason.
  ///
  /// In en, this message translates to:
  /// **'Correct previous entry'**
  String get reasonCorrectEntry;

  /// No description provided for @scheduleMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get scheduleMonday;

  /// No description provided for @scheduleTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get scheduleTuesday;

  /// No description provided for @scheduleWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get scheduleWednesday;

  /// No description provided for @scheduleThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get scheduleThursday;

  /// No description provided for @scheduleFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get scheduleFriday;

  /// No description provided for @scheduleMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String scheduleMinutes(num count);

  /// No description provided for @scheduleHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String scheduleHours(num count);

  /// No description provided for @scheduleHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String scheduleHoursMinutes(Object hours, Object minutes);

  /// No description provided for @scheduleActivityCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No activities} =1{1 activity} other{{count} activities}}'**
  String scheduleActivityCount(num count);

  /// No description provided for @scheduleActivityCountToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No activities today} =1{1 activity} other{{count} activities}}'**
  String scheduleActivityCountToday(num count);

  /// No description provided for @classroomScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'{classroomName} Schedule'**
  String classroomScheduleTitle(Object classroomName);

  /// No description provided for @staffScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff Schedule'**
  String get staffScheduleTitle;

  /// No description provided for @scheduleLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The schedule could not be loaded.'**
  String get scheduleLoadFailed;

  /// No description provided for @classroomScheduleLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The classroom schedule could not be loaded.'**
  String get classroomScheduleLoadFailed;

  /// No description provided for @fillTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Fill Time Slot'**
  String get fillTimeSlot;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @activityName.
  ///
  /// In en, this message translates to:
  /// **'Activity name'**
  String get activityName;

  /// No description provided for @activityNameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Morning reading'**
  String get activityNameHint;

  /// No description provided for @activityType.
  ///
  /// In en, this message translates to:
  /// **'Activity type'**
  String get activityType;

  /// No description provided for @enterActivityName.
  ///
  /// In en, this message translates to:
  /// **'Please enter an activity name.'**
  String get enterActivityName;

  /// No description provided for @activityOverlap.
  ///
  /// In en, this message translates to:
  /// **'This duration overlaps another scheduled activity.'**
  String get activityOverlap;

  /// No description provided for @activitySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'The activity could not be saved.'**
  String get activitySaveFailed;

  /// No description provided for @fillSlot.
  ///
  /// In en, this message translates to:
  /// **'Fill Slot'**
  String get fillSlot;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @clearThisSlot.
  ///
  /// In en, this message translates to:
  /// **'Clear This Slot?'**
  String get clearThisSlot;

  /// No description provided for @removeActivityFromDay.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{activity}\" from {day}?'**
  String removeActivityFromDay(Object activity, Object day);

  /// No description provided for @clearSlot.
  ///
  /// In en, this message translates to:
  /// **'Clear Slot'**
  String get clearSlot;

  /// No description provided for @activityRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'The activity could not be removed.'**
  String get activityRemoveFailed;

  /// No description provided for @copySchedule.
  ///
  /// In en, this message translates to:
  /// **'Copy Schedule'**
  String get copySchedule;

  /// No description provided for @copyActivitiesToDay.
  ///
  /// In en, this message translates to:
  /// **'Copy all activities from {sourceDay} to:'**
  String copyActivitiesToDay(Object sourceDay);

  /// No description provided for @targetDay.
  ///
  /// In en, this message translates to:
  /// **'Target day'**
  String get targetDay;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @replaceExistingSchedule.
  ///
  /// In en, this message translates to:
  /// **'Replace Existing Schedule?'**
  String get replaceExistingSchedule;

  /// No description provided for @dayExistingActivityCount.
  ///
  /// In en, this message translates to:
  /// **'{day} already has {count, plural, =1{1 activity} other{{count} activities}}.'**
  String dayExistingActivityCount(num count, Object day);

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @scheduleCopied.
  ///
  /// In en, this message translates to:
  /// **'{sourceDay} was copied to {targetDay}.'**
  String scheduleCopied(Object sourceDay, Object targetDay);

  /// No description provided for @scheduleCopyFailed.
  ///
  /// In en, this message translates to:
  /// **'The schedule could not be copied.'**
  String get scheduleCopyFailed;

  /// No description provided for @copyThisDay.
  ///
  /// In en, this message translates to:
  /// **'Copy this day'**
  String get copyThisDay;

  /// No description provided for @copyDay.
  ///
  /// In en, this message translates to:
  /// **'Copy Day'**
  String get copyDay;

  /// No description provided for @tapBlankSlot.
  ///
  /// In en, this message translates to:
  /// **'Tap a blank slot to begin'**
  String get tapBlankSlot;

  /// No description provided for @addFifteenMinuteActivity.
  ///
  /// In en, this message translates to:
  /// **'Add 15-minute activity'**
  String get addFifteenMinuteActivity;

  /// No description provided for @tapToAddActivity.
  ///
  /// In en, this message translates to:
  /// **'Tap to add activity'**
  String get tapToAddActivity;

  /// No description provided for @editActivityTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit activity'**
  String get editActivityTooltip;

  /// No description provided for @clearSlotTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear slot'**
  String get clearSlotTooltip;

  /// No description provided for @happeningNow.
  ///
  /// In en, this message translates to:
  /// **'Happening Now'**
  String get happeningNow;

  /// No description provided for @comingNext.
  ///
  /// In en, this message translates to:
  /// **'Coming Next'**
  String get comingNext;

  /// No description provided for @nextActivity.
  ///
  /// In en, this message translates to:
  /// **'Next: {activity}'**
  String nextActivity(Object activity);

  /// No description provided for @startsAt.
  ///
  /// In en, this message translates to:
  /// **'Starts at {time}'**
  String startsAt(Object time);

  /// No description provided for @todaysActivitiesFinished.
  ///
  /// In en, this message translates to:
  /// **'All of today’s activities are finished.'**
  String get todaysActivitiesFinished;

  /// No description provided for @dayToday.
  ///
  /// In en, this message translates to:
  /// **'{day} • Today'**
  String dayToday(Object day);

  /// No description provided for @statusNow.
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get statusNow;

  /// No description provided for @statusNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get statusNext;

  /// No description provided for @statusFinished.
  ///
  /// In en, this message translates to:
  /// **'FINISHED'**
  String get statusFinished;

  /// No description provided for @nothingScheduledForDay.
  ///
  /// In en, this message translates to:
  /// **'Nothing is scheduled for {day}'**
  String nothingScheduledForDay(Object day);

  /// No description provided for @enjoyYourDay.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your day!'**
  String get enjoyYourDay;

  /// No description provided for @activityTypeLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get activityTypeLearning;

  /// No description provided for @activityTypeBreak.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get activityTypeBreak;

  /// No description provided for @activityTypeFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get activityTypeFood;

  /// No description provided for @activityTypeMovement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get activityTypeMovement;

  /// No description provided for @activityTypeTherapy.
  ///
  /// In en, this message translates to:
  /// **'Therapy'**
  String get activityTypeTherapy;

  /// No description provided for @activityTypeCreative.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get activityTypeCreative;

  /// No description provided for @activityTypeArrival.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get activityTypeArrival;

  /// No description provided for @activityTypeHome.
  ///
  /// In en, this message translates to:
  /// **'Home Time'**
  String get activityTypeHome;

  /// No description provided for @activityTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get activityTypeOther;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ga'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ga':
      return AppLocalizationsGa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
