import 'dart:math';

import 'package:flutter/material.dart';

import '../data/word_learning_visuals.dart';
import '../l10n/l10n.dart';
import '../models/word_attempt.dart';
import '../models/word_item.dart';
import '../models/word_pack.dart';
import '../services/firestore_service.dart';

class WordPracticePage extends StatefulWidget {
  final FirestoreService firestoreService;
  final String teacherUid;
  final String childId;
  final WordPack pack;

  const WordPracticePage({
    super.key,
    required this.firestoreService,
    required this.teacherUid,
    required this.childId,
    required this.pack,
  });

  @override
  State<WordPracticePage> createState() =>
      _WordPracticePageState();
}

class _WordPracticePageState extends State<WordPracticePage> {
  final Random _random = Random();

  List<WordItem> _allWords = [];
  List<WordItem> _sessionWords = [];
  List<String> _choices = [];

  int _currentIndex = 0;
  int _score = 0;

  String? _selectedAnswer;
  bool _answerConfirmed = false;
  bool _showHint = false;
  bool _isLoading = true;
  bool _isSavingAttempt = false;
  bool _isComplete = false;
  bool _hasLoadError = false;

  late String _sessionId;

  WordItem? get _currentWord {
    if (_sessionWords.isEmpty ||
        _currentIndex >= _sessionWords.length) {
      return null;
    }

    return _sessionWords[_currentIndex];
  }

  @override
  void initState() {
    super.initState();
    _startNewSessionId();
    _loadWords();
  }

  void _startNewSessionId() {
    _sessionId =
        '${widget.childId}_${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> _loadWords() async {
    try {
      final words = await widget.firestoreService
          .getCurrentWordItems(widget.pack.id)
          .first;

      if (!mounted) return;

      final distinctWordTexts = words
          .map((word) => word.text.trim().toLowerCase())
          .where((word) => word.isNotEmpty)
          .toSet();

      if (words.length < 2 || distinctWordTexts.length < 2) {
        setState(() {
          _allWords = words;
          _isLoading = false;
        });
        return;
      }

      final shuffled = List<WordItem>.from(words)
        ..shuffle(_random);

      setState(() {
        _allWords = List<WordItem>.from(words);
        _sessionWords = shuffled;
        _currentIndex = 0;
        _score = 0;
        _isLoading = false;
        _hasLoadError = false;
      });

      _prepareQuestion();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasLoadError = true;
      });
    }
  }

  void _prepareQuestion() {
    final word = _currentWord;

    if (word == null) {
      setState(() {
        _isComplete = true;
      });
      return;
    }

    final wrongAnswers = _allWords
        .where((item) => item.id != word.id)
        .map((item) => item.text)
        .where((text) => text != word.text)
        .toSet()
        .toList()
      ..shuffle(_random);

    final choices = [
      word.text,
      ...wrongAnswers.take(2),
    ]..shuffle(_random);

    setState(() {
      _choices = choices;
      _selectedAnswer = null;
      _answerConfirmed = false;
      _showHint = false;
    });
  }

  Future<void> _selectAnswer(String answer) async {
    final word = _currentWord;

    if (word == null ||
        _answerConfirmed ||
        _isSavingAttempt) {
      return;
    }

    final isCorrect = answer == word.text;

    setState(() {
      _selectedAnswer = answer;
      _answerConfirmed = true;
      _isSavingAttempt = true;

      if (isCorrect) {
        _score++;
      }
    });

    try {
      await widget.firestoreService.addCurrentWordAttempt(
        WordAttempt(
          id: '',
          childId: widget.childId,
          packId: widget.pack.id,
          wordId: word.id,
          wordText: word.text,
          selectedAnswer: answer,
          isCorrect: isCorrect,
          sessionId: _sessionId,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.error),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingAttempt = false;
        });
      }
    }
  }

  void _continue() {
    if (!_answerConfirmed || _isSavingAttempt) return;

    if (_currentIndex >= _sessionWords.length - 1) {
      setState(() {
        _isComplete = true;
      });
      return;
    }

    setState(() {
      _currentIndex++;
    });

    _prepareQuestion();
  }

  void _practiseAgain() {
    final shuffled = List<WordItem>.from(_allWords)
      ..shuffle(_random);

    _startNewSessionId();

    setState(() {
      _sessionWords = shuffled;
      _currentIndex = 0;
      _score = 0;
      _isComplete = false;
      _selectedAnswer = null;
      _answerConfirmed = false;
      _showHint = false;
    });

    _prepareQuestion();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            context.l10n.loadingWords,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 76,
              color: Color(0xFF66BB6A),
            ),
            const SizedBox(height: 18),
            Text(
              _hasLoadError
                  ? context.l10n.couldNotLoadWords
                  : context.l10n.packNeedsTwoWords,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (_hasLoadError) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasLoadError = false;
                  });

                  _loadWords();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(Color color) {
    final progress = _sessionWords.isEmpty
        ? 0.0
        : (_currentIndex + 1) / _sessionWords.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.wordProgressCount(
                    _currentIndex + 1,
                    _sessionWords.length,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                context.l10n.practiceScore(
                  _score,
                  _sessionWords.length,
                ),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 11,
              color: color,
              backgroundColor:
                  color.withValues(alpha: 0.13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrompt(Color color) {
    final word = _currentWord!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            context.l10n.chooseMatchingWord,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(34),
            ),
            alignment: Alignment.center,
            child: Text(
              word.imageValue.isEmpty ? '📚' : word.imageValue,
              style: const TextStyle(fontSize: 78),
            ),
          ),
          if (word.hint.isNotEmpty && !_answerConfirmed) ...[
            const SizedBox(height: 14),
            if (!_showHint)
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _showHint = true;
                  });
                },
                icon: const Icon(Icons.lightbulb_outline_rounded),
                label: Text(context.l10n.showHint),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  word.hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswers(Color color) {
    final correctAnswer = _currentWord!.text;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 14,
      children: _choices.map((answer) {
        final selected = answer == _selectedAnswer;
        final correct = answer == correctAnswer;

        return SizedBox(
          width: 260,
          child: _WordAnswerCard(
            answer: answer,
            color: color,
            selected: selected,
            correct: correct,
            reveal: _answerConfirmed,
            onTap: () => _selectAnswer(answer),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedback(Color color) {
    if (!_answerConfirmed || _selectedAnswer == null) {
      return const SizedBox.shrink();
    }

    final word = _currentWord!;
    final correct = _selectedAnswer == word.text;

    final feedbackColor = correct
        ? Colors.green.shade700
        : Colors.orange.shade700;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: feedbackColor.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: feedbackColor.withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            correct
                ? Icons.celebration_rounded
                : Icons.lightbulb_rounded,
            color: feedbackColor,
            size: 44,
          ),
          const SizedBox(height: 8),
          Text(
            correct
                ? context.l10n.greatJob
                : context.l10n.goodTry,
            style: TextStyle(
              color: feedbackColor,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (!correct) ...[
            const SizedBox(height: 6),
            Text(
              context.l10n.correctAnswerWas(word.text),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (word.hint.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              word.hint,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContinueButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed:
            _answerConfirmed && !_isSavingAttempt
                ? _continue
                : null,
        style: FilledButton.styleFrom(
          backgroundColor: color,
        ),
        icon: _isSavingAttempt
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                _currentIndex == _sessionWords.length - 1
                    ? Icons.emoji_events_rounded
                    : Icons.arrow_forward_rounded,
              ),
        label: Text(
          _currentIndex == _sessionWords.length - 1
              ? context.l10n.finishPractice
              : context.l10n.nextWord,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildPractice(Color color) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              _buildProgress(color),
              const SizedBox(height: 18),
              _buildPrompt(color),
              const SizedBox(height: 20),
              _buildAnswers(color),
              const SizedBox(height: 18),
              _buildFeedback(color),
              if (_answerConfirmed) ...[
                const SizedBox(height: 18),
                _buildContinueButton(color),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplete(Color color) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.celebration_rounded,
                color: Color(0xFFFFB300),
                size: 86,
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.practiceComplete,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                context.l10n.practisedWords(
                  _sessionWords.length,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  context.l10n.practiceScore(
                    _score,
                    _sessionWords.length,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _practiseAgain,
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                  ),
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(context.l10n.practiseAgain),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(context.l10n.backToPacks),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = wordPackColorFromHex(widget.pack.colorHex);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pack.name),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF3FFF5),
              Color(0xFFFFF8E8),
              Color(0xFFF7F2FF),
            ],
          ),
        ),
        child: _isLoading
            ? _buildLoadingState()
            : _hasLoadError || _allWords.length < 2
                ? _buildUnavailableState()
                : _isComplete
                    ? _buildComplete(color)
                    : _buildPractice(color),
      ),
    );
  }
}

class _WordAnswerCard extends StatelessWidget {
  final String answer;
  final Color color;
  final bool selected;
  final bool correct;
  final bool reveal;
  final VoidCallback onTap;

  const _WordAnswerCard({
    required this.answer,
    required this.color,
    required this.selected,
    required this.correct,
    required this.reveal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var borderColor = Colors.grey.shade300;
    var backgroundColor = Colors.white;
    IconData? statusIcon;

    if (reveal && correct) {
      borderColor = Colors.green.shade600;
      backgroundColor = Colors.green.shade50;
      statusIcon = Icons.check_circle_rounded;
    } else if (reveal && selected && !correct) {
      borderColor = Colors.orange.shade700;
      backgroundColor = Colors.orange.shade50;
      statusIcon = Icons.lightbulb_rounded;
    } else if (selected) {
      borderColor = color;
      backgroundColor = color.withValues(alpha: 0.10);
    }

    return Semantics(
      button: !reveal,
      selected: selected,
      label: answer,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: reveal ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 230),
          constraints: const BoxConstraints(minHeight: 95),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: borderColor,
              width: selected || (reveal && correct) ? 3 : 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  answer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (statusIcon != null)
                Icon(
                  statusIcon,
                  color: borderColor,
                  size: 29,
                ),
            ],
          ),
        ),
      ),
    );
  }
}