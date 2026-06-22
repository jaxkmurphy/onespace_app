import 'package:flutter/material.dart';
import 'icon_sequence_picker.dart';
import '../l10n/l10n.dart';

class ChildIconSequenceSetupDialog extends StatefulWidget {
  final String childName;

  const ChildIconSequenceSetupDialog({super.key, required this.childName});

  @override
  State<ChildIconSequenceSetupDialog> createState() =>
      _ChildIconSequenceSetupDialogState();
}

class _ChildIconSequenceSetupDialogState
    extends State<ChildIconSequenceSetupDialog> {
  List<String> firstSequence = [];
  List<String> confirmSequence = [];
  bool confirming = false;
  int pickerResetVersion = 0;

  bool _matches(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _restartSetup() {
    setState(() {
      firstSequence = [];
      confirmSequence = [];
      confirming = false;
      pickerResetVersion++;
    });
  }

  void _continueOrSave() {
    if (!confirming) {
      if (firstSequence.length != 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.chooseThreeIconsFirst)),
        );
        return;
      }

      setState(() {
        confirming = true;
        confirmSequence = [];
        pickerResetVersion++;
      });
      return;
    }

    if (confirmSequence.length != 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.confirmIconSequence)));
      return;
    }

    if (!_matches(firstSequence, confirmSequence)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.iconSequencesDoNotMatch)),
      );
      _restartSetup();
      return;
    }

    Navigator.of(context).pop(firstSequence);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.resetUnlockForChild(widget.childName)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              confirming
                  ? context.l10n.tapSameIconsConfirm
                  : context.l10n.chooseIconsInOrder,
            ),
            const SizedBox(height: 16),
            IconSequencePicker(
              resetKey: ValueKey(pickerResetVersion),
              requiredLength: 3,
              onChanged: (sequence) {
                if (confirming) {
                  confirmSequence = List<String>.from(sequence);
                } else {
                  firstSequence = List<String>.from(sequence);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _restartSetup,
          child: Text(context.l10n.startOver),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _continueOrSave,
          child: Text(confirming ? context.l10n.save : context.l10n.next),
        ),
      ],
    );
  }
}
