import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/child_profile.dart';

class NumberSequencePage extends StatefulWidget {
  final ChildProfile? child;

  const NumberSequencePage({super.key, this.child});

  @override
  State<NumberSequencePage> createState() => _NumberSequencePageState();
}

class _NumberSequencePageState extends State<NumberSequencePage> {
  _NumberSequenceDifficulty _difficulty = _NumberSequenceDifficulty.easy;

  late List<int> _numbers;

  Timer? _timer;
  Duration _elapsed = Duration.zero;

  int _nextNumber = 1;
  int _mistakes = 0;
  int? _wrongNumber;

  bool _hasStarted = false;
  bool _isComplete = false;
  bool _isShowingMistake = false;

  bool get _isIrish => Localizations.localeOf(context).languageCode == 'ga';

  @override
  void initState() {
    super.initState();
    _startGame(_difficulty);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _difficultyLabel(_NumberSequenceDifficulty difficulty) {
    return switch (difficulty) {
      _NumberSequenceDifficulty.easy => _isIrish ? 'Éasca' : 'Easy',
      _NumberSequenceDifficulty.medium => _isIrish ? 'Meánach' : 'Medium',
      _NumberSequenceDifficulty.hard => _isIrish ? 'Deacair' : 'Hard',
    };
  }

  int _maxNumberForDifficulty(_NumberSequenceDifficulty difficulty) {
    return switch (difficulty) {
      _NumberSequenceDifficulty.easy => 5,
      _NumberSequenceDifficulty.medium => 9,
      _NumberSequenceDifficulty.hard => 12,
    };
  }

  void _startGame(_NumberSequenceDifficulty difficulty) {
    _timer?.cancel();

    final maxNumber = _maxNumberForDifficulty(difficulty);
    final numbers = List<int>.generate(maxNumber, (index) => index + 1)
      ..shuffle(Random());

    setState(() {
      _difficulty = difficulty;
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

  void _startTimerIfNeeded() {
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

    final maxNumber = _maxNumberForDifficulty(_difficulty);

    if (number == maxNumber) {
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
    final maxNumber = _maxNumberForDifficulty(_difficulty);
    final seconds = _elapsed.inMilliseconds / 1000;

    final strongTime = switch (_difficulty) {
      _NumberSequenceDifficulty.easy => 6,
      _NumberSequenceDifficulty.medium => 12,
      _NumberSequenceDifficulty.hard => 18,
    };

    final okayTime = switch (_difficulty) {
      _NumberSequenceDifficulty.easy => 10,
      _NumberSequenceDifficulty.medium => 18,
      _NumberSequenceDifficulty.hard => 28,
    };

    if (_mistakes == 0 && seconds <= strongTime) return 3;
    if (_mistakes <= 2 && seconds <= okayTime + maxNumber) return 2;
    return 1;
  }

  Future<void> _showCompletionDialog() async {
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
                      ? 'Tapáil tú na huimhreacha san ord ceart.'
                      : 'You tapped the numbers in the right order.',
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
                          label: _isIrish ? 'Am' : 'Time',
                          value: '${_formatTime(_elapsed)}s',
                          icon: Icons.timer_rounded,
                        ),
                      ),
                      Container(width: 1, height: 42, color: Colors.black12),
                      Expanded(
                        child: _WinStat(
                          label: _isIrish ? 'Botúin' : 'Mistakes',
                          value: _mistakes.toString(),
                          icon: Icons.touch_app_rounded,
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
                          _startGame(_difficulty);
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

  Widget _buildHeader() {
    final childName = widget.child?.name.trim();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF29B6F6), Color(0xFF7E57C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF29B6F6).withValues(alpha: 0.20),
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
            child: const Icon(Icons.pin_rounded, color: Colors.white, size: 42),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isIrish ? 'Ord Uimhreacha' : 'Number Sequence',
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
                          ? 'Tapáil na huimhreacha san ord ceart.'
                          : 'Tap the numbers in the right order.')
                      : (_isIrish
                          ? 'Tapáil na huimhreacha san ord ceart, $childName.'
                          : 'Tap the numbers in order, $childName.'),
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
                _NumberSequenceDifficulty.values.map((difficulty) {
                  final selected = difficulty == _difficulty;
                  final maxNumber = _maxNumberForDifficulty(difficulty);

                  return ChoiceChip(
                    selected: selected,
                    label: Text(
                      '${_difficultyLabel(difficulty)} • 1-$maxNumber',
                    ),
                    onSelected: (_) => _startGame(difficulty),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final maxNumber = _maxNumberForDifficulty(_difficulty);

    return Row(
      children: [
        Expanded(
          child: _StatPill(
            icon: Icons.flag_rounded,
            label: _isIrish ? 'Ar aghaidh' : 'Next',
            value: _nextNumber > maxNumber ? '✓' : _nextNumber.toString(),
            color: const Color(0xFF7E57C2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatPill(
            icon: Icons.timer_rounded,
            label: _isIrish ? 'Am' : 'Time',
            value: '${_formatTime(_elapsed)}s',
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
                ? 4
                : constraints.maxWidth >= 520
                ? 3
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
              _isIrish
                  ? 'Tosaíonn an t-amadóir nuair a thapálann tú 1.'
                  : 'The timer starts when you tap 1.',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: AppBar(
        title: Text(_isIrish ? 'Ord Uimhreacha' : 'Number Sequence'),
        backgroundColor: const Color(0xFFF7F4FF),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: _isIrish ? 'Atosaigh' : 'Restart',
            onPressed: () => _startGame(_difficulty),
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
                constraints: const BoxConstraints(maxWidth: 840),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildDifficultySelector(),
                    const SizedBox(height: 14),
                    _buildInstructionCard(),
                    const SizedBox(height: 14),
                    _buildStats(),
                    const SizedBox(height: 16),
                    _buildNumberGrid(),
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

enum _NumberSequenceDifficulty { easy, medium, hard }

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
