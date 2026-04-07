import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/staff_profile.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';
import '../widgets/icon_sequence_picker.dart';

class AddProfilePage extends StatefulWidget {
  const AddProfilePage({super.key});

  @override
  State<AddProfilePage> createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  final FirestoreService firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  bool isStaff = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  List<String> childIconSequence = [];
  List<String> childIconSequenceConfirm = [];
  bool confirmingChildSequence = false;
  int pickerResetVersion = 0;

  bool _matches(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _restartChildSequenceSetup() {
    setState(() {
      childIconSequence = [];
      childIconSequenceConfirm = [];
      confirmingChildSequence = false;
      pickerResetVersion++;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final teacherUid = FirebaseAuth.instance.currentUser!.uid;
    final name = nameController.text.trim();

    try {
      if (isStaff) {
        final role = roleController.text.trim();
        final profile = StaffProfile(
          id: '',
          name: name,
          role: role,
          teacherUid: teacherUid,
        );
        await firestoreService.addStaffProfile(teacherUid, profile);
      } else {
        if (childIconSequence.length != 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please choose a 3-icon unlock sequence')),
          );
          return;
        }

        if (!confirmingChildSequence) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please confirm the child unlock sequence')),
          );
          return;
        }

        if (childIconSequenceConfirm.length != 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please tap the same 3 icons again to confirm')),
          );
          return;
        }

        if (!_matches(childIconSequence, childIconSequenceConfirm)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sequences did not match. Please try again.')),
          );
          _restartChildSequenceSetup();
          return;
        }

        final age = int.tryParse(ageController.text.trim()) ?? 0;
        final profile = ChildProfile(
          id: '',
          name: name,
          age: age,
          teacherUid: teacherUid,
          zone: null,
          accessMode: 'iconSequence',
          iconSequence: childIconSequence,
        );

        await firestoreService.addChildProfile(teacherUid, profile);
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: Text('Profile "$name" created successfully.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    roleController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isStaff ? 'Add Staff Profile' : 'Add Child Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Staff'),
                    selected: isStaff,
                    onSelected: (selected) {
                      setState(() {
                        isStaff = true;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('Child'),
                    selected: !isStaff,
                    onSelected: (selected) {
                      setState(() {
                        isStaff = false;
                        _restartChildSequenceSetup();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              if (isStaff)
                TextFormField(
                  controller: roleController,
                  decoration: const InputDecoration(labelText: 'Role'),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Role is required' : null,
                ),

              if (!isStaff) ...[
                TextFormField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Age is required';
                    if (int.tryParse(val.trim()) == null) return 'Age must be a number';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  confirmingChildSequence
                      ? 'Confirm Child Unlock Sequence'
                      : 'Set Child Unlock Sequence',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  confirmingChildSequence
                      ? 'Tap the same 3 icons again to confirm.'
                      : 'Ask the child to pick 3 icons in order.',
                ),
                const SizedBox(height: 12),
                IconSequencePicker(
                  resetKey: ValueKey(pickerResetVersion),
                  requiredLength: 3,
                  onChanged: (sequence) {
                    if (confirmingChildSequence) {
                      childIconSequenceConfirm = List<String>.from(sequence);
                    } else {
                      childIconSequence = List<String>.from(sequence);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: _restartChildSequenceSetup,
                      child: const Text('Start Over'),
                    ),
                    const SizedBox(width: 8),
                    if (!confirmingChildSequence)
                      ElevatedButton(
                        onPressed: () {
                          if (childIconSequence.length != 3) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please choose 3 icons first'),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            confirmingChildSequence = true;
                            childIconSequenceConfirm = [];
                            pickerResetVersion++;
                          });
                        },
                        child: const Text('Next'),
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save ${isStaff ? "Staff" : "Child"} Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}