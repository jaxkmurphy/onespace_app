enum ClassroomFeature {
  todayOverview('todayOverview'),
  schedules('schedules'),
  zones('zones'),
  points('points'),
  whenThen('whenThen'),
  visualTimer('visualTimer'),
  bodyCheck('bodyCheck'),
  circleTime('circleTime'),
  quizzes('quizzes'),
  associationPairs('associationPairs'),
  numberSequence('numberSequence'),
  oddOneOut('oddOneOut'),
  emotionDetective('emotionDetective'),
  wordLearning('wordLearning'),
  incidentLog('incidentLog'),
  handover('handover'),
  iconReset('iconReset'),
  calmingSounds('calmingSounds'),
  voiceLines('voiceLines'),
  backgroundPicker('backgroundPicker');

  final String key;

  const ClassroomFeature(this.key);

  static ClassroomFeature? fromKey(String key) {
    for (final feature in ClassroomFeature.values) {
      if (feature.key == key) return feature;
    }

    return null;
  }

  static Set<ClassroomFeature> allEnabled() {
    return ClassroomFeature.values.toSet();
  }

  static Set<ClassroomFeature> fromFirestoreValue(dynamic value) {
    if (value == null) {
      return allEnabled();
    }

    if (value is! List) {
      return allEnabled();
    }

    final features = <ClassroomFeature>{};

    for (final item in value) {
      final feature = ClassroomFeature.fromKey(item.toString());
      if (feature != null) {
        features.add(feature);
      }
    }

    return features;
  }

  static List<String> toFirestoreValue(Set<ClassroomFeature> features) {
    return features.map((feature) => feature.key).toList()..sort();
  }
}

extension ClassroomFeatureLabels on ClassroomFeature {
  String get adminLabel {
    switch (this) {
      case ClassroomFeature.todayOverview:
        return 'Today Overview';
      case ClassroomFeature.schedules:
        return 'Schedules';
      case ClassroomFeature.zones:
        return 'Zones';
      case ClassroomFeature.points:
        return 'Points';
      case ClassroomFeature.whenThen:
        return 'When-Then';
      case ClassroomFeature.visualTimer:
        return 'Visual Timer';
      case ClassroomFeature.bodyCheck:
        return 'Body Check';
      case ClassroomFeature.circleTime:
        return 'Circle Time';
      case ClassroomFeature.quizzes:
        return 'Quizzes';
      case ClassroomFeature.associationPairs:
        return 'Association Pairs';
      case ClassroomFeature.numberSequence:
        return 'Number Sequence';
      case ClassroomFeature.oddOneOut:
        return 'Odd One Out';
      case ClassroomFeature.emotionDetective:
        return 'Emotion Detective';
      case ClassroomFeature.wordLearning:
        return 'Word Learning';
      case ClassroomFeature.incidentLog:
        return 'Incident Log';
      case ClassroomFeature.handover:
        return 'Handover';
      case ClassroomFeature.iconReset:
        return 'Icon Reset';
      case ClassroomFeature.calmingSounds:
        return 'Calming Sounds';
      case ClassroomFeature.voiceLines:
        return 'Voice Lines';
      case ClassroomFeature.backgroundPicker:
        return 'Background Picker';
    }
  }

  String get adminDescription {
    switch (this) {
      case ClassroomFeature.todayOverview:
        return 'Staff daily overview of classroom activity.';
      case ClassroomFeature.schedules:
        return 'Staff and child schedule tools.';
      case ClassroomFeature.zones:
        return 'Zones of regulation tools.';
      case ClassroomFeature.points:
        return 'Classroom and child points/rewards.';
      case ClassroomFeature.whenThen:
        return 'When-Then boards for children.';
      case ClassroomFeature.visualTimer:
        return 'Shared visual timer.';
      case ClassroomFeature.bodyCheck:
        return 'Child body check and staff reports.';
      case ClassroomFeature.circleTime:
        return 'Circle Time classroom view.';
      case ClassroomFeature.quizzes:
        return 'Quiz creation and child quiz access.';
      case ClassroomFeature.associationPairs:
        return 'Child association matching game.';
      case ClassroomFeature.numberSequence:
        return 'Child number ordering and hand-eye coordination game.';
      case ClassroomFeature.oddOneOut:
        return 'Child odd-one-out reasoning game.';
      case ClassroomFeature.emotionDetective:
        return 'Child emotional reasoning and feelings game.';
      case ClassroomFeature.wordLearning:
        return 'Word learning and practice.';
      case ClassroomFeature.incidentLog:
        return 'Staff incident logging.';
      case ClassroomFeature.handover:
        return 'Staff handover tools.';
      case ClassroomFeature.iconReset:
        return 'Staff icon sequence reset tool.';
      case ClassroomFeature.calmingSounds:
        return 'Child calming sounds.';
      case ClassroomFeature.voiceLines:
        return 'Child voice lines.';
      case ClassroomFeature.backgroundPicker:
        return 'Child background colour picker.';
    }
  }
}
