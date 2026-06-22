import 'package:flutter/material.dart';
import '../models/classroom.dart';
import '../services/firestore_service.dart';
import '../l10n/l10n.dart';

class ClassroomDetailsPage extends StatefulWidget {
  final String schoolId;
  final String classroomId;

  const ClassroomDetailsPage({
    super.key,
    required this.schoolId,
    required this.classroomId,
  });

  @override
  State<ClassroomDetailsPage> createState() => _ClassroomDetailsPageState();
}

class _ClassroomDetailsPageState extends State<ClassroomDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _pinController = TextEditingController();

  final _firestoreService = FirestoreService();

  Classroom? _classroom;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _loadClassroom();
  }

  Future<void> _loadClassroom() async {
    try {
      final classroom = await _firestoreService.getClassroom(
        schoolId: widget.schoolId,
        classroomId: widget.classroomId,
      );

      if (!mounted) return;

      if (classroom == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.classroomNotFound)));
        Navigator.pop(context);
        return;
      }

      setState(() {
        _classroom = classroom;
        _nameController.text = classroom.name;
        _codeController.text = classroom.classroomCode;
        _pinController.text = classroom.pin;
        _active = classroom.active;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.classroomLoadError(e.toString()))),
      );
    }
  }

  Future<void> _saveClassroom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestoreService.updateClassroom(
        schoolId: widget.schoolId,
        classroomId: widget.classroomId,
        name: _nameController.text,
        classroomCode: _codeController.text,
        pin: _pinController.text,
        active: _active,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.classroomUpdated)));

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('classroom code is already in use')
                ? context.l10n.classroomCodeInUse
                : context.l10n.classroomUpdateError,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteClassroom() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.deleteClassroom),
            content: Text(context.l10n.deleteClassroomConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.delete),
              ),
            ],
          ),
    );

    if (shouldDelete != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestoreService.deleteClassroom(
        schoolId: widget.schoolId,
        classroomId: widget.classroomId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.classroomDeleted)));

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.classroomDeleteError(e.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classroom = _classroom;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.classroomDetails)),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : classroom == null
              ? Center(child: Text(context.l10n.classroomNotFound))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                context.l10n.classroomInformation,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(context.l10n.classroomAccessInfo),

                              const SizedBox(height: 22),

                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: context.l10n.classroomName,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(
                                    Icons.meeting_room_outlined,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.l10n.enterClassroomName;
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _codeController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: InputDecoration(
                                  labelText: context.l10n.classroomCode,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.l10n.enterClassroomCode;
                                  }

                                  if (value.trim().length < 3) {
                                    return context.l10n.classroomCodeMinLength;
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 8),

                              Text(
                                context.l10n.classroomCodeChangeInfo,
                                style: const TextStyle(fontSize: 13),
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _pinController,
                                obscureText: true,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: context.l10n.classroomPin,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.l10n.enterClassroomPin;
                                  }

                                  if (value.trim().length < 4) {
                                    return context.l10n.classroomPinMinLength;
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              SwitchListTile(
                                value: _active,
                                title: Text(context.l10n.classroomActive),
                                subtitle: Text(
                                  context.l10n.classroomInactiveInfo,
                                ),
                                onChanged:
                                    _isSaving
                                        ? null
                                        : (value) {
                                          setState(() {
                                            _active = value;
                                          });
                                        },
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon:
                                      _isSaving
                                          ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Icon(Icons.save),
                                  label: Text(
                                    _isSaving
                                        ? context.l10n.saving
                                        : context.l10n.saveClassroom,
                                  ),
                                  onPressed: _isSaving ? null : _saveClassroom,
                                ),
                              ),

                              const SizedBox(height: 12),

                              OutlinedButton.icon(
                                icon: const Icon(Icons.delete_outline),
                                label: Text(context.l10n.deleteClassroom),
                                onPressed: _isSaving ? null : _deleteClassroom,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
