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
  /// **'Selected children'**
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
  String welcomeChild(Object childName);

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

  /// Text used in the app for schedule monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get scheduleMonday;

  /// Text used in the app for schedule tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get scheduleTuesday;

  /// Text used in the app for schedule wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get scheduleWednesday;

  /// Text used in the app for schedule thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get scheduleThursday;

  /// Text used in the app for schedule friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get scheduleFriday;

  /// Text used in the app for schedule minutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String scheduleMinutes(num count);

  /// Text used in the app for schedule hours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String scheduleHours(num count);

  /// Text used in the app for schedule hours minutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String scheduleHoursMinutes(Object hours, Object minutes);

  /// Text used in the app for schedule activity count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No activities} =1{1 activity} other{{count} activities}}'**
  String scheduleActivityCount(num count);

  /// Text used in the app for schedule activity count today.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No activities today} =1{1 activity} other{{count} activities}}'**
  String scheduleActivityCountToday(num count);

  /// Text used in the app for classroom schedule title.
  ///
  /// In en, this message translates to:
  /// **'{classroomName} Schedule'**
  String classroomScheduleTitle(Object classroomName);

  /// Text used in the app for staff schedule title.
  ///
  /// In en, this message translates to:
  /// **'Staff Schedule'**
  String get staffScheduleTitle;

  /// Text used in the app for schedule load failed.
  ///
  /// In en, this message translates to:
  /// **'The schedule could not be loaded.'**
  String get scheduleLoadFailed;

  /// Text used in the app for classroom schedule load failed.
  ///
  /// In en, this message translates to:
  /// **'The classroom schedule could not be loaded.'**
  String get classroomScheduleLoadFailed;

  /// Text used in the app for fill time slot.
  ///
  /// In en, this message translates to:
  /// **'Fill Time Slot'**
  String get fillTimeSlot;

  /// Text used in the app for duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Text used in the app for activity name.
  ///
  /// In en, this message translates to:
  /// **'Activity name'**
  String get activityName;

  /// Text used in the app for activity name hint.
  ///
  /// In en, this message translates to:
  /// **'Example: Morning reading'**
  String get activityNameHint;

  /// Text used in the app for activity type.
  ///
  /// In en, this message translates to:
  /// **'Activity type'**
  String get activityType;

  /// Text used in the app for enter activity name.
  ///
  /// In en, this message translates to:
  /// **'Please enter an activity name.'**
  String get enterActivityName;

  /// Text used in the app for activity overlap.
  ///
  /// In en, this message translates to:
  /// **'This duration overlaps another scheduled activity.'**
  String get activityOverlap;

  /// Text used in the app for activity save failed.
  ///
  /// In en, this message translates to:
  /// **'The activity could not be saved.'**
  String get activitySaveFailed;

  /// Text used in the app for fill slot.
  ///
  /// In en, this message translates to:
  /// **'Fill Slot'**
  String get fillSlot;

  /// Text used in the app for save changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Text used in the app for clear this slot.
  ///
  /// In en, this message translates to:
  /// **'Clear This Slot?'**
  String get clearThisSlot;

  /// Text used in the app for remove activity from day.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{activity}\" from {day}?'**
  String removeActivityFromDay(Object activity, Object day);

  /// Text used in the app for clear slot.
  ///
  /// In en, this message translates to:
  /// **'Clear Slot'**
  String get clearSlot;

  /// Text used in the app for activity remove failed.
  ///
  /// In en, this message translates to:
  /// **'The activity could not be removed.'**
  String get activityRemoveFailed;

  /// Text used in the app for copy schedule.
  ///
  /// In en, this message translates to:
  /// **'Copy Schedule'**
  String get copySchedule;

  /// Text used in the app for copy activities to day.
  ///
  /// In en, this message translates to:
  /// **'Copy all activities from {sourceDay} to:'**
  String copyActivitiesToDay(Object sourceDay);

  /// Text used in the app for target day.
  ///
  /// In en, this message translates to:
  /// **'Target day'**
  String get targetDay;

  /// Text used in the app for continue label.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// Text used in the app for replace existing schedule.
  ///
  /// In en, this message translates to:
  /// **'Replace Existing Schedule?'**
  String get replaceExistingSchedule;

  /// Text used in the app for day existing activity count.
  ///
  /// In en, this message translates to:
  /// **'{day} already has {count, plural, =1{1 activity} other{{count} activities}}.'**
  String dayExistingActivityCount(Object day, num count);

  /// Text used in the app for replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// Text used in the app for schedule copied.
  ///
  /// In en, this message translates to:
  /// **'{sourceDay} was copied to {targetDay}.'**
  String scheduleCopied(Object sourceDay, Object targetDay);

  /// Text used in the app for schedule copy failed.
  ///
  /// In en, this message translates to:
  /// **'The schedule could not be copied.'**
  String get scheduleCopyFailed;

  /// Text used in the app for copy this day.
  ///
  /// In en, this message translates to:
  /// **'Copy this day'**
  String get copyThisDay;

  /// Text used in the app for copy day.
  ///
  /// In en, this message translates to:
  /// **'Copy Day'**
  String get copyDay;

  /// Text used in the app for tap blank slot.
  ///
  /// In en, this message translates to:
  /// **'Tap a blank slot to begin'**
  String get tapBlankSlot;

  /// Text used in the app for add fifteen minute activity.
  ///
  /// In en, this message translates to:
  /// **'Add 15-minute activity'**
  String get addFifteenMinuteActivity;

  /// Text used in the app for tap to add activity.
  ///
  /// In en, this message translates to:
  /// **'Tap to add activity'**
  String get tapToAddActivity;

  /// Text used in the app for edit activity tooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit activity'**
  String get editActivityTooltip;

  /// Text used in the app for clear slot tooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear slot'**
  String get clearSlotTooltip;

  /// Text used in the app for happening now.
  ///
  /// In en, this message translates to:
  /// **'Happening Now'**
  String get happeningNow;

  /// Text used in the app for coming next.
  ///
  /// In en, this message translates to:
  /// **'Coming Next'**
  String get comingNext;

  /// Text used in the app for next activity.
  ///
  /// In en, this message translates to:
  /// **'Next: {activity}'**
  String nextActivity(Object activity);

  /// Text used in the app for starts at.
  ///
  /// In en, this message translates to:
  /// **'Starts at {time}'**
  String startsAt(Object time);

  /// Text used in the app for todays activities finished.
  ///
  /// In en, this message translates to:
  /// **'All of today’s activities are finished.'**
  String get todaysActivitiesFinished;

  /// Text used in the app for day today.
  ///
  /// In en, this message translates to:
  /// **'{day} • Today'**
  String dayToday(Object day);

  /// Text used in the app for status now.
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get statusNow;

  /// Text used in the app for status next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get statusNext;

  /// Text used in the app for status finished.
  ///
  /// In en, this message translates to:
  /// **'FINISHED'**
  String get statusFinished;

  /// Text used in the app for nothing scheduled for day.
  ///
  /// In en, this message translates to:
  /// **'Nothing is scheduled for {day}'**
  String nothingScheduledForDay(Object day);

  /// Text used in the app for enjoy your day.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your day!'**
  String get enjoyYourDay;

  /// Text used in the app for activity type learning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get activityTypeLearning;

  /// Text used in the app for activity type break.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get activityTypeBreak;

  /// Text used in the app for activity type food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get activityTypeFood;

  /// Text used in the app for activity type movement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get activityTypeMovement;

  /// Text used in the app for activity type therapy.
  ///
  /// In en, this message translates to:
  /// **'Therapy'**
  String get activityTypeTherapy;

  /// Text used in the app for activity type creative.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get activityTypeCreative;

  /// Text used in the app for activity type arrival.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get activityTypeArrival;

  /// Text used in the app for activity type home.
  ///
  /// In en, this message translates to:
  /// **'Home Time'**
  String get activityTypeHome;

  /// Text used in the app for activity type other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get activityTypeOther;

  /// Text used in the app for school name.
  ///
  /// In en, this message translates to:
  /// **'School Name'**
  String get schoolName;

  /// Text used in the app for school name hint.
  ///
  /// In en, this message translates to:
  /// **'Example: St Mary’s Primary School'**
  String get schoolNameHint;

  /// Text used in the app for school code.
  ///
  /// In en, this message translates to:
  /// **'School Code'**
  String get schoolCode;

  /// Text used in the app for school code hint.
  ///
  /// In en, this message translates to:
  /// **'Example: STM123'**
  String get schoolCodeHint;

  /// Text used in the app for admin email.
  ///
  /// In en, this message translates to:
  /// **'Admin Email'**
  String get adminEmail;

  /// Text used in the app for password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Text used in the app for please wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// Text used in the app for create school admin account.
  ///
  /// In en, this message translates to:
  /// **'Create School Admin Account'**
  String get createSchoolAdminAccount;

  /// Text used in the app for admin login.
  ///
  /// In en, this message translates to:
  /// **'Admin Login'**
  String get adminLogin;

  /// Text used in the app for existing admin login.
  ///
  /// In en, this message translates to:
  /// **'Already have an admin account? Login'**
  String get existingAdminLogin;

  /// Text used in the app for register school prompt.
  ///
  /// In en, this message translates to:
  /// **'No admin account? Register school'**
  String get registerSchoolPrompt;

  /// Text used in the app for classroom code.
  ///
  /// In en, this message translates to:
  /// **'Classroom Code'**
  String get classroomCode;

  /// Text used in the app for classroom code hint.
  ///
  /// In en, this message translates to:
  /// **'Example: ASD1'**
  String get classroomCodeHint;

  /// Text used in the app for classroom pin.
  ///
  /// In en, this message translates to:
  /// **'Classroom PIN'**
  String get classroomPin;

  /// Text used in the app for checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// Text used in the app for enter classroom.
  ///
  /// In en, this message translates to:
  /// **'Enter Classroom'**
  String get enterClassroom;

  /// Text used in the app for create school admin intro.
  ///
  /// In en, this message translates to:
  /// **'Create a school admin account'**
  String get createSchoolAdminIntro;

  /// Text used in the app for admin login intro.
  ///
  /// In en, this message translates to:
  /// **'Admin login'**
  String get adminLoginIntro;

  /// Text used in the app for classroom login intro.
  ///
  /// In en, this message translates to:
  /// **'Classroom login'**
  String get classroomLoginIntro;

  /// Text used in the app for admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// Text used in the app for classroom.
  ///
  /// In en, this message translates to:
  /// **'Classroom'**
  String get classroom;

  /// Text used in the app for enter school details.
  ///
  /// In en, this message translates to:
  /// **'Please enter a school name and school code.'**
  String get enterSchoolDetails;

  /// Text used in the app for admin account create failed.
  ///
  /// In en, this message translates to:
  /// **'Could not create admin account.'**
  String get adminAccountCreateFailed;

  /// Text used in the app for login failed.
  ///
  /// In en, this message translates to:
  /// **'Could not log in.'**
  String get loginFailed;

  /// Text used in the app for enter classroom details.
  ///
  /// In en, this message translates to:
  /// **'Please enter school code, classroom code and PIN.'**
  String get enterClassroomDetails;

  /// Text used in the app for classroom login incorrect.
  ///
  /// In en, this message translates to:
  /// **'Classroom login details are incorrect.'**
  String get classroomLoginIncorrect;

  /// Text used in the app for check login fields.
  ///
  /// In en, this message translates to:
  /// **'Please check all login fields.'**
  String get checkLoginFields;

  /// Text used in the app for admin login incorrect.
  ///
  /// In en, this message translates to:
  /// **'Admin email or password is incorrect.'**
  String get adminLoginIncorrect;

  /// Text used in the app for logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Text used in the app for logout confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// Text used in the app for access denied incorrect pin.
  ///
  /// In en, this message translates to:
  /// **'Access denied: incorrect PIN'**
  String get accessDeniedIncorrectPin;

  /// Text used in the app for staff profile deleted.
  ///
  /// In en, this message translates to:
  /// **'Staff profile deleted'**
  String get staffProfileDeleted;

  /// Text used in the app for child profile deleted.
  ///
  /// In en, this message translates to:
  /// **'Child profile deleted'**
  String get childProfileDeleted;

  /// Text used in the app for staff profile delete failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete staff profile: {error}'**
  String staffProfileDeleteFailed(Object error);

  /// Text used in the app for child profile delete failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete child profile: {error}'**
  String childProfileDeleteFailed(Object error);

  /// Text used in the app for choose profile.
  ///
  /// In en, this message translates to:
  /// **'Choose a profile to continue'**
  String get chooseProfile;

  /// Text used in the app for staff profiles.
  ///
  /// In en, this message translates to:
  /// **'Staff Profiles'**
  String get staffProfiles;

  /// Text used in the app for child profiles.
  ///
  /// In en, this message translates to:
  /// **'Child Profiles'**
  String get childProfiles;

  /// Text used in the app for staff profile.
  ///
  /// In en, this message translates to:
  /// **'Staff profile'**
  String get staffProfile;

  /// Text used in the app for no child profiles short.
  ///
  /// In en, this message translates to:
  /// **'No child profiles found'**
  String get noChildProfilesShort;

  /// Text used in the app for age value.
  ///
  /// In en, this message translates to:
  /// **'Age: {age}'**
  String ageValue(Object age);

  /// Text used in the app for admin actions.
  ///
  /// In en, this message translates to:
  /// **'Admin Actions'**
  String get adminActions;

  /// Text used in the app for add profile.
  ///
  /// In en, this message translates to:
  /// **'Add Profile'**
  String get addProfile;

  /// Text used in the app for create profiles intro.
  ///
  /// In en, this message translates to:
  /// **'Create staff or child profiles'**
  String get createProfilesIntro;

  /// Text used in the app for app settings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// Text used in the app for account settings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// Text used in the app for language app options.
  ///
  /// In en, this message translates to:
  /// **'Language and app options'**
  String get languageAppOptions;

  /// Text used in the app for manage pin account options.
  ///
  /// In en, this message translates to:
  /// **'Manage PIN and account options'**
  String get managePinAccountOptions;

  /// Text used in the app for manage app settings.
  ///
  /// In en, this message translates to:
  /// **'Manage app settings'**
  String get manageAppSettings;

  /// Text used in the app for manage your account.
  ///
  /// In en, this message translates to:
  /// **'Manage your account'**
  String get manageYourAccount;

  /// Text used in the app for app settings description.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language and general app options.'**
  String get appSettingsDescription;

  /// Text used in the app for account settings description.
  ///
  /// In en, this message translates to:
  /// **'Set your PIN and choose the app language.'**
  String get accountSettingsDescription;

  /// Text used in the app for overwrite existing pin question.
  ///
  /// In en, this message translates to:
  /// **'Overwrite existing PIN?'**
  String get overwriteExistingPinQuestion;

  /// Text used in the app for overwrite existing pin message.
  ///
  /// In en, this message translates to:
  /// **'This will replace your current PIN. Continue?'**
  String get overwriteExistingPinMessage;

  /// Text used in the app for pin is set.
  ///
  /// In en, this message translates to:
  /// **'PIN is set'**
  String get pinIsSet;

  /// Text used in the app for no pin set.
  ///
  /// In en, this message translates to:
  /// **'No PIN set'**
  String get noPinSet;

  /// Text used in the app for account pin protects staff areas.
  ///
  /// In en, this message translates to:
  /// **'The account PIN protects staff-only areas.'**
  String get accountPinProtectsStaffAreas;

  /// Text used in the app for change pin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// Text used in the app for new pin instructions.
  ///
  /// In en, this message translates to:
  /// **'Enter a new 4-digit PIN.'**
  String get newPinInstructions;

  /// Text used in the app for choose app language.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language.'**
  String get chooseAppLanguage;

  /// Text used in the app for staff load error.
  ///
  /// In en, this message translates to:
  /// **'Error loading staff: {error}'**
  String staffLoadError(Object error);

  /// Text used in the app for children load error.
  ///
  /// In en, this message translates to:
  /// **'Error loading children: {error}'**
  String childrenLoadError(Object error);

  /// Text used in the app for delete profile.
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get deleteProfile;

  /// Text used in the app for enter pin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// Text used in the app for pin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// Text used in the app for incorrect pin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get incorrectPin;

  /// Text used in the app for submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Text used in the app for clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Text used in the app for next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Text used in the app for start over.
  ///
  /// In en, this message translates to:
  /// **'Start Over'**
  String get startOver;

  /// Text used in the app for success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Text used in the app for ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Text used in the app for role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// Text used in the app for age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// Text used in the app for name required.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// Text used in the app for role required.
  ///
  /// In en, this message translates to:
  /// **'Role is required'**
  String get roleRequired;

  /// Text used in the app for age required.
  ///
  /// In en, this message translates to:
  /// **'Age is required'**
  String get ageRequired;

  /// Text used in the app for age number required.
  ///
  /// In en, this message translates to:
  /// **'Age must be a number'**
  String get ageNumberRequired;

  /// Text used in the app for add staff profile.
  ///
  /// In en, this message translates to:
  /// **'Add Staff Profile'**
  String get addStaffProfile;

  /// Text used in the app for add child profile.
  ///
  /// In en, this message translates to:
  /// **'Add Child Profile'**
  String get addChildProfile;

  /// Text used in the app for profiles saved to classroom.
  ///
  /// In en, this message translates to:
  /// **'New profiles will be saved to this classroom.'**
  String get profilesSavedToClassroom;

  /// Text used in the app for create staff profile.
  ///
  /// In en, this message translates to:
  /// **'Create a staff profile'**
  String get createStaffProfile;

  /// Text used in the app for create child profile.
  ///
  /// In en, this message translates to:
  /// **'Create a child profile'**
  String get createChildProfile;

  /// Text used in the app for staff profile access info.
  ///
  /// In en, this message translates to:
  /// **'Staff profiles use the account or classroom PIN for access.'**
  String get staffProfileAccessInfo;

  /// Text used in the app for child profile access info.
  ///
  /// In en, this message translates to:
  /// **'Child profiles can use a simple 3-icon unlock sequence.'**
  String get childProfileAccessInfo;

  /// Text used in the app for staff details.
  ///
  /// In en, this message translates to:
  /// **'Staff Details'**
  String get staffDetails;

  /// Text used in the app for child details.
  ///
  /// In en, this message translates to:
  /// **'Child Details'**
  String get childDetails;

  /// Text used in the app for confirm child unlock.
  ///
  /// In en, this message translates to:
  /// **'Confirm Child Unlock Sequence'**
  String get confirmChildUnlock;

  /// Text used in the app for set child unlock.
  ///
  /// In en, this message translates to:
  /// **'Set Child Unlock Sequence'**
  String get setChildUnlock;

  /// Text used in the app for tap same icons confirm.
  ///
  /// In en, this message translates to:
  /// **'Tap the same 3 icons again to confirm.'**
  String get tapSameIconsConfirm;

  /// Text used in the app for ask child pick icons.
  ///
  /// In en, this message translates to:
  /// **'Ask the child to pick 3 icons in order.'**
  String get askChildPickIcons;

  /// Text used in the app for choose three icons first.
  ///
  /// In en, this message translates to:
  /// **'Please choose 3 icons first'**
  String get chooseThreeIconsFirst;

  /// Text used in the app for choose unlock sequence.
  ///
  /// In en, this message translates to:
  /// **'Please choose a 3-icon unlock sequence'**
  String get chooseUnlockSequence;

  /// Text used in the app for confirm child unlock prompt.
  ///
  /// In en, this message translates to:
  /// **'Please confirm the child unlock sequence'**
  String get confirmChildUnlockPrompt;

  /// Text used in the app for confirm three icons prompt.
  ///
  /// In en, this message translates to:
  /// **'Please tap the same 3 icons again to confirm'**
  String get confirmThreeIconsPrompt;

  /// Text used in the app for sequences do not match.
  ///
  /// In en, this message translates to:
  /// **'Sequences did not match. Please try again.'**
  String get sequencesDoNotMatch;

  /// Text used in the app for profile created.
  ///
  /// In en, this message translates to:
  /// **'Profile \"{name}\" created successfully.'**
  String profileCreated(Object name);

  /// Text used in the app for profile save error.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile: {error}'**
  String profileSaveError(Object error);

  /// Text used in the app for save staff profile.
  ///
  /// In en, this message translates to:
  /// **'Save Staff Profile'**
  String get saveStaffProfile;

  /// Text used in the app for save child profile.
  ///
  /// In en, this message translates to:
  /// **'Save Child Profile'**
  String get saveChildProfile;

  /// Text used in the app for selected none.
  ///
  /// In en, this message translates to:
  /// **'Selected: None'**
  String get selectedNone;

  /// Text used in the app for selected icons.
  ///
  /// In en, this message translates to:
  /// **'Selected: {icons}'**
  String selectedIcons(Object icons);

  /// Text used in the app for selected count.
  ///
  /// In en, this message translates to:
  /// **'{selected}/{required} selected'**
  String selectedCount(Object selected, Object required);

  /// Text used in the app for wrong icon sequence.
  ///
  /// In en, this message translates to:
  /// **'Wrong sequence, try again'**
  String get wrongIconSequence;

  /// Text used in the app for unlock child.
  ///
  /// In en, this message translates to:
  /// **'Unlock {childName}'**
  String unlockChild(Object childName);

  /// Text used in the app for tap pictures in order.
  ///
  /// In en, this message translates to:
  /// **'Tap your 3 pictures in order'**
  String get tapPicturesInOrder;

  /// Text used in the app for entered count.
  ///
  /// In en, this message translates to:
  /// **'Entered: {entered}/{required}'**
  String enteredCount(Object entered, Object required);

  /// Text used in the app for reset unlock for child.
  ///
  /// In en, this message translates to:
  /// **'Reset unlock for {childName}'**
  String resetUnlockForChild(Object childName);

  /// Text used in the app for choose icons in order.
  ///
  /// In en, this message translates to:
  /// **'Choose 3 icons in order'**
  String get chooseIconsInOrder;

  /// Text used in the app for confirm icon sequence.
  ///
  /// In en, this message translates to:
  /// **'Please confirm the 3-icon sequence'**
  String get confirmIconSequence;

  /// Text used in the app for icon sequences do not match.
  ///
  /// In en, this message translates to:
  /// **'Sequences did not match. Try again.'**
  String get iconSequencesDoNotMatch;

  /// Text used in the app for icon star.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get iconStar;

  /// Text used in the app for icon car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get iconCar;

  /// Text used in the app for icon dog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get iconDog;

  /// Text used in the app for icon apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get iconApple;

  /// Text used in the app for icon ball.
  ///
  /// In en, this message translates to:
  /// **'Ball'**
  String get iconBall;

  /// Text used in the app for icon music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get iconMusic;

  /// Text used in the app for icon sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get iconSun;

  /// Text used in the app for icon heart.
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get iconHeart;

  /// Text used in the app for school admin title.
  ///
  /// In en, this message translates to:
  /// **'{schoolName} Admin'**
  String schoolAdminTitle(Object schoolName);

  /// Text used in the app for school settings.
  ///
  /// In en, this message translates to:
  /// **'School Settings'**
  String get schoolSettings;

  /// Text used in the app for school code value.
  ///
  /// In en, this message translates to:
  /// **'School Code: {code}'**
  String schoolCodeValue(Object code);

  /// Text used in the app for classrooms used.
  ///
  /// In en, this message translates to:
  /// **'Classrooms Used: {used} / {limit}'**
  String classroomsUsed(Object used, Object limit);

  /// Text used in the app for status value.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusValue(Object status);

  /// Text used in the app for active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Text used in the app for inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Text used in the app for classrooms load error.
  ///
  /// In en, this message translates to:
  /// **'Error loading classrooms: {error}'**
  String classroomsLoadError(Object error);

  /// Text used in the app for no classrooms yet.
  ///
  /// In en, this message translates to:
  /// **'No classrooms yet.\nTap + Add Classroom to create one.'**
  String get noClassroomsYet;

  /// Text used in the app for classroom list summary.
  ///
  /// In en, this message translates to:
  /// **'Code: {code} • Active: {active}'**
  String classroomListSummary(Object code, Object active);

  /// Text used in the app for yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Text used in the app for no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Text used in the app for add classroom.
  ///
  /// In en, this message translates to:
  /// **'Add Classroom'**
  String get addClassroom;

  /// Text used in the app for classroom created.
  ///
  /// In en, this message translates to:
  /// **'Classroom created'**
  String get classroomCreated;

  /// Text used in the app for classroom create error.
  ///
  /// In en, this message translates to:
  /// **'Error creating classroom: {error}'**
  String classroomCreateError(Object error);

  /// Text used in the app for create classroom.
  ///
  /// In en, this message translates to:
  /// **'Create Classroom'**
  String get createClassroom;

  /// Text used in the app for classroom details.
  ///
  /// In en, this message translates to:
  /// **'Classroom Details'**
  String get classroomDetails;

  /// Text used in the app for classroom name.
  ///
  /// In en, this message translates to:
  /// **'Classroom Name'**
  String get classroomName;

  /// Text used in the app for classroom name hint.
  ///
  /// In en, this message translates to:
  /// **'Example: ASD Unit 1'**
  String get classroomNameHint;

  /// Text used in the app for enter classroom name.
  ///
  /// In en, this message translates to:
  /// **'Enter a classroom name'**
  String get enterClassroomName;

  /// Text used in the app for enter classroom code.
  ///
  /// In en, this message translates to:
  /// **'Enter a classroom code'**
  String get enterClassroomCode;

  /// Text used in the app for classroom code min length.
  ///
  /// In en, this message translates to:
  /// **'Classroom code should be at least 3 characters'**
  String get classroomCodeMinLength;

  /// Text used in the app for classroom pin hint.
  ///
  /// In en, this message translates to:
  /// **'Example: 1234'**
  String get classroomPinHint;

  /// Text used in the app for enter classroom pin.
  ///
  /// In en, this message translates to:
  /// **'Enter a classroom PIN'**
  String get enterClassroomPin;

  /// Text used in the app for classroom pin min length.
  ///
  /// In en, this message translates to:
  /// **'PIN should be at least 4 digits'**
  String get classroomPinMinLength;

  /// Text used in the app for classroom not found.
  ///
  /// In en, this message translates to:
  /// **'Classroom not found'**
  String get classroomNotFound;

  /// Text used in the app for classroom load error.
  ///
  /// In en, this message translates to:
  /// **'Error loading classroom: {error}'**
  String classroomLoadError(Object error);

  /// Text used in the app for classroom updated.
  ///
  /// In en, this message translates to:
  /// **'Classroom updated'**
  String get classroomUpdated;

  /// Text used in the app for delete classroom.
  ///
  /// In en, this message translates to:
  /// **'Delete Classroom'**
  String get deleteClassroom;

  /// Text used in the app for delete classroom confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this classroom? This cannot be undone.'**
  String get deleteClassroomConfirmation;

  /// Text used in the app for classroom deleted.
  ///
  /// In en, this message translates to:
  /// **'Classroom deleted'**
  String get classroomDeleted;

  /// Text used in the app for classroom delete error.
  ///
  /// In en, this message translates to:
  /// **'Error deleting classroom: {error}'**
  String classroomDeleteError(Object error);

  /// Text used in the app for classroom information.
  ///
  /// In en, this message translates to:
  /// **'Classroom Information'**
  String get classroomInformation;

  /// Text used in the app for classroom access info.
  ///
  /// In en, this message translates to:
  /// **'These details control how staff access this classroom.'**
  String get classroomAccessInfo;

  /// Text used in the app for classroom code change info.
  ///
  /// In en, this message translates to:
  /// **'Changing this code will change what staff enter on the Classroom Login screen.'**
  String get classroomCodeChangeInfo;

  /// Text used in the app for classroom active.
  ///
  /// In en, this message translates to:
  /// **'Classroom Active'**
  String get classroomActive;

  /// Text used in the app for classroom inactive info.
  ///
  /// In en, this message translates to:
  /// **'If disabled, classroom login will be blocked for this classroom.'**
  String get classroomInactiveInfo;

  /// Text used in the app for save classroom.
  ///
  /// In en, this message translates to:
  /// **'Save Classroom'**
  String get saveClassroom;

  /// Text used in the app for school not found.
  ///
  /// In en, this message translates to:
  /// **'School not found'**
  String get schoolNotFound;

  /// Text used in the app for school settings load error.
  ///
  /// In en, this message translates to:
  /// **'Error loading school settings: {error}'**
  String schoolSettingsLoadError(Object error);

  /// Text used in the app for school settings updated.
  ///
  /// In en, this message translates to:
  /// **'School settings updated'**
  String get schoolSettingsUpdated;

  /// Text used in the app for school information.
  ///
  /// In en, this message translates to:
  /// **'School Information'**
  String get schoolInformation;

  /// Text used in the app for school account info.
  ///
  /// In en, this message translates to:
  /// **'These details control the school account and classroom login.'**
  String get schoolAccountInfo;

  /// Text used in the app for enter school name.
  ///
  /// In en, this message translates to:
  /// **'Enter a school name'**
  String get enterSchoolName;

  /// Text used in the app for enter school code.
  ///
  /// In en, this message translates to:
  /// **'Enter a school code'**
  String get enterSchoolCode;

  /// Text used in the app for school code min length.
  ///
  /// In en, this message translates to:
  /// **'School code should be at least 3 characters'**
  String get schoolCodeMinLength;

  /// Text used in the app for school code change info.
  ///
  /// In en, this message translates to:
  /// **'Changing the school code will change what staff enter on the Classroom Login screen.'**
  String get schoolCodeChangeInfo;

  /// Text used in the app for classroom limit.
  ///
  /// In en, this message translates to:
  /// **'Classroom Limit'**
  String get classroomLimit;

  /// Text used in the app for enter classroom limit.
  ///
  /// In en, this message translates to:
  /// **'Enter a classroom limit'**
  String get enterClassroomLimit;

  /// Text used in the app for enter valid number.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// Text used in the app for classroom limit minimum.
  ///
  /// In en, this message translates to:
  /// **'Classroom limit must be at least 1'**
  String get classroomLimitMinimum;

  /// Text used in the app for contact details.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get contactDetails;

  /// Text used in the app for principal name.
  ///
  /// In en, this message translates to:
  /// **'Principal Name'**
  String get principalName;

  /// Text used in the app for vice principal name.
  ///
  /// In en, this message translates to:
  /// **'Vice Principal Name'**
  String get vicePrincipalName;

  /// Text used in the app for school email.
  ///
  /// In en, this message translates to:
  /// **'School Email'**
  String get schoolEmail;

  /// Text used in the app for phone number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Text used in the app for school address.
  ///
  /// In en, this message translates to:
  /// **'School Address'**
  String get schoolAddress;

  /// Text used in the app for school active.
  ///
  /// In en, this message translates to:
  /// **'School Active'**
  String get schoolActive;

  /// Text used in the app for school inactive info.
  ///
  /// In en, this message translates to:
  /// **'If disabled later, classroom login can be blocked for this school.'**
  String get schoolInactiveInfo;

  /// Text used in the app for save school settings.
  ///
  /// In en, this message translates to:
  /// **'Save School Settings'**
  String get saveSchoolSettings;

  /// Text used in the app for school code in use.
  ///
  /// In en, this message translates to:
  /// **'That school code is already in use.'**
  String get schoolCodeInUse;

  /// Text used in the app for classroom code in use.
  ///
  /// In en, this message translates to:
  /// **'That classroom code is already in use.'**
  String get classroomCodeInUse;

  /// Text used in the app for classroom limit reached.
  ///
  /// In en, this message translates to:
  /// **'Classroom limit reached. Increase the classroom limit in School Settings.'**
  String get classroomLimitReached;

  /// Text used in the app for classroom update error.
  ///
  /// In en, this message translates to:
  /// **'The classroom could not be updated.'**
  String get classroomUpdateError;

  /// Text used in the app for school settings update error.
  ///
  /// In en, this message translates to:
  /// **'The school settings could not be updated.'**
  String get schoolSettingsUpdateError;

  /// Text used in the app for body part head.
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get bodyPartHead;

  /// Text used in the app for body part throat.
  ///
  /// In en, this message translates to:
  /// **'Throat'**
  String get bodyPartThroat;

  /// Text used in the app for body part chest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get bodyPartChest;

  /// Text used in the app for body part tummy.
  ///
  /// In en, this message translates to:
  /// **'Tummy'**
  String get bodyPartTummy;

  /// Text used in the app for body part left arm.
  ///
  /// In en, this message translates to:
  /// **'Left arm'**
  String get bodyPartLeftArm;

  /// Text used in the app for body part right arm.
  ///
  /// In en, this message translates to:
  /// **'Right arm'**
  String get bodyPartRightArm;

  /// Text used in the app for body part left hand.
  ///
  /// In en, this message translates to:
  /// **'Left hand'**
  String get bodyPartLeftHand;

  /// Text used in the app for body part right hand.
  ///
  /// In en, this message translates to:
  /// **'Right hand'**
  String get bodyPartRightHand;

  /// Text used in the app for body part left leg.
  ///
  /// In en, this message translates to:
  /// **'Left leg'**
  String get bodyPartLeftLeg;

  /// Text used in the app for body part right leg.
  ///
  /// In en, this message translates to:
  /// **'Right leg'**
  String get bodyPartRightLeg;

  /// Text used in the app for body part left foot.
  ///
  /// In en, this message translates to:
  /// **'Left foot'**
  String get bodyPartLeftFoot;

  /// Text used in the app for body part right foot.
  ///
  /// In en, this message translates to:
  /// **'Right foot'**
  String get bodyPartRightFoot;

  /// Text used in the app for body part back of head.
  ///
  /// In en, this message translates to:
  /// **'Back of head'**
  String get bodyPartBackOfHead;

  /// Text used in the app for body part neck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get bodyPartNeck;

  /// Text used in the app for body part upper back.
  ///
  /// In en, this message translates to:
  /// **'Upper back'**
  String get bodyPartUpperBack;

  /// Text used in the app for body part lower back.
  ///
  /// In en, this message translates to:
  /// **'Lower back'**
  String get bodyPartLowerBack;

  /// Text used in the app for body map front.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get bodyMapFront;

  /// Text used in the app for body map back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get bodyMapBack;

  /// Text used in the app for body diagram semantics.
  ///
  /// In en, this message translates to:
  /// **'{side} body diagram. Tap where it hurts.'**
  String bodyDiagramSemantics(Object side);

  /// Text used in the app for tap sore body part.
  ///
  /// In en, this message translates to:
  /// **'Tap the body where you feel sore or uncomfortable.'**
  String get tapSoreBodyPart;

  /// Text used in the app for body part selected.
  ///
  /// In en, this message translates to:
  /// **'You selected: {bodyPart}'**
  String bodyPartSelected(Object bodyPart);

  /// Text used in the app for choose body part list.
  ///
  /// In en, this message translates to:
  /// **'Choose from a list instead'**
  String get chooseBodyPartList;

  /// Text used in the app for pain little sore.
  ///
  /// In en, this message translates to:
  /// **'A little sore'**
  String get painLittleSore;

  /// Text used in the app for pain little sore description.
  ///
  /// In en, this message translates to:
  /// **'I notice it, but it only hurts a little.'**
  String get painLittleSoreDescription;

  /// Text used in the app for pain hurts.
  ///
  /// In en, this message translates to:
  /// **'It hurts'**
  String get painHurts;

  /// Text used in the app for pain hurts short.
  ///
  /// In en, this message translates to:
  /// **'Hurts'**
  String get painHurtsShort;

  /// Text used in the app for pain hurts description.
  ///
  /// In en, this message translates to:
  /// **'It is uncomfortable and I need help.'**
  String get painHurtsDescription;

  /// Text used in the app for pain hurts alot.
  ///
  /// In en, this message translates to:
  /// **'It hurts a lot'**
  String get painHurtsALot;

  /// Text used in the app for pain hurts alot short.
  ///
  /// In en, this message translates to:
  /// **'Hurts a lot'**
  String get painHurtsALotShort;

  /// Text used in the app for pain hurts alot description.
  ///
  /// In en, this message translates to:
  /// **'It hurts badly and I need an adult now.'**
  String get painHurtsALotDescription;

  /// Text used in the app for pain unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get painUnknown;

  /// Text used in the app for pain sore aching.
  ///
  /// In en, this message translates to:
  /// **'Sore or aching'**
  String get painSoreAching;

  /// Text used in the app for pain sore aching description.
  ///
  /// In en, this message translates to:
  /// **'A dull or heavy pain.'**
  String get painSoreAchingDescription;

  /// Text used in the app for pain sharp.
  ///
  /// In en, this message translates to:
  /// **'Sharp'**
  String get painSharp;

  /// Text used in the app for pain sharp description.
  ///
  /// In en, this message translates to:
  /// **'A sudden or pointed pain.'**
  String get painSharpDescription;

  /// Text used in the app for pain burning hot.
  ///
  /// In en, this message translates to:
  /// **'Burning or hot'**
  String get painBurningHot;

  /// Text used in the app for pain burning hot description.
  ///
  /// In en, this message translates to:
  /// **'It feels hot or burning.'**
  String get painBurningHotDescription;

  /// Text used in the app for pain itchy.
  ///
  /// In en, this message translates to:
  /// **'Itchy'**
  String get painItchy;

  /// Text used in the app for pain itchy description.
  ///
  /// In en, this message translates to:
  /// **'I want to scratch it.'**
  String get painItchyDescription;

  /// Text used in the app for pain throbbing.
  ///
  /// In en, this message translates to:
  /// **'Throbbing'**
  String get painThrobbing;

  /// Text used in the app for pain throbbing description.
  ///
  /// In en, this message translates to:
  /// **'It pulses or beats.'**
  String get painThrobbingDescription;

  /// Text used in the app for pain tingly numb.
  ///
  /// In en, this message translates to:
  /// **'Tingly or numb'**
  String get painTinglyNumb;

  /// Text used in the app for pain tingly numb description.
  ///
  /// In en, this message translates to:
  /// **'It feels asleep or strange.'**
  String get painTinglyNumbDescription;

  /// Text used in the app for pain sick.
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get painSick;

  /// Text used in the app for pain sick description.
  ///
  /// In en, this message translates to:
  /// **'I feel like I might be sick.'**
  String get painSickDescription;

  /// Text used in the app for pain not sure.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get painNotSure;

  /// Text used in the app for pain not sure description.
  ///
  /// In en, this message translates to:
  /// **'I cannot explain the feeling.'**
  String get painNotSureDescription;

  /// Text used in the app for choose sore location.
  ///
  /// In en, this message translates to:
  /// **'Please choose where you feel sore.'**
  String get chooseSoreLocation;

  /// Text used in the app for choose pain amount.
  ///
  /// In en, this message translates to:
  /// **'Please choose how much it hurts.'**
  String get choosePainAmount;

  /// Text used in the app for choose pain feeling.
  ///
  /// In en, this message translates to:
  /// **'Please choose what it feels like.'**
  String get choosePainFeeling;

  /// Text used in the app for body check send failed.
  ///
  /// In en, this message translates to:
  /// **'Your Body Check could not be sent. Please tell an adult now.'**
  String get bodyCheckSendFailed;

  /// Text used in the app for staff have been told.
  ///
  /// In en, this message translates to:
  /// **'Staff Have Been Told'**
  String get staffHaveBeenTold;

  /// Text used in the app for body check sent message.
  ///
  /// In en, this message translates to:
  /// **'Your Body Check was sent.\n\nPlease tell an adult now if you need help.'**
  String get bodyCheckSentMessage;

  /// Text used in the app for okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get okay;

  /// Text used in the app for body check where.
  ///
  /// In en, this message translates to:
  /// **'Where?'**
  String get bodyCheckWhere;

  /// Text used in the app for body check how much.
  ///
  /// In en, this message translates to:
  /// **'How much?'**
  String get bodyCheckHowMuch;

  /// Text used in the app for body check what feeling.
  ///
  /// In en, this message translates to:
  /// **'What feeling?'**
  String get bodyCheckWhatFeeling;

  /// Text used in the app for review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// Text used in the app for body check step.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}: {name}'**
  String bodyCheckStep(Object current, Object total, Object name);

  /// Text used in the app for where does it hurt.
  ///
  /// In en, this message translates to:
  /// **'Where does it hurt?'**
  String get whereDoesItHurt;

  /// Text used in the app for how much does it hurt.
  ///
  /// In en, this message translates to:
  /// **'How much does it hurt?'**
  String get howMuchDoesItHurt;

  /// Text used in the app for choose pain face.
  ///
  /// In en, this message translates to:
  /// **'Choose the face that best shows how you feel.'**
  String get choosePainFace;

  /// Text used in the app for what does it feel like.
  ///
  /// In en, this message translates to:
  /// **'What does it feel like?'**
  String get whatDoesItFeelLike;

  /// Text used in the app for choose pain description.
  ///
  /// In en, this message translates to:
  /// **'Choose the description that feels closest. It is okay if you are not sure.'**
  String get choosePainDescription;

  /// Text used in the app for check your body check.
  ///
  /// In en, this message translates to:
  /// **'Check Your Body Check'**
  String get checkYourBodyCheck;

  /// Text used in the app for review body check message.
  ///
  /// In en, this message translates to:
  /// **'Make sure this shows how you feel before telling staff.'**
  String get reviewBodyCheckMessage;

  /// Text used in the app for tell adult body check.
  ///
  /// In en, this message translates to:
  /// **'If you need help now, please tell an adult as well as sending this Body Check.'**
  String get tellAdultBodyCheck;

  /// Text used in the app for change body check answer.
  ///
  /// In en, this message translates to:
  /// **'Change {label}'**
  String changeBodyCheckAnswer(Object label);

  /// Text used in the app for back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Text used in the app for sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// Text used in the app for tell staff.
  ///
  /// In en, this message translates to:
  /// **'Tell Staff'**
  String get tellStaff;

  /// Text used in the app for continue button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Text used in the app for check child report.
  ///
  /// In en, this message translates to:
  /// **'Check {childName}’s Report'**
  String checkChildReport(Object childName);

  /// Text used in the app for optional staff note.
  ///
  /// In en, this message translates to:
  /// **'Optional staff note'**
  String get optionalStaffNote;

  /// Text used in the app for staff note hint.
  ///
  /// In en, this message translates to:
  /// **'Record what was checked or what support was given.'**
  String get staffNoteHint;

  /// Text used in the app for mark checked.
  ///
  /// In en, this message translates to:
  /// **'Mark Checked'**
  String get markChecked;

  /// Text used in the app for report marked checked.
  ///
  /// In en, this message translates to:
  /// **'{childName}’s report was marked as checked.'**
  String reportMarkedChecked(Object childName);

  /// Text used in the app for report update failed.
  ///
  /// In en, this message translates to:
  /// **'The report could not be updated.'**
  String get reportUpdateFailed;

  /// Text used in the app for delete report question.
  ///
  /// In en, this message translates to:
  /// **'Delete Report?'**
  String get deleteReportQuestion;

  /// Text used in the app for delete body check report.
  ///
  /// In en, this message translates to:
  /// **'Delete this Body Check report for {childName}?\n\nThis cannot be undone.'**
  String deleteBodyCheckReport(Object childName);

  /// Text used in the app for report delete failed.
  ///
  /// In en, this message translates to:
  /// **'The report could not be deleted.'**
  String get reportDeleteFailed;

  /// Text used in the app for classroom body checks.
  ///
  /// In en, this message translates to:
  /// **'Classroom Body Checks'**
  String get classroomBodyChecks;

  /// Text used in the app for classroom body checks intro.
  ///
  /// In en, this message translates to:
  /// **'Review reports and record when support has been provided.'**
  String get classroomBodyChecksIntro;

  /// Text used in the app for urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// Text used in the app for unchecked.
  ///
  /// In en, this message translates to:
  /// **'Unchecked'**
  String get unchecked;

  /// Text used in the app for checked.
  ///
  /// In en, this message translates to:
  /// **'Checked'**
  String get checked;

  /// Text used in the app for reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// Text used in the app for urgent body check message.
  ///
  /// In en, this message translates to:
  /// **'This child selected “Hurts a lot” and has not been checked.'**
  String get urgentBodyCheckMessage;

  /// Text used in the app for checked by staff.
  ///
  /// In en, this message translates to:
  /// **'Checked by staff'**
  String get checkedByStaff;

  /// Text used in the app for checked at.
  ///
  /// In en, this message translates to:
  /// **'Checked {time}'**
  String checkedAt(Object time);

  /// Text used in the app for delete report.
  ///
  /// In en, this message translates to:
  /// **'Delete report'**
  String get deleteReport;

  /// Text used in the app for needs checking.
  ///
  /// In en, this message translates to:
  /// **'Needs checking'**
  String get needsChecking;

  /// Text used in the app for no body check reports.
  ///
  /// In en, this message translates to:
  /// **'No Body Check reports yet'**
  String get noBodyCheckReports;

  /// Text used in the app for body check reports appear here.
  ///
  /// In en, this message translates to:
  /// **'Reports sent by children will appear here.'**
  String get bodyCheckReportsAppearHere;

  /// Text used in the app for no reports match filters.
  ///
  /// In en, this message translates to:
  /// **'No reports match these filters.'**
  String get noReportsMatchFilters;

  /// Text used in the app for body check reports load failed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong loading Body Check reports.'**
  String get bodyCheckReportsLoadFailed;

  /// Text used in the app for date time at.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String dateTimeAt(Object date, Object time);

  /// Text used in the app for quiz style general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get quizStyleGeneral;

  /// Text used in the app for quiz style numbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get quizStyleNumbers;

  /// Text used in the app for quiz style words.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get quizStyleWords;

  /// Text used in the app for quiz style science.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get quizStyleScience;

  /// Text used in the app for quiz style world.
  ///
  /// In en, this message translates to:
  /// **'Our World'**
  String get quizStyleWorld;

  /// Text used in the app for quiz style memory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get quizStyleMemory;

  /// Text used in the app for quiz style fun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get quizStyleFun;

  /// Text used in the app for enter quiz title.
  ///
  /// In en, this message translates to:
  /// **'Please enter a quiz title.'**
  String get enterQuizTitle;

  /// Text used in the app for choose quiz audience.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one child or make the quiz available to everyone.'**
  String get chooseQuizAudience;

  /// Text used in the app for add at least one question.
  ///
  /// In en, this message translates to:
  /// **'Add at least one question.'**
  String get addAtLeastOneQuestion;

  /// Text used in the app for quiz updated success.
  ///
  /// In en, this message translates to:
  /// **'Quiz updated successfully!'**
  String get quizUpdatedSuccess;

  /// Text used in the app for quiz created success.
  ///
  /// In en, this message translates to:
  /// **'Quiz created successfully!'**
  String get quizCreatedSuccess;

  /// Text used in the app for quiz save failed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the quiz: {error}'**
  String quizSaveFailed(Object error);

  /// Text used in the app for edit your quiz.
  ///
  /// In en, this message translates to:
  /// **'Edit your quiz'**
  String get editYourQuiz;

  /// Text used in the app for create new quiz.
  ///
  /// In en, this message translates to:
  /// **'Create a new quiz'**
  String get createNewQuiz;

  /// Text used in the app for quiz editor intro.
  ///
  /// In en, this message translates to:
  /// **'Keep questions clear, encouraging and easy to understand.'**
  String get quizEditorIntro;

  /// Text used in the app for quiz details.
  ///
  /// In en, this message translates to:
  /// **'Quiz details'**
  String get quizDetails;

  /// Text used in the app for quiz details intro.
  ///
  /// In en, this message translates to:
  /// **'Give the quiz a clear name and short description.'**
  String get quizDetailsIntro;

  /// Text used in the app for quiz title.
  ///
  /// In en, this message translates to:
  /// **'Quiz title'**
  String get quizTitle;

  /// Text used in the app for quiz title hint.
  ///
  /// In en, this message translates to:
  /// **'For example: Animal Sounds'**
  String get quizTitleHint;

  /// Text used in the app for quiz description hint.
  ///
  /// In en, this message translates to:
  /// **'What will children practise in this quiz?'**
  String get quizDescriptionHint;

  /// Text used in the app for quiz style.
  ///
  /// In en, this message translates to:
  /// **'Quiz style'**
  String get quizStyle;

  /// Text used in the app for quiz style intro.
  ///
  /// In en, this message translates to:
  /// **'Choose a friendly visual theme.'**
  String get quizStyleIntro;

  /// Text used in the app for who can play.
  ///
  /// In en, this message translates to:
  /// **'Who can play?'**
  String get whoCanPlay;

  /// Text used in the app for quiz audience intro.
  ///
  /// In en, this message translates to:
  /// **'Make it available to everyone or selected children.'**
  String get quizAudienceIntro;

  /// Text used in the app for questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// Text used in the app for question count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question} other{{count} questions}}'**
  String questionCount(num count);

  /// Text used in the app for add question.
  ///
  /// In en, this message translates to:
  /// **'Add question'**
  String get addQuestion;

  /// Text used in the app for add another question.
  ///
  /// In en, this message translates to:
  /// **'Add another question'**
  String get addAnotherQuestion;

  /// Text used in the app for edit quiz.
  ///
  /// In en, this message translates to:
  /// **'Edit Quiz'**
  String get editQuiz;

  /// Text used in the app for create quiz.
  ///
  /// In en, this message translates to:
  /// **'Create Quiz'**
  String get createQuiz;

  /// Text used in the app for question number.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String questionNumber(Object number);

  /// Text used in the app for move up.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveUp;

  /// Text used in the app for move down.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveDown;

  /// Text used in the app for delete question.
  ///
  /// In en, this message translates to:
  /// **'Delete question'**
  String get deleteQuestion;

  /// Text used in the app for question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// Text used in the app for question hint.
  ///
  /// In en, this message translates to:
  /// **'What would you like to ask?'**
  String get questionHint;

  /// Text used in the app for answers.
  ///
  /// In en, this message translates to:
  /// **'Answers'**
  String get answers;

  /// Text used in the app for correct answer instruction.
  ///
  /// In en, this message translates to:
  /// **'Tap the circle beside the correct answer.'**
  String get correctAnswerInstruction;

  /// Text used in the app for correct answer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get correctAnswer;

  /// Text used in the app for mark as correct.
  ///
  /// In en, this message translates to:
  /// **'Mark as correct'**
  String get markAsCorrect;

  /// Text used in the app for answer label.
  ///
  /// In en, this message translates to:
  /// **'Answer {letter}'**
  String answerLabel(Object letter);

  /// Text used in the app for remove answer.
  ///
  /// In en, this message translates to:
  /// **'Remove answer'**
  String get removeAnswer;

  /// Text used in the app for add answer.
  ///
  /// In en, this message translates to:
  /// **'Add answer'**
  String get addAnswer;

  /// Text used in the app for helpful explanation.
  ///
  /// In en, this message translates to:
  /// **'Helpful explanation (optional)'**
  String get helpfulExplanation;

  /// Text used in the app for helpful explanation hint.
  ///
  /// In en, this message translates to:
  /// **'Shown after the child answers the question.'**
  String get helpfulExplanationHint;

  /// Text used in the app for question needs text.
  ///
  /// In en, this message translates to:
  /// **'Question {number} needs some question text.'**
  String questionNeedsText(Object number);

  /// Text used in the app for question needs answers.
  ///
  /// In en, this message translates to:
  /// **'Question {number} needs at least two answers.'**
  String questionNeedsAnswers(Object number);

  /// Text used in the app for complete question answers.
  ///
  /// In en, this message translates to:
  /// **'Please complete every answer for question {number}.'**
  String completeQuestionAnswers(Object number);

  /// Text used in the app for question duplicate answers.
  ///
  /// In en, this message translates to:
  /// **'Question {number} has duplicate answers.'**
  String questionDuplicateAnswers(Object number);

  /// Text used in the app for choose correct answer.
  ///
  /// In en, this message translates to:
  /// **'Choose the correct answer for question {number}.'**
  String chooseCorrectAnswer(Object number);

  /// Text used in the app for preview needs question.
  ///
  /// In en, this message translates to:
  /// **'Add at least one question before previewing.'**
  String get previewNeedsQuestion;

  /// Text used in the app for quiz copy title.
  ///
  /// In en, this message translates to:
  /// **'{title} Copy'**
  String quizCopyTitle(Object title);

  /// Text used in the app for quiz duplicated.
  ///
  /// In en, this message translates to:
  /// **'Quiz duplicated successfully.'**
  String get quizDuplicated;

  /// Text used in the app for quiz duplicate failed.
  ///
  /// In en, this message translates to:
  /// **'Could not duplicate the quiz: {error}'**
  String quizDuplicateFailed(Object error);

  /// Text used in the app for delete quiz question.
  ///
  /// In en, this message translates to:
  /// **'Delete quiz?'**
  String get deleteQuizQuestion;

  /// Text used in the app for delete quiz confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete “{title}”? Existing result history will be kept.'**
  String deleteQuizConfirmation(Object title);

  /// Text used in the app for quiz deleted.
  ///
  /// In en, this message translates to:
  /// **'Quiz deleted.'**
  String get quizDeleted;

  /// Text used in the app for quiz delete failed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the quiz: {error}'**
  String quizDeleteFailed(Object error);

  /// Text used in the app for quizzes load failed.
  ///
  /// In en, this message translates to:
  /// **'Could not load quizzes'**
  String get quizzesLoadFailed;

  /// Text used in the app for quiz library empty.
  ///
  /// In en, this message translates to:
  /// **'Your quiz library is empty'**
  String get quizLibraryEmpty;

  /// Text used in the app for create first quiz.
  ///
  /// In en, this message translates to:
  /// **'Create your first quiz to get started.'**
  String get createFirstQuiz;

  /// Text used in the app for quiz results load failed.
  ///
  /// In en, this message translates to:
  /// **'Could not load results'**
  String get quizResultsLoadFailed;

  /// Text used in the app for child profiles load failed short.
  ///
  /// In en, this message translates to:
  /// **'Child profiles could not be loaded.'**
  String get childProfilesLoadFailedShort;

  /// Text used in the app for no child profiles.
  ///
  /// In en, this message translates to:
  /// **'No child profiles'**
  String get noChildProfiles;

  /// Text used in the app for quiz results after profiles.
  ///
  /// In en, this message translates to:
  /// **'Quiz results will appear after profiles are added.'**
  String get quizResultsAfterProfiles;

  /// Text used in the app for quiz results.
  ///
  /// In en, this message translates to:
  /// **'Quiz results'**
  String get quizResults;

  /// Text used in the app for quiz results intro.
  ///
  /// In en, this message translates to:
  /// **'Recent attempts and scores for each child.'**
  String get quizResultsIntro;

  /// Text used in the app for quiz library.
  ///
  /// In en, this message translates to:
  /// **'Quiz Library'**
  String get quizLibrary;

  /// Text used in the app for results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// Text used in the app for audience selected count.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String audienceSelectedCount(Object count);

  /// Text used in the app for more options.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// Text used in the app for duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// Text used in the app for no description added.
  ///
  /// In en, this message translates to:
  /// **'No description added.'**
  String get noDescriptionAdded;

  /// Text used in the app for preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Text used in the app for loading attempts.
  ///
  /// In en, this message translates to:
  /// **'Loading attempts...'**
  String get loadingAttempts;

  /// Text used in the app for no quiz attempts.
  ///
  /// In en, this message translates to:
  /// **'No quiz attempts yet'**
  String get noQuizAttempts;

  /// Text used in the app for attempt count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attempt} other{{count} attempts}}'**
  String attemptCount(num count);

  /// Text used in the app for attempts load failed.
  ///
  /// In en, this message translates to:
  /// **'Could not load attempts.'**
  String get attemptsLoadFailed;

  /// Text used in the app for results after quiz.
  ///
  /// In en, this message translates to:
  /// **'Results will appear after this child completes a quiz.'**
  String get resultsAfterQuiz;

  /// Text used in the app for deleted quiz.
  ///
  /// In en, this message translates to:
  /// **'Deleted quiz'**
  String get deletedQuiz;

  /// Text used in the app for score summary.
  ///
  /// In en, this message translates to:
  /// **'{score}/{total} • {percentage}%'**
  String scoreSummary(Object score, Object total, Object percentage);

  /// Text used in the app for points value.
  ///
  /// In en, this message translates to:
  /// **'{score} points'**
  String pointsValue(Object score);

  /// Text used in the app for no quizzes now.
  ///
  /// In en, this message translates to:
  /// **'No quizzes right now'**
  String get noQuizzesNow;

  /// Text used in the app for quiz will appear.
  ///
  /// In en, this message translates to:
  /// **'A new quiz will appear here when it is ready for you.'**
  String get quizWillAppear;

  /// Text used in the app for child quizzes load failed.
  ///
  /// In en, this message translates to:
  /// **'We could not load your quizzes'**
  String get childQuizzesLoadFailed;

  /// Text used in the app for ready to play.
  ///
  /// In en, this message translates to:
  /// **'Ready to play, {childName}?'**
  String readyToPlay(Object childName);

  /// Text used in the app for quizzes to explore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You have 1 quiz to explore.} other{You have {count} quizzes to explore.}}'**
  String quizzesToExplore(num count);

  /// Text used in the app for quizzes played.
  ///
  /// In en, this message translates to:
  /// **'{count} played'**
  String quizzesPlayed(Object count);

  /// Text used in the app for my quizzes.
  ///
  /// In en, this message translates to:
  /// **'My Quizzes'**
  String get myQuizzes;

  /// Text used in the app for quiz card semantics.
  ///
  /// In en, this message translates to:
  /// **'{title}, {count, plural, =1{1 question} other{{count} questions}}'**
  String quizCardSemantics(Object title, num count);

  /// Text used in the app for played.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get played;

  /// Text used in the app for tap to start quiz.
  ///
  /// In en, this message translates to:
  /// **'Tap to start this quiz!'**
  String get tapToStartQuiz;

  /// Text used in the app for play again.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// Text used in the app for lets play.
  ///
  /// In en, this message translates to:
  /// **'Let’s Play!'**
  String get letsPlay;

  /// Text used in the app for result save failed.
  ///
  /// In en, this message translates to:
  /// **'Your result could not be saved. Please try again.'**
  String get resultSaveFailed;

  /// Text used in the app for leave quiz question.
  ///
  /// In en, this message translates to:
  /// **'Leave this quiz?'**
  String get leaveQuizQuestion;

  /// Text used in the app for close quiz preview.
  ///
  /// In en, this message translates to:
  /// **'Close the quiz preview?'**
  String get closeQuizPreview;

  /// Text used in the app for unsaved quiz answers.
  ///
  /// In en, this message translates to:
  /// **'Your answers in this attempt will not be saved.'**
  String get unsavedQuizAnswers;

  /// Text used in the app for keep playing.
  ///
  /// In en, this message translates to:
  /// **'Keep Playing'**
  String get keepPlaying;

  /// Text used in the app for leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// Text used in the app for quiz has no questions.
  ///
  /// In en, this message translates to:
  /// **'This quiz has no questions yet'**
  String get quizHasNoQuestions;

  /// Text used in the app for go back.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Text used in the app for staff preview banner.
  ///
  /// In en, this message translates to:
  /// **'Staff Preview — results will not be saved'**
  String get staffPreviewBanner;

  /// Text used in the app for question uppercase.
  ///
  /// In en, this message translates to:
  /// **'QUESTION'**
  String get questionUppercase;

  /// Text used in the app for question progress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String questionProgress(Object current, Object total);

  /// Text used in the app for tap correct answer.
  ///
  /// In en, this message translates to:
  /// **'Tap the answer you think is right.'**
  String get tapCorrectAnswer;

  /// Text used in the app for brilliant.
  ///
  /// In en, this message translates to:
  /// **'Brilliant!'**
  String get brilliant;

  /// Text used in the app for answer is.
  ///
  /// In en, this message translates to:
  /// **'The answer is {answer}.'**
  String answerIs(Object answer);

  /// Text used in the app for saving result.
  ///
  /// In en, this message translates to:
  /// **'Saving your result...'**
  String get savingResult;

  /// Text used in the app for see my result.
  ///
  /// In en, this message translates to:
  /// **'See My Result'**
  String get seeMyResult;

  /// Text used in the app for next question.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get nextQuestion;

  /// Text used in the app for result amazing.
  ///
  /// In en, this message translates to:
  /// **'Amazing!'**
  String get resultAmazing;

  /// Text used in the app for result perfect message.
  ///
  /// In en, this message translates to:
  /// **'You got every question right!'**
  String get resultPerfectMessage;

  /// Text used in the app for result great work.
  ///
  /// In en, this message translates to:
  /// **'Great work!'**
  String get resultGreatWork;

  /// Text used in the app for result great message.
  ///
  /// In en, this message translates to:
  /// **'You did a brilliant job!'**
  String get resultGreatMessage;

  /// Text used in the app for result well done.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get resultWellDone;

  /// Text used in the app for result well done message.
  ///
  /// In en, this message translates to:
  /// **'You kept trying and learned something new!'**
  String get resultWellDoneMessage;

  /// Text used in the app for result good effort.
  ///
  /// In en, this message translates to:
  /// **'Good effort!'**
  String get resultGoodEffort;

  /// Text used in the app for result good effort message.
  ///
  /// In en, this message translates to:
  /// **'Every try helps your brain grow!'**
  String get resultGoodEffortMessage;

  /// Text used in the app for preview complete.
  ///
  /// In en, this message translates to:
  /// **'Preview complete'**
  String get previewComplete;

  /// Text used in the app for preview result message.
  ///
  /// In en, this message translates to:
  /// **'This is how the child’s result screen will look.'**
  String get previewResultMessage;

  /// Text used in the app for close preview.
  ///
  /// In en, this message translates to:
  /// **'Close Preview'**
  String get closePreview;

  /// Text used in the app for back to my quizzes.
  ///
  /// In en, this message translates to:
  /// **'Back to My Quizzes'**
  String get backToMyQuizzes;

  /// Text used in the app for answer semantics.
  ///
  /// In en, this message translates to:
  /// **'Answer {letter}: {answer}'**
  String answerSemantics(Object letter, Object answer);

  /// Text used in the app for zone blue.
  ///
  /// In en, this message translates to:
  /// **'Blue Zone'**
  String get zoneBlue;

  /// Text used in the app for zone green.
  ///
  /// In en, this message translates to:
  /// **'Green Zone'**
  String get zoneGreen;

  /// Text used in the app for zone yellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow Zone'**
  String get zoneYellow;

  /// Text used in the app for zone red.
  ///
  /// In en, this message translates to:
  /// **'Red Zone'**
  String get zoneRed;

  /// Text used in the app for zone blue child description.
  ///
  /// In en, this message translates to:
  /// **'My body is running slowly. I may need rest, comfort or gentle movement.'**
  String get zoneBlueChildDescription;

  /// Text used in the app for zone green child description.
  ///
  /// In en, this message translates to:
  /// **'My body feels calm and comfortable. I may feel ready to learn or play.'**
  String get zoneGreenChildDescription;

  /// Text used in the app for zone yellow child description.
  ///
  /// In en, this message translates to:
  /// **'My energy is rising. I may need help slowing down or finding focus.'**
  String get zoneYellowChildDescription;

  /// Text used in the app for zone red child description.
  ///
  /// In en, this message translates to:
  /// **'My feelings are very intense. I may need space, safety and support.'**
  String get zoneRedChildDescription;

  /// Text used in the app for zone blue staff description.
  ///
  /// In en, this message translates to:
  /// **'Low energy, tired, sad or unwell.'**
  String get zoneBlueStaffDescription;

  /// Text used in the app for zone green staff description.
  ///
  /// In en, this message translates to:
  /// **'Calm, focused, comfortable and ready.'**
  String get zoneGreenStaffDescription;

  /// Text used in the app for zone yellow staff description.
  ///
  /// In en, this message translates to:
  /// **'Worried, excited, frustrated or restless.'**
  String get zoneYellowStaffDescription;

  /// Text used in the app for zone red staff description.
  ///
  /// In en, this message translates to:
  /// **'Very intense feelings requiring support.'**
  String get zoneRedStaffDescription;

  /// Text used in the app for feeling tired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get feelingTired;

  /// Text used in the app for feeling sad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get feelingSad;

  /// Text used in the app for feeling bored.
  ///
  /// In en, this message translates to:
  /// **'Bored'**
  String get feelingBored;

  /// Text used in the app for feeling unwell.
  ///
  /// In en, this message translates to:
  /// **'Unwell'**
  String get feelingUnwell;

  /// Text used in the app for feeling slow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get feelingSlow;

  /// Text used in the app for feeling calm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get feelingCalm;

  /// Text used in the app for feeling focused.
  ///
  /// In en, this message translates to:
  /// **'Focused'**
  String get feelingFocused;

  /// Text used in the app for feeling happy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get feelingHappy;

  /// Text used in the app for feeling content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get feelingContent;

  /// Text used in the app for feeling ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get feelingReady;

  /// Text used in the app for feeling worried.
  ///
  /// In en, this message translates to:
  /// **'Worried'**
  String get feelingWorried;

  /// Text used in the app for feeling excited.
  ///
  /// In en, this message translates to:
  /// **'Excited'**
  String get feelingExcited;

  /// Text used in the app for feeling frustrated.
  ///
  /// In en, this message translates to:
  /// **'Frustrated'**
  String get feelingFrustrated;

  /// Text used in the app for feeling silly.
  ///
  /// In en, this message translates to:
  /// **'Silly'**
  String get feelingSilly;

  /// Text used in the app for feeling restless.
  ///
  /// In en, this message translates to:
  /// **'Restless'**
  String get feelingRestless;

  /// Text used in the app for feeling angry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get feelingAngry;

  /// Text used in the app for feeling panicked.
  ///
  /// In en, this message translates to:
  /// **'Panicked'**
  String get feelingPanicked;

  /// Text used in the app for feeling terrified.
  ///
  /// In en, this message translates to:
  /// **'Terrified'**
  String get feelingTerrified;

  /// Text used in the app for feeling overwhelmed.
  ///
  /// In en, this message translates to:
  /// **'Overwhelmed'**
  String get feelingOverwhelmed;

  /// Text used in the app for feeling out of control.
  ///
  /// In en, this message translates to:
  /// **'Out of control'**
  String get feelingOutOfControl;

  /// Text used in the app for zone selected.
  ///
  /// In en, this message translates to:
  /// **'You selected the {zoneName}.'**
  String zoneSelected(Object zoneName);

  /// Text used in the app for zone update failed.
  ///
  /// In en, this message translates to:
  /// **'Could not update your zone: {error}'**
  String zoneUpdateFailed(Object error);

  /// Text used in the app for how are you feeling.
  ///
  /// In en, this message translates to:
  /// **'How Are You Feeling?'**
  String get howAreYouFeeling;

  /// Text used in the app for hello child.
  ///
  /// In en, this message translates to:
  /// **'Hello {childName}'**
  String helloChild(Object childName);

  /// Text used in the app for choose current zone.
  ///
  /// In en, this message translates to:
  /// **'Choose the zone that feels most like you right now.'**
  String get chooseCurrentZone;

  /// Text used in the app for every zone okay.
  ///
  /// In en, this message translates to:
  /// **'Every zone is okay.'**
  String get everyZoneOkay;

  /// Text used in the app for this is my zone.
  ///
  /// In en, this message translates to:
  /// **'This is my zone'**
  String get thisIsMyZone;

  /// Text used in the app for choose zone.
  ///
  /// In en, this message translates to:
  /// **'Choose {zoneName}'**
  String chooseZone(Object zoneName);

  /// Text used in the app for no bad zones.
  ///
  /// In en, this message translates to:
  /// **'There are no bad zones. Our feelings give us information about what our body may need.'**
  String get noBadZones;

  /// Text used in the app for zones overview.
  ///
  /// In en, this message translates to:
  /// **'Zones Overview'**
  String get zonesOverview;

  /// Text used in the app for classroom zones load failed.
  ///
  /// In en, this message translates to:
  /// **'Could not load classroom zones.'**
  String get classroomZonesLoadFailed;

  /// Text used in the app for classroom zones.
  ///
  /// In en, this message translates to:
  /// **'Classroom Zones'**
  String get classroomZones;

  /// Text used in the app for classroom zones intro.
  ///
  /// In en, this message translates to:
  /// **'A live view of how children are feeling.'**
  String get classroomZonesIntro;

  /// Text used in the app for checked in.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get checkedIn;

  /// Text used in the app for no children in zone.
  ///
  /// In en, this message translates to:
  /// **'No children are currently in this zone.'**
  String get noChildrenInZone;

  /// Text used in the app for all children checked in.
  ///
  /// In en, this message translates to:
  /// **'Every child has completed their zone check-in.'**
  String get allChildrenCheckedIn;

  /// Text used in the app for not checked in.
  ///
  /// In en, this message translates to:
  /// **'Not checked in'**
  String get notCheckedIn;

  /// Text used in the app for no child profiles found short.
  ///
  /// In en, this message translates to:
  /// **'No child profiles found'**
  String get noChildProfilesFoundShort;

  /// Text used in the app for create child before zones.
  ///
  /// In en, this message translates to:
  /// **'Create a child profile before using the Zones Overview.'**
  String get createChildBeforeZones;

  /// Text used in the app for view body check reports.
  ///
  /// In en, this message translates to:
  /// **'View Body Check Reports'**
  String get viewBodyCheckReports;

  /// Text used in the app for open incident log.
  ///
  /// In en, this message translates to:
  /// **'Open Incident Log'**
  String get openIncidentLog;

  /// Text used in the app for open schedule.
  ///
  /// In en, this message translates to:
  /// **'Open Schedule'**
  String get openSchedule;

  /// Text used in the app for open zones overview.
  ///
  /// In en, this message translates to:
  /// **'Open Zones Overview'**
  String get openZonesOverview;

  /// Text used in the app for total child profiles.
  ///
  /// In en, this message translates to:
  /// **'Total child profiles'**
  String get totalChildProfiles;

  /// Text used in the app for zones checked in.
  ///
  /// In en, this message translates to:
  /// **'Zones checked in'**
  String get zonesCheckedIn;

  /// Text used in the app for children with selected zone.
  ///
  /// In en, this message translates to:
  /// **'Children with a selected zone'**
  String get childrenWithSelectedZone;

  /// Text used in the app for no child profiles yet.
  ///
  /// In en, this message translates to:
  /// **'No child profiles yet.'**
  String get noChildProfilesYet;

  /// Text used in the app for no zone.
  ///
  /// In en, this message translates to:
  /// **'No zone'**
  String get noZone;

  /// Text used in the app for child zone summary.
  ///
  /// In en, this message translates to:
  /// **'{childName}: {zone}'**
  String childZoneSummary(Object childName, Object zone);

  /// Text used in the app for no unchecked body checks.
  ///
  /// In en, this message translates to:
  /// **'No unchecked Body Check reports'**
  String get noUncheckedBodyChecks;

  /// Text used in the app for nothing needs review.
  ///
  /// In en, this message translates to:
  /// **'Nothing currently needs review.'**
  String get nothingNeedsReview;

  /// Text used in the app for unchecked body checks intro.
  ///
  /// In en, this message translates to:
  /// **'Unchecked reports needing staff review'**
  String get uncheckedBodyChecksIntro;

  /// Text used in the app for body check summary.
  ///
  /// In en, this message translates to:
  /// **'{bodyPart} • {painType} • {date}'**
  String bodyCheckSummary(Object bodyPart, Object painType, Object date);

  /// Text used in the app for view all body checks.
  ///
  /// In en, this message translates to:
  /// **'View all {count} Body Check reports'**
  String viewAllBodyChecks(Object count);

  /// Text used in the app for schedule saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get scheduleSaturday;

  /// Text used in the app for schedule sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get scheduleSunday;

  /// Text used in the app for no schedule entries for day.
  ///
  /// In en, this message translates to:
  /// **'No schedule entries for {day}'**
  String noScheduleEntriesForDay(Object day);

  /// Text used in the app for nothing scheduled today yet.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been added for today yet.'**
  String get nothingScheduledTodayYet;

  /// Text used in the app for no important incidents.
  ///
  /// In en, this message translates to:
  /// **'No important recent incidents'**
  String get noImportantIncidents;

  /// Text used in the app for no important incidents intro.
  ///
  /// In en, this message translates to:
  /// **'No medium/high incidents found for review.'**
  String get noImportantIncidentsIntro;

  /// Text used in the app for severity high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get severityHigh;

  /// Text used in the app for severity medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get severityMedium;

  /// Text used in the app for severity low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get severityLow;

  /// Text used in the app for incident summary.
  ///
  /// In en, this message translates to:
  /// **'{severity} • {date}\n{description}'**
  String incidentSummary(Object severity, Object date, Object description);

  /// Text used in the app for today overview for staff.
  ///
  /// In en, this message translates to:
  /// **'Quick classroom overview for {staffName}.'**
  String todayOverviewForStaff(Object staffName);

  /// Text used in the app for quick actions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Text used in the app for zones snapshot.
  ///
  /// In en, this message translates to:
  /// **'Zones Snapshot'**
  String get zonesSnapshot;

  /// Text used in the app for body check attention.
  ///
  /// In en, this message translates to:
  /// **'Body Check Attention'**
  String get bodyCheckAttention;

  /// Text used in the app for todays schedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get todaysSchedule;

  /// Text used in the app for recent important incidents.
  ///
  /// In en, this message translates to:
  /// **'Recent / Important Incidents'**
  String get recentImportantIncidents;

  /// Text used in the app for choose my background.
  ///
  /// In en, this message translates to:
  /// **'Choose My Background'**
  String get chooseMyBackground;

  /// Text used in the app for make it yours.
  ///
  /// In en, this message translates to:
  /// **'Make It Yours'**
  String get makeItYours;

  /// Text used in the app for choose comfortable dashboard colour.
  ///
  /// In en, this message translates to:
  /// **'Choose a comfortable colour for your dashboard.'**
  String get chooseComfortableDashboardColour;

  /// Text used in the app for my zones.
  ///
  /// In en, this message translates to:
  /// **'My Zones'**
  String get myZones;

  /// Text used in the app for colour choices.
  ///
  /// In en, this message translates to:
  /// **'Colour Choices'**
  String get colourChoices;

  /// Text used in the app for use this background.
  ///
  /// In en, this message translates to:
  /// **'Use This Background'**
  String get useThisBackground;

  /// Text used in the app for background colour updated.
  ///
  /// In en, this message translates to:
  /// **'Background colour updated.'**
  String get backgroundColourUpdated;

  /// Text used in the app for background colour update failed.
  ///
  /// In en, this message translates to:
  /// **'The background colour could not be updated.'**
  String get backgroundColourUpdateFailed;

  /// Text used in the app for background classic white.
  ///
  /// In en, this message translates to:
  /// **'Classic White'**
  String get backgroundClassicWhite;

  /// Text used in the app for background classic white description.
  ///
  /// In en, this message translates to:
  /// **'Clean and simple'**
  String get backgroundClassicWhiteDescription;

  /// Text used in the app for background soft rose.
  ///
  /// In en, this message translates to:
  /// **'Soft Rose'**
  String get backgroundSoftRose;

  /// Text used in the app for background soft rose description.
  ///
  /// In en, this message translates to:
  /// **'Warm and gentle'**
  String get backgroundSoftRoseDescription;

  /// Text used in the app for background clear sky.
  ///
  /// In en, this message translates to:
  /// **'Clear Sky'**
  String get backgroundClearSky;

  /// Text used in the app for background clear sky description.
  ///
  /// In en, this message translates to:
  /// **'Cool and peaceful'**
  String get backgroundClearSkyDescription;

  /// Text used in the app for background fresh mint.
  ///
  /// In en, this message translates to:
  /// **'Fresh Mint'**
  String get backgroundFreshMint;

  /// Text used in the app for background fresh mint description.
  ///
  /// In en, this message translates to:
  /// **'Calm and natural'**
  String get backgroundFreshMintDescription;

  /// Text used in the app for background warm sunshine.
  ///
  /// In en, this message translates to:
  /// **'Warm Sunshine'**
  String get backgroundWarmSunshine;

  /// Text used in the app for background warm sunshine description.
  ///
  /// In en, this message translates to:
  /// **'Bright and cheerful'**
  String get backgroundWarmSunshineDescription;

  /// Text used in the app for background soft lavender.
  ///
  /// In en, this message translates to:
  /// **'Soft Lavender'**
  String get backgroundSoftLavender;

  /// Text used in the app for background soft lavender description.
  ///
  /// In en, this message translates to:
  /// **'Quiet and relaxing'**
  String get backgroundSoftLavenderDescription;

  /// Text used in the app for background gentle grey.
  ///
  /// In en, this message translates to:
  /// **'Gentle Grey'**
  String get backgroundGentleGrey;

  /// Text used in the app for background gentle grey description.
  ///
  /// In en, this message translates to:
  /// **'Neutral and focused'**
  String get backgroundGentleGreyDescription;

  /// Text used in the app for background warm peach.
  ///
  /// In en, this message translates to:
  /// **'Warm Peach'**
  String get backgroundWarmPeach;

  /// Text used in the app for background warm peach description.
  ///
  /// In en, this message translates to:
  /// **'Cosy and welcoming'**
  String get backgroundWarmPeachDescription;

  /// Text used in the app for unlock sequence reset for.
  ///
  /// In en, this message translates to:
  /// **'Unlock sequence reset for {childName}'**
  String unlockSequenceResetFor(Object childName);

  /// Text used in the app for unlock sequence reset failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset sequence: {error}'**
  String unlockSequenceResetFailed(Object error);

  /// Text used in the app for schedule time range.
  ///
  /// In en, this message translates to:
  /// **'{start} - {end}'**
  String scheduleTimeRange(Object start, Object end);

  /// Text used in the app for missing admin dashboard details.
  ///
  /// In en, this message translates to:
  /// **'Missing admin dashboard details.'**
  String get missingAdminDashboardDetails;

  /// Text used in the app for missing child profile.
  ///
  /// In en, this message translates to:
  /// **'Missing child profile.'**
  String get missingChildProfile;

  /// Text used in the app for missing staff profile.
  ///
  /// In en, this message translates to:
  /// **'Missing staff profile.'**
  String get missingStaffProfile;

  /// Text used in the app for missing quiz creator.
  ///
  /// In en, this message translates to:
  /// **'Missing quiz creator.'**
  String get missingQuizCreator;

  /// Text used in the app for missing teacher id.
  ///
  /// In en, this message translates to:
  /// **'Missing teacher ID.'**
  String get missingTeacherId;

  /// Text used in the app for missing quiz.
  ///
  /// In en, this message translates to:
  /// **'Missing quiz.'**
  String get missingQuiz;

  /// Text used in the app for missing student quiz details.
  ///
  /// In en, this message translates to:
  /// **'Missing student quiz details.'**
  String get missingStudentQuizDetails;

  /// Text used in the app for missing when then child details.
  ///
  /// In en, this message translates to:
  /// **'Missing When–Then child details.'**
  String get missingWhenThenChildDetails;

  /// Text used in the app for missing circle time details.
  ///
  /// In en, this message translates to:
  /// **'Missing Circle Time details.'**
  String get missingCircleTimeDetails;

  /// Text used in the app for missing body check details.
  ///
  /// In en, this message translates to:
  /// **'Missing Body Check details.'**
  String get missingBodyCheckDetails;

  /// Text used in the app for missing body check overview details.
  ///
  /// In en, this message translates to:
  /// **'Missing Body Check overview details.'**
  String get missingBodyCheckOverviewDetails;

  /// Text used in the app for invalid route or missing arguments.
  ///
  /// In en, this message translates to:
  /// **'Invalid route or missing arguments.'**
  String get invalidRouteOrMissingArguments;

  /// Text used in the app for missing school id.
  ///
  /// In en, this message translates to:
  /// **'Missing school ID'**
  String get missingSchoolId;

  /// Text used in the app for missing classroom details.
  ///
  /// In en, this message translates to:
  /// **'Missing classroom details'**
  String get missingClassroomDetails;

  /// Text used in the app for staff profile not found.
  ///
  /// In en, this message translates to:
  /// **'Staff Profile Not Found'**
  String get staffProfileNotFound;

  /// Text used in the app for child profile not found.
  ///
  /// In en, this message translates to:
  /// **'Child Profile Not Found'**
  String get childProfileNotFound;

  /// Text used in the app for return to profiles.
  ///
  /// In en, this message translates to:
  /// **'Return to Profiles'**
  String get returnToProfiles;

  /// Text used in the app for i might feel.
  ///
  /// In en, this message translates to:
  /// **'I might feel:'**
  String get iMightFeel;
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
