import 'package:flutter/material.dart';
import '../models/classroom.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboardPage extends StatelessWidget {
  final String schoolId;
  final String schoolName;

  const AdminDashboardPage({
    super.key,
    required this.schoolId,
    required this.schoolName,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
  title: Text('$schoolName Admin'),
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Logout',
      onPressed: () async {
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text(
              'Are you sure you want to logout?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
        );
              if (shouldLogout == true) {
                await FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text(
                  schoolName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('School administration dashboard'),
                leading: const Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<List<Classroom>>(
                stream: firestoreService.getClassrooms(schoolId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading classrooms: ${snapshot.error}'),
                    );
                  }

                  final classrooms = snapshot.data ?? [];

                  if (classrooms.isEmpty) {
                    return const Center(
                      child: Text(
                        'No classrooms yet.\nTap + Add Classroom to create one.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: classrooms.length,
                    itemBuilder: (context, index) {
                      final classroom = classrooms[index];

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.meeting_room),
                          title: Text(classroom.name),
                          subtitle: Text(
                            'Code: ${classroom.classroomCode} • Active: ${classroom.active ? "Yes" : "No"}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pushNamed(context, '/profiles');
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Classroom'),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/create-classroom',
                    arguments: {
                      'schoolId': schoolId,
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}