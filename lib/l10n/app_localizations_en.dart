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
  String get selectedChildren => 'Selected children';

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

  @override
  String get profiles => 'Profiles';

  @override
  String staffHubTitle(String staffName) {
    return '$staffName Hub';
  }

  @override
  String get staffFeatureHub => 'Staff Feature Hub';

  @override
  String get staffHubIntro => 'Choose a tool for today\'s classroom support.';

  @override
  String get dailyTools => 'Daily Tools';

  @override
  String get todayOverview => 'Today Overview';

  @override
  String get todayOverviewSubtitle =>
      'See zones, reports, schedule and incidents at a glance.';

  @override
  String get staffZonesSubtitle => 'View children\'s current zones.';

  @override
  String get staffPointsSubtitle => 'View and update child points.';

  @override
  String get staffScheduleSubtitle => 'Create and edit the daily schedule.';

  @override
  String get whenThenSetup => 'When–Then Setup';

  @override
  String get staffWhenThenSubtitle =>
      'Create When–Then activities and rewards.';

  @override
  String get visualTimer => 'Visual Timer';

  @override
  String get staffTimerSubtitle => 'Open the classroom timer.';

  @override
  String get communication => 'Communication';

  @override
  String get bodyCheckReports => 'Body Check Reports';

  @override
  String get bodyCheckReportsSubtitle =>
      'Review body check messages from children.';

  @override
  String get circleTime => 'Circle Time';

  @override
  String get staffCircleTimeSubtitle =>
      'Move children between home and school.';

  @override
  String get learning => 'Learning';

  @override
  String get quizzes => 'Quizzes';

  @override
  String get staffQuizzesSubtitle => 'Create, preview and manage quizzes.';

  @override
  String get staffWordLearningSubtitle =>
      'Create word packs and view progress.';

  @override
  String get staffAdmin => 'Staff / Admin';

  @override
  String get staffIncidentLogSubtitle =>
      'Record and review classroom incidents.';

  @override
  String get staffHandoverSubtitle =>
      'View overview notes and staff documents.';

  @override
  String get iconReset => 'Icon Reset';

  @override
  String get iconResetSubtitle => 'View or reset child profile unlock icons.';

  @override
  String childSpaceTitle(String childName) {
    return '$childName\'s Space';
  }

  @override
  String welcomeChild(Object childName) {
    return 'Welcome, $childName!';
  }

  @override
  String get whatWouldYouLikeToDo => 'What would you like to do?';

  @override
  String get childCircleTimeSubtitle => 'Start the day together.';

  @override
  String get childScheduleSubtitle => 'See what is happening today.';

  @override
  String get whenThen => 'When–Then';

  @override
  String get childWhenThenSubtitle => 'See your next activity and reward.';

  @override
  String get childZonesSubtitle => 'Share how you are feeling.';

  @override
  String get bodyCheck => 'Body Check';

  @override
  String get childBodyCheckSubtitle => 'Show where your body feels sore.';

  @override
  String get childCalmingSoundsSubtitle => 'Listen and take a calm moment.';

  @override
  String get voiceLines => 'Voice Lines';

  @override
  String get childVoiceLinesSubtitle => 'Listen to helpful words and phrases.';

  @override
  String get childPointsSubtitle => 'See your points and rewards.';

  @override
  String get childQuizSubtitle => 'Play a quiz and learn something new.';

  @override
  String get childWordPracticeSubtitle => 'Practise words at your own pace.';

  @override
  String get childTimerSubtitle => 'See how much time is left.';

  @override
  String get myDay => 'My Day';

  @override
  String get myDaySubtitle => 'See what is happening next.';

  @override
  String get howIFeel => 'How I Feel';

  @override
  String get howIFeelSubtitle => 'Check in with your body and feelings.';

  @override
  String get learnAndPlay => 'Learn & Play';

  @override
  String get learnAndPlaySubtitle => 'Practise, explore and have some fun.';

  @override
  String get timeFinished => 'Time Finished';

  @override
  String get timerCountingDown => 'The timer is counting down';

  @override
  String get chooseTimeAndStart => 'Choose a time and press start';

  @override
  String get minutesShort => 'min';

  @override
  String get chooseTimerLength => 'Choose a timer length';

  @override
  String get customTime => 'Custom time';

  @override
  String timerMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get start => 'Start';

  @override
  String get pause => 'Pause';

  @override
  String get reset => 'Reset';

  @override
  String get calmingSoundsIntro => 'Choose a relaxing sound to listen to';

  @override
  String get soundPlaybackFailed =>
      'Could not play this sound. Check the asset file.';

  @override
  String get paused => 'Paused';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get volume => 'Volume';

  @override
  String get play => 'Play';

  @override
  String get stop => 'Stop';

  @override
  String get pausedTapToPlay => 'Paused - tap to play';

  @override
  String get playingTapToPause => 'Playing - tap to pause';

  @override
  String get tapToPlay => 'Tap to play';

  @override
  String get whenThenChoiceSaveFailed =>
      'That choice could not be saved. Please try again.';

  @override
  String get gettingPlanReady => 'Getting your plan ready...';

  @override
  String get planLoadFailed => 'We could not load your plan';

  @override
  String get waitAndTryAgain => 'Please wait a moment and try again.';

  @override
  String get allCaughtUp => 'You\'re all caught up!';

  @override
  String get noActiveWhenThen => 'No active When–Then board right now';

  @override
  String get newPlanWillAppear =>
      'A new plan will appear here when it is ready.';

  @override
  String get whenLabel => 'WHEN';

  @override
  String get thenLabel => 'THEN';

  @override
  String childPlanGreeting(String childName) {
    return 'Here\'s your plan, $childName!';
  }

  @override
  String get oneStepAtATime => 'One step at a time — you\'ve got this!';

  @override
  String get greatChoice => 'Great choice!';

  @override
  String get thisComesNext => 'This is what comes next';

  @override
  String get chooseYourReward => 'Choose your reward';

  @override
  String get tapRewardYouWouldLike => 'Tap the one you would like.';

  @override
  String get finishWhenEnjoyReward =>
      'Finish your WHEN activity, then enjoy your reward!';

  @override
  String get brilliantChoice => 'Brilliant choice!';

  @override
  String get pleaseChooseChild => 'Please choose a child.';

  @override
  String get chooseAtLeastOneChild => 'Please choose at least one child.';

  @override
  String get noChildProfilesFound => 'No child profiles were found.';

  @override
  String get chooseWhenActivityFirst => 'Choose the WHEN activity first.';

  @override
  String get chooseOneToThreeRewards => 'Choose between 1 and 3 THEN rewards.';

  @override
  String get selectedRewardUnavailable =>
      'One of the selected rewards is no longer available.';

  @override
  String get whenThenBoardCreated => 'When–Then board created successfully';

  @override
  String whenThenCreateFailed(String error) {
    return 'Failed to create the When–Then board: $error';
  }

  @override
  String get editActivity => 'Edit activity';

  @override
  String get addActivity => 'Add activity';

  @override
  String get editReward => 'Edit reward';

  @override
  String get addReward => 'Add reward';

  @override
  String get nameLabel => 'Name';

  @override
  String get shortClearNameHint => 'Enter a clear, short name';

  @override
  String get chooseIcon => 'Choose an icon';

  @override
  String optionSaveFailed(String error) {
    return 'Could not save this option: $error';
  }

  @override
  String get deleteOptionQuestion => 'Delete option?';

  @override
  String deleteOptionMessage(String optionName) {
    return 'Are you sure you want to delete “$optionName”?';
  }

  @override
  String optionDeleteFailed(String error) {
    return 'Could not delete this option: $error';
  }

  @override
  String get whoLabel => 'WHO';

  @override
  String get whoShouldSeeBoard => 'Who should see this board?';

  @override
  String get one => 'One';

  @override
  String get some => 'Some';

  @override
  String boardSentToAllChildren(int count) {
    return 'This board will be sent to all $count child profiles.';
  }

  @override
  String get noChildProfilesAvailable => 'No child profiles are available.';

  @override
  String get whatHappensFirst => 'What needs to happen first?';

  @override
  String get noActivitiesManageOptions =>
      'No activities yet. Add one in Manage Options.';

  @override
  String get possibleRewardsInstruction =>
      'Choose between 1 and 3 possible rewards.';

  @override
  String get noRewardsManageOptions =>
      'No rewards yet. Add one in Manage Options.';

  @override
  String rewardsSelectedCount(int count) {
    return '$count of 3 rewards selected';
  }

  @override
  String get boardPreview => 'Board preview';

  @override
  String get chooseActivity => 'Choose an activity';

  @override
  String get chooseRewards => 'Choose rewards';

  @override
  String rewardChoicesCount(int count) {
    return '$count reward choices';
  }

  @override
  String get boardOptionsLoadFailed =>
      'Something went wrong loading the board options.';

  @override
  String get createClearVisualBoard => 'Create a clear visual board';

  @override
  String get createBoardIntro =>
      'Choose who it is for, what happens WHEN, and what they can enjoy THEN.';

  @override
  String get creatingBoard => 'Creating board...';

  @override
  String get createWhenThenBoard => 'Create When–Then Board';

  @override
  String get childProfilesLoadFailed => 'Could not load child profiles.';

  @override
  String get activeBoards => 'Active Boards';

  @override
  String get activeBoardsIntro =>
      'See each child\'s current board and clear it when complete.';

  @override
  String optionsLoadFailed(String title) {
    return 'Could not load $title.';
  }

  @override
  String get noOptionsAdded => 'No options have been added yet.';

  @override
  String get manageOptions => 'Manage Options';

  @override
  String get manageOptionsIntro =>
      'Keep names short and clear so children can understand them quickly.';

  @override
  String get whenActivities => 'WHEN Activities';

  @override
  String get whenActivitiesDescription => 'Tasks and activities to complete.';

  @override
  String get thenRewards => 'THEN Rewards';

  @override
  String get thenRewardsDescription => 'Positive choices offered afterwards.';

  @override
  String get options => 'Options';

  @override
  String get noActiveBoard => 'No active board';

  @override
  String whenActivitySummary(String activity) {
    return 'WHEN: $activity';
  }

  @override
  String get thenWaitingForReward => 'THEN: Waiting for reward choice';

  @override
  String thenRewardSummary(String reward) {
    return 'THEN: $reward';
  }

  @override
  String childBoardCleared(String childName) {
    return '$childName\'s board was cleared.';
  }

  @override
  String boardClearFailed(String error) {
    return 'Could not clear the board: $error';
  }

  @override
  String get complete => 'Complete';

  @override
  String get myCircleTime => 'My Circle Time';

  @override
  String weatherSaveFailed(String error) {
    return 'Could not save the weather: $error';
  }

  @override
  String get todaysMessage => 'Today\'s Message';

  @override
  String get todaysMessageHint => 'Example: Today we are going to the library!';

  @override
  String messageSaveFailed(String error) {
    return 'Could not save today\'s message: $error';
  }

  @override
  String get circleTimeLoadFailed =>
      'Could not load today\'s Circle Time information.';

  @override
  String get today => 'Today';

  @override
  String get winter => 'Winter';

  @override
  String get spring => 'Spring';

  @override
  String get summer => 'Summer';

  @override
  String get autumn => 'Autumn';

  @override
  String get weatherTodayQuestion => 'What is the weather like today?';

  @override
  String get sunny => 'Sunny';

  @override
  String get cloudy => 'Cloudy';

  @override
  String get rainy => 'Rainy';

  @override
  String get windy => 'Windy';

  @override
  String get snowy => 'Snowy';

  @override
  String get foggy => 'Foggy';

  @override
  String get weatherNotSelected => 'The weather has not been selected yet.';

  @override
  String get noMessageToday => 'There is no message for today yet.';

  @override
  String get addMessageToday =>
      'Add a short message or special activity for today.';

  @override
  String get editMessage => 'Edit message';

  @override
  String get addMessage => 'Add message';

  @override
  String get staffProfilesLoadFailed => 'Could not load staff profiles.';

  @override
  String get homeLabel => 'Home';

  @override
  String get schoolLabel => 'School';

  @override
  String get childLabel => 'Child';

  @override
  String get staffLabel => 'Staff';

  @override
  String personPositionSaveFailed(String personName) {
    return 'Could not save $personName\'s position.';
  }

  @override
  String get pointsLoadFailed => 'Could not load your points.';

  @override
  String get pointsHistoryLoadFailed => 'Could not load your points history.';

  @override
  String wellDoneChild(String childName) {
    return 'Well done, $childName!';
  }

  @override
  String get pointsCelebrateEffort =>
      'Your points celebrate your effort and achievements.';

  @override
  String pointLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Points',
      one: 'Point',
    );
    return '$_temp0';
  }

  @override
  String get nextStarMilestone => 'Next Star Milestone';

  @override
  String milestoneProgress(int current, int target) {
    return '$current of 10 points toward $target';
  }

  @override
  String milestonesCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count milestones completed!',
      one: '1 milestone completed!',
    );
    return '$_temp0';
  }

  @override
  String get recentAchievements => 'My Recent Achievements';

  @override
  String get achievementsWillAppear => 'Your achievements will appear here.';

  @override
  String get justNow => 'Just now';

  @override
  String todayAt(String time) {
    return 'Today at $time';
  }

  @override
  String get rewardsToWorkToward => 'Rewards I Can Work Toward';

  @override
  String get rewardsChildIntro =>
      'Keep earning points and ask a staff member when you are ready to choose a reward.';

  @override
  String get readyToChoose => 'Ready to choose!';

  @override
  String pointsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more points needed',
      one: '1 more point needed',
    );
    return '$_temp0';
  }

  @override
  String updateChildPoints(String childName) {
    return 'Update $childName\'s Points';
  }

  @override
  String get earnPoints => 'Earn Points';

  @override
  String get removePoints => 'Remove Points';

  @override
  String get howManyPoints => 'How many points?';

  @override
  String get reason => 'Reason';

  @override
  String get reasonRequiredInfo =>
      'A reason is required for the points history.';

  @override
  String get optionalNote => 'Optional note';

  @override
  String get pointNoteHint => 'Add any useful detail about this entry.';

  @override
  String get pointsCannotBelowZero => 'Points cannot fall below zero.';

  @override
  String get selectReason => 'Please select a reason.';

  @override
  String childPointsBalanceUpdated(String childName, int balance) {
    return '$childName now has $balance points.';
  }

  @override
  String get awardPoints => 'Award Points';

  @override
  String get childAlreadyZeroPoints => 'This child already has zero points.';

  @override
  String get currentBalance => 'Current balance';

  @override
  String childPointsHistory(String childName) {
    return '$childName\'s Points History';
  }

  @override
  String get pointsHistoryLoadError => 'Could not load points history.';

  @override
  String get noPointsHistory => 'No points history yet.';

  @override
  String balanceValue(int balance) {
    return 'Balance: $balance';
  }

  @override
  String get manageRewards => 'Manage rewards';

  @override
  String get childPointsLoadFailed => 'Could not load child points.';

  @override
  String get classroomPoints => 'Classroom Points';

  @override
  String get classroomPointsIntro =>
      'Recognise effort, progress and positive achievements.';

  @override
  String get children => 'Children';

  @override
  String get totalPoints => 'Total points';

  @override
  String get updatePoints => 'Update Points';

  @override
  String get viewHistory => 'View History';

  @override
  String get createChildBeforePoints =>
      'Create a child profile before awarding points.';

  @override
  String get reasonGreatEffort => 'Great effort';

  @override
  String get reasonCompletedActivity => 'Completed an activity';

  @override
  String get reasonKindness => 'Kindness';

  @override
  String get reasonHelpingOthers => 'Helping others';

  @override
  String get reasonGoodListening => 'Good listening';

  @override
  String get reasonPersonalGoal => 'Personal goal';

  @override
  String get reasonOther => 'Other';

  @override
  String get reasonRewardRedeemed => 'Reward redeemed';

  @override
  String get reasonCorrectEntry => 'Correct previous entry';

  @override
  String get scheduleMonday => 'Monday';

  @override
  String get scheduleTuesday => 'Tuesday';

  @override
  String get scheduleWednesday => 'Wednesday';

  @override
  String get scheduleThursday => 'Thursday';

  @override
  String get scheduleFriday => 'Friday';

  @override
  String scheduleMinutes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String scheduleHours(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String scheduleHoursMinutes(Object hours, Object minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String scheduleActivityCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activities',
      one: '1 activity',
      zero: 'No activities',
    );
    return '$_temp0';
  }

  @override
  String scheduleActivityCountToday(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activities',
      one: '1 activity',
      zero: 'No activities today',
    );
    return '$_temp0';
  }

  @override
  String classroomScheduleTitle(Object classroomName) {
    return '$classroomName Schedule';
  }

  @override
  String get staffScheduleTitle => 'Staff Schedule';

  @override
  String get scheduleLoadFailed => 'The schedule could not be loaded.';

  @override
  String get classroomScheduleLoadFailed =>
      'The classroom schedule could not be loaded.';

  @override
  String get fillTimeSlot => 'Fill Time Slot';

  @override
  String get duration => 'Duration';

  @override
  String get activityName => 'Activity name';

  @override
  String get activityNameHint => 'Example: Morning reading';

  @override
  String get activityType => 'Activity type';

  @override
  String get enterActivityName => 'Please enter an activity name.';

  @override
  String get activityOverlap =>
      'This duration overlaps another scheduled activity.';

  @override
  String get activitySaveFailed => 'The activity could not be saved.';

  @override
  String get fillSlot => 'Fill Slot';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get clearThisSlot => 'Clear This Slot?';

  @override
  String removeActivityFromDay(Object activity, Object day) {
    return 'Remove \"$activity\" from $day?';
  }

  @override
  String get clearSlot => 'Clear Slot';

  @override
  String get activityRemoveFailed => 'The activity could not be removed.';

  @override
  String get copySchedule => 'Copy Schedule';

  @override
  String copyActivitiesToDay(Object sourceDay) {
    return 'Copy all activities from $sourceDay to:';
  }

  @override
  String get targetDay => 'Target day';

  @override
  String get continueLabel => 'Continue';

  @override
  String get replaceExistingSchedule => 'Replace Existing Schedule?';

  @override
  String dayExistingActivityCount(Object day, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activities',
      one: '1 activity',
    );
    return '$day already has $_temp0.';
  }

  @override
  String get replace => 'Replace';

  @override
  String scheduleCopied(Object sourceDay, Object targetDay) {
    return '$sourceDay was copied to $targetDay.';
  }

  @override
  String get scheduleCopyFailed => 'The schedule could not be copied.';

  @override
  String get copyThisDay => 'Copy this day';

  @override
  String get copyDay => 'Copy Day';

  @override
  String get tapBlankSlot => 'Tap a blank slot to begin';

  @override
  String get addFifteenMinuteActivity => 'Add 15-minute activity';

  @override
  String get tapToAddActivity => 'Tap to add activity';

  @override
  String get editActivityTooltip => 'Edit activity';

  @override
  String get clearSlotTooltip => 'Clear slot';

  @override
  String get happeningNow => 'Happening Now';

  @override
  String get comingNext => 'Coming Next';

  @override
  String nextActivity(Object activity) {
    return 'Next: $activity';
  }

  @override
  String startsAt(Object time) {
    return 'Starts at $time';
  }

  @override
  String get todaysActivitiesFinished =>
      'All of today’s activities are finished.';

  @override
  String dayToday(Object day) {
    return '$day • Today';
  }

  @override
  String get statusNow => 'NOW';

  @override
  String get statusNext => 'NEXT';

  @override
  String get statusFinished => 'FINISHED';

  @override
  String nothingScheduledForDay(Object day) {
    return 'Nothing is scheduled for $day';
  }

  @override
  String get enjoyYourDay => 'Enjoy your day!';

  @override
  String get activityTypeLearning => 'Learning';

  @override
  String get activityTypeBreak => 'Break';

  @override
  String get activityTypeFood => 'Food';

  @override
  String get activityTypeMovement => 'Movement';

  @override
  String get activityTypeTherapy => 'Therapy';

  @override
  String get activityTypeCreative => 'Creative';

  @override
  String get activityTypeArrival => 'Arrival';

  @override
  String get activityTypeHome => 'Home Time';

  @override
  String get activityTypeOther => 'Other';

  @override
  String get schoolName => 'School Name';

  @override
  String get schoolNameHint => 'Example: St Mary’s Primary School';

  @override
  String get schoolCode => 'School Code';

  @override
  String get schoolCodeHint => 'Example: STM123';

  @override
  String get adminEmail => 'Admin Email';

  @override
  String get password => 'Password';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get createSchoolAdminAccount => 'Create School Admin Account';

  @override
  String get adminLogin => 'Admin Login';

  @override
  String get existingAdminLogin => 'Already have an admin account? Login';

  @override
  String get registerSchoolPrompt => 'No admin account? Register school';

  @override
  String get classroomCode => 'Classroom Code';

  @override
  String get classroomCodeHint => 'Example: ASD1';

  @override
  String get classroomPin => 'Classroom PIN';

  @override
  String get checking => 'Checking...';

  @override
  String get enterClassroom => 'Enter Classroom';

  @override
  String get createSchoolAdminIntro => 'Create a school admin account';

  @override
  String get adminLoginIntro => 'Admin login';

  @override
  String get classroomLoginIntro => 'Classroom login';

  @override
  String get admin => 'Admin';

  @override
  String get classroom => 'Classroom';

  @override
  String get enterSchoolDetails =>
      'Please enter a school name and school code.';

  @override
  String get adminAccountCreateFailed => 'Could not create admin account.';

  @override
  String get loginFailed => 'Could not log in.';

  @override
  String get enterClassroomDetails =>
      'Please enter school code, classroom code and PIN.';

  @override
  String get classroomLoginIncorrect =>
      'Classroom login details are incorrect.';

  @override
  String get checkLoginFields => 'Please check all login fields.';

  @override
  String get adminLoginIncorrect => 'Admin email or password is incorrect.';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get accessDeniedIncorrectPin => 'Access denied: incorrect PIN';

  @override
  String get staffProfileDeleted => 'Staff profile deleted';

  @override
  String get childProfileDeleted => 'Child profile deleted';

  @override
  String staffProfileDeleteFailed(Object error) {
    return 'Failed to delete staff profile: $error';
  }

  @override
  String childProfileDeleteFailed(Object error) {
    return 'Failed to delete child profile: $error';
  }

  @override
  String get chooseProfile => 'Choose a profile to continue';

  @override
  String get staffProfiles => 'Staff Profiles';

  @override
  String get childProfiles => 'Child Profiles';

  @override
  String get staffProfile => 'Staff profile';

  @override
  String get noChildProfilesShort => 'No child profiles found';

  @override
  String ageValue(Object age) {
    return 'Age: $age';
  }

  @override
  String get adminActions => 'Admin Actions';

  @override
  String get addProfile => 'Add Profile';

  @override
  String get createProfilesIntro => 'Create staff or child profiles';

  @override
  String get appSettings => 'App Settings';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get languageAppOptions => 'Language and app options';

  @override
  String get managePinAccountOptions => 'Manage PIN and account options';

  @override
  String get manageAppSettings => 'Manage app settings';

  @override
  String get manageYourAccount => 'Manage your account';

  @override
  String get appSettingsDescription =>
      'Choose the app language and general app options.';

  @override
  String get accountSettingsDescription =>
      'Set your PIN and choose the app language.';

  @override
  String get overwriteExistingPinQuestion => 'Overwrite existing PIN?';

  @override
  String get overwriteExistingPinMessage =>
      'This will replace your current PIN. Continue?';

  @override
  String get pinIsSet => 'PIN is set';

  @override
  String get noPinSet => 'No PIN set';

  @override
  String get accountPinProtectsStaffAreas =>
      'The account PIN protects staff-only areas.';

  @override
  String get changePin => 'Change PIN';

  @override
  String get newPinInstructions => 'Enter a new 4-digit PIN.';

  @override
  String get chooseAppLanguage => 'Choose the app language.';

  @override
  String staffLoadError(Object error) {
    return 'Error loading staff: $error';
  }

  @override
  String childrenLoadError(Object error) {
    return 'Error loading children: $error';
  }

  @override
  String get deleteProfile => 'Delete profile';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get pin => 'PIN';

  @override
  String get incorrectPin => 'Incorrect PIN';

  @override
  String get submit => 'Submit';

  @override
  String get clear => 'Clear';

  @override
  String get next => 'Next';

  @override
  String get startOver => 'Start Over';

  @override
  String get success => 'Success';

  @override
  String get ok => 'OK';

  @override
  String get role => 'Role';

  @override
  String get age => 'Age';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get roleRequired => 'Role is required';

  @override
  String get ageRequired => 'Age is required';

  @override
  String get ageNumberRequired => 'Age must be a number';

  @override
  String get addStaffProfile => 'Add Staff Profile';

  @override
  String get addChildProfile => 'Add Child Profile';

  @override
  String get profilesSavedToClassroom =>
      'New profiles will be saved to this classroom.';

  @override
  String get createStaffProfile => 'Create a staff profile';

  @override
  String get createChildProfile => 'Create a child profile';

  @override
  String get staffProfileAccessInfo =>
      'Staff profiles use the account or classroom PIN for access.';

  @override
  String get childProfileAccessInfo =>
      'Child profiles can use a simple 3-icon unlock sequence.';

  @override
  String get staffDetails => 'Staff Details';

  @override
  String get childDetails => 'Child Details';

  @override
  String get confirmChildUnlock => 'Confirm Child Unlock Sequence';

  @override
  String get setChildUnlock => 'Set Child Unlock Sequence';

  @override
  String get tapSameIconsConfirm => 'Tap the same 3 icons again to confirm.';

  @override
  String get askChildPickIcons => 'Ask the child to pick 3 icons in order.';

  @override
  String get chooseThreeIconsFirst => 'Please choose 3 icons first';

  @override
  String get chooseUnlockSequence => 'Please choose a 3-icon unlock sequence';

  @override
  String get confirmChildUnlockPrompt =>
      'Please confirm the child unlock sequence';

  @override
  String get confirmThreeIconsPrompt =>
      'Please tap the same 3 icons again to confirm';

  @override
  String get sequencesDoNotMatch =>
      'Sequences did not match. Please try again.';

  @override
  String profileCreated(Object name) {
    return 'Profile \"$name\" created successfully.';
  }

  @override
  String profileSaveError(Object error) {
    return 'Error saving profile: $error';
  }

  @override
  String get saveStaffProfile => 'Save Staff Profile';

  @override
  String get saveChildProfile => 'Save Child Profile';

  @override
  String get selectedNone => 'Selected: None';

  @override
  String selectedIcons(Object icons) {
    return 'Selected: $icons';
  }

  @override
  String selectedCount(Object selected, Object required) {
    return '$selected/$required selected';
  }

  @override
  String get wrongIconSequence => 'Wrong sequence, try again';

  @override
  String unlockChild(Object childName) {
    return 'Unlock $childName';
  }

  @override
  String get tapPicturesInOrder => 'Tap your 3 pictures in order';

  @override
  String enteredCount(Object entered, Object required) {
    return 'Entered: $entered/$required';
  }

  @override
  String resetUnlockForChild(Object childName) {
    return 'Reset unlock for $childName';
  }

  @override
  String get chooseIconsInOrder => 'Choose 3 icons in order';

  @override
  String get confirmIconSequence => 'Please confirm the 3-icon sequence';

  @override
  String get iconSequencesDoNotMatch => 'Sequences did not match. Try again.';

  @override
  String get iconStar => 'Star';

  @override
  String get iconCar => 'Car';

  @override
  String get iconDog => 'Dog';

  @override
  String get iconApple => 'Apple';

  @override
  String get iconBall => 'Ball';

  @override
  String get iconMusic => 'Music';

  @override
  String get iconSun => 'Sun';

  @override
  String get iconHeart => 'Heart';

  @override
  String schoolAdminTitle(Object schoolName) {
    return '$schoolName Admin';
  }

  @override
  String get schoolSettings => 'School Settings';

  @override
  String schoolCodeValue(Object code) {
    return 'School Code: $code';
  }

  @override
  String classroomsUsed(Object used, Object limit) {
    return 'Classrooms Used: $used / $limit';
  }

  @override
  String statusValue(Object status) {
    return 'Status: $status';
  }

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String classroomsLoadError(Object error) {
    return 'Error loading classrooms: $error';
  }

  @override
  String get noClassroomsYet =>
      'No classrooms yet.\nTap + Add Classroom to create one.';

  @override
  String classroomListSummary(Object code, Object active) {
    return 'Code: $code • Active: $active';
  }

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get addClassroom => 'Add Classroom';

  @override
  String get classroomCreated => 'Classroom created';

  @override
  String classroomCreateError(Object error) {
    return 'Error creating classroom: $error';
  }

  @override
  String get createClassroom => 'Create Classroom';

  @override
  String get classroomDetails => 'Classroom Details';

  @override
  String get classroomName => 'Classroom Name';

  @override
  String get classroomNameHint => 'Example: ASD Unit 1';

  @override
  String get enterClassroomName => 'Enter a classroom name';

  @override
  String get enterClassroomCode => 'Enter a classroom code';

  @override
  String get classroomCodeMinLength =>
      'Classroom code should be at least 3 characters';

  @override
  String get classroomPinHint => 'Example: 1234';

  @override
  String get enterClassroomPin => 'Enter a classroom PIN';

  @override
  String get classroomPinMinLength => 'PIN should be at least 4 digits';

  @override
  String get classroomNotFound => 'Classroom not found';

  @override
  String classroomLoadError(Object error) {
    return 'Error loading classroom: $error';
  }

  @override
  String get classroomUpdated => 'Classroom updated';

  @override
  String get deleteClassroom => 'Delete Classroom';

  @override
  String get deleteClassroomConfirmation =>
      'Are you sure you want to delete this classroom? This cannot be undone.';

  @override
  String get classroomDeleted => 'Classroom deleted';

  @override
  String classroomDeleteError(Object error) {
    return 'Error deleting classroom: $error';
  }

  @override
  String get classroomInformation => 'Classroom Information';

  @override
  String get classroomAccessInfo =>
      'These details control how staff access this classroom.';

  @override
  String get classroomCodeChangeInfo =>
      'Changing this code will change what staff enter on the Classroom Login screen.';

  @override
  String get classroomActive => 'Classroom Active';

  @override
  String get classroomInactiveInfo =>
      'If disabled, classroom login will be blocked for this classroom.';

  @override
  String get saveClassroom => 'Save Classroom';

  @override
  String get schoolNotFound => 'School not found';

  @override
  String schoolSettingsLoadError(Object error) {
    return 'Error loading school settings: $error';
  }

  @override
  String get schoolSettingsUpdated => 'School settings updated';

  @override
  String get schoolInformation => 'School Information';

  @override
  String get schoolAccountInfo =>
      'These details control the school account and classroom login.';

  @override
  String get enterSchoolName => 'Enter a school name';

  @override
  String get enterSchoolCode => 'Enter a school code';

  @override
  String get schoolCodeMinLength =>
      'School code should be at least 3 characters';

  @override
  String get schoolCodeChangeInfo =>
      'Changing the school code will change what staff enter on the Classroom Login screen.';

  @override
  String get classroomLimit => 'Classroom Limit';

  @override
  String get enterClassroomLimit => 'Enter a classroom limit';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get classroomLimitMinimum => 'Classroom limit must be at least 1';

  @override
  String get contactDetails => 'Contact Details';

  @override
  String get principalName => 'Principal Name';

  @override
  String get vicePrincipalName => 'Vice Principal Name';

  @override
  String get schoolEmail => 'School Email';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get schoolAddress => 'School Address';

  @override
  String get schoolActive => 'School Active';

  @override
  String get schoolInactiveInfo =>
      'If disabled later, classroom login can be blocked for this school.';

  @override
  String get saveSchoolSettings => 'Save School Settings';

  @override
  String get schoolCodeInUse => 'That school code is already in use.';

  @override
  String get classroomCodeInUse => 'That classroom code is already in use.';

  @override
  String get classroomLimitReached =>
      'Classroom limit reached. Increase the classroom limit in School Settings.';

  @override
  String get classroomUpdateError => 'The classroom could not be updated.';

  @override
  String get schoolSettingsUpdateError =>
      'The school settings could not be updated.';

  @override
  String get bodyPartHead => 'Head';

  @override
  String get bodyPartThroat => 'Throat';

  @override
  String get bodyPartChest => 'Chest';

  @override
  String get bodyPartTummy => 'Tummy';

  @override
  String get bodyPartLeftArm => 'Left arm';

  @override
  String get bodyPartRightArm => 'Right arm';

  @override
  String get bodyPartLeftHand => 'Left hand';

  @override
  String get bodyPartRightHand => 'Right hand';

  @override
  String get bodyPartLeftLeg => 'Left leg';

  @override
  String get bodyPartRightLeg => 'Right leg';

  @override
  String get bodyPartLeftFoot => 'Left foot';

  @override
  String get bodyPartRightFoot => 'Right foot';

  @override
  String get bodyPartBackOfHead => 'Back of head';

  @override
  String get bodyPartNeck => 'Neck';

  @override
  String get bodyPartUpperBack => 'Upper back';

  @override
  String get bodyPartLowerBack => 'Lower back';

  @override
  String get bodyMapFront => 'Front';

  @override
  String get bodyMapBack => 'Back';

  @override
  String bodyDiagramSemantics(Object side) {
    return '$side body diagram. Tap where it hurts.';
  }

  @override
  String get tapSoreBodyPart =>
      'Tap the body where you feel sore or uncomfortable.';

  @override
  String bodyPartSelected(Object bodyPart) {
    return 'You selected: $bodyPart';
  }

  @override
  String get chooseBodyPartList => 'Choose from a list instead';

  @override
  String get painLittleSore => 'A little sore';

  @override
  String get painLittleSoreDescription =>
      'I notice it, but it only hurts a little.';

  @override
  String get painHurts => 'It hurts';

  @override
  String get painHurtsShort => 'Hurts';

  @override
  String get painHurtsDescription => 'It is uncomfortable and I need help.';

  @override
  String get painHurtsALot => 'It hurts a lot';

  @override
  String get painHurtsALotShort => 'Hurts a lot';

  @override
  String get painHurtsALotDescription =>
      'It hurts badly and I need an adult now.';

  @override
  String get painUnknown => 'Unknown';

  @override
  String get painSoreAching => 'Sore or aching';

  @override
  String get painSoreAchingDescription => 'A dull or heavy pain.';

  @override
  String get painSharp => 'Sharp';

  @override
  String get painSharpDescription => 'A sudden or pointed pain.';

  @override
  String get painBurningHot => 'Burning or hot';

  @override
  String get painBurningHotDescription => 'It feels hot or burning.';

  @override
  String get painItchy => 'Itchy';

  @override
  String get painItchyDescription => 'I want to scratch it.';

  @override
  String get painThrobbing => 'Throbbing';

  @override
  String get painThrobbingDescription => 'It pulses or beats.';

  @override
  String get painTinglyNumb => 'Tingly or numb';

  @override
  String get painTinglyNumbDescription => 'It feels asleep or strange.';

  @override
  String get painSick => 'Sick';

  @override
  String get painSickDescription => 'I feel like I might be sick.';

  @override
  String get painNotSure => 'Not sure';

  @override
  String get painNotSureDescription => 'I cannot explain the feeling.';

  @override
  String get chooseSoreLocation => 'Please choose where you feel sore.';

  @override
  String get choosePainAmount => 'Please choose how much it hurts.';

  @override
  String get choosePainFeeling => 'Please choose what it feels like.';

  @override
  String get bodyCheckSendFailed =>
      'Your Body Check could not be sent. Please tell an adult now.';

  @override
  String get staffHaveBeenTold => 'Staff Have Been Told';

  @override
  String get bodyCheckSentMessage =>
      'Your Body Check was sent.\n\nPlease tell an adult now if you need help.';

  @override
  String get okay => 'Okay';

  @override
  String get bodyCheckWhere => 'Where?';

  @override
  String get bodyCheckHowMuch => 'How much?';

  @override
  String get bodyCheckWhatFeeling => 'What feeling?';

  @override
  String get review => 'Review';

  @override
  String bodyCheckStep(Object current, Object total, Object name) {
    return 'Step $current of $total: $name';
  }

  @override
  String get whereDoesItHurt => 'Where does it hurt?';

  @override
  String get howMuchDoesItHurt => 'How much does it hurt?';

  @override
  String get choosePainFace => 'Choose the face that best shows how you feel.';

  @override
  String get whatDoesItFeelLike => 'What does it feel like?';

  @override
  String get choosePainDescription =>
      'Choose the description that feels closest. It is okay if you are not sure.';

  @override
  String get checkYourBodyCheck => 'Check Your Body Check';

  @override
  String get reviewBodyCheckMessage =>
      'Make sure this shows how you feel before telling staff.';

  @override
  String get tellAdultBodyCheck =>
      'If you need help now, please tell an adult as well as sending this Body Check.';

  @override
  String changeBodyCheckAnswer(Object label) {
    return 'Change $label';
  }

  @override
  String get back => 'Back';

  @override
  String get sending => 'Sending...';

  @override
  String get tellStaff => 'Tell Staff';

  @override
  String get continueButton => 'Continue';

  @override
  String checkChildReport(Object childName) {
    return 'Check $childName’s Report';
  }

  @override
  String get optionalStaffNote => 'Optional staff note';

  @override
  String get staffNoteHint =>
      'Record what was checked or what support was given.';

  @override
  String get markChecked => 'Mark Checked';

  @override
  String reportMarkedChecked(Object childName) {
    return '$childName’s report was marked as checked.';
  }

  @override
  String get reportUpdateFailed => 'The report could not be updated.';

  @override
  String get deleteReportQuestion => 'Delete Report?';

  @override
  String deleteBodyCheckReport(Object childName) {
    return 'Delete this Body Check report for $childName?\n\nThis cannot be undone.';
  }

  @override
  String get reportDeleteFailed => 'The report could not be deleted.';

  @override
  String get classroomBodyChecks => 'Classroom Body Checks';

  @override
  String get classroomBodyChecksIntro =>
      'Review reports and record when support has been provided.';

  @override
  String get urgent => 'Urgent';

  @override
  String get unchecked => 'Unchecked';

  @override
  String get checked => 'Checked';

  @override
  String get reports => 'Reports';

  @override
  String get urgentBodyCheckMessage =>
      'This child selected “Hurts a lot” and has not been checked.';

  @override
  String get checkedByStaff => 'Checked by staff';

  @override
  String checkedAt(Object time) {
    return 'Checked $time';
  }

  @override
  String get deleteReport => 'Delete report';

  @override
  String get needsChecking => 'Needs checking';

  @override
  String get noBodyCheckReports => 'No Body Check reports yet';

  @override
  String get bodyCheckReportsAppearHere =>
      'Reports sent by children will appear here.';

  @override
  String get noReportsMatchFilters => 'No reports match these filters.';

  @override
  String get bodyCheckReportsLoadFailed =>
      'Something went wrong loading Body Check reports.';

  @override
  String dateTimeAt(Object date, Object time) {
    return '$date at $time';
  }

  @override
  String get quizStyleGeneral => 'General';

  @override
  String get quizStyleNumbers => 'Numbers';

  @override
  String get quizStyleWords => 'Words';

  @override
  String get quizStyleScience => 'Science';

  @override
  String get quizStyleWorld => 'Our World';

  @override
  String get quizStyleMemory => 'Memory';

  @override
  String get quizStyleFun => 'Fun';

  @override
  String get enterQuizTitle => 'Please enter a quiz title.';

  @override
  String get chooseQuizAudience =>
      'Choose at least one child or make the quiz available to everyone.';

  @override
  String get addAtLeastOneQuestion => 'Add at least one question.';

  @override
  String get quizUpdatedSuccess => 'Quiz updated successfully!';

  @override
  String get quizCreatedSuccess => 'Quiz created successfully!';

  @override
  String quizSaveFailed(Object error) {
    return 'Could not save the quiz: $error';
  }

  @override
  String get editYourQuiz => 'Edit your quiz';

  @override
  String get createNewQuiz => 'Create a new quiz';

  @override
  String get quizEditorIntro =>
      'Keep questions clear, encouraging and easy to understand.';

  @override
  String get quizDetails => 'Quiz details';

  @override
  String get quizDetailsIntro =>
      'Give the quiz a clear name and short description.';

  @override
  String get quizTitle => 'Quiz title';

  @override
  String get quizTitleHint => 'For example: Animal Sounds';

  @override
  String get quizDescriptionHint => 'What will children practise in this quiz?';

  @override
  String get quizStyle => 'Quiz style';

  @override
  String get quizStyleIntro => 'Choose a friendly visual theme.';

  @override
  String get whoCanPlay => 'Who can play?';

  @override
  String get quizAudienceIntro =>
      'Make it available to everyone or selected children.';

  @override
  String get questions => 'Questions';

  @override
  String questionCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String get addQuestion => 'Add question';

  @override
  String get addAnotherQuestion => 'Add another question';

  @override
  String get editQuiz => 'Edit Quiz';

  @override
  String get createQuiz => 'Create Quiz';

  @override
  String questionNumber(Object number) {
    return 'Question $number';
  }

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get deleteQuestion => 'Delete question';

  @override
  String get question => 'Question';

  @override
  String get questionHint => 'What would you like to ask?';

  @override
  String get answers => 'Answers';

  @override
  String get correctAnswerInstruction =>
      'Tap the circle beside the correct answer.';

  @override
  String get correctAnswer => 'Correct answer';

  @override
  String get markAsCorrect => 'Mark as correct';

  @override
  String answerLabel(Object letter) {
    return 'Answer $letter';
  }

  @override
  String get removeAnswer => 'Remove answer';

  @override
  String get addAnswer => 'Add answer';

  @override
  String get helpfulExplanation => 'Helpful explanation (optional)';

  @override
  String get helpfulExplanationHint =>
      'Shown after the child answers the question.';

  @override
  String questionNeedsText(Object number) {
    return 'Question $number needs some question text.';
  }

  @override
  String questionNeedsAnswers(Object number) {
    return 'Question $number needs at least two answers.';
  }

  @override
  String completeQuestionAnswers(Object number) {
    return 'Please complete every answer for question $number.';
  }

  @override
  String questionDuplicateAnswers(Object number) {
    return 'Question $number has duplicate answers.';
  }

  @override
  String chooseCorrectAnswer(Object number) {
    return 'Choose the correct answer for question $number.';
  }

  @override
  String get previewNeedsQuestion =>
      'Add at least one question before previewing.';

  @override
  String quizCopyTitle(Object title) {
    return '$title Copy';
  }

  @override
  String get quizDuplicated => 'Quiz duplicated successfully.';

  @override
  String quizDuplicateFailed(Object error) {
    return 'Could not duplicate the quiz: $error';
  }

  @override
  String get deleteQuizQuestion => 'Delete quiz?';

  @override
  String deleteQuizConfirmation(Object title) {
    return 'Are you sure you want to delete “$title”? Existing result history will be kept.';
  }

  @override
  String get quizDeleted => 'Quiz deleted.';

  @override
  String quizDeleteFailed(Object error) {
    return 'Could not delete the quiz: $error';
  }

  @override
  String get quizzesLoadFailed => 'Could not load quizzes';

  @override
  String get quizLibraryEmpty => 'Your quiz library is empty';

  @override
  String get createFirstQuiz => 'Create your first quiz to get started.';

  @override
  String get quizResultsLoadFailed => 'Could not load results';

  @override
  String get childProfilesLoadFailedShort =>
      'Child profiles could not be loaded.';

  @override
  String get noChildProfiles => 'No child profiles';

  @override
  String get quizResultsAfterProfiles =>
      'Quiz results will appear after profiles are added.';

  @override
  String get quizResults => 'Quiz results';

  @override
  String get quizResultsIntro => 'Recent attempts and scores for each child.';

  @override
  String get quizLibrary => 'Quiz Library';

  @override
  String get results => 'Results';

  @override
  String audienceSelectedCount(Object count) {
    return '$count selected';
  }

  @override
  String get moreOptions => 'More options';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get noDescriptionAdded => 'No description added.';

  @override
  String get preview => 'Preview';

  @override
  String get loadingAttempts => 'Loading attempts...';

  @override
  String get noQuizAttempts => 'No quiz attempts yet';

  @override
  String attemptCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts',
      one: '1 attempt',
    );
    return '$_temp0';
  }

  @override
  String get attemptsLoadFailed => 'Could not load attempts.';

  @override
  String get resultsAfterQuiz =>
      'Results will appear after this child completes a quiz.';

  @override
  String get deletedQuiz => 'Deleted quiz';

  @override
  String scoreSummary(Object score, Object total, Object percentage) {
    return '$score/$total • $percentage%';
  }

  @override
  String pointsValue(Object score) {
    return '$score points';
  }

  @override
  String get noQuizzesNow => 'No quizzes right now';

  @override
  String get quizWillAppear =>
      'A new quiz will appear here when it is ready for you.';

  @override
  String get childQuizzesLoadFailed => 'We could not load your quizzes';

  @override
  String readyToPlay(Object childName) {
    return 'Ready to play, $childName?';
  }

  @override
  String quizzesToExplore(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count quizzes to explore.',
      one: 'You have 1 quiz to explore.',
    );
    return '$_temp0';
  }

  @override
  String quizzesPlayed(Object count) {
    return '$count played';
  }

  @override
  String get myQuizzes => 'My Quizzes';

  @override
  String quizCardSemantics(Object title, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$title, $_temp0';
  }

  @override
  String get played => 'Played';

  @override
  String get tapToStartQuiz => 'Tap to start this quiz!';

  @override
  String get playAgain => 'Play Again';

  @override
  String get letsPlay => 'Let’s Play!';

  @override
  String get resultSaveFailed =>
      'Your result could not be saved. Please try again.';

  @override
  String get leaveQuizQuestion => 'Leave this quiz?';

  @override
  String get closeQuizPreview => 'Close the quiz preview?';

  @override
  String get unsavedQuizAnswers =>
      'Your answers in this attempt will not be saved.';

  @override
  String get keepPlaying => 'Keep Playing';

  @override
  String get leave => 'Leave';

  @override
  String get quizHasNoQuestions => 'This quiz has no questions yet';

  @override
  String get goBack => 'Go Back';

  @override
  String get staffPreviewBanner => 'Staff Preview — results will not be saved';

  @override
  String get questionUppercase => 'QUESTION';

  @override
  String questionProgress(Object current, Object total) {
    return '$current of $total';
  }

  @override
  String get tapCorrectAnswer => 'Tap the answer you think is right.';

  @override
  String get brilliant => 'Brilliant!';

  @override
  String answerIs(Object answer) {
    return 'The answer is $answer.';
  }

  @override
  String get savingResult => 'Saving your result...';

  @override
  String get seeMyResult => 'See My Result';

  @override
  String get nextQuestion => 'Next Question';

  @override
  String get resultAmazing => 'Amazing!';

  @override
  String get resultPerfectMessage => 'You got every question right!';

  @override
  String get resultGreatWork => 'Great work!';

  @override
  String get resultGreatMessage => 'You did a brilliant job!';

  @override
  String get resultWellDone => 'Well done!';

  @override
  String get resultWellDoneMessage =>
      'You kept trying and learned something new!';

  @override
  String get resultGoodEffort => 'Good effort!';

  @override
  String get resultGoodEffortMessage => 'Every try helps your brain grow!';

  @override
  String get previewComplete => 'Preview complete';

  @override
  String get previewResultMessage =>
      'This is how the child’s result screen will look.';

  @override
  String get closePreview => 'Close Preview';

  @override
  String get backToMyQuizzes => 'Back to My Quizzes';

  @override
  String answerSemantics(Object letter, Object answer) {
    return 'Answer $letter: $answer';
  }

  @override
  String get zoneBlue => 'Blue Zone';

  @override
  String get zoneGreen => 'Green Zone';

  @override
  String get zoneYellow => 'Yellow Zone';

  @override
  String get zoneRed => 'Red Zone';

  @override
  String get zoneBlueChildDescription =>
      'My body is running slowly. I may need rest, comfort or gentle movement.';

  @override
  String get zoneGreenChildDescription =>
      'My body feels calm and comfortable. I may feel ready to learn or play.';

  @override
  String get zoneYellowChildDescription =>
      'My energy is rising. I may need help slowing down or finding focus.';

  @override
  String get zoneRedChildDescription =>
      'My feelings are very intense. I may need space, safety and support.';

  @override
  String get zoneBlueStaffDescription => 'Low energy, tired, sad or unwell.';

  @override
  String get zoneGreenStaffDescription =>
      'Calm, focused, comfortable and ready.';

  @override
  String get zoneYellowStaffDescription =>
      'Worried, excited, frustrated or restless.';

  @override
  String get zoneRedStaffDescription =>
      'Very intense feelings requiring support.';

  @override
  String get feelingTired => 'Tired';

  @override
  String get feelingSad => 'Sad';

  @override
  String get feelingBored => 'Bored';

  @override
  String get feelingUnwell => 'Unwell';

  @override
  String get feelingSlow => 'Slow';

  @override
  String get feelingCalm => 'Calm';

  @override
  String get feelingFocused => 'Focused';

  @override
  String get feelingHappy => 'Happy';

  @override
  String get feelingContent => 'Content';

  @override
  String get feelingReady => 'Ready';

  @override
  String get feelingWorried => 'Worried';

  @override
  String get feelingExcited => 'Excited';

  @override
  String get feelingFrustrated => 'Frustrated';

  @override
  String get feelingSilly => 'Silly';

  @override
  String get feelingRestless => 'Restless';

  @override
  String get feelingAngry => 'Angry';

  @override
  String get feelingPanicked => 'Panicked';

  @override
  String get feelingTerrified => 'Terrified';

  @override
  String get feelingOverwhelmed => 'Overwhelmed';

  @override
  String get feelingOutOfControl => 'Out of control';

  @override
  String zoneSelected(Object zoneName) {
    return 'You selected the $zoneName.';
  }

  @override
  String zoneUpdateFailed(Object error) {
    return 'Could not update your zone: $error';
  }

  @override
  String get howAreYouFeeling => 'How Are You Feeling?';

  @override
  String helloChild(Object childName) {
    return 'Hello $childName';
  }

  @override
  String get chooseCurrentZone =>
      'Choose the zone that feels most like you right now.';

  @override
  String get everyZoneOkay => 'Every zone is okay.';

  @override
  String get thisIsMyZone => 'This is my zone';

  @override
  String chooseZone(Object zoneName) {
    return 'Choose $zoneName';
  }

  @override
  String get noBadZones =>
      'There are no bad zones. Our feelings give us information about what our body may need.';

  @override
  String get zonesOverview => 'Zones Overview';

  @override
  String get classroomZonesLoadFailed => 'Could not load classroom zones.';

  @override
  String get classroomZones => 'Classroom Zones';

  @override
  String get classroomZonesIntro => 'A live view of how children are feeling.';

  @override
  String get checkedIn => 'Checked in';

  @override
  String get noChildrenInZone => 'No children are currently in this zone.';

  @override
  String get allChildrenCheckedIn =>
      'Every child has completed their zone check-in.';

  @override
  String get notCheckedIn => 'Not checked in';

  @override
  String get noChildProfilesFoundShort => 'No child profiles found';

  @override
  String get createChildBeforeZones =>
      'Create a child profile before using the Zones Overview.';

  @override
  String get viewBodyCheckReports => 'View Body Check Reports';

  @override
  String get openIncidentLog => 'Open Incident Log';

  @override
  String get openSchedule => 'Open Schedule';

  @override
  String get openZonesOverview => 'Open Zones Overview';

  @override
  String get totalChildProfiles => 'Total child profiles';

  @override
  String get zonesCheckedIn => 'Zones checked in';

  @override
  String get childrenWithSelectedZone => 'Children with a selected zone';

  @override
  String get noChildProfilesYet => 'No child profiles yet.';

  @override
  String get noZone => 'No zone';

  @override
  String childZoneSummary(Object childName, Object zone) {
    return '$childName: $zone';
  }

  @override
  String get noUncheckedBodyChecks => 'No unchecked Body Check reports';

  @override
  String get nothingNeedsReview => 'Nothing currently needs review.';

  @override
  String get uncheckedBodyChecksIntro =>
      'Unchecked reports needing staff review';

  @override
  String bodyCheckSummary(Object bodyPart, Object painType, Object date) {
    return '$bodyPart • $painType • $date';
  }

  @override
  String viewAllBodyChecks(Object count) {
    return 'View all $count Body Check reports';
  }

  @override
  String get scheduleSaturday => 'Saturday';

  @override
  String get scheduleSunday => 'Sunday';

  @override
  String noScheduleEntriesForDay(Object day) {
    return 'No schedule entries for $day';
  }

  @override
  String get nothingScheduledTodayYet =>
      'Nothing has been added for today yet.';

  @override
  String get noImportantIncidents => 'No important recent incidents';

  @override
  String get noImportantIncidentsIntro =>
      'No medium/high incidents found for review.';

  @override
  String get severityHigh => 'High';

  @override
  String get severityMedium => 'Medium';

  @override
  String get severityLow => 'Low';

  @override
  String incidentSummary(Object severity, Object date, Object description) {
    return '$severity • $date\n$description';
  }

  @override
  String todayOverviewForStaff(Object staffName) {
    return 'Quick classroom overview for $staffName.';
  }

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get zonesSnapshot => 'Zones Snapshot';

  @override
  String get bodyCheckAttention => 'Body Check Attention';

  @override
  String get todaysSchedule => 'Today\'s Schedule';

  @override
  String get recentImportantIncidents => 'Recent / Important Incidents';

  @override
  String get chooseMyBackground => 'Choose My Background';

  @override
  String get makeItYours => 'Make It Yours';

  @override
  String get chooseComfortableDashboardColour =>
      'Choose a comfortable colour for your dashboard.';

  @override
  String get myZones => 'My Zones';

  @override
  String get colourChoices => 'Colour Choices';

  @override
  String get useThisBackground => 'Use This Background';

  @override
  String get backgroundColourUpdated => 'Background colour updated.';

  @override
  String get backgroundColourUpdateFailed =>
      'The background colour could not be updated.';

  @override
  String get backgroundClassicWhite => 'Classic White';

  @override
  String get backgroundClassicWhiteDescription => 'Clean and simple';

  @override
  String get backgroundSoftRose => 'Soft Rose';

  @override
  String get backgroundSoftRoseDescription => 'Warm and gentle';

  @override
  String get backgroundClearSky => 'Clear Sky';

  @override
  String get backgroundClearSkyDescription => 'Cool and peaceful';

  @override
  String get backgroundFreshMint => 'Fresh Mint';

  @override
  String get backgroundFreshMintDescription => 'Calm and natural';

  @override
  String get backgroundWarmSunshine => 'Warm Sunshine';

  @override
  String get backgroundWarmSunshineDescription => 'Bright and cheerful';

  @override
  String get backgroundSoftLavender => 'Soft Lavender';

  @override
  String get backgroundSoftLavenderDescription => 'Quiet and relaxing';

  @override
  String get backgroundGentleGrey => 'Gentle Grey';

  @override
  String get backgroundGentleGreyDescription => 'Neutral and focused';

  @override
  String get backgroundWarmPeach => 'Warm Peach';

  @override
  String get backgroundWarmPeachDescription => 'Cosy and welcoming';

  @override
  String unlockSequenceResetFor(Object childName) {
    return 'Unlock sequence reset for $childName';
  }

  @override
  String unlockSequenceResetFailed(Object error) {
    return 'Failed to reset sequence: $error';
  }

  @override
  String scheduleTimeRange(Object start, Object end) {
    return '$start - $end';
  }

  @override
  String get missingAdminDashboardDetails => 'Missing admin dashboard details.';

  @override
  String get missingChildProfile => 'Missing child profile.';

  @override
  String get missingStaffProfile => 'Missing staff profile.';

  @override
  String get missingQuizCreator => 'Missing quiz creator.';

  @override
  String get missingTeacherId => 'Missing teacher ID.';

  @override
  String get missingQuiz => 'Missing quiz.';

  @override
  String get missingStudentQuizDetails => 'Missing student quiz details.';

  @override
  String get missingWhenThenChildDetails => 'Missing When–Then child details.';

  @override
  String get missingCircleTimeDetails => 'Missing Circle Time details.';

  @override
  String get missingBodyCheckDetails => 'Missing Body Check details.';

  @override
  String get missingBodyCheckOverviewDetails =>
      'Missing Body Check overview details.';

  @override
  String get invalidRouteOrMissingArguments =>
      'Invalid route or missing arguments.';

  @override
  String get missingSchoolId => 'Missing school ID';

  @override
  String get missingClassroomDetails => 'Missing classroom details';

  @override
  String get staffProfileNotFound => 'Staff Profile Not Found';

  @override
  String get childProfileNotFound => 'Child Profile Not Found';

  @override
  String get returnToProfiles => 'Return to Profiles';

  @override
  String get iMightFeel => 'I might feel:';
}
