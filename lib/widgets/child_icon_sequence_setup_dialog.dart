import 'package:flutter/material.dart';
import 'icon_sequence_picker.dart';

class ChildIconSequenceSetupDialog extends StatefulWidget {
  final String childName;

  const ChildIconSequenceSetupDialog({
    super.key,
    required this.childName,
  });

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
          const SnackBar(content: Text('Please choose 3 icons first')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm the 3-icon sequence')),
      );
      return;
    }

    if (!_matches(firstSequence, confirmSequence)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sequences did not match. Try again.')),
      );
      _restartSetup();
      return;
    }

    Navigator.of(context).pop(firstSequence);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reset unlock for ${widget.childName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              confirming
                  ? 'Tap the same 3 icons again to confirm'
                  : 'Choose 3 icons in order',
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
          child: const Text('Start Over'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _continueOrSave,
          child: Text(confirming ? 'Save' : 'Next'),
        ),
      ],
    );
  }
}