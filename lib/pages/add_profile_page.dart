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
            const SnackBar(
              content: Text('Please choose a 3-icon unlock sequence'),
            ),
          );
          return;
        }

        if (!confirmingChildSequence) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please confirm the child unlock sequence'),
            ),
          );
          return;
        }

        if (childIconSequenceConfirm.length != 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please tap the same 3 icons again to confirm'),
            ),
          );
          return;
        }

        if (!_matches(childIconSequence, childIconSequenceConfirm)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sequences did not match. Please try again.'),
            ),
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
    final colourScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isStaff ? 'Add Staff Profile' : 'Add Child Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 3,
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Container(
                              width: 78,
                              height: 78,
                              decoration: BoxDecoration(
                                color: isStaff
                                    ? colourScheme.primaryContainer
                                    : const Color(0xFF26A69A).withOpacity(0.18),
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Icon(
                                isStaff
                                    ? Icons.person_add_alt_1_rounded
                                    : Icons.child_care_rounded,
                                size: 44,
                                color: isStaff
                                    ? colourScheme.onPrimaryContainer
                                    : const Color(0xFF26A69A),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isStaff
                                  ? 'Create a staff profile'
                                  : 'Create a child profile',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isStaff
                                  ? 'Staff profiles use the account PIN for access.'
                                  : 'Child profiles can use a simple 3-icon unlock sequence.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Card(
                      elevation: 2,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: _ProfileTypeButton(
                                label: 'Staff',
                                icon: Icons.person,
                                selected: isStaff,
                                color: colourScheme.primary,
                                onTap: () {
                                  setState(() {
                                    isStaff = true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ProfileTypeButton(
                                label: 'Child',
                                icon: Icons.child_care,
                                selected: !isStaff,
                                color: const Color(0xFF26A69A),
                                onTap: () {
                                  setState(() {
                                    isStaff = false;
                                    _restartChildSequenceSetup();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Card(
                      elevation: 2,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              isStaff ? 'Staff Details' : 'Child Details',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                prefixIcon: Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            if (isStaff)
                              TextFormField(
                                controller: roleController,
                                decoration: const InputDecoration(
                                  labelText: 'Role',
                                  prefixIcon: Icon(Icons.work_outline),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Role is required';
                                  }
                                  return null;
                                },
                              ),

                            if (!isStaff) ...[
                              TextFormField(
                                controller: ageController,
                                decoration: const InputDecoration(
                                  labelText: 'Age',
                                  prefixIcon:
                                      Icon(Icons.cake_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Age is required';
                                  }

                                  if (int.tryParse(val.trim()) == null) {
                                    return 'Age must be a number';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 22),

                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF26A69A)
                                      .withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.lock_open_rounded,
                                          color: Color(0xFF26A69A),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            confirmingChildSequence
                                                ? 'Confirm Child Unlock Sequence'
                                                : 'Set Child Unlock Sequence',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      confirmingChildSequence
                                          ? 'Tap the same 3 icons again to confirm.'
                                          : 'Ask the child to pick 3 icons in order.',
                                    ),
                                    const SizedBox(height: 14),
                                    IconSequencePicker(
                                      resetKey: ValueKey(pickerResetVersion),
                                      requiredLength: 3,
                                      onChanged: (sequence) {
                                        if (confirmingChildSequence) {
                                          childIconSequenceConfirm =
                                              List<String>.from(sequence);
                                        } else {
                                          childIconSequence =
                                              List<String>.from(sequence);
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed:
                                              _restartChildSequenceSetup,
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Start Over'),
                                        ),
                                        if (!confirmingChildSequence)
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              if (childIconSequence.length !=
                                                  3) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Please choose 3 icons first',
                                                    ),
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
                                            icon: const Icon(
                                              Icons.arrow_forward,
                                            ),
                                            label: const Text('Next'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save_rounded),
                      label: Text(
                        'Save ${isStaff ? "Staff" : "Child"} Profile',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ProfileTypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withOpacity(0.16) : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? color : Theme.of(context).dividerColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: selected ? color : Theme.of(context).iconTheme.color,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      color: selected ? color : null,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}