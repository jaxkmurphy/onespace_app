import 'package:flutter/material.dart';
import '../models/body_check_report.dart';
import '../services/firestore_service.dart';

enum BodyCheckFilter {
  all,
  unchecked,
  checked,
}

class BodyCheckOverviewPage extends StatefulWidget {
  final String teacherUid;
  final FirestoreService firestoreService;

  const BodyCheckOverviewPage({
    super.key,
    required this.teacherUid,
    required this.firestoreService,
  });

  @override
  State<BodyCheckOverviewPage> createState() => _BodyCheckOverviewPageState();
}

class _BodyCheckOverviewPageState extends State<BodyCheckOverviewPage> {
  BodyCheckFilter _statusFilter = BodyCheckFilter.all;
  String _selectedChild = 'All';

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

  List<BodyCheckReport> _applyFilters(List<BodyCheckReport> reports) {
    return reports.where((report) {
      final matchesStatus = switch (_statusFilter) {
        BodyCheckFilter.all => true,
        BodyCheckFilter.unchecked => !report.checked,
        BodyCheckFilter.checked => report.checked,
      };

      final matchesChild =
          _selectedChild == 'All' || report.childName == _selectedChild;

      return matchesStatus && matchesChild;
    }).toList();
  }

  Future<void> _markChecked(BodyCheckReport report) async {
    final noteController = TextEditingController();

    final note = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mark as Checked'),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Optional staff note',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, noteController.text.trim());
              },
              child: const Text('Mark Checked'),
            ),
          ],
        );
      },
    );

    if (note == null) return;

    await widget.firestoreService.markCurrentBodyCheckReportChecked(
      reportId: report.id,
      checkedNote: note,
    );
  }

  Future<void> _deleteReport(BodyCheckReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Report'),
          content: Text(
            'Delete this Body Check report for ${report.childName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await widget.firestoreService.deleteCurrentBodyCheckReport(report.id);
  }

  Widget _buildFilters(List<BodyCheckReport> reports) {
    final childNames = reports
        .map((report) => report.childName)
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final dropdownItems = ['All', ...childNames];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<BodyCheckFilter>(
          segments: const [
            ButtonSegment(
              value: BodyCheckFilter.all,
              label: Text('All'),
              icon: Icon(Icons.list),
            ),
            ButtonSegment(
              value: BodyCheckFilter.unchecked,
              label: Text('Unchecked'),
              icon: Icon(Icons.warning_amber),
            ),
            ButtonSegment(
              value: BodyCheckFilter.checked,
              label: Text('Checked'),
              icon: Icon(Icons.check_circle),
            ),
          ],
          selected: {_statusFilter},
          onSelectionChanged: (selected) {
            setState(() {
              _statusFilter = selected.first;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: dropdownItems.contains(_selectedChild)
              ? _selectedChild
              : 'All',
          decoration: const InputDecoration(
            labelText: 'Filter by child',
            border: OutlineInputBorder(),
          ),
          items: dropdownItems.map((name) {
            return DropdownMenuItem(
              value: name,
              child: Text(name),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedChild = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildReportCard(BodyCheckReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _painColor(report.painLevel),
                  child: Text(
                    report.painLevel.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    report.childName,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (report.checked)
                  const Icon(Icons.check_circle, color: Colors.green)
                else
                  const Icon(Icons.warning_amber, color: Colors.orange),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Body part: ${report.bodyPart}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Pain level: ${_painLabel(report.painLevel)}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Pain type: ${report.painType}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Sent: ${_formatTime(report.timestamp)}',
              style: const TextStyle(fontSize: 16),
            ),
            if (report.checkedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Checked: ${_formatTime(report.checkedAt!)}',
                style: const TextStyle(fontSize: 15),
              ),
            ],
            if (report.checkedNote.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Staff note: ${report.checkedNote}',
                style: const TextStyle(fontSize: 15),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (!report.checked)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _markChecked(report),
                      icon: const Icon(Icons.check),
                      label: const Text('Mark Checked'),
                    ),
                  ),
                if (!report.checked) const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Delete report',
                  onPressed: () => _deleteReport(report),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Check Reports'),
      ),
      body: StreamBuilder<List<BodyCheckReport>>(
        stream: widget.firestoreService.getCurrentBodyCheckReports(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong loading reports.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!;
          final filteredReports = _applyFilters(reports);

          if (reports.isEmpty) {
            return const Center(
              child: Text(
                'No Body Check reports yet.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildFilters(reports),
              const SizedBox(height: 16),
              Text(
                '${filteredReports.length} report(s) shown',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (filteredReports.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(
                    child: Text(
                      'No reports match these filters.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              else
                ...filteredReports.map(_buildReportCard),
            ],
          );
        },
      ),
    );
  }
}