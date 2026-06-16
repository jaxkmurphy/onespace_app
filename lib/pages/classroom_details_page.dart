import 'package:flutter/material.dart';
import '../models/classroom.dart';
import '../services/firestore_service.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Classroom not found')),
        );
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
        SnackBar(content: Text('Error loading classroom: $e')),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Classroom updated')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
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
      builder: (context) => AlertDialog(
        title: const Text('Delete Classroom'),
        content: const Text(
          'Are you sure you want to delete this classroom? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Classroom deleted')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting classroom: $e')),
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
      appBar: AppBar(
        title: const Text('Classroom Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : classroom == null
              ? const Center(child: Text('Classroom not found'))
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
                                const Text(
                                  'Classroom Information',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  'These details control how staff access this classroom.',
                                ),

                                const SizedBox(height: 22),

                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Classroom Name',
                                    border: OutlineInputBorder(),
                                    prefixIcon:
                                        Icon(Icons.meeting_room_outlined),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Enter a classroom name';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _codeController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  decoration: const InputDecoration(
                                    labelText: 'Classroom Code',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Enter a classroom code';
                                    }

                                    if (value.trim().length < 3) {
                                      return 'Classroom code should be at least 3 characters';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  'Changing this code will change what staff enter on the Classroom Login screen.',
                                  style: TextStyle(fontSize: 13),
                                ),

                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _pinController,
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Classroom PIN',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Enter a classroom PIN';
                                    }

                                    if (value.trim().length < 4) {
                                      return 'PIN should be at least 4 digits';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                SwitchListTile(
                                  value: _active,
                                  title: const Text('Classroom Active'),
                                  subtitle: const Text(
                                    'If disabled, classroom login will be blocked for this classroom.',
                                  ),
                                  onChanged: _isSaving
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
                                    icon: _isSaving
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
                                          ? 'Saving...'
                                          : 'Save Classroom',
                                    ),
                                    onPressed:
                                        _isSaving ? null : _saveClassroom,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                OutlinedButton.icon(
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Delete Classroom'),
                                  onPressed:
                                      _isSaving ? null : _deleteClassroom,
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