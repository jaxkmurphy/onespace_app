import 'package:flutter/material.dart';
import '../models/staff_profile.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProfilePage extends StatefulWidget {
  const AddProfilePage({super.key});

  @override
  State<AddProfilePage> createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  final FirestoreService firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  bool isStaff = true; // Toggle state: true = Staff, false = Child

  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  Future<void> _saveProfile() async {
  if (!_formKey.currentState!.validate()) return;

  final teacherUid = FirebaseAuth.instance.currentUser!.uid;
  final name = nameController.text.trim();

  try {
    if (isStaff) {
  final role = roleController.text.trim();
  final profile = StaffProfile(
    id: '', // Firestore will assign the ID
    name: name,
    role: role,
    teacherUid: teacherUid, // ✅ Add this
  );
  await firestoreService.addStaffProfile(teacherUid, profile);
} else {
  final age = int.tryParse(ageController.text.trim()) ?? 0;
  final profile = ChildProfile(
    id: '', // Firestore will assign the ID
    name: name,
    age: age,
    teacherUid: teacherUid, // ✅ Add this
    zone: null, // Optional, can be omitted if default constructor handles it
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
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Go back to previous screen
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(isStaff ? 'Add Staff Profile' : 'Add Child Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Toggle Buttons for Staff / Child
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text('Staff'),
                    selected: isStaff,
                    onSelected: (selected) {
                      setState(() {
                        isStaff = true;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: Text('Child'),
                    selected: !isStaff,
                    onSelected: (selected) {
                      setState(() {
                        isStaff = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name input (common)
              TextFormField(
                controller: nameController,
                autofillHints: const [], // disable autofill
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // Role input if Staff
              if (isStaff)
                TextFormField(
                  controller: roleController,
                  autofillHints: const [],
                  decoration: const InputDecoration(labelText: 'Role'),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Role is required' : null,
                ),

              // Age input if Child
              if (!isStaff)
                TextFormField(
                  controller: ageController,
                  autofillHints: const [],
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Age is required';
                    if (int.tryParse(val.trim()) == null) return 'Age must be a number';
                    return null;
                  },
                ),

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
