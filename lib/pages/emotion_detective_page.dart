import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_icon_catalog.dart';
import '../l10n/l10n.dart';
import '../l10n/learning_game_localizations.dart';
import '../models/child_profile.dart';
import '../models/emotion_detective_models.dart';
import '../services/firestore_service.dart';
import '../widgets/media_asset_picker_dialog.dart';

enum _CaseStep { feeling, bodyClue, helpfulAction }

class EmotionDetectivePage extends StatefulWidget {
  final ChildProfile profile;
  final FirestoreService firestoreService;

  const EmotionDetectivePage({
    super.key,
    required this.profile,
    required this.firestoreService,
  });

  @override
  State<EmotionDetectivePage> createState() => _EmotionDetectivePageState();
}

class _EmotionDetectivePageState extends State<EmotionDetectivePage> {
  final Random _random = Random();

  List<EmotionDetectivePack> _packs = [];
  EmotionDetectivePack? _selectedPack;
  List<_PlayableEmotionCase> _cases = [];
  int _caseIndex = 0;
  _CaseStep _step = _CaseStep.feeling;
  int? _selectedIndex;
  bool _answered = false;
  bool _loadingPacks = true;
  bool _loadingCases = false;
  bool _hasLoadError = false;
  int _score = 0;

  _PlayableEmotionCase? get _currentCase {
    if (_cases.isEmpty || _caseIndex >= _cases.length) return null;
    return _cases[_caseIndex];
  }

  bool get _complete => _cases.isNotEmpty && _caseIndex >= _cases.length;
  LearningGameLocalizations get _text => LearningGameLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _loadPacks();
  }

  Future<void> _loadPacks() async {
    setState(() {
      _loadingPacks = true;
      _hasLoadError = false;
    });

    try {
      final packs =
          await widget.firestoreService
              .getCurrentAssignedEmotionDetectivePacks(
                childId: widget.profile.id,
              )
              .first;

      final activePacks = packs.where((pack) => pack.active).toList();

      if (!mounted) return;

      setState(() {
        _packs = activePacks.isEmpty ? [_defaultPack()] : activePacks;
        _loadingPacks = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _packs = [_defaultPack()];
        _loadingPacks = false;
        _hasLoadError = true;
      });
    }
  }

  Future<void> _selectPack(EmotionDetectivePack pack) async {
    setState(() {
      _selectedPack = pack;
      _cases = [];
      _caseIndex = 0;
      _step = _CaseStep.feeling;
      _selectedIndex = null;
      _answered = false;
      _score = 0;
      _loadingCases = true;
    });

    try {
      final scenarios =
          pack.id == 'default'
              ? _defaultScenarios()
              : await widget.firestoreService
                  .getCurrentEmotionDetectiveScenarios(pack.id)
                  .first;

      final playableCases =
          scenarios
              .where((scenario) => scenario.isPlayable)
              .map(_toPlayableCase)
              .toList()
            ..shuffle(_random);

      if (!mounted) return;

      if (playableCases.isEmpty) {
        setState(() {
          _selectedPack = null;
          _loadingCases = false;
        });
        _showMessage(_text.noPlayableScenarios);
        return;
      }

      setState(() {
        _cases = playableCases.take(8).toList();
        _loadingCases = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _selectedPack = null;
        _loadingCases = false;
      });
      _showMessage(_text.couldNotLoadPack);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  EmotionDetectivePack _defaultPack() {
    return EmotionDetectivePack(
      id: 'default',
      title: _text.starterFeelings,
      description: _text.solveSocialCases,
      iconName: 'mood_smile',
      active: true,
      availableToAll: true,
      assignedChildIds: const [],
      createdByStaffId: '',
      createdByStaffName: '',
    );
  }

  List<EmotionDetectiveScenario> _defaultScenarios() {
    return const [
      EmotionDetectiveScenario(
        id: 'lost-toy',
        prompt: 'A child cannot find their favourite toy.',
        iconName: 'horse_toy',
        feelingChoices: [
          EmotionChoice(label: 'Happy', iconName: 'mood_smile'),
          EmotionChoice(label: 'Sad', iconName: 'mood_sad'),
          EmotionChoice(label: 'Excited', iconName: 'sparkles'),
          EmotionChoice(label: 'Sleepy', iconName: 'moon'),
        ],
        correctFeelingIndex: 1,
        bodyClueChoices: [
          EmotionChoice(label: 'Looking down', iconName: 'eye'),
          EmotionChoice(label: 'Big smile', iconName: 'mood_smile'),
          EmotionChoice(label: 'Jumping', iconName: 'run'),
          EmotionChoice(label: 'Yawning', iconName: 'bed'),
        ],
        correctBodyClueIndex: 0,
        helpfulActionChoices: [
          EmotionChoice(label: 'Help them look', iconName: 'eye'),
          EmotionChoice(label: 'Laugh loudly', iconName: 'mood_smile'),
          EmotionChoice(label: 'Hide another toy', iconName: 'building_blocks'),
          EmotionChoice(label: 'Walk away', iconName: 'walk'),
        ],
        correctHelpfulActionIndex: 0,
        explanation:
            'They might feel sad because something important is missing. Helping them look could make things feel easier.',
        sortOrder: 0,
      ),
      EmotionDetectiveScenario(
        id: 'loud-noise',
        prompt: 'There is a sudden loud noise in the room.',
        iconName: 'speakerphone',
        feelingChoices: [
          EmotionChoice(label: 'Scared', iconName: 'mood_sad'),
          EmotionChoice(label: 'Proud', iconName: 'award'),
          EmotionChoice(label: 'Calm', iconName: 'leaf'),
          EmotionChoice(label: 'Silly', iconName: 'mood_wink'),
        ],
        correctFeelingIndex: 0,
        bodyClueChoices: [
          EmotionChoice(label: 'Covering ears', iconName: 'ear'),
          EmotionChoice(label: 'Thumbs up', iconName: 'hand_love_you'),
          EmotionChoice(label: 'Sleeping', iconName: 'bed'),
          EmotionChoice(label: 'Dancing', iconName: 'music'),
        ],
        correctBodyClueIndex: 0,
        helpfulActionChoices: [
          EmotionChoice(label: 'Use headphones', iconName: 'headphones'),
          EmotionChoice(label: 'Make more noise', iconName: 'speakerphone'),
          EmotionChoice(label: 'Point and laugh', iconName: 'hand_finger'),
          EmotionChoice(label: 'Take their chair', iconName: 'building_blocks'),
        ],
        correctHelpfulActionIndex: 0,
        explanation:
            'A loud sound can surprise someone. A quieter space or headphones can help.',
        sortOrder: 1,
      ),
      EmotionDetectiveScenario(
        id: 'finished-work',
        prompt: 'A child finishes a tricky piece of work.',
        iconName: 'clipboard_check',
        feelingChoices: [
          EmotionChoice(label: 'Sleepy', iconName: 'moon'),
          EmotionChoice(label: 'Scared', iconName: 'mood_sad'),
          EmotionChoice(label: 'Angry', iconName: 'mood_angry'),
          EmotionChoice(label: 'Proud', iconName: 'award'),
        ],
        correctFeelingIndex: 3,
        bodyClueChoices: [
          EmotionChoice(label: 'Smiling tall', iconName: 'mood_smile'),
          EmotionChoice(label: 'Hiding face', iconName: 'eye'),
          EmotionChoice(label: 'Throwing paper', iconName: 'basket'),
          EmotionChoice(label: 'Falling asleep', iconName: 'bed'),
        ],
        correctBodyClueIndex: 0,
        helpfulActionChoices: [
          EmotionChoice(label: 'Celebrate kindly', iconName: 'sparkles'),
          EmotionChoice(label: 'Rip the work', iconName: 'basket'),
          EmotionChoice(label: 'Say it was easy', iconName: 'speakerphone'),
          EmotionChoice(label: 'Ignore them', iconName: 'eye'),
        ],
        correctHelpfulActionIndex: 0,
        explanation:
            'Finishing something hard can feel proud. A kind celebration can help them feel seen.',
        sortOrder: 2,
      ),
    ];
  }

  _PlayableEmotionCase _toPlayableCase(EmotionDetectiveScenario scenario) {
    return _PlayableEmotionCase(
      source: scenario,
      feeling: _shuffleChoiceSet(
        choices: scenario.feelingChoices,
        correctIndex: scenario.correctFeelingIndex,
      ),
      bodyClue: _shuffleChoiceSet(
        choices: scenario.bodyClueChoices,
        correctIndex: scenario.correctBodyClueIndex,
      ),
      helpfulAction: _shuffleChoiceSet(
        choices: scenario.helpfulActionChoices,
        correctIndex: scenario.correctHelpfulActionIndex,
      ),
    );
  }

  _PlayableChoiceSet _shuffleChoiceSet({
    required List<EmotionChoice> choices,
    required int correctIndex,
  }) {
    final correctChoice = choices[correctIndex];
    final shuffledChoices = List<EmotionChoice>.from(choices)..shuffle(_random);
    final shuffledCorrectIndex = shuffledChoices.indexWhere(
      (choice) =>
          choice.label == correctChoice.label &&
          choice.iconName == correctChoice.iconName,
    );

    return _PlayableChoiceSet(
      choices: shuffledChoices,
      correctIndex: shuffledCorrectIndex < 0 ? 0 : shuffledCorrectIndex,
    );
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    final currentSet = _currentChoiceSet;
    if (currentSet == null) return;

    final correct = index == currentSet.correctIndex;

    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (correct) _score++;
    });
  }

  void _nextStep() {
    setState(() {
      _selectedIndex = null;
      _answered = false;

      switch (_step) {
        case _CaseStep.feeling:
          _step = _CaseStep.bodyClue;
        case _CaseStep.bodyClue:
          _step = _CaseStep.helpfulAction;
        case _CaseStep.helpfulAction:
          _caseIndex++;
          _step = _CaseStep.feeling;
      }
    });
  }

  void _restart() {
    final shuffled =
        _cases.map((item) => _toPlayableCase(item.source)).toList()
          ..shuffle(_random);

    setState(() {
      _cases = shuffled;
      _caseIndex = 0;
      _step = _CaseStep.feeling;
      _selectedIndex = null;
      _answered = false;
      _score = 0;
    });
  }

  void _chooseAnotherPack() {
    setState(() {
      _selectedPack = null;
      _cases = [];
      _caseIndex = 0;
      _step = _CaseStep.feeling;
      _selectedIndex = null;
      _answered = false;
      _score = 0;
    });
  }

  _PlayableChoiceSet? get _currentChoiceSet {
    final currentCase = _currentCase;
    if (currentCase == null) return null;

    return switch (_step) {
      _CaseStep.feeling => currentCase.feeling,
      _CaseStep.bodyClue => currentCase.bodyClue,
      _CaseStep.helpfulAction => currentCase.helpfulAction,
    };
  }

  String get _stepQuestion {
    return switch (_step) {
      _CaseStep.feeling => _text.whatMightTheyFeel,
      _CaseStep.bodyClue => _text.whatClueMightShow,
      _CaseStep.helpfulAction => _text.whatCouldHelp,
    };
  }

  IconData get _stepIcon {
    return switch (_step) {
      _CaseStep.feeling => Icons.favorite_rounded,
      _CaseStep.bodyClue => Icons.visibility_rounded,
      _CaseStep.helpfulAction => Icons.volunteer_activism_rounded,
    };
  }

  int get _stepNumber {
    return switch (_step) {
      _CaseStep.feeling => 1,
      _CaseStep.bodyClue => 2,
      _CaseStep.helpfulAction => 3,
    };
  }

  int get _totalSteps => _cases.length * 3;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFEC6F91);

    return Scaffold(
      appBar: AppBar(title: Text(_text.emotionDetective)),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF3F7), Color(0xFFEFFFFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child:
              _loadingPacks || _loadingCases
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedPack == null
                  ? _buildPackPicker(color)
                  : _complete
                  ? _buildComplete(color)
                  : _buildGame(color),
        ),
      ),
    );
  }

  Widget _buildPackPicker(Color color) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, const Color(0xFF7E57C2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.manage_search_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _text.choosePack,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _text.solveSocialCases,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_hasLoadError) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              _text.usingStarterScenarios,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
        const SizedBox(height: 18),
        ..._packs.map(
          (pack) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _PackChoiceCard(
              pack: pack,
              color: color,
              onTap: () => _selectPack(pack),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGame(Color color) {
    final currentCase = _currentCase;
    final currentSet = _currentChoiceSet;
    final pack = _selectedPack;

    if (currentCase == null || currentSet == null || pack == null) {
      return _buildComplete(color);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
      children: [
        _buildHeader(color, pack),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              if (currentCase.source.iconName.trim().isNotEmpty) ...[
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      isMediaVisualValue(currentCase.source.iconName)
                          ? MediaImagePreview(
                            value: currentCase.source.iconName,
                            size: 88,
                            borderRadius: BorderRadius.circular(30),
                          )
                          : Icon(
                            appIconForKey(
                              currentCase.source.iconName,
                              fallbackKey: 'mood_smile',
                            ),
                            color: color,
                            size: 48,
                          ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                currentCase.source.prompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_stepIcon, color: color),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _stepQuestion,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, constraints) {
                  final twoColumns = constraints.maxWidth >= 520;
                  final cardWidth =
                      twoColumns
                          ? (constraints.maxWidth - 14) / 2
                          : constraints.maxWidth;

                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: List.generate(currentSet.choices.length, (index) {
                      return SizedBox(
                        width: cardWidth,
                        child: _EmotionChoiceCard(
                          choice: currentSet.choices[index],
                          selected: _selectedIndex == index,
                          correct: index == currentSet.correctIndex,
                          reveal: _answered,
                          onTap: () => _selectAnswer(index),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (_answered) _buildFeedback(color, currentCase, currentSet),
      ],
    );
  }

  Widget _buildHeader(Color color, EmotionDetectivePack pack) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, const Color(0xFF7E57C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              appIconForKey(pack.iconName, fallbackKey: 'mood_smile'),
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _text.caseProgress(
                    _caseIndex + 1,
                    _cases.length,
                    _stepNumber,
                    _score,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: _text.choosePack,
            onPressed: _chooseAnotherPack,
            icon: const Icon(Icons.grid_view_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback(
    Color color,
    _PlayableEmotionCase currentCase,
    _PlayableChoiceSet currentSet,
  ) {
    final correct = _selectedIndex == currentSet.correctIndex;
    final answer = currentSet.choices[currentSet.correctIndex].label;
    final explanation = currentCase.source.explanation.trim();
    final isFinalStep =
        _caseIndex == _cases.length - 1 && _step == _CaseStep.helpfulAction;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: correct ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: correct ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            correct ? Icons.favorite_rounded : Icons.lightbulb_rounded,
            color: correct ? Colors.green.shade700 : Colors.orange.shade800,
            size: 44,
          ),
          const SizedBox(height: 8),
          Text(
            correct ? _text.thatMakesSense : _text.goodThinking,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: correct ? Colors.green.shade800 : Colors.orange.shade900,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            correct
                ? _text.answerFits(answer)
                : _text.anotherAnswerCouldBe(answer),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          if (_step == _CaseStep.helpfulAction && explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              explanation,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _nextStep,
              style: FilledButton.styleFrom(backgroundColor: color),
              icon: Icon(
                isFinalStep
                    ? Icons.emoji_events_rounded
                    : Icons.arrow_forward_rounded,
              ),
              label: Text(isFinalStep ? _text.finish : context.l10n.next),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplete(Color color) {
    final pack = _selectedPack;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(Icons.emoji_events_rounded, color: color, size: 76),
              const SizedBox(height: 14),
              Text(
                _text.caseSolved,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (pack != null) ...[
                const SizedBox(height: 6),
                Text(
                  pack.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                _text.solvedClues(_score, _totalSteps),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _restart,
                  style: FilledButton.styleFrom(backgroundColor: color),
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(_text.playAgain),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _chooseAnotherPack,
                  icon: const Icon(Icons.grid_view_rounded),
                  label: Text(_text.chooseAnotherPack),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(_text.back),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackChoiceCard extends StatelessWidget {
  final EmotionDetectivePack pack;
  final Color color;
  final VoidCallback onTap;

  const _PackChoiceCard({
    required this.pack,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final description = pack.description.trim();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: color.withValues(alpha: 0.18), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  appIconForKey(pack.iconName, fallbackKey: 'mood_smile'),
                  color: color,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.play_circle_fill_rounded, color: color, size: 42),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmotionChoiceCard extends StatelessWidget {
  final EmotionChoice choice;
  final bool selected;
  final bool correct;
  final bool reveal;
  final VoidCallback onTap;

  const _EmotionChoiceCard({
    required this.choice,
    required this.selected,
    required this.correct,
    required this.reveal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var borderColor = Colors.grey.shade300;
    var backgroundColor = Colors.white;
    var iconColor = const Color(0xFFEC6F91);

    if (reveal && correct) {
      borderColor = Colors.green.shade600;
      backgroundColor = Colors.green.shade50;
      iconColor = Colors.green.shade700;
    } else if (reveal && selected && !correct) {
      borderColor = Colors.orange.shade700;
      backgroundColor = Colors.orange.shade50;
      iconColor = Colors.orange.shade800;
    } else if (selected) {
      borderColor = const Color(0xFFEC6F91);
      backgroundColor = const Color(0xFFEC6F91).withValues(alpha: 0.08);
    }

    return Semantics(
      button: !reveal,
      selected: selected,
      label: choice.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: reveal ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          constraints: const BoxConstraints(minHeight: 164),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: borderColor,
              width: selected || (reveal && correct) ? 3 : 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (choice.iconName.trim().isNotEmpty) ...[
                if (isMediaVisualValue(choice.iconName))
                  MediaImagePreview(value: choice.iconName, size: 72)
                else
                  Icon(
                    appIconForKey(choice.iconName, fallbackKey: 'mood_smile'),
                    color: iconColor,
                    size: 58,
                  ),
                const SizedBox(height: 12),
              ],
              Text(
                choice.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (reveal && (correct || selected)) ...[
                const SizedBox(height: 8),
                Icon(
                  correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: borderColor,
                  size: 26,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayableEmotionCase {
  final EmotionDetectiveScenario source;
  final _PlayableChoiceSet feeling;
  final _PlayableChoiceSet bodyClue;
  final _PlayableChoiceSet helpfulAction;

  const _PlayableEmotionCase({
    required this.source,
    required this.feeling,
    required this.bodyClue,
    required this.helpfulAction,
  });
}

class _PlayableChoiceSet {
  final List<EmotionChoice> choices;
  final int correctIndex;

  const _PlayableChoiceSet({required this.choices, required this.correctIndex});
}
