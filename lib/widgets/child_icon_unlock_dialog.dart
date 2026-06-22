import 'package:flutter/material.dart';
import '../data/profile_unlock_icons.dart';
import '../l10n/l10n.dart';
import '../l10n/profile_unlock_localizations.dart';

class ChildIconUnlockDialog extends StatefulWidget {
  final List<String> correctSequence;
  final String childName;

  const ChildIconUnlockDialog({
    super.key,
    required this.correctSequence,
    required this.childName,
  });

  @override
  State<ChildIconUnlockDialog> createState() => _ChildIconUnlockDialogState();
}

class _ChildIconUnlockDialogState extends State<ChildIconUnlockDialog> {
  final List<String> enteredSequence = [];

  void _handleTap(String keyName) {
    if (enteredSequence.length >= widget.correctSequence.length) return;

    setState(() {
      enteredSequence.add(keyName);
    });

    if (enteredSequence.length == widget.correctSequence.length) {
      final isCorrect = _matches(enteredSequence, widget.correctSequence);

      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;

        if (isCorrect) {
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            enteredSequence.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.wrongIconSequence)),
          );
        }
      });
    }
  }

  bool _matches(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _clear() {
    setState(() {
      enteredSequence.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.unlockChild(widget.childName)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.tapPicturesInOrder),
            const SizedBox(height: 12),
            Text(
              context.l10n.enteredCount(
                enteredSequence.length,
                widget.correctSequence.length,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  profileUnlockIcons.map((option) {
                    return ElevatedButton(
                      onPressed: () => _handleTap(option.keyName),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(option.icon, size: 32),
                          const SizedBox(height: 4),
                          Text(
                            localizedProfileUnlockIcon(
                              context.l10n,
                              option.keyName,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _clear, child: Text(context.l10n.clear)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.cancel),
        ),
      ],
    );
  }
}
