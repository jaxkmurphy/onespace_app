import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../l10n/l10n.dart';

class CreateClassroomPage extends StatefulWidget {
  final String schoolId;

  const CreateClassroomPage({super.key, required this.schoolId});

  @override
  State<CreateClassroomPage> createState() => _CreateClassroomPageState();
}

class _CreateClassroomPageState extends State<CreateClassroomPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _pinController = TextEditingController();

  final _firestoreService = FirestoreService();

  bool _isCheckingAccess = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final user = FirebaseAuth.instance.currentUser;
    final tokenResult = await user?.getIdTokenResult();
    final claims = tokenResult?.claims ?? {};

    if (claims['role'] == 'classroom') {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.adminOnlyArea)));
      Navigator.pop(context);
      return;
    }

    if (mounted) {
      setState(() {
        _isCheckingAccess = false;
      });
    }
  }

  String _createError(Object error) {
    final message = error.toString();
    if (message.contains('School not found')) {
      return context.l10n.schoolNotFound;
    }
    if (message.contains('Classroom limit reached')) {
      return context.l10n.classroomLimitReached;
    }
    if (message.contains('classroom code is already in use')) {
      return context.l10n.classroomCodeInUse;
    }
    return context.l10n.classroomCreateError(message);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _saveClassroom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestoreService.createClassroom(
        schoolId: widget.schoolId,
        name: _nameController.text,
        classroomCode: _codeController.text,
        pin: _pinController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.classroomCreated)));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_createError(e))));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAccess) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.createClassroom)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    context.l10n.classroomDetails,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: context.l10n.classroomName,
                      hintText: context.l10n.classroomNameHint,
                      border: const OutlineInputBorder(),
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
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: context.l10n.classroomCode,
                      hintText: context.l10n.classroomCodeHint,
                      border: const OutlineInputBorder(),
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

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: context.l10n.classroomPin,
                      hintText: context.l10n.classroomPinHint,
                      border: const OutlineInputBorder(),
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
                            : context.l10n.createClassroom,
                      ),
                      onPressed: _isSaving ? null : _saveClassroom,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
