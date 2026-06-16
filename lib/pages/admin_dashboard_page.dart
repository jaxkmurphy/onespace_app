import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/classroom.dart';
import '../models/school.dart';
import '../services/firestore_service.dart';

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
    final schoolFuture = firestoreService.getSchool(schoolId);

    return Scaffold(
      appBar: AppBar(
        title: Text('$schoolName Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'School Settings',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/school-settings',
                arguments: {
                  'schoolId': schoolId,
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
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

                if (!context.mounted) return;

                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<School?>(
              future: schoolFuture,
              builder: (context, schoolSnapshot) {
                final school = schoolSnapshot.data;

                return StreamBuilder<List<Classroom>>(
                  stream: firestoreService.getClassrooms(schoolId),
                  builder: (context, classroomSnapshot) {
                    final classrooms = classroomSnapshot.data ?? [];
                    final classroomLimit = school?.classroomLimit ?? 3;
                    final usedClassrooms = classrooms.length;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              school?.name ?? schoolName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'School Code: ${school?.schoolCode ?? "Loading..."}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Classrooms Used: $usedClassrooms / $classroomLimit',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status: ${(school?.active ?? true) ? "Active" : "Inactive"}',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
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
                      child: Text(
                        'Error loading classrooms: ${snapshot.error}',
                      ),
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
                            Navigator.pushNamed(
                              context,
                              '/classroom-details',
                              arguments: {
                                'schoolId': schoolId,
                                'classroomId': classroom.id,
                              },
                            );
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