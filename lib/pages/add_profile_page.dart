import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/staff_profile.dart';
import '../models/child_profile.dart';
import '../services/classroom_session_service.dart';
import '../services/firestore_service.dart';
import '../widgets/icon_sequence_picker.dart';
import '../l10n/l10n.dart';

class AddProfilePage extends StatefulWidget {
  final String? schoolId;
  final String? classroomId;
  final String? classroomName;

  const AddProfilePage({
    super.key,
    this.schoolId,
    this.classroomId,
    this.classroomName,
  });

  @override
  State<AddProfilePage> createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  final FirestoreService firestoreService = FirestoreService();
  final ClassroomSessionService session = ClassroomSessionService.instance;
  final _formKey = GlobalKey<FormState>();

  bool isStaff = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  List<String> childIconSequence = [];
  List<String> childIconSequenceConfirm = [];
  bool confirmingChildSequence = false;
  int pickerResetVersion = 0;

  bool get _isClassroomMode => session.hasClassroomSession;

  @override
  void initState() {
    super.initState();

    if (widget.schoolId != null &&
        widget.classroomId != null &&
        widget.classroomName != null) {
      session.setSession(
        schoolId: widget.schoolId!,
        classroomId: widget.classroomId!,
        classroomName: widget.classroomName!,
      );
    }
  }

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

    final name = nameController.text.trim();

    try {
      if (isStaff) {
        final role = roleController.text.trim();

        final profile = StaffProfile(
          id: '',
          name: name,
          role: role,
          teacherUid:
              _isClassroomMode
                  ? session.requireClassroomId
                  : FirebaseAuth.instance.currentUser!.uid,
        );

        await firestoreService.addCurrentStaffProfile(profile);
      } else {
        if (childIconSequence.length != 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.chooseUnlockSequence)),
          );
          return;
        }

        if (!confirmingChildSequence) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.confirmChildUnlockPrompt)),
          );
          return;
        }

        if (childIconSequenceConfirm.length != 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.confirmThreeIconsPrompt)),
          );
          return;
        }

        if (!_matches(childIconSequence, childIconSequenceConfirm)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.sequencesDoNotMatch)),
          );
          _restartChildSequenceSetup();
          return;
        }

        final age = int.tryParse(ageController.text.trim()) ?? 0;

        final profile = ChildProfile(
          id: '',
          name: name,
          age: age,
          teacherUid:
              _isClassroomMode
                  ? session.requireClassroomId
                  : FirebaseAuth.instance.currentUser!.uid,
          zone: null,
          accessMode: 'iconSequence',
          iconSequence: childIconSequence,
        );

        await firestoreService.addCurrentChildProfile(profile);
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(context.l10n.success),
            content: Text(context.l10n.profileCreated(name)),
            actions: [
              TextButton(
                child: Text(context.l10n.ok),
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
        SnackBar(content: Text(context.l10n.profileSaveError(e.toString()))),
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
    final classroomName = session.classroomName;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isStaff ? context.l10n.addStaffProfile : context.l10n.addChildProfile,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          key: PageStorageKey(
            isStaff ? 'add-staff-profile' : 'add-child-profile',
          ),
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isClassroomMode && classroomName != null) ...[
                      Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: const Icon(Icons.meeting_room_outlined),
                          title: Text(classroomName),
                          subtitle: Text(context.l10n.profilesSavedToClassroom),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
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
                                color:
                                    isStaff
                                        ? colourScheme.primaryContainer
                                        : const Color(
                                          0xFF26A69A,
                                        ).withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Icon(
                                isStaff
                                    ? Icons.person_add_alt_1_rounded
                                    : Icons.child_care_rounded,
                                size: 44,
                                color:
                                    isStaff
                                        ? colourScheme.onPrimaryContainer
                                        : const Color(0xFF26A69A),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isStaff
                                  ? context.l10n.createStaffProfile
                                  : context.l10n.createChildProfile,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isStaff
                                  ? context.l10n.staffProfileAccessInfo
                                  : context.l10n.childProfileAccessInfo,
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
                                label: context.l10n.staffLabel,
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
                                label: context.l10n.childLabel,
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
                              isStaff
                                  ? context.l10n.staffDetails
                                  : context.l10n.childDetails,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: context.l10n.nameLabel,
                                prefixIcon: const Icon(Icons.badge_outlined),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return context.l10n.nameRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            if (isStaff)
                              TextFormField(
                                controller: roleController,
                                decoration: InputDecoration(
                                  labelText: context.l10n.role,
                                  prefixIcon: const Icon(Icons.work_outline),
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return context.l10n.roleRequired;
                                  }
                                  return null;
                                },
                              ),
                            if (!isStaff) ...[
                              TextFormField(
                                controller: ageController,
                                decoration: InputDecoration(
                                  labelText: context.l10n.age,
                                  prefixIcon: const Icon(Icons.cake_outlined),
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return context.l10n.ageRequired;
                                  }

                                  if (int.tryParse(val.trim()) == null) {
                                    return context.l10n.ageNumberRequired;
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF26A69A,
                                  ).withValues(alpha: 0.10),
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
                                                ? context
                                                    .l10n
                                                    .confirmChildUnlock
                                                : context.l10n.setChildUnlock,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      confirmingChildSequence
                                          ? context.l10n.tapSameIconsConfirm
                                          : context.l10n.askChildPickIcons,
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
                                          childIconSequence = List<String>.from(
                                            sequence,
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: _restartChildSequenceSetup,
                                          icon: const Icon(Icons.refresh),
                                          label: Text(context.l10n.startOver),
                                        ),
                                        if (!confirmingChildSequence)
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              if (childIconSequence.length !=
                                                  3) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      context
                                                          .l10n
                                                          .chooseThreeIconsFirst,
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
                                            label: Text(context.l10n.next),
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
                        isStaff
                            ? context.l10n.saveStaffProfile
                            : context.l10n.saveChildProfile,
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
      color: selected ? color.withValues(alpha: 0.16) : Colors.transparent,
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
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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
