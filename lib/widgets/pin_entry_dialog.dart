import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

class PinEntryDialog extends StatefulWidget {
  final String correctPin;

  const PinEntryDialog({super.key, required this.correctPin});

  @override
  PinEntryDialogState createState() => PinEntryDialogState();
}

class PinEntryDialogState extends State<PinEntryDialog> {
  final TextEditingController _pinController = TextEditingController();
  String? _error;

  void _validatePin() {
    final enteredPin = _pinController.text;
    if (enteredPin == widget.correctPin) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _error = context.l10n.incorrectPin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.enterPin),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: InputDecoration(
              labelText: context.l10n.pin,
              errorText: _error,
            ),
            maxLength: 4,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _validatePin,
          child: Text(context.l10n.submit),
        ),
      ],
    );
  }
}
