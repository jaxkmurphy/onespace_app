import 'package:flutter/material.dart';
import '../data/quiz_visuals.dart';
import '../models/child_profile.dart';
import '../models/question.dart';
import '../models/quiz.dart';
import '../services/firestore_service.dart';

class QuizPlayPage extends StatefulWidget {
  final Quiz quiz;
  final ChildProfile? childProfile;

  const QuizPlayPage({
    super.key,
    required this.quiz,
    this.childProfile,
  });

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  final FirestoreService _firestoreService = FirestoreService();

  int _currentQuestionIndex = 0;
  int _score = 0;

  int? _selectedAnswerIndex;
  bool _answerConfirmed = false;
  bool _isSubmitting = false;
  bool _isFinished = false;

  final List<int> _selectedAnswerIndexes = [];

  bool get _isStaffPreview => widget.childProfile == null;

  Question get _currentQuestion =>
      widget.quiz.questions[_currentQuestionIndex];

  bool get _isLastQuestion =>
      _currentQuestionIndex == widget.quiz.questions.length - 1;

  double get _progress {
    if (widget.quiz.questions.isEmpty) return 0;

    return (_currentQuestionIndex + 1) /
        widget.quiz.questions.length;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _selectAnswer(int index) {
    if (_answerConfirmed || _isSubmitting) return;

    final isCorrect =
        _currentQuestion.isCorrectAnswer(index);

    setState(() {
      _selectedAnswerIndex = index;
      _answerConfirmed = true;
      _selectedAnswerIndexes.add(index);

      if (isCorrect) {
        _score++;
      }
    });
  }

  Future<void> _continue() async {
    if (!_answerConfirmed || _isSubmitting) return;

    if (!_isLastQuestion) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _answerConfirmed = false;
      });

      return;
    }

    await _finishQuiz();
  }

  Future<void> _finishQuiz() async {
    if (_isStaffPreview) {
      setState(() {
        _isFinished = true;
      });
      return;
    }

    final child = widget.childProfile;
    if (child == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _firestoreService.submitCurrentQuiz(
        childId: child.id,
        quizId: widget.quiz.id,
        score: _score,
        totalQuestions: widget.quiz.questions.length,
        selectedAnswerIndexes: _selectedAnswerIndexes,
      );

      if (!mounted) return;

      setState(() {
        _isFinished = true;
      });
    } catch (error) {
      _showMessage(
        'Your result could not be saved. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _playAgain() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _answerConfirmed = false;
      _isSubmitting = false;
      _isFinished = false;
      _selectedAnswerIndexes.clear();
    });
  }

  Future<void> _confirmExit() async {
    if (_isFinished) {
      Navigator.pop(context);
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Leave this quiz?'),
          content: Text(
            _isStaffPreview
                ? 'Close the quiz preview?'
                : 'Your answers in this attempt will not be saved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                false,
              ),
              child: const Text('Keep Playing'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                true,
              ),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true && mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildEmptyQuiz() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.quiz_outlined,
              size: 72,
              color: Color(0xFF7E57C2),
            ),
            const SizedBox(height: 18),
            Text(
              'This quiz has no questions yet',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewBanner() {
    if (!_isStaffPreview) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 9,
      ),
      color: Colors.orange.shade100,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility_rounded,
            size: 20,
          ),
          SizedBox(width: 7),
          Text(
            'Staff Preview — results will not be saved',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizHeader(Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(
                  quizStyleFor(widget.quiz.iconName).icon,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.quiz.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentQuestionIndex + 1}'
                  ' of ${widget.quiz.questions.length}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 12,
              backgroundColor: color.withValues(alpha: 0.14),
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.76),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'QUESTION',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _currentQuestion.question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswers(Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 650;
        final answerWidth = wide
            ? (constraints.maxWidth - 14) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: List.generate(
            _currentQuestion.options.length,
            (index) {
              final option = _currentQuestion.options[index];
              final isCorrect =
                  index == _currentQuestion.correctAnswerIndex;
              final isSelected = index == _selectedAnswerIndex;

              return SizedBox(
                width: answerWidth,
                child: _AnswerCard(
                  index: index,
                  answer: option,
                  themeColor: color,
                  selected: isSelected,
                  correct: isCorrect,
                  revealAnswer: _answerConfirmed,
                  onTap: () => _selectAnswer(index),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFeedback(Color color) {
    if (!_answerConfirmed || _selectedAnswerIndex == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_rounded,
              color: Color(0xFF7E57C2),
            ),
            SizedBox(width: 9),
            Flexible(
              child: Text(
                'Tap the answer you think is right.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isCorrect = _currentQuestion.isCorrectAnswer(
      _selectedAnswerIndex!,
    );

    final feedbackColor = isCorrect
        ? Colors.green.shade600
        : Colors.orange.shade700;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: feedbackColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: feedbackColor.withValues(alpha: 0.40),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isCorrect
                ? Icons.celebration_rounded
                : Icons.lightbulb_rounded,
            color: feedbackColor,
            size: 45,
          ),
          const SizedBox(height: 8),
          Text(
            isCorrect ? 'Brilliant!' : 'Good try!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: feedbackColor,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 6),
            Text(
              'The answer is '
              '${_currentQuestion.correctAnswer}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (_currentQuestion.explanation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _currentQuestion.explanation,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContinueButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton.icon(
        onPressed:
            !_answerConfirmed || _isSubmitting ? null : _continue,
        style: FilledButton.styleFrom(
          backgroundColor: color,
        ),
        icon: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                _isLastQuestion
                    ? Icons.emoji_events_rounded
                    : Icons.arrow_forward_rounded,
              ),
        label: Text(
          _isSubmitting
              ? 'Saving your result...'
              : _isLastQuestion
                  ? 'See My Result'
                  : 'Next Question',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildQuizBody(Color color) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 38),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              _buildQuizHeader(color),
              const SizedBox(height: 18),
              _buildQuestionCard(color),
              const SizedBox(height: 20),
              _buildAnswers(color),
              const SizedBox(height: 18),
              _buildFeedback(color),
              const SizedBox(height: 18),
              _buildContinueButton(color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(Color color) {
    final total = widget.quiz.questions.length;

    final percentage = total <= 0
        ? 0
        : ((_score / total) * 100).round();

    late String heading;
    late String message;
    late IconData icon;

    if (percentage == 100) {
      heading = 'Amazing!';
      message = 'You got every question right!';
      icon = Icons.workspace_premium_rounded;
    } else if (percentage >= 70) {
      heading = 'Great work!';
      message = 'You did a brilliant job!';
      icon = Icons.emoji_events_rounded;
    } else if (percentage >= 40) {
      heading = 'Well done!';
      message = 'You kept trying and learned something new!';
      icon = Icons.star_rounded;
    } else {
      heading = 'Good effort!';
      message = 'Every try helps your brain grow!';
      icon = Icons.favorite_rounded;
    }

    if (_isStaffPreview) {
      heading = 'Preview complete';
      message = 'This is how the child’s result screen will look.';
      icon = Icons.visibility_rounded;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.22),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFC107),
                    size: 34,
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFEC407A),
                    size: 38,
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFC107),
                    size: 34,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withValues(alpha: 0.70),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 68,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                heading,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_score / $total',
                      style: TextStyle(
                        color: color,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                  ),
                  icon: Icon(
                    _isStaffPreview
                        ? Icons.close_rounded
                        : Icons.arrow_back_rounded,
                  ),
                  label: Text(
                    _isStaffPreview
                        ? 'Close Preview'
                        : 'Back to My Quizzes',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _playAgain,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Play Again'),
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
    final color = quizColorFromHex(widget.quiz.colorHex);

    if (widget.quiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.title),
        ),
        body: _buildEmptyQuiz(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _confirmExit,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(widget.quiz.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildPreviewBanner(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF3F7FF),
                    Color(0xFFFFF8E8),
                    Color(0xFFF8F2FF),
                  ],
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _isFinished
                    ? _buildResults(color)
                    : _buildQuizBody(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final int index;
  final String answer;
  final Color themeColor;

  final bool selected;
  final bool correct;
  final bool revealAnswer;

  final VoidCallback onTap;

  const _AnswerCard({
    required this.index,
    required this.answer,
    required this.themeColor,
    required this.selected,
    required this.correct,
    required this.revealAnswer,
    required this.onTap,
  });

  String get _letter => String.fromCharCode(65 + index);

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey.shade300;
    Color backgroundColor = Colors.white;
    Color circleColor = themeColor;
    IconData? statusIcon;

    if (revealAnswer && correct) {
      borderColor = Colors.green.shade600;
      backgroundColor =
          Colors.green.shade50;
      circleColor = Colors.green.shade600;
      statusIcon = Icons.check_circle_rounded;
    } else if (revealAnswer && selected && !correct) {
      borderColor = Colors.orange.shade700;
      backgroundColor =
          Colors.orange.shade50;
      circleColor = Colors.orange.shade700;
      statusIcon = Icons.lightbulb_rounded;
    } else if (selected) {
      borderColor = themeColor;
      backgroundColor =
          themeColor.withValues(alpha: 0.10);
    }

    return Semantics(
      button: !revealAnswer,
      selected: selected,
      label: 'Answer $_letter: $answer',
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: revealAnswer ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: borderColor,
              width: selected || (revealAnswer && correct) ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.10),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _letter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  answer,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (statusIcon != null)
                Icon(
                  statusIcon,
                  color: circleColor,
                  size: 30,
                ),
            ],
          ),
        ),
      ),
    );
  }
}