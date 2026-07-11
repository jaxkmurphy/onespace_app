import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_icon_catalog.dart';
import '../l10n/learning_game_localizations.dart';
import '../models/association_pair_pack_models.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';
import '../widgets/media_asset_picker_dialog.dart';

class AssociationPairsPage extends StatefulWidget {
  final ChildProfile? child;
  final FirestoreService? firestoreService;

  const AssociationPairsPage({super.key, this.child, this.firestoreService});

  @override
  State<AssociationPairsPage> createState() => _AssociationPairsPageState();
}

class _AssociationPairsPageState extends State<AssociationPairsPage> {
  final Random _random = Random();

  List<ManagedAssociationPairPack> _packs = [];
  ManagedAssociationPairPack? _selectedPack;
  List<ManagedAssociationPair> _pairs = [];
  List<_AssociationCard> _cards = [];

  final Set<String> _matchedCardIds = {};
  final List<String> _selectedCardIds = [];

  bool _loadingPacks = true;
  bool _loadingPairs = false;
  bool _hasLoadError = false;
  bool _isChecking = false;
  int _moves = 0;

  bool get _isIrish => Localizations.localeOf(context).languageCode == 'ga';
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
      final service = widget.firestoreService;
      final child = widget.child;

      if (service == null || child == null) {
        setState(() {
          _packs = [_starterPack()];
          _loadingPacks = false;
        });
        return;
      }

      final packs =
          await service
              .getCurrentAssignedAssociationPairPacks(childId: child.id)
              .first;
      final activePacks = packs.where((pack) => pack.active).toList();

      if (!mounted) return;

      setState(() {
        _packs = activePacks.isEmpty ? [_starterPack()] : activePacks;
        _loadingPacks = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _packs = [_starterPack()];
        _loadingPacks = false;
        _hasLoadError = true;
      });
    }
  }

  Future<void> _selectPack(ManagedAssociationPairPack pack) async {
    setState(() {
      _selectedPack = pack;
      _pairs = [];
      _cards = [];
      _matchedCardIds.clear();
      _selectedCardIds.clear();
      _isChecking = false;
      _moves = 0;
      _loadingPairs = true;
    });

    try {
      final pairs =
          pack.id == 'default'
              ? _starterPairs()
              : await widget.firestoreService!
                  .getCurrentAssociationPairs(pack.id)
                  .first;

      final playablePairs =
          pairs
              .where(
                (pair) =>
                    pair.first.label.trim().isNotEmpty &&
                    pair.second.label.trim().isNotEmpty,
              )
              .toList()
            ..shuffle(_random);

      if (!mounted) return;

      if (playablePairs.length < 2) {
        setState(() {
          _selectedPack = null;
          _loadingPairs = false;
        });
        _showMessage(_text.noPlayablePairs);
        return;
      }

      setState(() {
        _pairs = playablePairs.take(8).toList();
        _cards = _cardsForPairs(_pairs);
        _loadingPairs = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _selectedPack = null;
        _loadingPairs = false;
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

  ManagedAssociationPairPack _starterPack() {
    return ManagedAssociationPairPack(
      id: 'default',
      title: _text.starterPairs,
      description: _text.matchThings,
      iconName: 'puzzle',
      active: true,
      availableToAll: true,
      assignedChildIds: [],
      createdByStaffId: '',
      createdByStaffName: '',
    );
  }

  List<ManagedAssociationPair> _starterPairs() {
    return const [
      ManagedAssociationPair(
        id: 'rabbit-carrot',
        sortOrder: 0,
        first: ManagedAssociationPairItem(label: 'Rabbit', iconName: 'rabbit'),
        second: ManagedAssociationPairItem(label: 'Carrot', iconName: 'carrot'),
      ),
      ManagedAssociationPair(
        id: 'rain-umbrella',
        sortOrder: 1,
        first: ManagedAssociationPairItem(label: 'Rain', iconName: 'droplet'),
        second: ManagedAssociationPairItem(
          label: 'Umbrella',
          iconName: 'umbrella',
        ),
      ),
      ManagedAssociationPair(
        id: 'toothbrush-tooth',
        sortOrder: 2,
        first: ManagedAssociationPairItem(
          label: 'Toothbrush',
          iconName: 'toothbrush',
        ),
        second: ManagedAssociationPairItem(label: 'Tooth', iconName: 'tooth'),
      ),
      ManagedAssociationPair(
        id: 'bee-flower',
        sortOrder: 3,
        first: ManagedAssociationPairItem(label: 'Bee', iconName: 'bee'),
        second: ManagedAssociationPairItem(label: 'Flower', iconName: 'flower'),
      ),
      ManagedAssociationPair(
        id: 'book-pencil',
        sortOrder: 4,
        first: ManagedAssociationPairItem(label: 'Book', iconName: 'book'),
        second: ManagedAssociationPairItem(label: 'Pencil', iconName: 'pencil'),
      ),
      ManagedAssociationPair(
        id: 'dog-bone',
        sortOrder: 5,
        first: ManagedAssociationPairItem(label: 'Dog', iconName: 'dog'),
        second: ManagedAssociationPairItem(label: 'Bone', iconName: 'bone'),
      ),
    ];
  }

  List<_AssociationCard> _cardsForPairs(List<ManagedAssociationPair> pairs) {
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

    cards.shuffle(_random);
    return cards;
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

  bool _isFaceUp(_AssociationCard card) {
    return _selectedCardIds.contains(card.id) ||
        _matchedCardIds.contains(card.id);
  }

  int _starCount() {
    final totalPairs = _cards.length ~/ 2;

    if (_moves <= totalPairs + 1) return 3;
    if (_moves <= totalPairs + 4) return 2;
    return 1;
  }

  void _restart() {
    setState(() {
      _cards = _cardsForPairs(_pairs);
      _matchedCardIds.clear();
      _selectedCardIds.clear();
      _isChecking = false;
      _moves = 0;
    });
  }

  void _chooseAnotherPack() {
    setState(() {
      _selectedPack = null;
      _pairs = [];
      _cards = [];
      _matchedCardIds.clear();
      _selectedCardIds.clear();
      _isChecking = false;
      _moves = 0;
    });
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
                  _text.greatJob,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _text.pairsFound(_moves),
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
                const SizedBox(height: 18),
                Text(
                  '${_text.movesLabel}: $_moves',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _restart();
                        },
                        child: Text(_text.playAgain),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _chooseAnotherPack();
                        },
                        child: Text(_text.anotherPack),
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

  Widget _buildPackPicker() {
    const color = Color(0xFF7E57C2);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
      children: [
        _buildHeroHeader(
          title: _text.choosePack,
          subtitle: _text.matchThings,
          icon: Icons.extension_rounded,
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
              _text.usingStarterPairs,
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

  Widget _buildHeroHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7E57C2), Color(0xFFFFB199)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: Colors.white, size: 38),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
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

  Widget _buildStats() {
    final matchedPairs = _matchedCardIds.length ~/ 2;
    final totalPairs = _cards.length ~/ 2;

    return Row(
      children: [
        Expanded(
          child: _StatPill(
            icon: Icons.check_circle_rounded,
            label: _text.pairsLabel,
            value: '$matchedPairs/$totalPairs',
            color: const Color(0xFF26A69A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatPill(
            icon: Icons.touch_app_rounded,
            label: _text.movesLabel,
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
              onTap: () => _onCardTap(card),
            );
          },
        );
      },
    );
  }

  Widget _buildGame() {
    final pack = _selectedPack;

    if (pack == null) return _buildPackPicker();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroHeader(
                  title: pack.title,
                  subtitle:
                      pack.description.trim().isEmpty
                          ? (_isIrish
                              ? 'Meaitseáil na péirí.'
                              : 'Match the pairs.')
                          : pack.description,
                  icon: appIconForKey(pack.iconName, fallbackKey: 'puzzle'),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildStats()),
                    const SizedBox(width: 10),
                    IconButton.filledTonal(
                      tooltip: _text.packs,
                      onPressed: _chooseAnotherPack,
                      icon: const Icon(Icons.grid_view_rounded),
                    ),
                    IconButton.filledTonal(
                      tooltip: _text.restart,
                      onPressed: _restart,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildGameGrid(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: AppBar(
        title: Text(_text.associationPairs),
        backgroundColor: const Color(0xFFF7F4FF),
        elevation: 0,
      ),
      body: SafeArea(
        child:
            _loadingPacks || _loadingPairs
                ? const Center(child: CircularProgressIndicator())
                : _selectedPack == null
                ? _buildPackPicker()
                : _buildGame(),
      ),
    );
  }
}

class _AssociationCard {
  final String id;
  final String pairId;
  final ManagedAssociationPairItem item;

  const _AssociationCard({
    required this.id,
    required this.pairId,
    required this.item,
  });
}

class _PackChoiceCard extends StatelessWidget {
  final ManagedAssociationPairPack pack;
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
                  appIconForKey(pack.iconName, fallbackKey: 'puzzle'),
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

class _AssociationPairCard extends StatelessWidget {
  final _AssociationCard card;
  final bool faceUp;
  final bool matched;
  final VoidCallback onTap;

  const _AssociationPairCard({
    required this.card,
    required this.faceUp,
    required this.matched,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF7E57C2);

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
                      if (isMediaVisualValue(card.item.iconName))
                        MediaImagePreview(value: card.item.iconName, size: 56)
                      else
                        Icon(
                          appIconForKey(card.item.iconName),
                          color: color,
                          size: 42,
                        ),
                      const SizedBox(height: 12),
                      Text(
                        card.item.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
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
