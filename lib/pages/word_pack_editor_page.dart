import 'package:flutter/material.dart';
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
  Future<void> _addWord() async {
    final wordController = TextEditingController();
    final emojiController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Word'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: wordController,
                decoration: const InputDecoration(
                  labelText: 'Word',
                ),
              ),
              TextField(
                controller: emojiController,
                decoration: const InputDecoration(
                  labelText: 'Emoji',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (wordController.text.trim().isEmpty) return;

    final word = WordItem(
      id: '',
      text: wordController.text.trim(),
      imageType: 'emoji',
      imageValue:
          emojiController.text.trim().isEmpty
              ? '📚'
              : emojiController.text.trim(),
    );

    await widget.firestoreService.addWordItem(
      teacherUid: widget.teacherUid,
      packId: widget.pack.id,
      word: word,
    );
  }

  Future<void> _deleteWord(WordItem word) async {
    await widget.firestoreService.deleteWordItem(
      teacherUid: widget.teacherUid,
      packId: widget.pack.id,
      wordId: word.id,
    );
  }

  Future<void> _assignChildren() async {
  final children = await widget.firestoreService
      .getChildProfilesOnce(widget.teacherUid);

  if (!mounted) return;

  final selectedChildren =
      widget.pack.assignedChildIds.toSet();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text(
              'Assign Children',
            ),
            content: SizedBox(
              width: 300,
              child: ListView(
                shrinkWrap: true,
                children: children.map((child) {
                  final isSelected =
                      selectedChildren.contains(
                    child.id,
                  );

                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(child.name),
                    onChanged: (_) {
                      setDialogState(() {
                        if (isSelected) {
                          selectedChildren.remove(
                            child.id,
                          );
                        } else {
                          selectedChildren.add(
                            child.id,
                          );
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(
                  context,
                  false,
                ),
                child: const Text(
                  'Cancel',
                ),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pop(
                  context,
                  true,
                ),
                child: const Text(
                  'Save',
                ),
              ),
            ],
          );
        },
      );
    },
  );

  if (confirmed != true) return;

  final updatedPack =
      widget.pack.copyWith(
    assignedChildIds:
        selectedChildren.toList(),
  );

  await widget.firestoreService
      .updateWordPack(
    teacherUid: widget.teacherUid,
    pack: updatedPack,
  );

  if (!mounted) return;

  Navigator.pop(context);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pack.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: _assignChildren,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWord,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<WordItem>>(
        stream:
            widget.firestoreService.getWordItems(
          teacherUid: widget.teacherUid,
          packId: widget.pack.id,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final words = snapshot.data!;

          if (words.isEmpty) {
            return const Center(
              child: Text(
                'No words yet.\nTap + to add one.',
                textAlign:
                    TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: words.length,
            itemBuilder: (
              context,
              index,
            ) {
              final word = words[index];

              return Card(
                margin:
                    const EdgeInsets.all(8),
                child: ListTile(
                  leading: Text(
                    word.imageValue,
                    style:
                        const TextStyle(
                      fontSize: 28,
                    ),
                  ),
                  title:
                      Text(word.text),
                  trailing:
                      IconButton(
                    icon: const Icon(
                      Icons.delete,
                    ),
                    onPressed: () =>
                        _deleteWord(
                      word,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}