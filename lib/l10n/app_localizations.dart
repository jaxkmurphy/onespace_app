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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OneSpace App'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @pinUpdated.
  ///
  /// In en, this message translates to:
  /// **'PIN updated'**
  String get pinUpdated;

  /// No description provided for @savePin.
  ///
  /// In en, this message translates to:
  /// **'Save PIN'**
  String get savePin;

  /// No description provided for @newPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @pinHint.
  ///
  /// In en, this message translates to:
  /// **'PINs must be 4 digits and match'**
  String get pinHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @everyone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get everyone;

  /// No description provided for @viewOnly.
  ///
  /// In en, this message translates to:
  /// **'View only'**
  String get viewOnly;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @zones_regulation.
  ///
  /// In en, this message translates to:
  /// **'Zones of Regulation'**
  String get zones_regulation;

  /// No description provided for @points_overview.
  ///
  /// In en, this message translates to:
  /// **'Points Overview'**
  String get points_overview;

  /// No description provided for @view_schedule.
  ///
  /// In en, this message translates to:
  /// **'View Schedule'**
  String get view_schedule;

  /// No description provided for @create_quiz.
  ///
  /// In en, this message translates to:
  /// **'Create Quiz'**
  String get create_quiz;

  /// No description provided for @manage_quizzes.
  ///
  /// In en, this message translates to:
  /// **'Manage Quizzes'**
  String get manage_quizzes;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @my_points.
  ///
  /// In en, this message translates to:
  /// **'My Points'**
  String get my_points;

  /// No description provided for @my_schedule.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get my_schedule;

  /// No description provided for @calming_sounds.
  ///
  /// In en, this message translates to:
  /// **'Calming Sounds'**
  String get calming_sounds;

  /// No description provided for @take_quiz.
  ///
  /// In en, this message translates to:
  /// **'Take a Quiz'**
  String get take_quiz;

  /// No description provided for @change_background.
  ///
  /// In en, this message translates to:
  /// **'Change Background Colour'**
  String get change_background;

  /// No description provided for @handoverHub.
  ///
  /// In en, this message translates to:
  /// **'Handover Hub'**
  String get handoverHub;

  /// No description provided for @handoverStartHereTab.
  ///
  /// In en, this message translates to:
  /// **'Start Here'**
  String get handoverStartHereTab;

  /// No description provided for @handoverStaffDocumentsTab.
  ///
  /// In en, this message translates to:
  /// **'Staff Documents'**
  String get handoverStaffDocumentsTab;

  /// No description provided for @handoverQuickNotesTab.
  ///
  /// In en, this message translates to:
  /// **'Quick Notes'**
  String get handoverQuickNotesTab;

  /// No description provided for @readThisFirst.
  ///
  /// In en, this message translates to:
  /// **'Read this first'**
  String get readThisFirst;

  /// No description provided for @startHereDescription.
  ///
  /// In en, this message translates to:
  /// **'This section should contain the most important things a substitute teacher or SNA needs to know immediately.'**
  String get startHereDescription;

  /// No description provided for @noStartHereInformation.
  ///
  /// In en, this message translates to:
  /// **'No Start Here information has been added yet.'**
  String get noStartHereInformation;

  /// No description provided for @editStartHere.
  ///
  /// In en, this message translates to:
  /// **'Edit Start Here'**
  String get editStartHere;

  /// No description provided for @editStartHereTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Start Here'**
  String get editStartHereTitle;

  /// No description provided for @startHereHint.
  ///
  /// In en, this message translates to:
  /// **'Write the most important classroom information here...'**
  String get startHereHint;

  /// No description provided for @noStaffProfilesFound.
  ///
  /// In en, this message translates to:
  /// **'No staff profiles found.'**
  String get noStaffProfilesFound;

  /// No description provided for @staffDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'{staffName} Document'**
  String staffDocumentTitle(String staffName);

  /// No description provided for @editStaffDocument.
  ///
  /// In en, this message translates to:
  /// **'Edit {staffName} Document'**
  String editStaffDocument(String staffName);

  /// No description provided for @aboutThisClass.
  ///
  /// In en, this message translates to:
  /// **'About This Class'**
  String get aboutThisClass;

  /// No description provided for @whatWorksWell.
  ///
  /// In en, this message translates to:
  /// **'What Works Well'**
  String get whatWorksWell;

  /// No description provided for @commonTriggers.
  ///
  /// In en, this message translates to:
  /// **'Common Triggers'**
  String get commonTriggers;

  /// No description provided for @successfulStrategies.
  ///
  /// In en, this message translates to:
  /// **'Successful Strategies'**
  String get successfulStrategies;

  /// No description provided for @communicationTips.
  ///
  /// In en, this message translates to:
  /// **'Communication Tips'**
  String get communicationTips;

  /// No description provided for @otherNotes.
  ///
  /// In en, this message translates to:
  /// **'Other Notes'**
  String get otherNotes;

  /// No description provided for @nothingAddedYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing added yet.'**
  String get nothingAddedYet;

  /// No description provided for @editQuickNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Quick Note'**
  String get editQuickNote;

  /// No description provided for @addQuickNote.
  ///
  /// In en, this message translates to:
  /// **'Add Quick Note'**
  String get addQuickNote;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @deleteNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete note?'**
  String get deleteNoteTitle;

  /// No description provided for @deleteNoteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get deleteNoteMessage;

  /// No description provided for @noQuickNotes.
  ///
  /// In en, this message translates to:
  /// **'No quick notes yet.'**
  String get noQuickNotes;

  /// No description provided for @quickNoteBy.
  ///
  /// In en, this message translates to:
  /// **'By: {staffName}'**
  String quickNoteBy(String staffName);

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @handoverLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load handover information.'**
  String get handoverLoadError;

  /// No description provided for @handoverSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the handover information.'**
  String get handoverSaveError;

  /// No description provided for @handoverDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the note.'**
  String get handoverDeleteError;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {date}'**
  String lastUpdated(String date);

  /// No description provided for @incidentLog.
  ///
  /// In en, this message translates to:
  /// **'Incident Log'**
  String get incidentLog;

  /// No description provided for @incidentLogClassroom.
  ///
  /// In en, this message translates to:
  /// **'{classroomName} Incident Log'**
  String incidentLogClassroom(String classroomName);

  /// No description provided for @incidentLogIntro.
  ///
  /// In en, this message translates to:
  /// **'Create and review classroom incident records.'**
  String get incidentLogIntro;

  /// No description provided for @createIncident.
  ///
  /// In en, this message translates to:
  /// **'Create Incident'**
  String get createIncident;

  /// No description provided for @viewIncidents.
  ///
  /// In en, this message translates to:
  /// **'View Incidents'**
  String get viewIncidents;

  /// No description provided for @selectChild.
  ///
  /// In en, this message translates to:
  /// **'Select Child'**
  String get selectChild;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @useCurrentTime.
  ///
  /// In en, this message translates to:
  /// **'Use Current Time (Default)'**
  String get useCurrentTime;

  /// No description provided for @manualTime.
  ///
  /// In en, this message translates to:
  /// **'Manual Time: {date}'**
  String manualTime(String date);

  /// No description provided for @resetToCurrentTime.
  ///
  /// In en, this message translates to:
  /// **'Reset to current time'**
  String get resetToCurrentTime;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @actionTaken.
  ///
  /// In en, this message translates to:
  /// **'Action Taken'**
  String get actionTaken;

  /// No description provided for @saveIncident.
  ///
  /// In en, this message translates to:
  /// **'Save Incident'**
  String get saveIncident;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @pleaseSelectChild.
  ///
  /// In en, this message translates to:
  /// **'Please select a child.'**
  String get pleaseSelectChild;

  /// No description provided for @enterIncidentDetails.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description and the action taken.'**
  String get enterIncidentDetails;

  /// No description provided for @incidentSaved.
  ///
  /// In en, this message translates to:
  /// **'Incident saved.'**
  String get incidentSaved;

  /// No description provided for @incidentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Incident updated.'**
  String get incidentUpdated;

  /// No description provided for @incidentSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save the incident.'**
  String get incidentSaveFailed;

  /// No description provided for @editIncident.
  ///
  /// In en, this message translates to:
  /// **'Edit Incident'**
  String get editIncident;

  /// No description provided for @archiveIncident.
  ///
  /// In en, this message translates to:
  /// **'Archive Incident'**
  String get archiveIncident;

  /// No description provided for @archiveIncidentQuestion.
  ///
  /// In en, this message translates to:
  /// **'Archive this incident?'**
  String get archiveIncidentQuestion;

  /// No description provided for @archiveIncidentMessage.
  ///
  /// In en, this message translates to:
  /// **'Archive the incident for {childName}? It will remain in the audit history.'**
  String archiveIncidentMessage(String childName);

  /// No description provided for @archiveReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for archiving'**
  String get archiveReason;

  /// No description provided for @incidentArchived.
  ///
  /// In en, this message translates to:
  /// **'Incident archived.'**
  String get incidentArchived;

  /// No description provided for @incidentArchiveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to archive the incident.'**
  String get incidentArchiveFailed;

  /// No description provided for @noIncidents.
  ///
  /// In en, this message translates to:
  /// **'No incidents logged yet.'**
  String get noIncidents;

  /// No description provided for @filterByChild.
  ///
  /// In en, this message translates to:
  /// **'Filter by child'**
  String get filterByChild;

  /// No description provided for @incidentsShown.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No incidents shown} one{1 incident shown} other{{count} incidents shown}}'**
  String incidentsShown(int count);

  /// No description provided for @noMatchingIncidents.
  ///
  /// In en, this message translates to:
  /// **'No incidents match these filters.'**
  String get noMatchingIncidents;

  /// No description provided for @severityLabel.
  ///
  /// In en, this message translates to:
  /// **'{severity} severity'**
  String severityLabel(String severity);

  /// No description provided for @loggedBy.
  ///
  /// In en, this message translates to:
  /// **'Logged by {staffName}'**
  String loggedBy(String staffName);

  /// No description provided for @incidentCategory.
  ///
  /// In en, this message translates to:
  /// **'Incident Category'**
  String get incidentCategory;

  /// No description provided for @behaviour.
  ///
  /// In en, this message translates to:
  /// **'Behaviour'**
  String get behaviour;

  /// No description provided for @injury.
  ///
  /// In en, this message translates to:
  /// **'Injury'**
  String get injury;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @emotional.
  ///
  /// In en, this message translates to:
  /// **'Emotional'**
  String get emotional;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @followUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get followUp;

  /// No description provided for @noFollowUp.
  ///
  /// In en, this message translates to:
  /// **'No follow-up needed'**
  String get noFollowUp;

  /// No description provided for @followUpRequired.
  ///
  /// In en, this message translates to:
  /// **'Follow-up required'**
  String get followUpRequired;

  /// No description provided for @followUpCompleted.
  ///
  /// In en, this message translates to:
  /// **'Follow-up completed'**
  String get followUpCompleted;

  /// No description provided for @followUpNotes.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Notes'**
  String get followUpNotes;

  /// No description provided for @archivedIncidents.
  ///
  /// In en, this message translates to:
  /// **'Archived Incidents'**
  String get archivedIncidents;

  /// No description provided for @wordLearning.
  ///
  /// In en, this message translates to:
  /// **'Word Learning'**
  String get wordLearning;

  /// No description provided for @wordPractice.
  ///
  /// In en, this message translates to:
  /// **'Word Practice'**
  String get wordPractice;

  /// No description provided for @wordProgress.
  ///
  /// In en, this message translates to:
  /// **'Word Progress'**
  String get wordProgress;

  /// No description provided for @createWordPack.
  ///
  /// In en, this message translates to:
  /// **'Create Word Pack'**
  String get createWordPack;

  /// No description provided for @editWordPack.
  ///
  /// In en, this message translates to:
  /// **'Edit Word Pack'**
  String get editWordPack;

  /// No description provided for @deleteWordPack.
  ///
  /// In en, this message translates to:
  /// **'Delete Word Pack'**
  String get deleteWordPack;

  /// No description provided for @deleteWordPackMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete “{packName}”? Its words will also be deleted.'**
  String deleteWordPackMessage(String packName);

  /// No description provided for @packName.
  ///
  /// In en, this message translates to:
  /// **'Pack Name'**
  String get packName;

  /// No description provided for @packDescription.
  ///
  /// In en, this message translates to:
  /// **'Pack Description'**
  String get packDescription;

  /// No description provided for @packDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What will children practise in this pack?'**
  String get packDescriptionHint;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created by {staffName}'**
  String createdBy(String staffName);

  /// No description provided for @wordCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No words} one{1 word} other{{count} words}}'**
  String wordCount(int count);

  /// No description provided for @assignedChildCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Not assigned} one{Assigned to 1 child} other{Assigned to {count} children}}'**
  String assignedChildCount(int count);

  /// No description provided for @noWordPacks.
  ///
  /// In en, this message translates to:
  /// **'No word packs yet.'**
  String get noWordPacks;

  /// No description provided for @createFirstWordPack.
  ///
  /// In en, this message translates to:
  /// **'Create your first word pack to get started.'**
  String get createFirstWordPack;

  /// No description provided for @addWord.
  ///
  /// In en, this message translates to:
  /// **'Add Word'**
  String get addWord;

  /// No description provided for @editWord.
  ///
  /// In en, this message translates to:
  /// **'Edit Word'**
  String get editWord;

  /// No description provided for @deleteWord.
  ///
  /// In en, this message translates to:
  /// **'Delete Word'**
  String get deleteWord;

  /// No description provided for @deleteWordMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete the word “{word}”?'**
  String deleteWordMessage(String word);

  /// No description provided for @word.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get word;

  /// No description provided for @emoji.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get emoji;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @assignChildren.
  ///
  /// In en, this message translates to:
  /// **'Assign Children'**
  String get assignChildren;

  /// No description provided for @saveAssignments.
  ///
  /// In en, this message translates to:
  /// **'Save Assignments'**
  String get saveAssignments;

  /// No description provided for @noChildrenAvailable.
  ///
  /// In en, this message translates to:
  /// **'No child profiles are available.'**
  String get noChildrenAvailable;

  /// No description provided for @noWords.
  ///
  /// In en, this message translates to:
  /// **'No words have been added yet.'**
  String get noWords;

  /// No description provided for @addFirstWord.
  ///
  /// In en, this message translates to:
  /// **'Add at least two words before assigning this pack.'**
  String get addFirstWord;

  /// No description provided for @tapToPractise.
  ///
  /// In en, this message translates to:
  /// **'Tap to practise'**
  String get tapToPractise;

  /// No description provided for @noAssignedWordPacks.
  ///
  /// In en, this message translates to:
  /// **'No word packs are assigned right now.'**
  String get noAssignedWordPacks;

  /// No description provided for @packNeedsTwoWords.
  ///
  /// In en, this message translates to:
  /// **'This pack needs at least two words before it can be practised.'**
  String get packNeedsTwoWords;

  /// No description provided for @practiceComplete.
  ///
  /// In en, this message translates to:
  /// **'Practice Complete!'**
  String get practiceComplete;

  /// No description provided for @practisedWords.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{You practised 1 word.} other{You practised {count} words.}}'**
  String practisedWords(int count);

  /// No description provided for @practiseAgain.
  ///
  /// In en, this message translates to:
  /// **'Practise Again'**
  String get practiseAgain;

  /// No description provided for @backToPacks.
  ///
  /// In en, this message translates to:
  /// **'Back to Packs'**
  String get backToPacks;

  /// No description provided for @selectChildForProgress.
  ///
  /// In en, this message translates to:
  /// **'Select a child to view their progress.'**
  String get selectChildForProgress;

  /// No description provided for @noWordAttempts.
  ///
  /// In en, this message translates to:
  /// **'No word practice attempts yet.'**
  String get noWordAttempts;

  /// No description provided for @totalAttempts.
  ///
  /// In en, this message translates to:
  /// **'Total attempts: {count}'**
  String totalAttempts(int count);

  /// No description provided for @correctAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct answers: {count}'**
  String correctAnswers(int count);

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy: {percentage}%'**
  String accuracy(String percentage);

  /// No description provided for @wordBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Word Breakdown'**
  String get wordBreakdown;

  /// No description provided for @attemptSummary.
  ///
  /// In en, this message translates to:
  /// **'Attempts: {attempts} • Correct: {correct} • Accuracy: {accuracy}%'**
  String attemptSummary(int attempts, int correct, String accuracy);

  /// No description provided for @chooseMatchingWord.
  ///
  /// In en, this message translates to:
  /// **'Choose the word that matches the picture.'**
  String get chooseMatchingWord;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get greatJob;

  /// No description provided for @goodTry.
  ///
  /// In en, this message translates to:
  /// **'Good try!'**
  String get goodTry;

  /// No description provided for @correctAnswerWas.
  ///
  /// In en, this message translates to:
  /// **'The correct answer was {answer}.'**
  String correctAnswerWas(String answer);

  /// No description provided for @nextWord.
  ///
  /// In en, this message translates to:
  /// **'Next Word'**
  String get nextWord;

  /// No description provided for @finishPractice.
  ///
  /// In en, this message translates to:
  /// **'Finish Practice'**
  String get finishPractice;

  /// No description provided for @loadingWords.
  ///
  /// In en, this message translates to:
  /// **'Getting your words ready...'**
  String get loadingWords;

  /// No description provided for @couldNotLoadWords.
  ///
  /// In en, this message translates to:
  /// **'Could not load this word pack.'**
  String get couldNotLoadWords;

  /// No description provided for @packStyle.
  ///
  /// In en, this message translates to:
  /// **'Pack Style'**
  String get packStyle;

  /// No description provided for @words.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get words;

  /// No description provided for @school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @animals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get animals;

  /// No description provided for @feelings.
  ///
  /// In en, this message translates to:
  /// **'Feelings'**
  String get feelings;

  /// No description provided for @ourWorld.
  ///
  /// In en, this message translates to:
  /// **'Our World'**
  String get ourWorld;

  /// No description provided for @fun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get fun;

  /// No description provided for @selectedChildren.
  ///
  /// In en, this message translates to:
  /// **'Selected Children'**
  String get selectedChildren;

  /// No description provided for @availableToEveryone.
  ///
  /// In en, this message translates to:
  /// **'Available to Everyone'**
  String get availableToEveryone;

  /// No description provided for @couldNotLoadWordPacks.
  ///
  /// In en, this message translates to:
  /// **'Could not load word packs.'**
  String get couldNotLoadWordPacks;

  /// No description provided for @wordPackCreated.
  ///
  /// In en, this message translates to:
  /// **'Word pack created.'**
  String get wordPackCreated;

  /// No description provided for @wordPackDeleted.
  ///
  /// In en, this message translates to:
  /// **'Word pack deleted.'**
  String get wordPackDeleted;

  /// No description provided for @wordPackSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the word pack.'**
  String get wordPackSaveFailed;

  /// No description provided for @wordPackDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the word pack.'**
  String get wordPackDeleteFailed;

  /// No description provided for @editPackDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Pack Details'**
  String get editPackDetails;

  /// No description provided for @wordPackUpdated.
  ///
  /// In en, this message translates to:
  /// **'Word pack updated.'**
  String get wordPackUpdated;

  /// No description provided for @assignmentsSaved.
  ///
  /// In en, this message translates to:
  /// **'Assignments saved.'**
  String get assignmentsSaved;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @hintOptional.
  ///
  /// In en, this message translates to:
  /// **'Helpful hint (optional)'**
  String get hintOptional;

  /// No description provided for @wordSaved.
  ///
  /// In en, this message translates to:
  /// **'Word saved.'**
  String get wordSaved;

  /// No description provided for @wordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Word deleted.'**
  String get wordDeleted;

  /// No description provided for @wordSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the word.'**
  String get wordSaveFailed;

  /// No description provided for @wordDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the word.'**
  String get wordDeleteFailed;

  /// No description provided for @wordProgressCount.
  ///
  /// In en, this message translates to:
  /// **'Word {current} of {total}'**
  String wordProgressCount(int current, int total);

  /// No description provided for @practiceScore.
  ///
  /// In en, this message translates to:
  /// **'{score} of {total} correct'**
  String practiceScore(int score, int total);

  /// No description provided for @showHint.
  ///
  /// In en, this message translates to:
  /// **'Show Hint'**
  String get showHint;
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
