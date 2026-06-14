import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models/school.dart';
import 'models/school_member.dart';
import 'services/classroom_auth_service.dart';
import 'services/firestore_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final schoolNameController = TextEditingController();
  final schoolCodeController = TextEditingController();

  final classroomSchoolCodeController = TextEditingController();
  final classroomCodeController = TextEditingController();
  final classroomPinController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final ClassroomAuthService _classroomAuthService = ClassroomAuthService();

  bool isRegistering = false;
  bool isLoading = false;
  int selectedTab = 0;

  Future<void> _handleAdminAuth() async {
    setState(() => isLoading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (isRegistering) {
        final schoolName = schoolNameController.text.trim();
        final schoolCode = schoolCodeController.text.trim().toUpperCase();

        if (schoolName.isEmpty || schoolCode.isEmpty) {
          throw Exception('Please enter a school name and school code.');
        }

        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user;

        if (user == null) {
          throw Exception('Could not create admin account.');
        }

        final schoolId = await _firestoreService.createSchool(
          name: schoolName,
          schoolCode: schoolCode,
          adminUid: user.uid,
          adminEmail: email,
        );

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          '/admin-dashboard',
          arguments: {
            'schoolId': schoolId,
            'schoolName': schoolName,
          },
        );
      } else {
        final userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user;

        if (user == null) {
          throw Exception('Could not log in.');
        }

        await _sendUserToCorrectPage(user);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_cleanError(e))),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleClassroomLogin() async {
    setState(() => isLoading = true);

    try {
      final schoolCode = classroomSchoolCodeController.text.trim();
      final classroomCode = classroomCodeController.text.trim();
      final pin = classroomPinController.text.trim();

      if (schoolCode.isEmpty || classroomCode.isEmpty || pin.isEmpty) {
        throw Exception('Please enter school code, classroom code and PIN.');
      }

      final result = await _classroomAuthService.login(
        schoolCode: schoolCode,
        classroomCode: classroomCode,
        pin: pin,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/profiles',
        arguments: {
          'schoolId': result['schoolId'],
          'classroomId': result['classroomId'],
          'classroomName': result['classroomName'],
          'isClassroomLogin': true,
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_cleanError(e))),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _sendUserToCorrectPage(User user) async {
    final SchoolMember? member =
        await _firestoreService.getSchoolMemberByUid(user.uid);

    if (!mounted) return;

    if (member != null && member.active && member.role == 'schoolAdmin') {
      final School? school = await _firestoreService.getSchool(member.schoolId);

      if (!mounted) return;

      if (school != null) {
        Navigator.pushReplacementNamed(
          context,
          '/admin-dashboard',
          arguments: {
            'schoolId': school.id,
            'schoolName': school.name,
          },
        );
        return;
      }
    }

    Navigator.pushReplacementNamed(context, '/profiles');
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.contains('permission-denied')) {
      return 'Classroom login details are incorrect.';
    }

    if (message.contains('invalid-argument')) {
      return 'Please check all login fields.';
    }

    if (message.contains('user-not-found') ||
        message.contains('wrong-password') ||
        message.contains('invalid-credential')) {
      return 'Admin email or password is incorrect.';
    }

    return message.replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    schoolNameController.dispose();
    schoolCodeController.dispose();
    classroomSchoolCodeController.dispose();
    classroomCodeController.dispose();
    classroomPinController.dispose();
    super.dispose();
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required int index,
  }) {
    final selected = selectedTab == index;
    final colourScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: isLoading
            ? null
            : () {
                setState(() {
                  selectedTab = index;
                  isRegistering = false;
                });
              },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? colourScheme.primaryContainer : null,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? colourScheme.primary
                  : colourScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? colourScheme.onPrimaryContainer
                    : colourScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected
                      ? colourScheme.onPrimaryContainer
                      : colourScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminLoginForm() {
    return Column(
      children: [
        if (isRegistering) ...[
          TextField(
            controller: schoolNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'School Name',
              hintText: 'Example: St Mary’s Primary School',
              prefixIcon: Icon(Icons.school_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: schoolCodeController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'School Code',
              hintText: 'Example: STM123',
              prefixIcon: Icon(Icons.badge_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
        ],
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Admin Email',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: passwordController,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!isLoading) _handleAdminAuth();
          },
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _handleAdminAuth,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(isRegistering ? Icons.person_add : Icons.login),
            label: Text(
              isLoading
                  ? 'Please wait...'
                  : isRegistering
                      ? 'Create School Admin Account'
                      : 'Admin Login',
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  setState(() {
                    isRegistering = !isRegistering;
                  });
                },
          child: Text(
            isRegistering
                ? 'Already have an admin account? Login'
                : 'No admin account? Register school',
          ),
        ),
      ],
    );
  }

  Widget _buildClassroomLoginForm() {
    return Column(
      children: [
        TextField(
          controller: classroomSchoolCodeController,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'School Code',
            hintText: 'Example: STM123',
            prefixIcon: Icon(Icons.school_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: classroomCodeController,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Classroom Code',
            hintText: 'Example: ASD1',
            prefixIcon: Icon(Icons.meeting_room_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: classroomPinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!isLoading) _handleClassroomLogin();
          },
          decoration: const InputDecoration(
            labelText: 'Classroom PIN',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _handleClassroomLogin,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login),
            label: Text(isLoading ? 'Checking...' : 'Enter Classroom'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colourScheme = Theme.of(context).colorScheme;
    final isAdminTab = selectedTab == 0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: colourScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          size: 48,
                          color: colourScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'OneSpace',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAdminTab
                            ? isRegistering
                                ? 'Create a school admin account'
                                : 'Admin login'
                            : 'Classroom login',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildTabButton(
                            label: 'Admin',
                            icon: Icons.admin_panel_settings,
                            index: 0,
                          ),
                          const SizedBox(width: 12),
                          _buildTabButton(
                            label: 'Classroom',
                            icon: Icons.meeting_room,
                            index: 1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      if (isAdminTab)
                        _buildAdminLoginForm()
                      else
                        _buildClassroomLoginForm(),
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