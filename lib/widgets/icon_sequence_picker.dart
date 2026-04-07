import 'package:flutter/material.dart';
import '../data/profile_unlock_icons.dart';

class IconSequencePicker extends StatefulWidget {
  final void Function(List<String>) onChanged;
  final int requiredLength;
  final List<String> initialValue;
  final Key? resetKey;

  const IconSequencePicker({
    super.key,
    required this.onChanged,
    this.requiredLength = 3,
    this.initialValue = const [],
    this.resetKey,
  });

  @override
  State<IconSequencePicker> createState() => _IconSequencePickerState();
}

class _IconSequencePickerState extends State<IconSequencePicker> {
  late List<String> selected;

  @override
  void initState() {
    super.initState();
    selected = List<String>.from(widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant IconSequencePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetKey != widget.resetKey) {
      setState(() {
        selected = List<String>.from(widget.initialValue);
      });
      widget.onChanged(selected);
    }
  }

  void _selectIcon(String keyName) {
    if (selected.length >= widget.requiredLength) return;

    setState(() {
      selected.add(keyName);
    });

    widget.onChanged(List<String>.from(selected));
  }

  void _clearSelection() {
    setState(() {
      selected.clear();
    });
    widget.onChanged(List<String>.from(selected));
  }

  String _labelFor(String keyName) {
    for (final icon in profileUnlockIcons) {
      if (icon.keyName == keyName) return icon.label;
    }
    return keyName;
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabels = selected.map(_labelFor).join(' → ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selected.isEmpty ? 'Selected: None' : 'Selected: $selectedLabels',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: profileUnlockIcons.map((option) {
            return ElevatedButton(
              onPressed: () => _selectIcon(option.keyName),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(option.icon, size: 32),
                  const SizedBox(height: 4),
                  Text(option.label),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('${selected.length}/${widget.requiredLength} selected'),
            const SizedBox(width: 12),
            TextButton(
              onPressed: _clearSelection,
              child: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }
}