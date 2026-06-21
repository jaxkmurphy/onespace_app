import 'package:flutter/material.dart';
import '../data/word_learning_visuals.dart';
import '../l10n/l10n.dart';
import '../models/child_profile.dart';
import '../models/word_item.dart';
import '../models/word_pack.dart';
import '../services/firestore_service.dart';

class WordPackEditorPage extends StatefulWidget {
  final FirestoreService firestoreService;
  final String teacherUid;
  final WordPack pack;

  const WordPackEditorPage({
    super.key,
    required this.firestoreService,
    required this.teacherUid,
    required this.pack,
  });

  @override
  State<WordPackEditorPage> createState() =>
      _WordPackEditorPageState();
}

class _WordPackEditorPageState
    extends State<WordPackEditorPage> {
  late WordPack _pack;

  @override
  void initState() {
    super.initState();
    _pack = widget.pack;
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

  String _styleLabel(String key) {
    switch (key) {
      case 'school':
        return context.l10n.school;
      case 'home':
        return context.l10n.home;
      case 'animals':
        return context.l10n.animals;
      case 'feelings':
        return context.l10n.feelings;
      case 'world':
        return context.l10n.ourWorld;
      case 'fun':
        return context.l10n.fun;
      default:
        return context.l10n.words;
    }
  }

  String _difficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'medium':
        return context.l10n.medium;
      case 'hard':
        return context.l10n.hard;
      default:
        return context.l10n.easy;
    }
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'medium':
        return Colors.orange.shade700;
      case 'hard':
        return Colors.red.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  Future<void> _editPackDetails() async {
    final draft = await showDialog<_PackDetailsDraft>(
      context: context,
      builder: (_) => _PackDetailsDialog(
        pack: _pack,
        styleLabel: _styleLabel,
      ),
    );

    if (draft == null) return;

    final style = wordPackStyleFor(draft.styleKey);

    final updatedPack = _pack.copyWith(
      name: draft.name,
      description: draft.description,
      iconName: style.key,
      colorHex: style.colorHex,
      updatedAt: DateTime.now(),
    );

    try {
      await widget.firestoreService.updateCurrentWordPack(
        updatedPack,
      );

      if (!mounted) return;

      setState(() {
        _pack = updatedPack;
      });

      _showMessage(context.l10n.wordPackUpdated);
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.wordPackSaveFailed);
    }
  }

  Future<void> _assignChildren() async {
    List<ChildProfile> children;

    try {
      children = await widget.firestoreService
          .getCurrentChildProfilesOnce();
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.noChildrenAvailable);
      return;
    }

    if (!mounted) return;

    final draft = await showDialog<_AssignmentDraft>(
      context: context,
      builder: (_) => _AssignmentDialog(
        children: children,
        pack: _pack,
      ),
    );

    if (draft == null) return;

    final updatedPack = _pack.copyWith(
      availableToAll: draft.availableToAll,
      assignedChildIds: draft.availableToAll
          ? const []
          : draft.selectedChildIds,
      updatedAt: DateTime.now(),
    );

    try {
      await widget.firestoreService.updateCurrentWordPack(
        updatedPack,
      );

      if (!mounted) return;

      setState(() {
        _pack = updatedPack;
      });

      _showMessage(context.l10n.assignmentsSaved);
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.wordPackSaveFailed);
    }
  }

  Future<void> _openWordDialog({
    WordItem? existingWord,
  }) async {
    final draft = await showDialog<_WordDraft>(
      context: context,
      builder: (_) => _WordDialog(
        existingWord: existingWord,
      ),
    );

    if (draft == null) return;

    final word = WordItem(
      id: existingWord?.id ?? '',
      text: draft.word,
      imageType: 'emoji',
      imageValue: draft.emoji,
      difficulty: draft.difficulty,
      hint: draft.hint,
    );

    try {
      if (existingWord == null) {
        await widget.firestoreService.addCurrentWordItem(
          packId: _pack.id,
          word: word,
        );
      } else {
        await widget.firestoreService.updateCurrentWordItem(
          packId: _pack.id,
          word: word,
        );
      }

      if (!mounted) return;
      _showMessage(context.l10n.wordSaved);
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.wordSaveFailed);
    }
  }

  Future<void> _deleteWord(WordItem word) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.deleteWord),
          content: Text(
            context.l10n.deleteWordMessage(word.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                false,
              ),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () => Navigator.pop(
                dialogContext,
                true,
              ),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await widget.firestoreService.deleteCurrentWordItem(
        packId: _pack.id,
        wordId: word.id,
      );

      if (!mounted) return;
      _showMessage(context.l10n.wordDeleted);
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.wordDeleteFailed);
    }
  }

  Widget _buildHeader(int wordCount) {
    final style = wordPackStyleFor(_pack.iconName);
    final color = wordPackColorFromHex(_pack.colorHex);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              style.icon,
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
                  _pack.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (_pack.description.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    _pack.description,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeaderChip(
                      icon: Icons.abc_rounded,
                      label: context.l10n.wordCount(wordCount),
                    ),
                    _HeaderChip(
                      icon: _pack.availableToAll
                          ? Icons.groups_rounded
                          : Icons.people_alt_rounded,
                      label: _pack.availableToAll
                          ? context.l10n.availableToEveryone
                          : context.l10n.assignedChildCount(
                              _pack.assignedChildIds.length,
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Icon(
            Icons.abc_rounded,
            size: 78,
            color: Color(0xFF66BB6A),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noWords,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.addFirstWord,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _openWordDialog(),
            icon: const Icon(Icons.add_rounded),
            label: Text(context.l10n.addWord),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = wordPackColorFromHex(_pack.colorHex);

    return Scaffold(
      appBar: AppBar(
        title: Text(_pack.name),
        actions: [
          IconButton(
            tooltip: context.l10n.editPackDetails,
            onPressed: _editPackDetails,
            icon: const Icon(Icons.edit_note_rounded),
          ),
          IconButton(
            tooltip: context.l10n.assignChildren,
            onPressed: _assignChildren,
            icon: const Icon(Icons.groups_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openWordDialog(),
        backgroundColor: color,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.addWord),
      ),
      body: StreamBuilder<List<WordItem>>(
        stream:
            widget.firestoreService.getCurrentWordItems(_pack.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _EditorMessageState(
              icon: Icons.cloud_off_rounded,
              message: context.l10n.couldNotLoadWords,
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final words = snapshot.data!;

          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF3FFF5),
                  Color(0xFFF7F4FF),
                ],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                100,
              ),
              children: [
                _buildHeader(words.length),
                const SizedBox(height: 20),
                if (words.isEmpty)
                  _buildEmptyState()
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 360,
                      mainAxisExtent: 230,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];

                      return _WordCard(
                        word: word,
                        color: color,
                        difficultyLabel:
                            _difficultyLabel(word.difficulty),
                        difficultyColor:
                            _difficultyColor(word.difficulty),
                        onEdit: () => _openWordDialog(
                          existingWord: word,
                        ),
                        onDelete: () => _deleteWord(word),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final WordItem word;
  final Color color;
  final String difficultyLabel;
  final Color difficultyColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WordCard({
    required this.word,
    required this.color,
    required this.difficultyLabel,
    required this.difficultyColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: color.withValues(alpha: 0.25),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.edit_rounded),
                        title: Text(context.l10n.edit),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                        ),
                        title: Text(context.l10n.delete),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              word.imageValue.isEmpty ? '📚' : word.imageValue,
              style: const TextStyle(fontSize: 54),
            ),
            const SizedBox(height: 8),
            Text(
              word.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: difficultyColor.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                difficultyLabel,
                style: TextStyle(
                  color: difficultyColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (word.hint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                word.hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PackDetailsDialog extends StatefulWidget {
  final WordPack pack;
  final String Function(String key) styleLabel;

  const _PackDetailsDialog({
    required this.pack,
    required this.styleLabel,
  });

  @override
  State<_PackDetailsDialog> createState() =>
      _PackDetailsDialogState();
}

class _PackDetailsDialogState
    extends State<_PackDetailsDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String _styleKey;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.pack.name);
    _descriptionController =
        TextEditingController(text: widget.pack.description);
    _styleKey = widget.pack.iconName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.editPackDetails),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.packName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: context.l10n.packDescription,
                  hintText: context.l10n.packDescriptionHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.packStyle,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: wordPackVisualStyles.map((style) {
                  return ChoiceChip(
                    selected: style.key == _styleKey,
                    avatar: Icon(
                      style.icon,
                      color: style.color,
                    ),
                    label: Text(
                      widget.styleLabel(style.key),
                    ),
                    onSelected: (_) {
                      setState(() {
                        _styleKey = style.key;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: () {
            final name = _nameController.text.trim();

            if (name.isEmpty) return;

            Navigator.pop(
              context,
              _PackDetailsDraft(
                name: name,
                description:
                    _descriptionController.text.trim(),
                styleKey: _styleKey,
              ),
            );
          },
          icon: const Icon(Icons.save_rounded),
          label: Text(context.l10n.save),
        ),
      ],
    );
  }
}

class _AssignmentDialog extends StatefulWidget {
  final List<ChildProfile> children;
  final WordPack pack;

  const _AssignmentDialog({
    required this.children,
    required this.pack,
  });

  @override
  State<_AssignmentDialog> createState() =>
      _AssignmentDialogState();
}

class _AssignmentDialogState
    extends State<_AssignmentDialog> {
  late bool _availableToAll;
  late Set<String> _selectedChildIds;

  @override
  void initState() {
    super.initState();

    _availableToAll = widget.pack.availableToAll;
    _selectedChildIds =
        widget.pack.assignedChildIds.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.assignChildren),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ChoiceChip(
                    selected: _availableToAll,
                    avatar: const Icon(Icons.groups_rounded),
                    label: Text(
                      context.l10n.availableToEveryone,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _availableToAll = true;
                        _selectedChildIds.clear();
                      });
                    },
                  ),
                  ChoiceChip(
                    selected: !_availableToAll,
                    avatar:
                        const Icon(Icons.people_alt_rounded),
                    label: Text(
                      context.l10n.selectedChildren,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _availableToAll = false;
                      });
                    },
                  ),
                ],
              ),
              if (!_availableToAll) ...[
                const SizedBox(height: 16),
                if (widget.children.isEmpty)
                  Text(context.l10n.noChildrenAvailable)
                else
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: widget.children.map((child) {
                      final selected =
                          _selectedChildIds.contains(child.id);

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
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(
              context,
              _AssignmentDraft(
                availableToAll: _availableToAll,
                selectedChildIds:
                    _selectedChildIds.toList(),
              ),
            );
          },
          icon: const Icon(Icons.save_rounded),
          label: Text(context.l10n.saveAssignments),
        ),
      ],
    );
  }
}

class _WordDialog extends StatefulWidget {
  final WordItem? existingWord;

  const _WordDialog({
    this.existingWord,
  });

  @override
  State<_WordDialog> createState() => _WordDialogState();
}

class _WordDialogState extends State<_WordDialog> {
  late final TextEditingController _wordController;
  late final TextEditingController _emojiController;
  late final TextEditingController _hintController;
  late String _difficulty;

  @override
  void initState() {
    super.initState();

    _wordController = TextEditingController(
      text: widget.existingWord?.text ?? '',
    );
    _emojiController = TextEditingController(
      text: widget.existingWord?.imageValue ?? '',
    );
    _hintController = TextEditingController(
      text: widget.existingWord?.hint ?? '',
    );
    _difficulty =
        widget.existingWord?.difficulty ?? 'easy';
  }

  @override
  void dispose() {
    _wordController.dispose();
    _emojiController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existingWord != null;

    return AlertDialog(
      title: Text(
        editing
            ? context.l10n.editWord
            : context.l10n.addWord,
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _wordController,
                autofocus: true,
                textCapitalization:
                    TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: context.l10n.word,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _emojiController,
                decoration: InputDecoration(
                  labelText: context.l10n.emoji,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _difficulty,
                decoration: InputDecoration(
                  labelText: context.l10n.difficulty,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'easy',
                    child: Text(context.l10n.easy),
                  ),
                  DropdownMenuItem(
                    value: 'medium',
                    child: Text(context.l10n.medium),
                  ),
                  DropdownMenuItem(
                    value: 'hard',
                    child: Text(context.l10n.hard),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _difficulty = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _hintController,
                textCapitalization:
                    TextCapitalization.sentences,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: context.l10n.hintOptional,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: () {
            final word = _wordController.text.trim();

            if (word.isEmpty) return;

            Navigator.pop(
              context,
              _WordDraft(
                word: word,
                emoji: _emojiController.text.trim().isEmpty
                    ? '📚'
                    : _emojiController.text.trim(),
                difficulty: _difficulty,
                hint: _hintController.text.trim(),
              ),
            );
          },
          icon: const Icon(Icons.save_rounded),
          label: Text(context.l10n.save),
        ),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorMessageState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EditorMessageState({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 72,
              color: const Color(0xFF66BB6A),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackDetailsDraft {
  final String name;
  final String description;
  final String styleKey;

  const _PackDetailsDraft({
    required this.name,
    required this.description,
    required this.styleKey,
  });
}

class _AssignmentDraft {
  final bool availableToAll;
  final List<String> selectedChildIds;

  const _AssignmentDraft({
    required this.availableToAll,
    required this.selectedChildIds,
  });
}

class _WordDraft {
  final String word;
  final String emoji;
  final String difficulty;
  final String hint;

  const _WordDraft({
    required this.word,
    required this.emoji,
    required this.difficulty,
    required this.hint,
  });
}