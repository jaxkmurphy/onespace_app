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
  String welcomeChild(String childName) {
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
  String dayExistingActivityCount(num count, Object day) {
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
}
