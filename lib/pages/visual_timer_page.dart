import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../simple_localizations.dart';

class VisualTimerPage extends StatefulWidget {
  const VisualTimerPage({super.key});

  @override
  State<VisualTimerPage> createState() => _VisualTimerPageState();
}

class _VisualTimerPageState extends State<VisualTimerPage> {
  static const List<int> _presetMinutes = [1, 3, 5, 10, 15, 20];

  Timer? _timer;

  int _selectedSeconds = 60;
  int _remainingSeconds = 60;

  bool _isRunning = false;
  bool _isFinished = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectPreset(int minutes) {
    _timer?.cancel();

    setState(() {
      _selectedSeconds = minutes * 60;
      _remainingSeconds = _selectedSeconds;
      _isRunning = false;
      _isFinished = false;
    });
  }

  void _changeCustomMinutes(int change) {
    final currentMinutes = (_selectedSeconds / 60).round();
    final newMinutes = (currentMinutes + change).clamp(1, 60);

    _timer?.cancel();

    setState(() {
      _selectedSeconds = newMinutes * 60;
      _remainingSeconds = _selectedSeconds;
      _isRunning = false;
      _isFinished = false;
    });
  }

  void _startTimer() {
    if (_isRunning || _remainingSeconds <= 0) return;

    setState(() {
      _isRunning = true;
      _isFinished = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();

        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
          _isFinished = true;
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();

    setState(() {
      _remainingSeconds = _selectedSeconds;
      _isRunning = false;
      _isFinished = false;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    final minuteString = minutes.toString().padLeft(2, '0');
    final secondString = seconds.toString().padLeft(2, '0');

    return '$minuteString:$secondString';
  }

  double get _progress {
    if (_selectedSeconds == 0) return 0;
    return _remainingSeconds / _selectedSeconds;
  }

  int get _selectedMinutes => (_selectedSeconds / 60).round();

  Color _timerColor() {
    if (_isFinished) return const Color(0xFF43A047);

    if (_progress <= 0.15) {
      return const Color(0xFFE53935);
    }

    if (_progress <= 0.35) {
      return const Color(0xFFFF8F00);
    }

    if (_progress <= 0.60) {
      return const Color(0xFFFBC02D);
    }

    return const Color(0xFF26A69A);
  }

  String _timerMessage(SimpleLocalizations loc) {
    if (_isFinished) {
      return loc.getString('time_finished');
    }

    if (_isRunning) {
      return Localizations.localeOf(context).languageCode == 'ga'
          ? 'Tá an t-am ag comhaireamh síos'
          : 'The timer is counting down';
    }

    return Localizations.localeOf(context).languageCode == 'ga'
        ? 'Roghnaigh am agus brúigh tosaigh'
        : 'Choose a time and press start';
  }

  Widget _buildHeader(SimpleLocalizations loc) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF26A69A),
            Color(0xFF66BB6A),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26A69A).withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.hourglass_bottom_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.getString('visual_timer'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _timerMessage(loc),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCircle(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: _progress,
            ),
            duration: const Duration(milliseconds: 350),
            builder: (context, animatedProgress, _) {
              return SizedBox(
                width: 260,
                height: 260,
                child: CustomPaint(
                  painter: _TimerRingPainter(
                    progress: animatedProgress,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.13),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Column(
                        key: ValueKey(
                          '${_remainingSeconds}_$_isFinished',
                        ),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isFinished
                                ? Icons.celebration_rounded
                                : _isRunning
                                    ? Icons.timer_rounded
                                    : Icons.timer_outlined,
                            color: color,
                            size: 50,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatTime(_remainingSeconds),
                            style: TextStyle(
                              color: color,
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: _progress,
            minHeight: 12,
            color: color,
            backgroundColor: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard({
    required int minutes,
    required bool selected,
    required SimpleLocalizations loc,
  }) {
    final color = selected ? _timerColor() : const Color(0xFF5E35B1);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: _isRunning ? null : () => _selectPreset(minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 128,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.13)
              : Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? color
                : Colors.black.withValues(alpha: 0.08),
            width: selected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: selected ? 0.16 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.hourglass_empty_rounded,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              '$minutes',
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              loc.getString('min'),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(SimpleLocalizations loc) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      constraints: const BoxConstraints(maxWidth: 900),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Text(
            Localizations.localeOf(context).languageCode == 'ga'
                ? 'Roghnaigh fad ama'
                : 'Choose a timer length',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: _presetMinutes.map((minutes) {
              return _buildPresetCard(
                minutes: minutes,
                selected: _selectedSeconds == minutes * 60,
                loc: loc,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                  onPressed:
                      _isRunning ? null : () => _changeCustomMinutes(-1),
                  icon: const Icon(Icons.remove_rounded),
                ),
                const SizedBox(width: 14),
                Column(
                  children: [
                    Text(
                      Localizations.localeOf(context).languageCode == 'ga'
                          ? 'Am saincheaptha'
                          : 'Custom time',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_selectedMinutes ${loc.getString('min')}',
                      style: const TextStyle(
                        color: Color(0xFF5E35B1),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                IconButton.filledTonal(
                  onPressed:
                      _isRunning ? null : () => _changeCustomMinutes(1),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(SimpleLocalizations loc, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      constraints: const BoxConstraints(maxWidth: 720),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            height: 54,
            width: 180,
            child: FilledButton.icon(
              onPressed: _isRunning ? null : _startTimer,
              style: FilledButton.styleFrom(
                backgroundColor: color,
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                loc.getString('start'),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          SizedBox(
            height: 54,
            width: 180,
            child: FilledButton.tonalIcon(
              onPressed: _isRunning ? _pauseTimer : null,
              icon: const Icon(Icons.pause_rounded),
              label: Text(
                loc.getString('pause'),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          SizedBox(
            height: 54,
            width: 180,
            child: OutlinedButton.icon(
              onPressed: _resetTimer,
              icon: const Icon(Icons.replay_rounded),
              label: Text(
                loc.getString('reset'),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishedCard(SimpleLocalizations loc) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: !_isFinished
          ? const SizedBox.shrink()
          : Container(
              key: const ValueKey('finished'),
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 36),
              constraints: const BoxConstraints(maxWidth: 560),
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(0xFF43A047).withValues(alpha: 0.20),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.celebration_rounded,
                    color: Color(0xFFFFB300),
                    size: 76,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    loc.getString('time_finished'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF43A047),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Localizations.localeOf(context).languageCode == 'ga'
                        ? 'Maith thú!'
                        : 'Great job!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = SimpleLocalizations(Localizations.localeOf(context));
    final color = _timerColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.getString('visual_timer')),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3FFF5),
              Color(0xFFFFF8E8),
              Color(0xFFF7F2FF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  _buildHeader(loc),
                  _buildTimerCircle(color),
                  _buildTimeSelector(loc),
                  _buildControls(loc, color),
                  _buildFinishedCard(loc),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  const _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.075;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}