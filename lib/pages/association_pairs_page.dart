import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/association_pair_packs.dart';
import '../models/association_pair.dart';
import '../models/child_profile.dart';

class AssociationPairsPage extends StatefulWidget {
  final ChildProfile? child;

  const AssociationPairsPage({super.key, this.child});

  @override
  State<AssociationPairsPage> createState() => _AssociationPairsPageState();
}

class _AssociationPairsPageState extends State<AssociationPairsPage> {
  AssociationPairPack _selectedPack = associationPairPacks.first;
  _AssociationDifficulty _difficulty = _AssociationDifficulty.easy;

  late List<_AssociationCard> _cards;

  final Set<String> _matchedCardIds = {};
  final List<String> _selectedCardIds = [];

  bool _isChecking = false;
  int _moves = 0;

  bool get _isIrish => Localizations.localeOf(context).languageCode == 'ga';

  @override
  void initState() {
    super.initState();
    _startGame(pack: _selectedPack, difficulty: _difficulty);
  }

  String _packTitle(AssociationPairPack pack) {
    return _isIrish ? pack.titleGA : pack.titleEN;
  }

  String _packDescription(AssociationPairPack pack) {
    return _isIrish ? pack.descriptionGA : pack.descriptionEN;
  }

  String _itemLabel(AssociationPairItem item) {
    return _isIrish ? item.labelGA : item.labelEN;
  }

  String _difficultyLabel(_AssociationDifficulty difficulty) {
    return switch (difficulty) {
      _AssociationDifficulty.easy => _isIrish ? 'Éasca' : 'Easy',
      _AssociationDifficulty.medium => _isIrish ? 'Meánach' : 'Medium',
      _AssociationDifficulty.hard => _isIrish ? 'Deacair' : 'Hard',
    };
  }

  int _pairCountForDifficulty(
    AssociationPairPack pack,
    _AssociationDifficulty difficulty,
  ) {
    final maxPairs = pack.pairs.length;

    return switch (difficulty) {
      _AssociationDifficulty.easy => min(3, maxPairs),
      _AssociationDifficulty.medium => min(4, maxPairs),
      _AssociationDifficulty.hard => maxPairs,
    };
  }

  List<AssociationPair> _pairsForGame(
    AssociationPairPack pack,
    _AssociationDifficulty difficulty,
  ) {
    final shuffledPairs = [...pack.pairs]..shuffle(Random());
    final count = _pairCountForDifficulty(pack, difficulty);

    return shuffledPairs.take(count).toList();
  }

  void _startGame({
    required AssociationPairPack pack,
    required _AssociationDifficulty difficulty,
  }) {
    final random = Random();
    final pairs = _pairsForGame(pack, difficulty);
    final cards = <_AssociationCard>[];

    for (final pair in pairs) {
      cards.add(
        _AssociationCard(id: '${pair.id}_a', pairId: pair.id, item: pair.first),
      );
      cards.add(
        _AssociationCard(
          id: '${pair.id}_b',
          pairId: pair.id,
          item: pair.second,
        ),
      );
    }

    cards.shuffle(random);

    setState(() {
      _selectedPack = pack;
      _difficulty = difficulty;
      _cards = cards;
      _matchedCardIds.clear();
      _selectedCardIds.clear();
      _isChecking = false;
      _moves = 0;
    });
  }

  Future<void> _onCardTap(_AssociationCard card) async {
    if (_isChecking) return;
    if (_matchedCardIds.contains(card.id)) return;
    if (_selectedCardIds.contains(card.id)) return;
    if (_selectedCardIds.length >= 2) return;

    setState(() {
      _selectedCardIds.add(card.id);
    });

    if (_selectedCardIds.length != 2) return;

    setState(() {
      _moves++;
      _isChecking = true;
    });

    final first = _cards.firstWhere((item) => item.id == _selectedCardIds[0]);
    final second = _cards.firstWhere((item) => item.id == _selectedCardIds[1]);

    if (first.pairId == second.pairId) {
      await Future<void>.delayed(const Duration(milliseconds: 420));

      if (!mounted) return;

      setState(() {
        _matchedCardIds.add(first.id);
        _matchedCardIds.add(second.id);
        _selectedCardIds.clear();
        _isChecking = false;
      });

      if (_matchedCardIds.length == _cards.length) {
        _showWinDialog();
      }

      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 850));

    if (!mounted) return;

    setState(() {
      _selectedCardIds.clear();
      _isChecking = false;
    });
  }

  int _starCount() {
    final totalPairs = _cards.length ~/ 2;

    if (_moves <= totalPairs + 1) return 3;
    if (_moves <= totalPairs + 4) return 2;
    return 1;
  }

  Future<void> _showWinDialog() async {
    final stars = _starCount();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFCA28).withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFFFB300),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isIrish ? 'Maith thú!' : 'Great job!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isIrish
                      ? 'Fuair tú na péirí ar fad.'
                      : 'You found all the pairs.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final filled = index < stars;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(
                        filled ? Icons.star_rounded : Icons.star_border_rounded,
                        color: const Color(0xFFFFB300),
                        size: 34,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F4FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _WinStat(
                          label: _isIrish ? 'Iarrachtaí' : 'Moves',
                          value: _moves.toString(),
                          icon: Icons.touch_app_rounded,
                        ),
                      ),
                      Container(width: 1, height: 42, color: Colors.black12),
                      Expanded(
                        child: _WinStat(
                          label: _isIrish ? 'Leibhéal' : 'Level',
                          value: _difficultyLabel(_difficulty),
                          icon: Icons.speed_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _startGame(
                            pack: _selectedPack,
                            difficulty: _difficulty,
                          );
                        },
                        child: Text(_isIrish ? 'Arís' : 'Play again'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text(_isIrish ? 'Críochnaigh' : 'Finish'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isFaceUp(_AssociationCard card) {
    return _selectedCardIds.contains(card.id) ||
        _matchedCardIds.contains(card.id);
  }

  Widget _buildHeader() {
    final childName = widget.child?.name.trim();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7E57C2), Color(0xFFFFB199)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E57C2).withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.extension_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isIrish ? 'Péirí Ceangailte' : 'Association Pairs',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  childName == null || childName.isEmpty
                      ? (_isIrish
                          ? 'Meaitseáil rudaí a théann le chéile.'
                          : 'Match things that go together.')
                      : (_isIrish
                          ? 'Meaitseáil na péirí, $childName.'
                          : 'Match the pairs, $childName.'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isIrish ? 'Roghnaigh pacáiste' : 'Choose a pack',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                associationPairPacks.map((pack) {
                  final selected = pack.id == _selectedPack.id;

                  return ChoiceChip(
                    selected: selected,
                    label: Text(_packTitle(pack)),
                    onSelected:
                        (_) => _startGame(pack: pack, difficulty: _difficulty),
                  );
                }).toList(),
          ),
          const SizedBox(height: 10),
          Text(
            _packDescription(_selectedPack),
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isIrish ? 'Roghnaigh leibhéal' : 'Choose a level',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                _AssociationDifficulty.values.map((difficulty) {
                  final selected = difficulty == _difficulty;
                  final pairCount = _pairCountForDifficulty(
                    _selectedPack,
                    difficulty,
                  );

                  return ChoiceChip(
                    selected: selected,
                    label: Text(
                      '${_difficultyLabel(difficulty)} • $pairCount ${_isIrish ? 'péirí' : 'pairs'}',
                    ),
                    onSelected:
                        (_) => _startGame(
                          pack: _selectedPack,
                          difficulty: difficulty,
                        ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final matchedPairs = _matchedCardIds.length ~/ 2;
    final totalPairs = _cards.length ~/ 2;

    return Row(
      children: [
        Expanded(
          child: _StatPill(
            icon: Icons.check_circle_rounded,
            label: _isIrish ? 'Péirí' : 'Pairs',
            value: '$matchedPairs/$totalPairs',
            color: const Color(0xFF26A69A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatPill(
            icon: Icons.touch_app_rounded,
            label: _isIrish ? 'Iarrachtaí' : 'Moves',
            value: _moves.toString(),
            color: const Color(0xFF7E57C2),
          ),
        ),
      ],
    );
  }

  Widget _buildGameGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 760
                ? 4
                : constraints.maxWidth >= 520
                ? 3
                : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 146,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final card = _cards[index];
            final faceUp = _isFaceUp(card);
            final matched = _matchedCardIds.contains(card.id);

            return _AssociationPairCard(
              card: card,
              faceUp: faceUp,
              matched: matched,
              label: _itemLabel(card.item),
              onTap: () => _onCardTap(card),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: AppBar(
        title: Text(_isIrish ? 'Péirí Ceangailte' : 'Association Pairs'),
        backgroundColor: const Color(0xFFF7F4FF),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: _isIrish ? 'Atosaigh' : 'Restart',
            onPressed:
                () => _startGame(pack: _selectedPack, difficulty: _difficulty),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildPackSelector(),
                    const SizedBox(height: 14),
                    _buildDifficultySelector(),
                    const SizedBox(height: 14),
                    _buildStats(),
                    const SizedBox(height: 16),
                    _buildGameGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AssociationDifficulty { easy, medium, hard }

class _AssociationCard {
  final String id;
  final String pairId;
  final AssociationPairItem item;

  const _AssociationCard({
    required this.id,
    required this.pairId,
    required this.item,
  });
}

class _AssociationPairCard extends StatelessWidget {
  final _AssociationCard card;
  final bool faceUp;
  final bool matched;
  final String label;
  final VoidCallback onTap;

  const _AssociationPairCard({
    required this.card,
    required this.faceUp,
    required this.matched,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = card.item.color;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: faceUp ? null : onTap,
        borderRadius: BorderRadius.circular(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: faceUp ? Colors.white : color.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color:
                  matched
                      ? const Color(0xFF26A69A)
                      : color.withValues(alpha: 0.24),
              width: matched ? 3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: faceUp ? 0.10 : 0.20),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child:
              faceUp
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(card.item.icon, color: color, size: 42),
                      const SizedBox(height: 12),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (matched) ...[
                        const SizedBox(height: 8),
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF26A69A),
                        ),
                      ],
                    ],
                  )
                  : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.question_mark_rounded,
                        color: Colors.white,
                        size: 46,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _WinStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _WinStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF7E57C2)),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
