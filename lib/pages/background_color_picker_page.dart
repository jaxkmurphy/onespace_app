import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';

class BackgroundColorPickerPage extends StatelessWidget {
  final ChildProfile child;
  final FirestoreService firestoreService;

  BackgroundColorPickerPage({
    super.key,
    required this.child,
    required this.firestoreService,
  });

  final List<String> colorOptions = [
    '#FFFFFF', // White
    '#FFEBEE', // Light Red
    '#E3F2FD', // Light Blue
    '#E8F5E9', // Light Green
    '#FFFDE7', // Light Yellow
    '#F3E5F5', // Light Purple
    '#ECEFF1', // Light Grey
    '#FFE0B2', // Light Orange
  ];

  void _updateColor(BuildContext context, String color) async {
    final updatedChild = child.copyWith(backgroundColorHex: color);
    await firestoreService.updateChildProfile(child.teacherUid, updatedChild);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Background Color")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: colorOptions.map((hex) {
          return GestureDetector(
            onTap: () => _updateColor(context, hex),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(int.parse(hex.replaceFirst('#', '0xff'))),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black26, width: 2),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}