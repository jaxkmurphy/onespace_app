import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_icon_catalog.dart';
import '../l10n/learning_game_localizations.dart';
import '../models/child_profile.dart';
import '../models/number_sequence_models.dart';
import '../services/firestore_service.dart';

class NumberSequencePage extends StatefulWidget {
  final ChildProfile? child;
  final FirestoreService? firestoreService;

  const NumberSequencePage({super.key, this.child, this.firestoreService});

  @override
  State<NumberSequencePage> createState() => _NumberSequencePageState();
}

class _NumberSequencePageState extends State<NumberSequencePage> {
  final Random _random = Random();

  List<NumberSequenceChallenge> _challenges = [];
  NumberSequenceChallenge? _selectedChallenge;
  List<int> _numbers = [];

  Timer? _timer;
  Duration _elapsed = Duration.zero;

  int _nextNumber = 1;
  int _mistakes = 0;
  int? _wrongNumber;

  bool _loadingChallenges = true;
  bool _hasLoadError = false;
  bool _hasStarted = false;
  bool _isComplete = false;
  bool _isShowingMistake = false;

  bool get _isIrish => Localizations.localeOf(context).languageCode == 'ga';
  LearningGameLocalizations get _text => LearningGameLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    setState(() {
      _loadingChallenges = true;
      _hasLoadError = false;
    });

    try {
      final service = widget.firestoreService;
      final child = widget.child;

      if (service == null || child == null) {
        setState(() {
          _challenges = _starterChallenges();
          _loadingChallenges = false;
        });
        return;
      }

      final challenges =
          await service
              .getCurrentAssignedNumberSequenceChallenges(childId: child.id)
              .first;
      final activeChallenges =
          challenges.where((challenge) => challenge.active).toList();

      if (!mounted) return;

      setState(() {
        _challenges =
            activeChallenges.isEmpty ? _starterChallenges() : activeChallenges;
        _loadingChallenges = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _challenges = _starterChallenges();
        _loadingChallenges = false;
        _hasLoadError = true;
      });
    }
  }

  List<NumberSequenceChallenge> _starterChallenges() {
    return [
      NumberSequenceChallenge(
        id: 'easy',
        title: _isIrish ? 'Éasca' : 'Easy',
        description:
            _isIrish ? 'Tapáil uimhreacha 1 go 5.' : 'Tap numbers 1 to 5.',
        iconName: 'number_5_small',
        maxNumber: 5,
        timerEnabled: true,
        active: true,
        availableToAll: true,
        assignedChildIds: [],
        createdByStaffId: '',
        createdByStaffName: '',
      ),
      NumberSequenceChallenge(
        id: 'medium',
        title: _isIrish ? 'Meánach' : 'Medium',
        description:
            _isIrish ? 'Tapáil uimhreacha 1 go 9.' : 'Tap numbers 1 to 9.',
        iconName: 'number_9_small',
        maxNumber: 9,
        timerEnabled: true,
        active: true,
        availableToAll: true,
        assignedChildIds: [],
        createdByStaffId: '',
        createdByStaffName: '',
      ),
      NumberSequenceChallenge(
        id: 'hard',
        title: _isIrish ? 'Deacair' : 'Hard',
        description:
            _isIrish ? 'Tapáil uimhreacha 1 go 12.' : 'Tap numbers 1 to 12.',
        iconName: 'numbers',
        maxNumber: 12,
        timerEnabled: true,
        active: true,
        availableToAll: true,
        assignedChildIds: [],
        createdByStaffId: '',
        createdByStaffName: '',
      ),
    ];
  }

  void _selectChallenge(NumberSequenceChallenge challenge) {
    _timer?.cancel();

    final maxNumber = challenge.maxNumber.clamp(3, 30);
    final numbers = List<int>.generate(maxNumber, (index) => index + 1)
      ..shuffle(_random);

    setState(() {
      _selectedChallenge = challenge.copyWith(maxNumber: maxNumber);
      _numbers = numbers;
      _elapsed = Duration.zero;
      _nextNumber = 1;
      _mistakes = 0;
      _wrongNumber = null;
      _hasStarted = false;
      _isComplete = false;
      _isShowingMistake = false;
    });
  }

  void _restart() {
    final challenge = _selectedChallenge;
    if (challenge == null) return;
    _selectChallenge(challenge);
  }

  void _chooseAnotherChallenge() {
    _timer?.cancel();

    setState(() {
      _selectedChallenge = null;
      _numbers = [];
      _elapsed = Duration.zero;
      _nextNumber = 1;
      _mistakes = 0;
      _wrongNumber = null;
      _hasStarted = false;
      _isComplete = false;
      _isShowingMistake = false;
    });
  }

  void _startTimerIfNeeded() {
    final challenge = _selectedChallenge;
    if (challenge == null || !challenge.timerEnabled) return;
    if (_hasStarted) return;

    _hasStarted = true;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;

      setState(() {
        _elapsed += const Duration(milliseconds: 100);
      });
    });
  }

  Future<void> _handleNumberTap(int number) async {
    final challenge = _selectedChallenge;
    if (challenge == null) return;
    if (_isComplete) return;
    if (_isShowingMistake) return;

    if (number != _nextNumber) {
      setState(() {
        _mistakes++;
        _wrongNumber = number;
        _isShowingMistake = true;
      });

      await Future<void>.delayed(const Duration(milliseconds: 420));

      if (!mounted) return;

      setState(() {
        _wrongNumber = null;
        _isShowingMistake = false;
      });

      return;
    }

    _startTimerIfNeeded();

    if (number == challenge.maxNumber) {
      _timer?.cancel();

      setState(() {
        _nextNumber++;
        _isComplete = true;
      });

      _showCompletionDialog();
      return;
    }

    setState(() {
      _nextNumber++;
    });
  }

  String _formatTime(Duration duration) {
    final seconds = duration.inSeconds;
    final tenths = (duration.inMilliseconds % 1000) ~/ 100;

    return '$seconds.$tenths';
  }

  int _starCount() {
    final challenge = _selectedChallenge;
    if (challenge == null) return 1;

    final seconds = _elapsed.inMilliseconds / 1000;
    final strongTime = challenge.maxNumber * 1.6;
    final okayTime = challenge.maxNumber * 2.7;

    if (_mistakes == 0 && seconds <= strongTime) return 3;
    if (_mistakes <= 2 && seconds <= okayTime + challenge.maxNumber) return 2;
    return 1;
  }

  Future<void> _showCompletionDialog() async {
    final challenge = _selectedChallenge;
    if (challenge == null) return;

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
                    Icons.bolt_rounded,
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
                  _text.tapNumbersInOrder,
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
                Text(
                  challenge.timerEnabled
                      ? '${_text.timeLabel}: ${_formatTime(_elapsed)}s • ${_text.mistakesLabel}: $_mistakes'
                      : '${_text.mistakesLabel}: $_mistakes',
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
                          _chooseAnotherChallenge();
                        },
                        child: Text(_text.anotherChallenge),
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

  Widget _buildHeroHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF29B6F6), Color(0xFF7E57C2)],
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

  Widget _buildChallengePicker() {
    const color = Color(0xFF29B6F6);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
      children: [
        _buildHeroHeader(
          title: _text.chooseChallenge,
          subtitle: _text.tapNumbersInOrder,
          icon: Icons.pin_rounded,
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
              _text.usingStarterChallenges,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
        const SizedBox(height: 18),
        ..._challenges.map(
          (challenge) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ChallengeCard(
              challenge: challenge,
              color: color,
              onTap: () => _selectChallenge(challenge),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final challenge = _selectedChallenge;
    if (challenge == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _StatPill(
            icon: Icons.flag_rounded,
            label: _text.nextLabel,
            value:
                _nextNumber > challenge.maxNumber
                    ? '✓'
                    : _nextNumber.toString(),
            color: const Color(0xFF7E57C2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatPill(
            icon:
                challenge.timerEnabled
                    ? Icons.timer_rounded
                    : Icons.touch_app_rounded,
            label:
                challenge.timerEnabled
                    ? (_text.timeLabel)
                    : (_text.mistakesLabel),
            value:
                challenge.timerEnabled
                    ? '${_formatTime(_elapsed)}s'
                    : _mistakes.toString(),
            color: const Color(0xFF29B6F6),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 760
                ? 5
                : constraints.maxWidth >= 520
                ? 4
                : 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _numbers.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 104,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final number = _numbers[index];
            final completed = number < _nextNumber;
            final wrong = number == _wrongNumber;

            return _NumberTile(
              number: number,
              completed: completed,
              wrong: wrong,
              onTap: () => _handleNumberTap(number),
            );
          },
        );
      },
    );
  }

  Widget _buildInstructionCard() {
    final challenge = _selectedChallenge;
    if (challenge == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFB300).withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_rounded, color: Color(0xFFFF8F00)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              challenge.timerEnabled
                  ? (_isIrish
                      ? 'Tosaíonn an t-amadóir nuair a thapálann tú 1.'
                      : 'The timer starts when you tap 1.')
                  : (_isIrish
                      ? 'Tapáil na huimhreacha san ord ceart.'
                      : 'Tap the numbers in order.'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGame() {
    final challenge = _selectedChallenge;
    if (challenge == null) return _buildChallengePicker();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroHeader(
                  title: challenge.title,
                  subtitle:
                      challenge.description.trim().isEmpty
                          ? 'Tap numbers 1 to ${challenge.maxNumber}.'
                          : challenge.description,
                  icon: appIconForKey(challenge.iconName, fallbackKey: 'pin'),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildStats()),
                    const SizedBox(width: 10),
                    IconButton.filledTonal(
                      tooltip: _text.challenges,
                      onPressed: _chooseAnotherChallenge,
                      icon: const Icon(Icons.grid_view_rounded),
                    ),
                    IconButton.filledTonal(
                      tooltip: _text.restart,
                      onPressed: _restart,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildInstructionCard(),
                const SizedBox(height: 16),
                _buildNumberGrid(),
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
        title: Text(_text.numberSequence),
        backgroundColor: const Color(0xFFF7F4FF),
        elevation: 0,
      ),
      body: SafeArea(
        child:
            _loadingChallenges
                ? const Center(child: CircularProgressIndicator())
                : _selectedChallenge == null
                ? _buildChallengePicker()
                : _buildGame(),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final NumberSequenceChallenge challenge;
  final Color color;
  final VoidCallback onTap;

  const _ChallengeCard({
    required this.challenge,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final description = challenge.description.trim();

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
                  appIconForKey(challenge.iconName, fallbackKey: 'pin'),
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
                      challenge.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description.isEmpty
                          ? '1-${challenge.maxNumber}${challenge.timerEnabled ? ' • Timer' : ''}'
                          : description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _NumberTile extends StatelessWidget {
  final int number;
  final bool completed;
  final bool wrong;
  final VoidCallback onTap;

  const _NumberTile({
    required this.number,
    required this.completed,
    required this.wrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        completed
            ? const Color(0xFF26A69A)
            : wrong
            ? const Color(0xFFEF5350)
            : const Color(0xFF7E57C2);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: completed ? null : onTap,
        borderRadius: BorderRadius.circular(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color:
                completed
                    ? color.withValues(alpha: 0.16)
                    : wrong
                    ? color.withValues(alpha: 0.22)
                    : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: wrong ? color : color.withValues(alpha: 0.22),
              width: wrong ? 3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: completed ? 0.05 : 0.12),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Center(
            child:
                completed
                    ? Icon(Icons.check_circle_rounded, color: color, size: 38)
                    : Text(
                      number.toString(),
                      style: TextStyle(
                        color: color,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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
