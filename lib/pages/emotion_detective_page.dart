import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_icon_catalog.dart';
import '../l10n/l10n.dart';
import '../l10n/learning_game_localizations.dart';
import '../models/child_profile.dart';
import '../models/emotion_detective_models.dart';
import '../services/firestore_service.dart';

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
  List<_PlayableEmotionScenario> _scenarios = [];
  int _scenarioIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _loadingPacks = true;
  bool _loadingScenarios = false;
  bool _hasLoadError = false;
  int _score = 0;

  _PlayableEmotionScenario? get _currentScenario {
    if (_scenarios.isEmpty || _scenarioIndex >= _scenarios.length) {
      return null;
    }

    return _scenarios[_scenarioIndex];
  }

  bool get _complete =>
      _scenarios.isNotEmpty && _scenarioIndex >= _scenarios.length;
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
      _scenarios = [];
      _scenarioIndex = 0;
      _selectedIndex = null;
      _answered = false;
      _score = 0;
      _loadingScenarios = true;
    });

    try {
      final scenarios =
          pack.id == 'default'
              ? _defaultScenarios()
              : await widget.firestoreService
                  .getCurrentEmotionDetectiveScenarios(pack.id)
                  .first;

      final playableScenarios =
          scenarios
              .where(
                (scenario) =>
                    scenario.prompt.trim().isNotEmpty &&
                    scenario.choices.length == 4 &&
                    scenario.correctIndex >= 0 &&
                    scenario.correctIndex < scenario.choices.length,
              )
              .map(_shuffleScenarioChoices)
              .toList()
            ..shuffle(_random);

      if (!mounted) return;

      if (playableScenarios.isEmpty) {
        setState(() {
          _selectedPack = null;
          _loadingScenarios = false;
        });
        _showMessage(_text.noPlayableScenarios);
        return;
      }

      setState(() {
        _scenarios = playableScenarios.take(12).toList();
        _loadingScenarios = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _selectedPack = null;
        _loadingScenarios = false;
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
      description: _text.thinkAboutFeelings,
      iconName: 'mood_smile',
      active: true,
      availableToAll: true,
      assignedChildIds: [],
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
        correctIndex: 1,
        explanation:
            'They might feel sad because something important to them is missing.',
        sortOrder: 0,
        choices: [
          EmotionChoice(label: 'Happy', iconName: 'mood_smile'),
          EmotionChoice(label: 'Sad', iconName: 'mood_sad'),
          EmotionChoice(label: 'Excited', iconName: 'sparkles'),
          EmotionChoice(label: 'Sleepy', iconName: 'zzz'),
        ],
      ),
      EmotionDetectiveScenario(
        id: 'birthday-surprise',
        prompt: 'Someone gets a surprise birthday cake.',
        iconName: 'cake',
        correctIndex: 2,
        explanation:
            'They might feel excited because something special happened.',
        sortOrder: 1,
        choices: [
          EmotionChoice(label: 'Angry', iconName: 'mood_angry'),
          EmotionChoice(label: 'Worried', iconName: 'mood_worried'),
          EmotionChoice(label: 'Excited', iconName: 'sparkles'),
          EmotionChoice(label: 'Tired', iconName: 'moon'),
        ],
      ),
      EmotionDetectiveScenario(
        id: 'loud-noise',
        prompt: 'There is a sudden loud noise in the room.',
        iconName: 'volume',
        correctIndex: 0,
        explanation:
            'They might feel scared or worried because loud noises can surprise us.',
        sortOrder: 2,
        choices: [
          EmotionChoice(label: 'Scared', iconName: 'mood_sad'),
          EmotionChoice(label: 'Proud', iconName: 'award'),
          EmotionChoice(label: 'Calm', iconName: 'leaf'),
          EmotionChoice(label: 'Happy', iconName: 'mood_smile'),
        ],
      ),
      EmotionDetectiveScenario(
        id: 'finished-work',
        prompt: 'A child finishes a tricky piece of work.',
        iconName: 'clipboard_check',
        correctIndex: 3,
        explanation:
            'They might feel proud because they kept going and finished it.',
        sortOrder: 3,
        choices: [
          EmotionChoice(label: 'Sleepy', iconName: 'zzz'),
          EmotionChoice(label: 'Scared', iconName: 'mood_sad'),
          EmotionChoice(label: 'Angry', iconName: 'mood_angry'),
          EmotionChoice(label: 'Proud', iconName: 'award'),
        ],
      ),
    ];
  }

  _PlayableEmotionScenario _shuffleScenarioChoices(
    EmotionDetectiveScenario scenario,
  ) {
    final correctChoice = scenario.choices[scenario.correctIndex];
    final shuffledChoices = List<EmotionChoice>.from(scenario.choices)
      ..shuffle(_random);
    final shuffledCorrectIndex = shuffledChoices.indexWhere(
      (choice) =>
          choice.label == correctChoice.label &&
          choice.iconName == correctChoice.iconName,
    );

    return _PlayableEmotionScenario(
      prompt: scenario.prompt,
      iconName: scenario.iconName,
      choices: shuffledChoices,
      correctIndex: shuffledCorrectIndex < 0 ? 0 : shuffledCorrectIndex,
      explanation: scenario.explanation,
    );
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    final scenario = _currentScenario;
    if (scenario == null) return;

    final correct = index == scenario.correctIndex;

    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (correct) _score++;
    });
  }

  void _nextScenario() {
    setState(() {
      _scenarioIndex++;
      _selectedIndex = null;
      _answered = false;
    });
  }

  void _restart() {
    final shuffled =
        _scenarios
            .map((scenario) => scenario.toSourceScenario())
            .map(_shuffleScenarioChoices)
            .toList()
          ..shuffle(_random);

    setState(() {
      _scenarios = shuffled;
      _scenarioIndex = 0;
      _selectedIndex = null;
      _answered = false;
      _score = 0;
    });
  }

  void _chooseAnotherPack() {
    setState(() {
      _selectedPack = null;
      _scenarios = [];
      _scenarioIndex = 0;
      _selectedIndex = null;
      _answered = false;
      _score = 0;
    });
  }

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
              _loadingPacks || _loadingScenarios
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _text.thinkAboutFeelings,
                      style: TextStyle(
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
              style: TextStyle(fontWeight: FontWeight.w700),
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
    final scenario = _currentScenario;
    final pack = _selectedPack;

    if (scenario == null || pack == null) {
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
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  appIconForKey(scenario.iconName, fallbackKey: 'mood_smile'),
                  color: color,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                scenario.prompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _text.thinkAboutFeelings,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w700,
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
                    children: List.generate(scenario.choices.length, (index) {
                      return SizedBox(
                        width: cardWidth,
                        child: _EmotionChoiceCard(
                          choice: scenario.choices[index],
                          selected: _selectedIndex == index,
                          correct: index == scenario.correctIndex,
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
        if (_answered) _buildFeedback(color, scenario),
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
                  _text.scenarioProgress(
                    _scenarioIndex + 1,
                    _scenarios.length,
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

  Widget _buildFeedback(Color color, _PlayableEmotionScenario scenario) {
    final correct = _selectedIndex == scenario.correctIndex;
    final answer = scenario.choices[scenario.correctIndex].label;
    final explanation = scenario.explanation.trim();

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
                ? '$answer fits this situation.'
                : 'Another feeling could be $answer.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          if (explanation.isNotEmpty) ...[
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
              onPressed: _nextScenario,
              style: FilledButton.styleFrom(backgroundColor: color),
              icon: Icon(
                _scenarioIndex == _scenarios.length - 1
                    ? Icons.emoji_events_rounded
                    : Icons.arrow_forward_rounded,
              ),
              label: Text(
                _scenarioIndex == _scenarios.length - 1
                    ? _text.finish
                    : context.l10n.next,
              ),
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
                _text.detectiveComplete,
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
                'You matched $_score out of ${_scenarios.length} feelings.',
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
              Icon(
                appIconForKey(choice.iconName, fallbackKey: 'mood_smile'),
                color: iconColor,
                size: 58,
              ),
              const SizedBox(height: 12),
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

class _PlayableEmotionScenario {
  final String prompt;
  final String iconName;
  final List<EmotionChoice> choices;
  final int correctIndex;
  final String explanation;

  const _PlayableEmotionScenario({
    required this.prompt,
    required this.iconName,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
  });

  EmotionDetectiveScenario toSourceScenario() {
    return EmotionDetectiveScenario(
      id: '',
      prompt: prompt,
      iconName: iconName,
      choices: choices,
      correctIndex: correctIndex,
      explanation: explanation,
      sortOrder: 0,
    );
  }
}
