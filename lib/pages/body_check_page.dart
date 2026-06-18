import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../models/body_check_report.dart';
import '../services/firestore_service.dart';

class BodyCheckPage extends StatefulWidget {
  final ChildProfile child;
  final FirestoreService firestoreService;

  const BodyCheckPage({
    super.key,
    required this.child,
    required this.firestoreService,
  });

  @override
  State<BodyCheckPage> createState() => _BodyCheckPageState();
}

class _BodyCheckPageState extends State<BodyCheckPage> {
  String? selectedBodyPart;
  int? selectedPainLevel;
  String? selectedPainType;
  bool isSaving = false;

  final List<String> bodyParts = [
    'Head',
    'Eyes',
    'Ears',
    'Mouth / Teeth',
    'Throat',
    'Chest',
    'Tummy',
    'Back',
    'Arm',
    'Hand',
    'Leg',
    'Foot',
  ];

  final List<Map<String, dynamic>> painLevels = [
    {'label': 'A little sore', 'level': 1, 'icon': Icons.sentiment_neutral},
    {'label': 'Hurts', 'level': 2, 'icon': Icons.sentiment_dissatisfied},
    {
      'label': 'Hurts a lot',
      'level': 3,
      'icon': Icons.sentiment_very_dissatisfied,
    },
  ];

  final List<String> painTypes = [
    'Sore',
    'Sharp',
    'Burning',
    'Itchy',
    'Sick',
    'Tired',
  ];

  Future<void> submitReport() async {
    if (selectedBodyPart == null ||
        selectedPainLevel == null ||
        selectedPainType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose where, how much, and what kind of pain.'),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    final report = BodyCheckReport(
      id: '',
      childId: widget.child.id,
      childName: widget.child.name,
      bodyPart: selectedBodyPart!,
      painLevel: selectedPainLevel!,
      painType: selectedPainType!,
      timestamp: DateTime.now(),
      checked: false,
    );

    await widget.firestoreService.addCurrentBodyCheckReport(report);

    if (!mounted) return;

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Body Check sent to staff.')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Check'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Where does it hurt?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bodyParts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final part = bodyParts[index];
                final isSelected = selectedBodyPart == part;

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.blue : null,
                    foregroundColor: isSelected ? Colors.white : null,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedBodyPart = part;
                    });
                  },
                  child: Text(
                    part,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            const Text(
              'How much does it hurt?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Column(
              children: painLevels.map((pain) {
                final isSelected = selectedPainLevel == pain['level'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.red : null,
                        foregroundColor: isSelected ? Colors.white : null,
                      ),
                      icon: Icon(pain['icon'], size: 32),
                      label: Text(
                        pain['label'],
                        style: const TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedPainLevel = pain['level'];
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            const Text(
              'What does it feel like?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: painTypes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final type = painTypes[index];
                final isSelected = selectedPainType == type;

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.purple : null,
                    foregroundColor: isSelected ? Colors.white : null,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedPainType = type;
                    });
                  },
                  child: Text(
                    type,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                icon: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  isSaving ? 'Sending...' : 'Tell Staff',
                  style: const TextStyle(fontSize: 22),
                ),
                onPressed: isSaving ? null : submitReport,
              ),
            ),
          ],
        ),
      ),
    );
  }
}