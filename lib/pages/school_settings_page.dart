import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/school.dart';
import '../services/firestore_service.dart';
import '../l10n/l10n.dart';

class SchoolSettingsPage extends StatefulWidget {
  final String schoolId;

  const SchoolSettingsPage({super.key, required this.schoolId});

  @override
  State<SchoolSettingsPage> createState() => _SchoolSettingsPageState();
}

class _SchoolSettingsPageState extends State<SchoolSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _schoolCodeController = TextEditingController();
  final _classroomLimitController = TextEditingController();
  final _principalNameController = TextEditingController();
  final _vicePrincipalNameController = TextEditingController();
  final _schoolEmailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();

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

      final school = await _firestoreService.getSchool(widget.schoolId);

      if (!mounted) return;

      if (school == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.schoolNotFound)));
        Navigator.pop(context);
        return;
      }

      setState(() {
        _school = school;
        _nameController.text = school.name;
        _schoolCodeController.text = school.schoolCode;
        _classroomLimitController.text = school.classroomLimit.toString();
        _principalNameController.text = school.principalName;
        _vicePrincipalNameController.text = school.vicePrincipalName;
        _schoolEmailController.text = school.schoolEmail;
        _phoneNumberController.text = school.phoneNumber;
        _addressController.text = school.address;
        _active = school.active;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.schoolSettingsLoadError(e.toString())),
        ),
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
        principalName: _principalNameController.text,
        vicePrincipalName: _vicePrincipalNameController.text,
        schoolEmail: _schoolEmailController.text,
        phoneNumber: _phoneNumberController.text,
        address: _addressController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.schoolSettingsUpdated)),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('school code is already in use')
                ? context.l10n.schoolCodeInUse
                : context.l10n.schoolSettingsUpdateError,
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

  @override
  void dispose() {
    _nameController.dispose();
    _schoolCodeController.dispose();
    _classroomLimitController.dispose();
    _principalNameController.dispose();
    _vicePrincipalNameController.dispose();
    _schoolEmailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final school = _school;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.schoolSettings)),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : school == null
              ? Center(child: Text(context.l10n.schoolNotFound))
              : SingleChildScrollView(
                key: const PageStorageKey('school-settings'),
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
                                context.l10n.schoolInformation,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(context.l10n.schoolAccountInfo),
                              const SizedBox(height: 22),

                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: context.l10n.schoolName,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.school_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.l10n.enterSchoolName;
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _schoolCodeController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: InputDecoration(
                                  labelText: context.l10n.schoolCode,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.l10n.enterSchoolCode;
                                  }

                                  if (value.trim().length < 3) {
                                    return context.l10n.schoolCodeMinLength;
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 8),

                              Text(
                                context.l10n.schoolCodeChangeInfo,
                                style: const TextStyle(fontSize: 13),
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _classroomLimitController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: context.l10n.classroomLimit,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(
                                    Icons.meeting_room_outlined,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.l10n.enterClassroomLimit;
                                  }

                                  final parsed = int.tryParse(value.trim());

                                  if (parsed == null) {
                                    return context.l10n.enterValidNumber;
                                  }

                                  if (parsed < 1) {
                                    return context.l10n.classroomLimitMinimum;
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              const Divider(),

                              const SizedBox(height: 16),

                              Text(
                                context.l10n.contactDetails,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _principalNameController,
                                decoration: InputDecoration(
                                  labelText: context.l10n.principalName,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.person_outline),
                                ),
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _vicePrincipalNameController,
                                decoration: InputDecoration(
                                  labelText: context.l10n.vicePrincipalName,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.person_outline),
                                ),
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _schoolEmailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: context.l10n.schoolEmail,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.email_outlined),
                                ),
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _phoneNumberController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: context.l10n.phoneNumber,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                ),
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _addressController,
                                minLines: 2,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  labelText: context.l10n.schoolAddress,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(
                                    Icons.location_on_outlined,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              const Divider(),

                              const SizedBox(height: 16),

                              SwitchListTile(
                                value: _active,
                                title: Text(context.l10n.schoolActive),
                                subtitle: Text(context.l10n.schoolInactiveInfo),
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
                                        : context.l10n.saveSchoolSettings,
                                  ),
                                  onPressed: _isSaving ? null : _saveSettings,
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
