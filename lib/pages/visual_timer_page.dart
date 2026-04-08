import 'dart:async';
import 'package:flutter/material.dart';
import '../simple_localizations.dart';

class VisualTimerPage extends StatefulWidget {
  const VisualTimerPage({super.key});

  @override
  State<VisualTimerPage> createState() => _VisualTimerPageState();
}

class _VisualTimerPageState extends State<VisualTimerPage> {
  static const List<int> _presetMinutes = [1, 3, 5];

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

  Color _progressColor(BuildContext context) {
    if (_remainingSeconds <= 10 && _remainingSeconds > 0) {
      return Colors.orange;
    }
    if (_isFinished) {
      return Colors.green;
    }
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final loc = SimpleLocalizations(Localizations.localeOf(context));

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.getString('visual_timer')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                loc.getString('visual_timer'),
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 16,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _progressColor(context),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _presetMinutes.map((minutes) {
                  final seconds = minutes * 60;
                  final isSelected = _selectedSeconds == seconds;

                  return ChoiceChip(
                    label: Text('$minutes ${loc.getString("min")}'),
                    selected: isSelected,
                    onSelected: (_) => _selectPreset(minutes),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isRunning ? null : _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(loc.getString('start')),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isRunning ? _pauseTimer : null,
                    icon: const Icon(Icons.pause),
                    label: Text(loc.getString('pause')),
                  ),
                  ElevatedButton.icon(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.replay),
                    label: Text(loc.getString('reset')),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isFinished
                    ? Column(
                        key: const ValueKey('finished'),
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 56,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            loc.getString('time_finished'),
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : const SizedBox(
                        key: ValueKey('empty'),
                        height: 80,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}