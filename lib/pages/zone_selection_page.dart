import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';

class ZoneSelectionPage extends StatefulWidget {
  final String teacherUid;
  final ChildProfile child;

  const ZoneSelectionPage({
    super.key,
    required this.teacherUid,
    required this.child,
  });

  @override
  State<ZoneSelectionPage> createState() => _ZoneSelectionPageState();
}

class _ZoneSelectionPageState extends State<ZoneSelectionPage> {
  bool _colorFilled = false;
  Color _selectedColor = Colors.white;

  final Map<String, Color> zoneColors = {
    'green': const Color(0xFF33975F),
    'red': const Color(0xFFC72D2C),
    'yellow': const Color(0xFFF6DE39),
    'blue': const Color(0xFF425DAC),
  };

  Future<void> _selectZone(String zone) async {
    final selected = zoneColors[zone]!;

    setState(() {
      _selectedColor = selected;
      _colorFilled = true;
    });

    final updatedProfile = widget.child.copyWith(zone: zone);
    await FirestoreService().updateChildProfile(widget.teacherUid, updatedProfile);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _colorFilled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorFilled ? _selectedColor : Colors.white,
      appBar: AppBar(
        title: const Text('Select Your Zone'),
        backgroundColor: _colorFilled ? _selectedColor : Colors.blue,
      ),
      body: !_colorFilled
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: zoneColors.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GestureDetector(
                    onTap: () => _selectZone(entry.key),
                    child: Container(
                      width: double.infinity,
                      height: 80,
                      color: entry.value,
                      alignment: Alignment.center,
                      child: Text(
                        entry.key.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          : const SizedBox.expand(),
    );
  }
}