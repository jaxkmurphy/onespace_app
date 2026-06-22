import 'package:flutter/material.dart';
import '../data/quiz_visuals.dart';
import '../models/child_profile.dart';
import '../models/question.dart';
import '../models/quiz.dart';
import '../services/firestore_service.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../l10n/quiz_localizations.dart';

class QuizCreationPage extends StatefulWidget {
  final String staffUid;
  final Quiz? existingQuiz;

  const QuizCreationPage({
    super.key,
    required this.staffUid,
    this.existingQuiz,
  });

  @override
  State<QuizCreationPage> createState() => _QuizCreationPageState();
}

class _QuizCreationPageState extends State<QuizCreationPage> {
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final Set<String> _selectedChildIds = {};

  late List<_QuestionDraft> _questions;
  late String _selectedStyleKey;
  late bool _availableToAll;

  bool _isSaving = false;

  bool get _isEditing => widget.existingQuiz != null;

  @override
  void initState() {
    super.initState();

    final existingQuiz = widget.existingQuiz;

    _titleController.text = existingQuiz?.title ?? '';
    _descriptionController.text = existingQuiz?.description ?? '';

    _selectedStyleKey =
        quizVisualStyles.any((style) => style.key == existingQuiz?.iconName)
            ? existingQuiz!.iconName
            : 'quiz';

    _availableToAll = existingQuiz?.availableToAll ?? true;

    _selectedChildIds.addAll(existingQuiz?.assignedChildIds ?? const []);

    if (existingQuiz != null && existingQuiz.questions.isNotEmpty) {
      _questions =
          existingQuiz.questions.map(_QuestionDraft.fromQuestion).toList();
    } else {
      _questions = [_QuestionDraft.empty()];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    for (final question in _questions) {
      question.dispose();
    }

    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _addQuestion() {
    setState(() {
      _questions.add(_QuestionDraft.empty());
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length <= 1) return;

    setState(() {
      final removed = _questions.removeAt(index);
      removed.dispose();
    });
  }

  void _moveQuestionUp(int index) {
    if (index <= 0) return;

    setState(() {
      final question = _questions.removeAt(index);
      _questions.insert(index - 1, question);
    });
  }

  void _moveQuestionDown(int index) {
    if (index >= _questions.length - 1) return;

    setState(() {
      final question = _questions.removeAt(index);
      _questions.insert(index + 1, question);
    });
  }

  String? _validationError() {
    if (_titleController.text.trim().isEmpty) {
      return context.l10n.enterQuizTitle;
    }

    if (!_availableToAll && _selectedChildIds.isEmpty) {
      return context.l10n.chooseQuizAudience;
    }

    if (_questions.isEmpty) {
      return context.l10n.addAtLeastOneQuestion;
    }

    for (var index = 0; index < _questions.length; index++) {
      final error = _questions[index].validationError(index + 1, context.l10n);

      if (error != null) return error;
    }

    return null;
  }

  Future<void> _saveQuiz() async {
    final validationError = _validationError();

    if (validationError != null) {
      _showMessage(validationError);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final existingQuiz = widget.existingQuiz;
    final style = quizStyleFor(_selectedStyleKey);
    final now = DateTime.now();

    final quiz = Quiz(
      id: existingQuiz?.id ?? _firestoreService.generateQuizId(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdBy:
          existingQuiz?.createdBy.isNotEmpty == true
              ? existingQuiz!.createdBy
              : widget.staffUid,
      questions: _questions.map((question) => question.toQuestion()).toList(),
      iconName: style.key,
      colorHex: style.colorHex,
      availableToAll: _availableToAll,
      assignedChildIds: _availableToAll ? const [] : _selectedChildIds.toList(),
      createdAt: existingQuiz?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (_isEditing) {
        await _firestoreService.updateCurrentQuiz(quiz);
      } else {
        await _firestoreService.addCurrentQuiz(quiz);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? context.l10n.quizUpdatedSuccess
                : context.l10n.quizCreatedSuccess,
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      _showMessage(context.l10n.quizSaveFailed(error.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildIntroductionCard() {
    final style = quizStyleFor(_selectedStyleKey);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [style.color, style.color.withValues(alpha: 0.75)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(style.icon, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing
                      ? context.l10n.editYourQuiz
                      : context.l10n.createNewQuiz,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  context.l10n.quizEditorIntro,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return _EditorSection(
      icon: Icons.edit_note_rounded,
      title: context.l10n.quizDetails,
      subtitle: context.l10n.quizDetailsIntro,
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: context.l10n.quizTitle,
              hintText: context.l10n.quizTitleHint,
              prefixIcon: const Icon(Icons.title_rounded),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.l10n.description,
              hintText: context.l10n.quizDescriptionHint,
              prefixIcon: const Icon(Icons.notes_rounded),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleCard() {
    return _EditorSection(
      icon: Icons.palette_rounded,
      title: context.l10n.quizStyle,
      subtitle: context.l10n.quizStyleIntro,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children:
            quizVisualStyles.map((style) {
              final selected = style.key == _selectedStyleKey;

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  setState(() {
                    _selectedStyleKey = style.key;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 145,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        selected
                            ? style.color.withValues(alpha: 0.16)
                            : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color:
                          selected
                              ? style.color
                              : Theme.of(context).dividerColor,
                      width: selected ? 3 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: style.color.withValues(alpha: 0.16),
                        child: Icon(style.icon, color: style.color),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizedQuizStyle(context.l10n, style.key),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (selected) ...[
                        const SizedBox(height: 5),
                        Icon(
                          Icons.check_circle_rounded,
                          color: style.color,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildAudienceCard() {
    return StreamBuilder<List<ChildProfile>>(
      stream: _firestoreService.getCurrentChildProfiles(),
      builder: (context, snapshot) {
        final children = snapshot.data ?? [];

        return _EditorSection(
          icon: Icons.groups_rounded,
          title: context.l10n.whoCanPlay,
          subtitle: context.l10n.quizAudienceIntro,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.groups_rounded),
                    label: Text(context.l10n.everyone),
                  ),
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.people_alt_rounded),
                    label: Text(context.l10n.selectedChildren),
                  ),
                ],
                selected: {_availableToAll},
                onSelectionChanged: (selection) {
                  setState(() {
                    _availableToAll = selection.first;

                    if (_availableToAll) {
                      _selectedChildIds.clear();
                    }
                  });
                },
              ),
              if (!_availableToAll) ...[
                const SizedBox(height: 18),
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData)
                  const Center(child: CircularProgressIndicator())
                else if (snapshot.hasError)
                  Text(context.l10n.childProfilesLoadFailed)
                else if (children.isEmpty)
                  Text(context.l10n.noChildProfilesAvailable)
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        children.map((child) {
                          final selected = _selectedChildIds.contains(child.id);

                          return FilterChip(
                            selected: selected,
                            avatar: Icon(
                              selected
                                  ? Icons.check_circle_rounded
                                  : Icons.face_rounded,
                            ),
                            label: Text(child.name),
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  _selectedChildIds.add(child.id);
                                } else {
                                  _selectedChildIds.remove(child.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionsSection() {
    return Column(
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF7E57C2),
              foregroundColor: Colors.white,
              child: Icon(Icons.quiz_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.questions,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(context.l10n.questionCount(_questions.length)),
                ],
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.addQuestion),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...List.generate(_questions.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _QuestionEditorCard(
              key: ObjectKey(_questions[index]),
              number: index + 1,
              draft: _questions[index],
              canDelete: _questions.length > 1,
              canMoveUp: index > 0,
              canMoveDown: index < _questions.length - 1,
              onDelete: () => _removeQuestion(index),
              onMoveUp: () => _moveQuestionUp(index),
              onMoveDown: () => _moveQuestionDown(index),
              onChanged: () => setState(() {}),
            ),
          );
        }),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: _addQuestion,
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: Text(context.l10n.addAnotherQuestion),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? context.l10n.editQuiz : context.l10n.createQuiz,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _saveQuiz,
              icon:
                  _isSaving
                      ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Icon(
                        _isEditing
                            ? Icons.save_rounded
                            : Icons.add_task_rounded,
                      ),
              label: Text(
                _isSaving
                    ? context.l10n.saving
                    : _isEditing
                    ? context.l10n.saveChanges
                    : context.l10n.createQuiz,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                _buildIntroductionCard(),
                const SizedBox(height: 18),
                _buildDetailsCard(),
                const SizedBox(height: 18),
                _buildStyleCard(),
                const SizedBox(height: 18),
                _buildAudienceCard(),
                const SizedBox(height: 24),
                _buildQuestionsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _EditorSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Icon(icon)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(subtitle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _QuestionEditorCard extends StatelessWidget {
  final int number;
  final _QuestionDraft draft;

  final bool canDelete;
  final bool canMoveUp;
  final bool canMoveDown;

  final VoidCallback onDelete;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onChanged;

  const _QuestionEditorCard({
    super.key,
    required this.number,
    required this.draft,
    required this.canDelete,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onChanged,
  });

  String _answerLetter(int index) {
    return String.fromCharCode(65 + index);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFF7E57C2).withValues(alpha: 0.045),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: const Color(0xFF7E57C2).withValues(alpha: 0.22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF7E57C2),
                  foregroundColor: Colors.white,
                  child: Text(
                    '$number',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.questionNumber(number),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.moveUp,
                  onPressed: canMoveUp ? onMoveUp : null,
                  icon: const Icon(Icons.arrow_upward_rounded),
                ),
                IconButton(
                  tooltip: context.l10n.moveDown,
                  onPressed: canMoveDown ? onMoveDown : null,
                  icon: const Icon(Icons.arrow_downward_rounded),
                ),
                IconButton(
                  tooltip: context.l10n.deleteQuestion,
                  onPressed: canDelete ? onDelete : null,
                  color: Colors.red.shade700,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: draft.questionController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.l10n.question,
                hintText: context.l10n.questionHint,
                prefixIcon: const Icon(Icons.help_outline_rounded),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              context.l10n.answers,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.correctAnswerInstruction,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            ...List.generate(draft.optionControllers.length, (index) {
              final isCorrect = draft.correctOptionIndex == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Tooltip(
                      message:
                          isCorrect
                              ? context.l10n.correctAnswer
                              : context.l10n.markAsCorrect,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          draft.correctOptionIndex = index;
                          onChanged();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color:
                                isCorrect
                                    ? Colors.green.shade600
                                    : Colors.grey.shade200,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isCorrect
                                      ? Colors.green.shade700
                                      : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child:
                              isCorrect
                                  ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                  )
                                  : Text(
                                    _answerLetter(index),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: draft.optionControllers[index],
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: context.l10n.answerLabel(
                            _answerLetter(index),
                          ),
                          border: const OutlineInputBorder(),
                          suffixIcon:
                              isCorrect
                                  ? Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.green.shade600,
                                  )
                                  : null,
                        ),
                      ),
                    ),
                    if (draft.optionControllers.length > 2)
                      IconButton(
                        tooltip: context.l10n.removeAnswer,
                        onPressed: () {
                          draft.removeOption(index);
                          onChanged();
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                ),
              );
            }),
            if (draft.optionControllers.length < 4)
              TextButton.icon(
                onPressed: () {
                  draft.addOption();
                  onChanged();
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(context.l10n.addAnswer),
              ),
            const SizedBox(height: 14),
            TextField(
              controller: draft.explanationController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: context.l10n.helpfulExplanation,
                hintText: context.l10n.helpfulExplanationHint,
                prefixIcon: const Icon(Icons.lightbulb_outline_rounded),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionDraft {
  final TextEditingController questionController;
  final TextEditingController explanationController;
  final List<TextEditingController> optionControllers;

  int correctOptionIndex;

  _QuestionDraft({
    required this.questionController,
    required this.explanationController,
    required this.optionControllers,
    required this.correctOptionIndex,
  });

  factory _QuestionDraft.empty() {
    return _QuestionDraft(
      questionController: TextEditingController(),
      explanationController: TextEditingController(),
      optionControllers: [TextEditingController(), TextEditingController()],
      correctOptionIndex: 0,
    );
  }

  factory _QuestionDraft.fromQuestion(Question question) {
    final options =
        question.options.isEmpty
            ? ['', '']
            : question.options.length == 1
            ? [question.options.first, '']
            : question.options.take(4).toList();

    var correctIndex = question.correctAnswerIndex;

    if (correctIndex < 0 || correctIndex >= options.length) {
      correctIndex = 0;
    }

    return _QuestionDraft(
      questionController: TextEditingController(text: question.question),
      explanationController: TextEditingController(text: question.explanation),
      optionControllers:
          options.map((option) => TextEditingController(text: option)).toList(),
      correctOptionIndex: correctIndex,
    );
  }

  void addOption() {
    if (optionControllers.length >= 4) return;

    optionControllers.add(TextEditingController());
  }

  void removeOption(int index) {
    if (optionControllers.length <= 2) return;
    if (index < 0 || index >= optionControllers.length) return;

    final removed = optionControllers.removeAt(index);
    removed.dispose();

    if (correctOptionIndex == index) {
      correctOptionIndex = 0;
    } else if (correctOptionIndex > index) {
      correctOptionIndex--;
    }
  }

  String? validationError(int questionNumber, AppLocalizations l10n) {
    if (questionController.text.trim().isEmpty) {
      return l10n.questionNeedsText(questionNumber);
    }

    if (optionControllers.length < 2) {
      return l10n.questionNeedsAnswers(questionNumber);
    }

    final answers =
        optionControllers.map((controller) => controller.text.trim()).toList();

    if (answers.any((answer) => answer.isEmpty)) {
      return l10n.completeQuestionAnswers(questionNumber);
    }

    final uniqueAnswers = answers.map((answer) => answer.toLowerCase()).toSet();

    if (uniqueAnswers.length != answers.length) {
      return l10n.questionDuplicateAnswers(questionNumber);
    }

    if (correctOptionIndex < 0 || correctOptionIndex >= answers.length) {
      return l10n.chooseCorrectAnswer(questionNumber);
    }

    return null;
  }

  Question toQuestion() {
    final answers =
        optionControllers.map((controller) => controller.text.trim()).toList();

    return Question(
      question: questionController.text.trim(),
      options: answers,
      correctAnswer: answers[correctOptionIndex],
      correctAnswerIndex: correctOptionIndex,
      explanation: explanationController.text.trim(),
    );
  }

  void dispose() {
    questionController.dispose();
    explanationController.dispose();

    for (final controller in optionControllers) {
      controller.dispose();
    }
  }
}
