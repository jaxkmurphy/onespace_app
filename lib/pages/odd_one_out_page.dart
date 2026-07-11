import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_icon_catalog.dart';
import '../l10n/l10n.dart';
import '../l10n/learning_game_localizations.dart';
import '../models/child_profile.dart';
import '../models/odd_one_out_models.dart';
import '../services/firestore_service.dart';
import '../widgets/media_asset_picker_dialog.dart';

class OddOneOutPage extends StatefulWidget {
  final ChildProfile profile;
  final FirestoreService firestoreService;

  const OddOneOutPage({
    super.key,
    required this.profile,
    required this.firestoreService,
  });

  @override
  State<OddOneOutPage> createState() => _OddOneOutPageState();
}

class _OddOneOutPageState extends State<OddOneOutPage> {
  final Random _random = Random();

  List<OddOneOutPack> _packs = [];
  OddOneOutPack? _selectedPack;
  List<_PlayableOddOneOutRound> _rounds = [];
  int _roundIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _loadingPacks = true;
  bool _loadingRounds = false;
  bool _hasLoadError = false;
  int _score = 0;

  _PlayableOddOneOutRound? get _currentRound {
    if (_rounds.isEmpty || _roundIndex >= _rounds.length) return null;
    return _rounds[_roundIndex];
  }

  bool get _complete => _rounds.isNotEmpty && _roundIndex >= _rounds.length;
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
              .getCurrentAssignedOddOneOutPacks(childId: widget.profile.id)
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

  Future<void> _selectPack(OddOneOutPack pack) async {
    setState(() {
      _selectedPack = pack;
      _rounds = [];
      _roundIndex = 0;
      _selectedIndex = null;
      _answered = false;
      _score = 0;
      _loadingRounds = true;
    });

    try {
      final rounds =
          pack.id == 'default'
              ? _defaultRounds()
              : await widget.firestoreService
                  .getCurrentOddOneOutRounds(pack.id)
                  .first;

      final playableRounds =
          rounds
              .where(
                (round) =>
                    round.items.length == 4 &&
                    round.oddIndex >= 0 &&
                    round.oddIndex < round.items.length,
              )
              .map(_shuffleRoundChoices)
              .toList()
            ..shuffle(_random);

      if (!mounted) return;

      if (playableRounds.isEmpty) {
        setState(() {
          _selectedPack = null;
          _loadingRounds = false;
        });
        _showMessage(_text.noPlayableRounds);
        return;
      }

      setState(() {
        _rounds = playableRounds.take(12).toList();
        _loadingRounds = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _selectedPack = null;
        _loadingRounds = false;
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

  OddOneOutPack _defaultPack() {
    return OddOneOutPack(
      id: 'default',
      title: _text.starterPack,
      description: _text.findOddOne,
      iconName: 'target',
      active: true,
      availableToAll: true,
      assignedChildIds: [],
      createdByStaffId: '',
      createdByStaffName: '',
    );
  }

  List<OddOneOutRound> _defaultRounds() {
    return const [
      OddOneOutRound(
        id: 'animals',
        prompt: 'Which one is not an animal?',
        oddIndex: 3,
        sortOrder: 0,
        items: [
          OddOneOutItem(label: 'Cat', iconName: 'cat'),
          OddOneOutItem(label: 'Dog', iconName: 'dog'),
          OddOneOutItem(label: 'Fish', iconName: 'fish'),
          OddOneOutItem(label: 'Pencil', iconName: 'pencil'),
        ],
      ),
      OddOneOutRound(
        id: 'food',
        prompt: 'Which one is not food?',
        oddIndex: 2,
        sortOrder: 1,
        items: [
          OddOneOutItem(label: 'Apple', iconName: 'apple'),
          OddOneOutItem(label: 'Pizza', iconName: 'pizza'),
          OddOneOutItem(label: 'Bus', iconName: 'bus'),
          OddOneOutItem(label: 'Carrot', iconName: 'carrot'),
        ],
      ),
      OddOneOutRound(
        id: 'weather',
        prompt: 'Which one is not weather?',
        oddIndex: 1,
        sortOrder: 2,
        items: [
          OddOneOutItem(label: 'Sun', iconName: 'sun'),
          OddOneOutItem(label: 'Book', iconName: 'book'),
          OddOneOutItem(label: 'Cloud', iconName: 'cloud'),
          OddOneOutItem(label: 'Rain', iconName: 'droplet'),
        ],
      ),
      OddOneOutRound(
        id: 'play',
        prompt: 'Which one is not for play?',
        oddIndex: 0,
        sortOrder: 3,
        items: [
          OddOneOutItem(label: 'Soup', iconName: 'soup'),
          OddOneOutItem(label: 'Ball', iconName: 'ball_football'),
          OddOneOutItem(label: 'Puzzle', iconName: 'puzzle'),
          OddOneOutItem(label: 'Game', iconName: 'device_gamepad_2'),
        ],
      ),
    ];
  }

  _PlayableOddOneOutRound _shuffleRoundChoices(OddOneOutRound round) {
    final oddItem = round.items[round.oddIndex];
    final shuffledItems = List<OddOneOutItem>.from(round.items)
      ..shuffle(_random);
    final shuffledOddIndex = shuffledItems.indexWhere(
      (item) =>
          item.label == oddItem.label && item.iconName == oddItem.iconName,
    );

    return _PlayableOddOneOutRound(
      prompt: round.prompt,
      items: shuffledItems,
      oddIndex: shuffledOddIndex < 0 ? 0 : shuffledOddIndex,
    );
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    final round = _currentRound;
    if (round == null) return;

    final correct = index == round.oddIndex;

    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (correct) _score++;
    });
  }

  void _nextRound() {
    setState(() {
      _roundIndex++;
      _selectedIndex = null;
      _answered = false;
    });
  }

  void _restart() {
    final shuffled =
        _rounds
            .map((round) => round.toSourceRound())
            .map(_shuffleRoundChoices)
            .toList()
          ..shuffle(_random);

    setState(() {
      _rounds = shuffled;
      _roundIndex = 0;
      _selectedIndex = null;
      _answered = false;
      _score = 0;
    });
  }

  void _chooseAnotherPack() {
    setState(() {
      _selectedPack = null;
      _rounds = [];
      _roundIndex = 0;
      _selectedIndex = null;
      _answered = false;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF7E57C2);

    return Scaffold(
      appBar: AppBar(title: Text(_text.oddOneOut)),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F3FF), Color(0xFFEFFFFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child:
              _loadingPacks || _loadingRounds
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
              colors: [color, const Color(0xFF26A69A)],
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
                  Icons.psychology_alt_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose a pack',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pick one set of odd-one-out rounds to play.',
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
              _text.usingStarterRounds,
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
    final round = _currentRound;
    final pack = _selectedPack;

    if (round == null || pack == null) {
      return _buildComplete(color);
    }

    final prompt =
        round.prompt.trim().isEmpty ? _text.findOddOne : round.prompt.trim();

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
              Text(
                prompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _text.findOddOne,
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
                    children: List.generate(round.items.length, (index) {
                      return SizedBox(
                        width: cardWidth,
                        child: _OddChoiceCard(
                          item: round.items[index],
                          selected: _selectedIndex == index,
                          correct: index == round.oddIndex,
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
        if (_answered) _buildFeedback(color, round),
      ],
    );
  }

  Widget _buildHeader(Color color, OddOneOutPack pack) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, const Color(0xFF26A69A)],
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
              appIconForKey(pack.iconName, fallbackKey: 'target'),
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
                  _text.roundProgress(_roundIndex + 1, _rounds.length, _score),
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

  Widget _buildFeedback(Color color, _PlayableOddOneOutRound round) {
    final correct = _selectedIndex == round.oddIndex;

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
            correct ? Icons.celebration_rounded : Icons.lightbulb_rounded,
            color: correct ? Colors.green.shade700 : Colors.orange.shade800,
            size: 44,
          ),
          const SizedBox(height: 8),
          Text(
            correct ? _text.greatChoice : _text.goodTry,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: correct ? Colors.green.shade800 : Colors.orange.shade900,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _text.correctOddWas(round.items[round.oddIndex].label),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _nextRound,
              style: FilledButton.styleFrom(backgroundColor: color),
              icon: Icon(
                _roundIndex == _rounds.length - 1
                    ? Icons.emoji_events_rounded
                    : Icons.arrow_forward_rounded,
              ),
              label: Text(
                _roundIndex == _rounds.length - 1
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
                _text.gameComplete,
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
                'You found $_score out of ${_rounds.length} odd ones.',
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
  final OddOneOutPack pack;
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
                  appIconForKey(pack.iconName, fallbackKey: 'target'),
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

class _OddChoiceCard extends StatelessWidget {
  final OddOneOutItem item;
  final bool selected;
  final bool correct;
  final bool reveal;
  final VoidCallback onTap;

  const _OddChoiceCard({
    required this.item,
    required this.selected,
    required this.correct,
    required this.reveal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var borderColor = Colors.grey.shade300;
    var backgroundColor = Colors.white;
    var iconColor = const Color(0xFF7E57C2);

    if (reveal && correct) {
      borderColor = Colors.green.shade600;
      backgroundColor = Colors.green.shade50;
      iconColor = Colors.green.shade700;
    } else if (reveal && selected && !correct) {
      borderColor = Colors.orange.shade700;
      backgroundColor = Colors.orange.shade50;
      iconColor = Colors.orange.shade800;
    } else if (selected) {
      borderColor = const Color(0xFF7E57C2);
      backgroundColor = const Color(0xFF7E57C2).withValues(alpha: 0.08);
    }

    return Semantics(
      button: !reveal,
      selected: selected,
      label: item.label,
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
              if (isMediaVisualValue(item.iconName))
                MediaImagePreview(value: item.iconName, size: 72)
              else
                Icon(appIconForKey(item.iconName), color: iconColor, size: 58),
              const SizedBox(height: 12),
              Text(
                item.label,
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

class _PlayableOddOneOutRound {
  final String prompt;
  final List<OddOneOutItem> items;
  final int oddIndex;

  const _PlayableOddOneOutRound({
    required this.prompt,
    required this.items,
    required this.oddIndex,
  });

  OddOneOutRound toSourceRound() {
    return OddOneOutRound(
      id: '',
      prompt: prompt,
      items: items,
      oddIndex: oddIndex,
      sortOrder: 0,
    );
  }
}
