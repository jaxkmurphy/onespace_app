import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/l10n.dart';
import '../models/school_contact.dart';
import '../services/firestore/admin_firestore_service.dart';
import '../services/firestore_service.dart';

class ContactDirectoryPage extends StatefulWidget {
  final String schoolId;

  const ContactDirectoryPage({super.key, required this.schoolId});

  @override
  State<ContactDirectoryPage> createState() => _ContactDirectoryPageState();
}

class _ContactDirectoryPageState extends State<ContactDirectoryPage> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<List<AdminChildProfileOption>>? _childOptionsFuture;
  Future<List<AdminStaffProfileOption>>? _staffOptionsFuture;
  bool _isCheckingAccess = true;

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

    _childOptionsFuture = _firestoreService.getSchoolChildProfileOptions(
      widget.schoolId,
    );
    _staffOptionsFuture = _firestoreService.getSchoolStaffProfileOptions(
      widget.schoolId,
    );

    if (mounted) {
      setState(() {
        _isCheckingAccess = false;
      });
    }
  }

  Future<void> _refreshProfileOptions() async {
    setState(() {
      _childOptionsFuture = _firestoreService.getSchoolChildProfileOptions(
        widget.schoolId,
      );
      _staffOptionsFuture = _firestoreService.getSchoolStaffProfileOptions(
        widget.schoolId,
      );
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openContactDialog({
    required SchoolContactType type,
    SchoolContact? contact,
  }) async {
    final childOptions = await _childOptionsFuture;
    final staffOptions = await _staffOptionsFuture;
    final existingContacts =
        await _firestoreService.getSchoolContacts(widget.schoolId).first;
    if (!mounted) return;

    final result = await showDialog<SchoolContact>(
      context: context,
      builder:
          (context) => _ContactDialog(
            schoolId: widget.schoolId,
            type: type,
            contact: contact,
            childOptions: childOptions ?? const [],
            staffOptions: staffOptions ?? const [],
            existingContacts: existingContacts,
          ),
    );

    if (result == null) return;

    try {
      if (contact == null) {
        await _firestoreService.addSchoolContact(
          schoolId: widget.schoolId,
          contact: result,
        );
        if (mounted) _showMessage(context.l10n.contactAdded);
      } else {
        await _firestoreService.updateSchoolContact(
          schoolId: widget.schoolId,
          contact: result,
        );
        if (mounted) _showMessage(context.l10n.contactUpdated);
      }
    } catch (error) {
      if (mounted) {
        _showMessage(context.l10n.contactSaveFailed(error.toString()));
      }
    }
  }

  Future<void> _deleteContact(SchoolContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.l10n.deleteContact),
            content: Text(context.l10n.deleteContactMessage(contact.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.delete),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await _firestoreService.deleteSchoolContact(
        schoolId: widget.schoolId,
        contactId: contact.id,
      );
      if (mounted) _showMessage(context.l10n.contactDeleted);
    } catch (error) {
      if (mounted) {
        _showMessage(context.l10n.contactDeleteFailed(error.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAccess) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.contactDirectory),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.badge_outlined),
                text: context.l10n.staffContacts,
              ),
              Tab(
                icon: const Icon(Icons.family_restroom_rounded),
                text: context.l10n.guardianContacts,
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshProfileOptions,
          child: TabBarView(
            children: [
              _ContactListTab(
                type: SchoolContactType.staff,
                contactsStream: _firestoreService.getSchoolContactsByType(
                  schoolId: widget.schoolId,
                  type: SchoolContactType.staff,
                ),
                onAdd: () => _openContactDialog(type: SchoolContactType.staff),
                onEdit:
                    (contact) => _openContactDialog(
                      type: SchoolContactType.staff,
                      contact: contact,
                    ),
                onDelete: _deleteContact,
              ),
              _ContactListTab(
                type: SchoolContactType.guardian,
                contactsStream: _firestoreService.getSchoolContactsByType(
                  schoolId: widget.schoolId,
                  type: SchoolContactType.guardian,
                ),
                onAdd:
                    () => _openContactDialog(type: SchoolContactType.guardian),
                onEdit:
                    (contact) => _openContactDialog(
                      type: SchoolContactType.guardian,
                      contact: contact,
                    ),
                onDelete: _deleteContact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactListTab extends StatefulWidget {
  final SchoolContactType type;
  final Stream<List<SchoolContact>> contactsStream;
  final VoidCallback onAdd;
  final ValueChanged<SchoolContact> onEdit;
  final ValueChanged<SchoolContact> onDelete;

  const _ContactListTab({
    required this.type,
    required this.contactsStream,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ContactListTab> createState() => _ContactListTabState();
}

class _ContactListTabState extends State<_ContactListTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SchoolContact> _filteredContacts(List<SchoolContact> contacts) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return contacts;

    return contacts.where((contact) {
      final values =
          [
            contact.name,
            contact.email,
            contact.classroomName,
            contact.childName,
            contact.staffProfileName,
            contact.relationship,
            contact.role,
          ].join(' ').toLowerCase();

      return values.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SchoolContact>>(
      stream: widget.contactsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              context.l10n.contactsLoadFailed(snapshot.error.toString()),
            ),
          );
        }

        final contacts = snapshot.data ?? const <SchoolContact>[];
        final filteredContacts = _filteredContacts(contacts);

        return ListView(
          key: PageStorageKey('contact-directory-${widget.type.name}'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ContactHeaderCard(
                      type: widget.type,
                      count: contacts.length,
                      onAdd: widget.onAdd,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: context.l10n.searchContacts,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon:
                            _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                  tooltip: context.l10n.clear,
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                  icon: const Icon(Icons.clear_rounded),
                                ),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    if (contacts.isEmpty)
                      _EmptyContactsCard(type: widget.type)
                    else if (filteredContacts.isEmpty)
                      _NoMatchingContactsCard()
                    else
                      ...filteredContacts.map(
                        (contact) => _ContactCard(
                          contact: contact,
                          onEdit: () => widget.onEdit(contact),
                          onDelete: () => widget.onDelete(contact),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ContactHeaderCard extends StatelessWidget {
  final SchoolContactType type;
  final int count;
  final VoidCallback onAdd;

  const _ContactHeaderCard({
    required this.type,
    required this.count,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isStaff = type == SchoolContactType.staff;
    final colour = isStaff ? const Color(0xFF5E7CE2) : const Color(0xFF26A69A);

    return Card(
      elevation: 0,
      color: colour.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colour.withValues(alpha: 0.16),
              child: Icon(
                isStaff ? Icons.badge_outlined : Icons.family_restroom_rounded,
                color: colour,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isStaff
                        ? context.l10n.staffContacts
                        : context.l10n.guardianContacts,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isStaff
                        ? context.l10n.staffContactsDescription
                        : context.l10n.guardianContactsDescription,
                  ),
                  const SizedBox(height: 10),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(context.l10n.contactCount(count)),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.addContact),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyContactsCard extends StatelessWidget {
  final SchoolContactType type;

  const _EmptyContactsCard({required this.type});

  @override
  Widget build(BuildContext context) {
    final isStaff = type == SchoolContactType.staff;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              isStaff ? Icons.badge_outlined : Icons.family_restroom_outlined,
              size: 54,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              isStaff
                  ? context.l10n.noStaffContacts
                  : context.l10n.noGuardianContacts,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              isStaff
                  ? context.l10n.noStaffContactsDescription
                  : context.l10n.noGuardianContactsDescription,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMatchingContactsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 54,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.noMatchingContacts,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.noMatchingContactsDescription,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final SchoolContact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;
    final isGuardian = contact.isGuardian;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              contact.active
                  ? colourScheme.primaryContainer
                  : colourScheme.surfaceContainerHighest,
          child: Icon(
            isGuardian ? Icons.family_restroom_rounded : Icons.badge_outlined,
            color:
                contact.active
                    ? colourScheme.onPrimaryContainer
                    : colourScheme.outline,
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contact.email),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ContactChip(
                    icon:
                        contact.active
                            ? Icons.check_circle_rounded
                            : Icons.pause_circle_outline_rounded,
                    label:
                        contact.active
                            ? context.l10n.active
                            : context.l10n.inactive,
                  ),
                  if (contact.role.isNotEmpty)
                    _ContactChip(
                      icon: Icons.work_outline_rounded,
                      label: contact.role,
                    ),
                  if (!isGuardian)
                    _ContactChip(
                      icon: Icons.person_pin_rounded,
                      label:
                          contact.staffProfileName.isEmpty
                              ? context.l10n.staffProfileNotLinked
                              : contact.staffProfileName,
                    ),
                  if (isGuardian && contact.relationship.isNotEmpty)
                    _ContactChip(
                      icon: Icons.favorite_outline_rounded,
                      label: contact.relationship,
                    ),
                  if (isGuardian)
                    _ContactChip(
                      icon: Icons.child_care_rounded,
                      label:
                          contact.childName.isEmpty
                              ? context.l10n.childNotAssigned
                              : contact.childName,
                    ),
                  if (contact.classroomName.isNotEmpty)
                    _ContactChip(
                      icon: Icons.meeting_room_outlined,
                      label: contact.classroomName,
                    ),
                  if (isGuardian)
                    _ContactChip(
                      icon:
                          contact.canReceiveReports
                              ? Icons.mark_email_read_outlined
                              : Icons.block_rounded,
                      label:
                          contact.canReceiveReports
                              ? context.l10n.canReceiveReports
                              : context.l10n.cannotReceiveReports,
                    ),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.edit_rounded),
                    title: Text(context.l10n.edit),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.delete_outline_rounded,
                      color: colourScheme.error,
                    ),
                    title: Text(context.l10n.delete),
                  ),
                ),
              ],
        ),
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContactChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ContactDialog extends StatefulWidget {
  final String schoolId;
  final SchoolContactType type;
  final SchoolContact? contact;
  final List<AdminChildProfileOption> childOptions;
  final List<AdminStaffProfileOption> staffOptions;
  final List<SchoolContact> existingContacts;

  const _ContactDialog({
    required this.schoolId,
    required this.type,
    required this.contact,
    required this.childOptions,
    required this.staffOptions,
    required this.existingContacts,
  });

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactClassroomOption {
  final String id;
  final String name;

  const _ContactClassroomOption({required this.id, required this.name});
}

class _DuplicateEmailWarning extends StatelessWidget {
  final SchoolContact contact;

  const _DuplicateEmailWarning({required this.contact});

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colourScheme.errorContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colourScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.duplicateEmailExistingContact(contact.name),
              style: TextStyle(
                color: colourScheme.onErrorContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactDialogState extends State<_ContactDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _roleController;
  late final TextEditingController _relationshipController;
  late bool _active;
  late bool _canReceiveReports;
  String? _selectedClassroomId;
  AdminChildProfileOption? _selectedChildOption;
  AdminStaffProfileOption? _selectedStaffOption;

  bool get _isGuardian => widget.type == SchoolContactType.guardian;

  SchoolContact? get _duplicateEmailContact {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty) return null;

    for (final contact in widget.existingContacts) {
      if (contact.id == widget.contact?.id) continue;
      if (contact.email.trim().toLowerCase() == email) {
        return contact;
      }
    }

    return null;
  }

  List<_ContactClassroomOption> get _classroomOptions {
    final optionsById = <String, _ContactClassroomOption>{};

    if (_isGuardian) {
      for (final option in widget.childOptions) {
        optionsById.putIfAbsent(
          option.classroomId,
          () => _ContactClassroomOption(
            id: option.classroomId,
            name: option.classroomName,
          ),
        );
      }
    } else {
      for (final option in widget.staffOptions) {
        optionsById.putIfAbsent(
          option.classroomId,
          () => _ContactClassroomOption(
            id: option.classroomId,
            name: option.classroomName,
          ),
        );
      }
    }

    final options = optionsById.values.toList();
    options.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return options;
  }

  List<AdminChildProfileOption> get _filteredChildOptions {
    final classroomId = _selectedClassroomId;
    if (classroomId == null || classroomId.isEmpty) {
      return const [];
    }

    return widget.childOptions
        .where((option) => option.classroomId == classroomId)
        .toList();
  }

  List<AdminStaffProfileOption> get _filteredStaffOptions {
    final classroomId = _selectedClassroomId;
    if (classroomId == null || classroomId.isEmpty) {
      return const [];
    }

    return widget.staffOptions
        .where((option) => option.classroomId == classroomId)
        .toList();
  }

  @override
  void initState() {
    super.initState();

    final contact = widget.contact;
    _nameController = TextEditingController(text: contact?.name ?? '');
    _emailController = TextEditingController(text: contact?.email ?? '');
    _roleController = TextEditingController(text: contact?.role ?? '');
    _relationshipController = TextEditingController(
      text: contact?.relationship ?? '',
    );
    _active = contact?.active ?? true;
    _canReceiveReports = contact?.canReceiveReports ?? true;
    _emailController.addListener(_handleEmailChanged);

    if (contact != null && contact.childId.isNotEmpty) {
      for (final option in widget.childOptions) {
        if (option.child.id == contact.childId &&
            option.classroomId == contact.classroomId) {
          _selectedChildOption = option;
          _selectedClassroomId = option.classroomId;
          break;
        }
      }
    } else if (contact != null && contact.staffProfileId.isNotEmpty) {
      for (final option in widget.staffOptions) {
        if (option.staff.id == contact.staffProfileId &&
            option.classroomId == contact.classroomId) {
          _selectedStaffOption = option;
          _selectedClassroomId = option.classroomId;
          break;
        }
      }
    } else if (contact != null && contact.classroomId.isNotEmpty) {
      _selectedClassroomId = contact.classroomId;
    }
  }

  void _handleEmailChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.removeListener(_handleEmailChanged);
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.contactNameEmailRequired)),
      );
      return;
    }

    if (_isGuardian && _selectedChildOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.guardianChildRequired)),
      );
      return;
    }

    if (!_isGuardian && _selectedStaffOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.staffProfileRequired)),
      );
      return;
    }

    if (_duplicateEmailContact != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.duplicateEmailWarning)),
      );
      return;
    }

    final selectedChild = _selectedChildOption;
    final selectedStaff = _selectedStaffOption;

    Navigator.pop(
      context,
      SchoolContact(
        id: widget.contact?.id ?? '',
        schoolId: widget.schoolId,
        type: widget.type,
        name: name,
        email: email,
        active: _active,
        classroomId:
            selectedChild?.classroomId ?? selectedStaff?.classroomId ?? '',
        classroomName:
            selectedChild?.classroomName ?? selectedStaff?.classroomName ?? '',
        childId: selectedChild?.child.id ?? '',
        childName: selectedChild?.child.name ?? '',
        staffProfileId: selectedStaff?.staff.id ?? '',
        staffProfileName: selectedStaff?.staff.name ?? '',
        relationship: _relationshipController.text.trim(),
        role: _roleController.text.trim(),
        canReceiveReports: _isGuardian ? _canReceiveReports : false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.contact != null;

    return AlertDialog(
      title: Text(
        editing
            ? context.l10n.editContact
            : _isGuardian
            ? context.l10n.addGuardianContact
            : context.l10n.addStaffContact,
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          key: PageStorageKey(
            'contact-dialog-${widget.contact?.id ?? widget.type.name}',
          ),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: context.l10n.name,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: context.l10n.email,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_duplicateEmailContact != null) ...[
                const SizedBox(height: 8),
                _DuplicateEmailWarning(contact: _duplicateEmailContact!),
              ],
              const SizedBox(height: 12),
              if (_isGuardian) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedClassroomId,
                  decoration: InputDecoration(
                    labelText: context.l10n.classroom,
                    border: const OutlineInputBorder(),
                  ),
                  items:
                      _classroomOptions.map((option) {
                        return DropdownMenuItem(
                          value: option.id,
                          child: Text(option.name),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClassroomId = value;
                      _selectedChildOption = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AdminChildProfileOption>(
                  initialValue:
                      _filteredChildOptions.contains(_selectedChildOption)
                          ? _selectedChildOption
                          : null,
                  decoration: InputDecoration(
                    labelText: context.l10n.assignedChild,
                    helperText:
                        _selectedClassroomId == null
                            ? context.l10n.selectClassroomFirst
                            : null,
                    border: const OutlineInputBorder(),
                  ),
                  items:
                      _filteredChildOptions.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option.child.name),
                        );
                      }).toList(),
                  onChanged:
                      _selectedClassroomId == null
                          ? null
                          : (value) {
                            setState(() {
                              _selectedChildOption = value;
                            });
                          },
                ),
                if (_selectedClassroomId != null &&
                    _filteredChildOptions.isEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.noChildrenInSelectedClassroom,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _relationshipController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: context.l10n.relationship,
                    hintText: context.l10n.relationshipHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _canReceiveReports,
                  title: Text(context.l10n.canReceiveReports),
                  subtitle: Text(context.l10n.canReceiveReportsDescription),
                  onChanged: (value) {
                    setState(() {
                      _canReceiveReports = value;
                    });
                  },
                ),
              ] else ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedClassroomId,
                  decoration: InputDecoration(
                    labelText: context.l10n.classroom,
                    border: const OutlineInputBorder(),
                  ),
                  items:
                      _classroomOptions.map((option) {
                        return DropdownMenuItem(
                          value: option.id,
                          child: Text(option.name),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClassroomId = value;
                      _selectedStaffOption = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AdminStaffProfileOption>(
                  initialValue:
                      _filteredStaffOptions.contains(_selectedStaffOption)
                          ? _selectedStaffOption
                          : null,
                  decoration: InputDecoration(
                    labelText: context.l10n.assignedStaffProfile,
                    helperText:
                        _selectedClassroomId == null
                            ? context.l10n.selectClassroomFirst
                            : null,
                    border: const OutlineInputBorder(),
                  ),
                  items:
                      _filteredStaffOptions.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option.staff.name),
                        );
                      }).toList(),
                  onChanged:
                      _selectedClassroomId == null
                          ? null
                          : (value) {
                            setState(() {
                              _selectedStaffOption = value;
                              if (value != null &&
                                  _nameController.text.trim().isEmpty) {
                                _nameController.text = value.staff.name;
                              }
                              if (value != null &&
                                  _roleController.text.trim().isEmpty) {
                                _roleController.text = value.staff.role;
                              }
                            });
                          },
                ),
                if (_selectedClassroomId != null &&
                    _filteredStaffOptions.isEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.noStaffInSelectedClassroom,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _roleController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: context.l10n.role,
                    hintText: context.l10n.staffContactRoleHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _active,
                title: Text(context.l10n.active),
                subtitle: Text(context.l10n.contactActiveDescription),
                onChanged: (value) {
                  setState(() {
                    _active = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save_rounded),
          label: Text(context.l10n.save),
        ),
      ],
    );
  }
}
