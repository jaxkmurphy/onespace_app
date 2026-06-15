import 'package:flutter/material.dart';
import '../models/school.dart';
import '../services/firestore_service.dart';

class SchoolSettingsPage extends StatefulWidget {
  final String schoolId;

  const SchoolSettingsPage({
    super.key,
    required this.schoolId,
  });

  @override
  State<SchoolSettingsPage> createState() => _SchoolSettingsPageState();
}

class _SchoolSettingsPageState extends State<SchoolSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _schoolCodeController = TextEditingController();
  final _classroomLimitController = TextEditingController();

  final _firestoreService = FirestoreService();

  School? _school;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _loadSchool();
  }

  Future<void> _loadSchool() async {
    try {
      final school = await _firestoreService.getSchool(widget.schoolId);

      if (!mounted) return;

      if (school == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('School not found')),
        );
        Navigator.pop(context);
        return;
      }

      setState(() {
        _school = school;
        _nameController.text = school.name;
        _schoolCodeController.text = school.schoolCode;
        _classroomLimitController.text = school.classroomLimit.toString();
        _active = school.active;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading school settings: $e')),
      );
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestoreService.updateSchool(
        schoolId: widget.schoolId,
        name: _nameController.text,
        schoolCode: _schoolCodeController.text,
        classroomLimit: int.parse(_classroomLimitController.text.trim()),
        active: _active,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('School settings updated')),
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

  @override
  void dispose() {
    _nameController.dispose();
    _schoolCodeController.dispose();
    _classroomLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final school = _school;

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : school == null
              ? const Center(child: Text('School not found'))
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
                                  'School Information',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'These details control how the school appears and how classrooms log in.',
                                ),
                                const SizedBox(height: 22),

                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'School Name',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.school_outlined),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Enter a school name';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _schoolCodeController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  decoration: const InputDecoration(
                                    labelText: 'School Code',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Enter a school code';
                                    }

                                    if (value.trim().length < 3) {
                                      return 'School code should be at least 3 characters';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  'Changing the school code will change what staff enter on the Classroom Login screen.',
                                  style: TextStyle(fontSize: 13),
                                ),

                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _classroomLimitController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Classroom Limit',
                                    border: OutlineInputBorder(),
                                    prefixIcon:
                                        Icon(Icons.meeting_room_outlined),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Enter a classroom limit';
                                    }

                                    final parsed = int.tryParse(value.trim());

                                    if (parsed == null) {
                                      return 'Enter a valid number';
                                    }

                                    if (parsed < 1) {
                                      return 'Classroom limit must be at least 1';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                SwitchListTile(
                                  value: _active,
                                  title: const Text('School Active'),
                                  subtitle: const Text(
                                    'If disabled later, classroom login can be blocked for this school.',
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
                                          : 'Save School Settings',
                                    ),
                                    onPressed:
                                        _isSaving ? null : _saveSettings,
                                  ),
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