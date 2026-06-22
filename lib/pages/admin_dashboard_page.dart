import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/classroom.dart';
import '../models/school.dart';
import '../services/firestore_service.dart';
import '../l10n/l10n.dart';

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
        title: Text(context.l10n.schoolAdminTitle(schoolName)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: context.l10n.schoolSettings,
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/school-settings',
                arguments: {'schoolId': schoolId},
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: context.l10n.logout,
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text(context.l10n.logout),
                      content: Text(context.l10n.logoutConfirmation),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(context.l10n.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(context.l10n.logout),
                        ),
                      ],
                    ),
              );

              if (shouldLogout == true) {
                await FirebaseAuth.instance.signOut();

                if (!context.mounted) return;

                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
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
                              context.l10n.schoolCodeValue(
                                school?.schoolCode ?? context.l10n.loading,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.classroomsUsed(
                                usedClassrooms,
                                classroomLimit,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.statusValue(
                                (school?.active ?? true)
                                    ? context.l10n.active
                                    : context.l10n.inactive,
                              ),
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
                        context.l10n.classroomsLoadError(
                          snapshot.error.toString(),
                        ),
                      ),
                    );
                  }

                  final classrooms = snapshot.data ?? [];

                  if (classrooms.isEmpty) {
                    return Center(
                      child: Text(
                        context.l10n.noClassroomsYet,
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
                            context.l10n.classroomListSummary(
                              classroom.classroomCode,
                              classroom.active
                                  ? context.l10n.yes
                                  : context.l10n.no,
                            ),
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
                label: Text(context.l10n.addClassroom),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/create-classroom',
                    arguments: {'schoolId': schoolId},
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
