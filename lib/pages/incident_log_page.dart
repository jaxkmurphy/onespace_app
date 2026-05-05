import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/child_profile.dart';
import '../models/incident_log_entry.dart';
import '../models/staff_profile.dart';
import '../services/firestore_service.dart';

class IncidentLogPage extends StatefulWidget {
  final StaffProfile staffProfile;

  const IncidentLogPage({
    super.key,
    required this.staffProfile,
  });

  @override
  State<IncidentLogPage> createState() => _IncidentLogPageState();
}

class _IncidentLogPageState extends State<IncidentLogPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _actionTakenController = TextEditingController();

  String? _selectedChildId;
  DateTime? _selectedDateTime;
  bool _isSaving = false;

  String get _teacherUid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    _descriptionController.dispose();
    _actionTakenController.dispose();
    super.dispose();
  }

  Future<void> _saveIncident(List<ChildProfile> children) async {
    if (_selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a child.')),
      );
      return;
    }

    final selectedChild = children.firstWhere(
      (child) => child.id == _selectedChildId,
    );

    final description = _descriptionController.text.trim();
    final actionTaken = _actionTakenController.text.trim();

    if (description.isEmpty || actionTaken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description and action taken.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final entry = IncidentLogEntry(
      id: '',
      childId: selectedChild.id,
      childName: selectedChild.name,
      timestamp: _selectedDateTime ?? DateTime.now(),
      description: description,
      actionTaken: actionTaken,
      staffId: widget.staffProfile.id,
      staffName: widget.staffProfile.name,
    );

    await _firestoreService.addIncidentLogEntry(
      teacherUid: _teacherUid,
      entry: entry,
    );

    if (!mounted) return;

    _descriptionController.clear();
    _actionTakenController.clear();

    setState(() {
      _selectedChildId = null;
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incident saved.')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDateTime() async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2024),
    lastDate: DateTime(2100),
  );

  if (pickedDate == null || !mounted) return;

  final pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (pickedTime == null || !mounted) return;

  setState(() {
    _selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  });
}

  Future<void> _deleteIncident(IncidentLogEntry incident) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Incident?'),
        content: Text(
          'Are you sure you want to delete the incident for ${incident.childName}?',
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

  if (shouldDelete != true) return;

  await _firestoreService.deleteIncidentLogEntry(
    teacherUid: _teacherUid,
    incidentId: incident.id,
  );

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Incident deleted.')),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: AppBar(
        title: const Text('Incident Log'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<ChildProfile>>(
        stream: _firestoreService.getChildProfiles(_teacherUid),
        builder: (context, childSnapshot) {
          if (childSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final children = childSnapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Incident',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _selectedChildId,
                  decoration: const InputDecoration(
                    labelText: 'Select Child',
                    border: OutlineInputBorder(),
                  ),
                  items: children.map((child) {
                    return DropdownMenuItem<String>(
                      value: child.id,
                      child: Text(child.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedChildId = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _selectedDateTime == null
                      ? 'Use Current Time (Default)'
                      : 'Manual Time: ${_formatDate(_selectedDateTime!)}',
                  ),
                  onPressed: _pickDateTime,
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _actionTakenController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Action Taken',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(_isSaving ? 'Saving...' : 'Save Incident'),
                    onPressed: _isSaving ? null : () => _saveIncident(children),
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Recent Incidents',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                StreamBuilder<List<IncidentLogEntry>>(
                  stream: _firestoreService.getIncidentLogEntries(_teacherUid),
                  builder: (context, incidentSnapshot) {
                    if (incidentSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final incidents = incidentSnapshot.data ?? [];

                    if (incidents.isEmpty) {
                      return const Text('No incidents logged yet.');
                    }

                    return Column(
                      children: incidents.map((incident) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Colors.deepPurple,
                                      child: Icon(
                                        Icons.event_note,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            incident.childName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            _formatDate(incident.timestamp),
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Delete incident',
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteIncident(incident),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                const Text(
                                  'Description',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(incident.description),

                                const SizedBox(height: 12),

                                const Text(
                                  'Action Taken',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(incident.actionTaken),

                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 18),
                                    const SizedBox(width: 6),
                                    Text('Logged by ${incident.staffName}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}