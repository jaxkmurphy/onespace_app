import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../models/incident_log_entry.dart';
import '../models/staff_profile.dart';
import '../services/classroom_session_service.dart';
import '../services/firestore_service.dart';

enum IncidentLogMode {
  create,
  view,
}

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
  final ClassroomSessionService _session = ClassroomSessionService.instance;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _actionTakenController = TextEditingController();

  IncidentLogMode _mode = IncidentLogMode.create;

  String? _selectedChildId;
  String _selectedSeverity = 'Low';
  String _severityFilter = 'All';
  String _selectedChildFilter = 'All';
  DateTime? _selectedDateTime;
  bool _isSaving = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _actionTakenController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
      default:
        return Colors.green;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity) {
      case 'High':
        return Icons.priority_high;
      case 'Medium':
        return Icons.warning_amber;
      case 'Low':
      default:
        return Icons.info_outline;
    }
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedDateTime == null
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(_selectedDateTime!),
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

    try {
      final entry = IncidentLogEntry(
        id: '',
        childId: selectedChild.id,
        childName: selectedChild.name,
        timestamp: _selectedDateTime ?? DateTime.now(),
        description: description,
        actionTaken: actionTaken,
        staffId: widget.staffProfile.id,
        staffName: widget.staffProfile.name,
        severity: _selectedSeverity,
      );

      await _firestoreService.addCurrentIncidentLogEntry(entry);

      if (!mounted) return;

      _descriptionController.clear();
      _actionTakenController.clear();

      setState(() {
        _selectedChildId = null;
        _selectedSeverity = 'Low';
        _selectedDateTime = null;
        _isSaving = false;
        _mode = IncidentLogMode.view;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incident saved.')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save incident: $e')),
      );
    }
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

    await _firestoreService.deleteCurrentIncidentLogEntry(incident.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incident deleted.')),
    );
  }

  List<IncidentLogEntry> _applyFilters(List<IncidentLogEntry> incidents) {
    return incidents.where((incident) {
      final matchesSeverity =
          _severityFilter == 'All' || incident.severity == _severityFilter;

      final matchesChild =
          _selectedChildFilter == 'All' ||
          incident.childName == _selectedChildFilter;

      return matchesSeverity && matchesChild;
    }).toList();
  }

  Widget _buildModeSelector() {
    return SegmentedButton<IncidentLogMode>(
      segments: const [
        ButtonSegment(
          value: IncidentLogMode.create,
          icon: Icon(Icons.add),
          label: Text('Create Incident'),
        ),
        ButtonSegment(
          value: IncidentLogMode.view,
          icon: Icon(Icons.list),
          label: Text('View Incidents'),
        ),
      ],
      selected: {_mode},
      onSelectionChanged: (selected) {
        setState(() {
          _mode = selected.first;
        });
      },
    );
  }

  Widget _buildCreateIncidentSection(List<ChildProfile> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Create Incident',
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
        DropdownButtonFormField<String>(
          initialValue: _selectedSeverity,
          decoration: const InputDecoration(
            labelText: 'Severity',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Low',
              child: Text('Low'),
            ),
            DropdownMenuItem(
              value: 'Medium',
              child: Text('Medium'),
            ),
            DropdownMenuItem(
              value: 'High',
              child: Text('High'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedSeverity = value;
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
        if (_selectedDateTime != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedDateTime = null;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset to current time'),
          ),
        ],
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
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: Text(_isSaving ? 'Saving...' : 'Save Incident'),
            onPressed: _isSaving ? null : () => _saveIncident(children),
          ),
        ),
      ],
    );
  }

  Widget _buildViewIncidentsSection() {
    return StreamBuilder<List<IncidentLogEntry>>(
      stream: _firestoreService.getCurrentIncidentLogEntries(),
      builder: (context, incidentSnapshot) {
        if (incidentSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final incidents = incidentSnapshot.data ?? [];
        final filteredIncidents = _applyFilters(incidents);

        final childNames = incidents
            .map((incident) => incident.childName)
            .where((name) => name.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        final childFilterItems = ['All', ...childNames];

        if (incidents.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                'No incidents logged yet.',
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'View Incidents',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'All',
                  label: Text('All'),
                  icon: Icon(Icons.list),
                ),
                ButtonSegment(
                  value: 'Low',
                  label: Text('Low'),
                  icon: Icon(Icons.info_outline),
                ),
                ButtonSegment(
                  value: 'Medium',
                  label: Text('Medium'),
                  icon: Icon(Icons.warning_amber),
                ),
                ButtonSegment(
                  value: 'High',
                  label: Text('High'),
                  icon: Icon(Icons.priority_high),
                ),
              ],
              selected: {_severityFilter},
              onSelectionChanged: (selected) {
                setState(() {
                  _severityFilter = selected.first;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: childFilterItems.contains(_selectedChildFilter)
                  ? _selectedChildFilter
                  : 'All',
              decoration: const InputDecoration(
                labelText: 'Filter by child',
                border: OutlineInputBorder(),
              ),
              items: childFilterItems.map((name) {
                return DropdownMenuItem(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedChildFilter = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              '${filteredIncidents.length} incident(s) shown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (filteredIncidents.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Center(
                  child: Text(
                    'No incidents match these filters.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              ...filteredIncidents.map(_buildIncidentCard),
          ],
        );
      },
    );
  }

  Widget _buildIncidentCard(IncidentLogEntry incident) {
    final severityColor = _severityColor(incident.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: severityColor,
                  child: Icon(
                    _severityIcon(incident.severity),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    incident.childName,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
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
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(
                    _severityIcon(incident.severity),
                    size: 18,
                    color: severityColor,
                  ),
                  label: Text('${incident.severity} severity'),
                ),
                Chip(
                  avatar: const Icon(Icons.calendar_today, size: 18),
                  label: Text(_formatDate(incident.timestamp)),
                ),
                Chip(
                  avatar: const Icon(Icons.person, size: 18),
                  label: Text('Logged by ${incident.staffName}'),
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _session.hasClassroomSession
        ? '${_session.currentClassroomName} Incident Log'
        : 'Incident Log';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder<List<ChildProfile>>(
        stream: _firestoreService.getCurrentChildProfiles(),
        builder: (context, childSnapshot) {
          if (childSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final children = childSnapshot.data ?? [];

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Incident Log',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create and review classroom incident records.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildModeSelector(),
                const SizedBox(height: 24),
                if (_mode == IncidentLogMode.create)
                  _buildCreateIncidentSection(children)
                else
                  _buildViewIncidentsSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}