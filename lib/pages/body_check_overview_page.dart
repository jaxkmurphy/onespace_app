import 'package:flutter/material.dart';
import '../models/body_check_report.dart';
import '../services/firestore_service.dart';

class BodyCheckOverviewPage extends StatelessWidget {
  final String teacherUid;
  final FirestoreService firestoreService;

  const BodyCheckOverviewPage({
    super.key,
    required this.teacherUid,
    required this.firestoreService,
  });

  String _painLabel(int level) {
    switch (level) {
      case 1:
        return 'A little sore';
      case 2:
        return 'Hurts';
      case 3:
        return 'Hurts a lot';
      default:
        return 'Unknown';
    }
  }

  Color _painColor(int level) {
    switch (level) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.deepOrange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} '
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Check Reports'),
      ),
      body: StreamBuilder<List<BodyCheckReport>>(
        stream: firestoreService.getBodyCheckReports(teacherUid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong loading reports.'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!;

          if (reports.isEmpty) {
            return const Center(
              child: Text(
                'No Body Check reports yet.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _painColor(report.painLevel),
                    child: Text(
                      report.painLevel.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    '${report.childName} - ${report.bodyPart}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: report.checked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                    '${_painLabel(report.painLevel)}\n${_formatTime(report.timestamp)}',
                  ),
                  isThreeLine: true,
                  trailing: report.checked
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : ElevatedButton(
                          onPressed: () {
                            firestoreService.markBodyCheckReportChecked(
                              teacherUid: teacherUid,
                              reportId: report.id,
                            );
                          },
                          child: const Text('Checked'),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}