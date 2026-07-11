import 'package:flutter/material.dart';
import '../data/word_learning_visuals.dart';
import '../l10n/l10n.dart';
import '../models/child_profile.dart';
import '../models/media_asset.dart';
import '../models/word_item.dart';
import '../models/word_pack.dart';
import '../services/firestore_service.dart';
import '../data/app_icon_catalog.dart';
import '../widgets/app_icon_picker_dialog.dart';
import '../widgets/media_asset_picker_dialog.dart';

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
  State<WordPackEditorPage> createState() => _WordPackEditorPageState();
}

class _WordPackEditorPageState extends State<WordPackEditorPage> {
  late WordPack _pack;

  @override
  void initState() {
    super.initState();
    _pack = widget.pack;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
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
      builder: (_) => _PackDetailsDialog(pack: _pack),
    );

    if (draft == null) return;

    final updatedPack = _pack.copyWith(
      name: draft.name,
      description: draft.description,
      iconName: appIconKeyFor(draft.styleKey, fallbackKey: 'abc'),
      colorHex: _pack.colorHex,
      updatedAt: DateTime.now(),
    );

    try {
      await widget.firestoreService.updateCurrentWordPack(updatedPack);

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
      children = await widget.firestoreService.getCurrentChildProfilesOnce();
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.noChildrenAvailable);
      return;
    }

    if (!mounted) return;

    final draft = await showDialog<_AssignmentDraft>(
      context: context,
      builder: (_) => _AssignmentDialog(children: children, pack: _pack),
    );

    if (draft == null) return;

    final updatedPack = _pack.copyWith(
      availableToAll: draft.availableToAll,
      assignedChildIds:
          draft.availableToAll ? const [] : draft.selectedChildIds,
      updatedAt: DateTime.now(),
    );

    try {
      await widget.firestoreService.updateCurrentWordPack(updatedPack);

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

  Future<void> _openWordDialog({WordItem? existingWord}) async {
    final draft = await showDialog<_WordDraft>(
      context: context,
      builder:
          (_) => _WordDialog(
            firestoreService: widget.firestoreService,
            existingWord: existingWord,
          ),
    );

    if (draft == null) return;

    final word = WordItem(
      id: existingWord?.id ?? '',
      text: draft.word,
      imageType: draft.imageType,
      imageValue: draft.imageValue,
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
          content: Text(context.l10n.deleteWordMessage(word.text)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
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
    final color = wordPackColorFromHex(_pack.colorHex);
    final icon = appIconForKey(_pack.iconName, fallbackKey: 'abc');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.72)],
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
            child: Icon(icon, color: Colors.white, size: 44),
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
                    style: const TextStyle(color: Colors.white),
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
                      icon:
                          _pack.availableToAll
                              ? Icons.groups_rounded
                              : Icons.people_alt_rounded,
                      label:
                          _pack.availableToAll
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
          const Icon(Icons.abc_rounded, size: 78, color: Color(0xFF66BB6A)),
          const SizedBox(height: 16),
          Text(
            context.l10n.noWords,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(context.l10n.addFirstWord, textAlign: TextAlign.center),
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
        stream: widget.firestoreService.getCurrentWordItems(_pack.id),
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
                colors: [Color(0xFFF3FFF5), Color(0xFFF7F4FF)],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
              children: [
                _buildHeader(words.length),
                const SizedBox(height: 20),
                if (words.isEmpty)
                  _buildEmptyState()
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 360,
                          mainAxisExtent: 260,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];

                      return _WordCard(
                        word: word,
                        color: color,
                        difficultyLabel: _difficultyLabel(word.difficulty),
                        difficultyColor: _difficultyColor(word.difficulty),
                        onEdit: () => _openWordDialog(existingWord: word),
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
        side: BorderSide(color: color.withValues(alpha: 0.25), width: 2),
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
                  itemBuilder:
                      (context) => [
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
            _WordVisual(word: word, color: color, size: 54),
            const SizedBox(height: 8),
            Text(
              word.text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

  const _PackDetailsDialog({required this.pack});

  @override
  State<_PackDetailsDialog> createState() => _PackDetailsDialogState();
}

class _PackDetailsDialogState extends State<_PackDetailsDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String _styleKey;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.pack.name);
    _descriptionController = TextEditingController(
      text: widget.pack.description,
    );
    _styleKey = appIconKeyFor(widget.pack.iconName, fallbackKey: 'abc');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _chooseIcon() async {
    final selected = await showAppIconPickerDialog(
      context: context,
      selectedKey: _styleKey,
      title: context.l10n.packStyle,
      categories: const [
        AppIconCategory.learning,
        AppIconCategory.feelings,
        AppIconCategory.dailyLife,
        AppIconCategory.animals,
        AppIconCategory.food,
        AppIconCategory.play,
        AppIconCategory.nature,
        AppIconCategory.objects,
      ],
    );

    if (selected == null) return;

    setState(() {
      _styleKey = selected.key;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIcon = appIconOptionForKey(_styleKey, fallbackKey: 'abc');
    final packColor = wordPackColorFromHex(widget.pack.colorHex);

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
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _chooseIcon,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: packColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: packColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: packColor.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          selectedIcon.icon,
                          color: packColor,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedIcon.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.l10n.chooseIcon,
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.edit_rounded, color: packColor),
                    ],
                  ),
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
            final name = _nameController.text.trim();

            if (name.isEmpty) return;

            Navigator.pop(
              context,
              _PackDetailsDraft(
                name: name,
                description: _descriptionController.text.trim(),
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

  const _AssignmentDialog({required this.children, required this.pack});

  @override
  State<_AssignmentDialog> createState() => _AssignmentDialogState();
}

class _AssignmentDialogState extends State<_AssignmentDialog> {
  late bool _availableToAll;
  late Set<String> _selectedChildIds;

  @override
  void initState() {
    super.initState();

    _availableToAll = widget.pack.availableToAll;
    _selectedChildIds = widget.pack.assignedChildIds.toSet();
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
                    label: Text(context.l10n.availableToEveryone),
                    onSelected: (_) {
                      setState(() {
                        _availableToAll = true;
                        _selectedChildIds.clear();
                      });
                    },
                  ),
                  ChoiceChip(
                    selected: !_availableToAll,
                    avatar: const Icon(Icons.people_alt_rounded),
                    label: Text(context.l10n.selectedChildren),
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
                    children:
                        widget.children.map((child) {
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
                selectedChildIds: _selectedChildIds.toList(),
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
  final FirestoreService firestoreService;
  final WordItem? existingWord;

  const _WordDialog({required this.firestoreService, this.existingWord});

  @override
  State<_WordDialog> createState() => _WordDialogState();
}

class _WordDialogState extends State<_WordDialog> {
  late final TextEditingController _wordController;
  late final TextEditingController _hintController;
  late String _imageType;
  late String _imageValue;
  late String _difficulty;

  @override
  void initState() {
    super.initState();

    _wordController = TextEditingController(
      text: widget.existingWord?.text ?? '',
    );
    _imageType = widget.existingWord?.imageType ?? 'icon';
    _imageValue =
        widget.existingWord?.imageValue.trim().isNotEmpty == true
            ? widget.existingWord!.imageValue
            : 'book';
    _hintController = TextEditingController(
      text: widget.existingWord?.hint ?? '',
    );
    _difficulty = widget.existingWord?.difficulty ?? 'easy';
  }

  @override
  void dispose() {
    _wordController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  Future<void> _chooseIcon() async {
    final selected = await showAppIconPickerDialog(
      context: context,
      selectedKey: _imageType == 'icon' ? _imageValue : null,
      title: context.l10n.chooseIcon,
      categories: const [
        AppIconCategory.learning,
        AppIconCategory.feelings,
        AppIconCategory.dailyLife,
        AppIconCategory.animals,
        AppIconCategory.food,
        AppIconCategory.play,
        AppIconCategory.health,
        AppIconCategory.nature,
        AppIconCategory.objects,
      ],
    );

    if (selected == null) return;

    setState(() {
      _imageType = 'icon';
      _imageValue = selected.key;
    });
  }

  Future<void> _chooseMediaImage() async {
    final selected = await showMediaAssetPickerDialog(
      context: context,
      firestoreService: widget.firestoreService,
      type: MediaAssetType.image,
      title: 'Choose word image',
    );

    if (selected == null) return;

    setState(() {
      _imageType = 'media';
      _imageValue = mediaVisualValue(selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existingWord != null;

    return AlertDialog(
      title: Text(editing ? context.l10n.editWord : context.l10n.addWord),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _wordController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: context.l10n.word,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              _WordVisualPickerCard(
                imageType: _imageType,
                imageValue: _imageValue,
                onChooseIcon: _chooseIcon,
                onChooseMedia: _chooseMediaImage,
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
                textCapitalization: TextCapitalization.sentences,
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
                imageType: _imageType,
                imageValue:
                    _imageType == 'media'
                        ? _imageValue
                        : (_imageValue.trim().isEmpty
                            ? appIconKeyFor('book', fallbackKey: 'book')
                            : appIconKeyFor(_imageValue, fallbackKey: 'book')),
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

  const _HeaderChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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

  const _EditorMessageState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: const Color(0xFF66BB6A)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordVisual extends StatelessWidget {
  final WordItem word;
  final Color color;
  final double size;

  const _WordVisual({
    required this.word,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (word.imageType == 'media' || isMediaVisualValue(word.imageValue)) {
      return MediaImagePreview(value: word.imageValue, size: size);
    }

    if (word.imageType == 'icon') {
      return Icon(
        appIconForKey(word.imageValue, fallbackKey: 'book'),
        size: size,
        color: color,
      );
    }

    return Text(
      word.imageValue.isEmpty ? '📚' : word.imageValue,
      style: TextStyle(fontSize: size),
    );
  }
}

class _WordVisualPickerCard extends StatelessWidget {
  final String imageType;
  final String imageValue;
  final VoidCallback onChooseIcon;
  final VoidCallback onChooseMedia;

  const _WordVisualPickerCard({
    required this.imageType,
    required this.imageValue,
    required this.onChooseIcon,
    required this.onChooseMedia,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;
    final isMedia = imageType == 'media' || isMediaVisualValue(imageValue);
    final title =
        isMedia
            ? 'Media Library image'
            : appIconOptionForKey(imageValue, fallbackKey: 'book').label;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF66BB6A).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF66BB6A).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF66BB6A).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child:
                isMedia
                    ? MediaImagePreview(
                      value: imageValue,
                      size: 56,
                      borderRadius: BorderRadius.circular(18),
                    )
                    : Icon(
                      appIconForKey(imageValue, fallbackKey: 'book'),
                      color: const Color(0xFF2E7D32),
                      size: 30,
                    ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isMedia ? 'Uploaded image selected' : context.l10n.chooseIcon,
                  style: TextStyle(
                    color: colourScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onChooseIcon,
                      icon: const Icon(Icons.apps_rounded),
                      label: const Text('Icon'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: onChooseMedia,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Media image'),
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
  final String imageType;
  final String imageValue;
  final String difficulty;
  final String hint;

  const _WordDraft({
    required this.word,
    required this.imageType,
    required this.imageValue,
    required this.difficulty,
    required this.hint,
  });
}
