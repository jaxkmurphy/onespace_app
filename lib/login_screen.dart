import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/school.dart';
import 'models/school_member.dart';
import 'services/classroom_auth_service.dart';
import 'services/firestore_service.dart';
import 'services/classroom_session_service.dart';
import 'l10n/l10n.dart';

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
  final setupCodeController = TextEditingController();

  final classroomSchoolCodeController = TextEditingController();
  final classroomCodeController = TextEditingController();
  final classroomPinController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final ClassroomAuthService _classroomAuthService = ClassroomAuthService();

  bool isRegistering = false;
  bool isLoading = false;
  bool _showAdminPassword = false;
  bool _showSetupCode = false;
  bool _showClassroomPin = false;
  int selectedTab = 0;

  Future<void> _handleAdminAuth() async {
    final l10n = context.l10n;
    setState(() => isLoading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (isRegistering) {
        final schoolName = schoolNameController.text.trim();
        final schoolCode = schoolCodeController.text.trim().toUpperCase();
        final setupCode = setupCodeController.text.trim();

        if (schoolName.isEmpty || schoolCode.isEmpty || setupCode.isEmpty) {
          throw Exception(l10n.enterSchoolDetails);
        }

        final result = await _classroomAuthService.registerSchoolAdmin(
          email: email,
          password: password,
          schoolName: schoolName,
          schoolCode: schoolCode,
          setupCode: setupCode,
        );

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          '/admin-dashboard',
          arguments: {
            'schoolId': result['schoolId'],
            'schoolName': result['schoolName'],
          },
        );
      } else {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        final user = userCredential.user;

        if (user == null) {
          throw Exception(l10n.loginFailed);
        }

        await _sendUserToCorrectPage(user);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_cleanError(e))));
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
        throw Exception(context.l10n.enterClassroomDetails);
      }

      final result = await _classroomAuthService.login(
        schoolCode: schoolCode,
        classroomCode: classroomCode,
        pin: pin,
      );

      if (!mounted) return;

      ClassroomSessionService.instance.setSession(
        schoolId: result['schoolId']!,
        classroomId: result['classroomId']!,
        classroomName: result['classroomName']!,
      );

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_cleanError(e))));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _sendUserToCorrectPage(User user) async {
    final SchoolMember? member = await _firestoreService.getSchoolMemberByUid(
      user.uid,
    );

    if (!mounted) return;

    if (member != null && member.active && member.role == 'schoolAdmin') {
      final School? school = await _firestoreService.getSchool(member.schoolId);

      if (!mounted) return;

      if (school != null) {
        Navigator.pushReplacementNamed(
          context,
          '/admin-dashboard',
          arguments: {'schoolId': school.id, 'schoolName': school.name},
        );
        return;
      }
    }

    Navigator.pushReplacementNamed(context, '/profiles');
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.contains('permission-denied')) {
      return context.l10n.classroomLoginIncorrect;
    }

    if (message.contains('resource-exhausted') ||
        message.contains('classroom-login-rate-limited')) {
      return context.l10n.classroomLoginTooManyAttempts;
    }

    if (message.contains('school-registration-not-allowed')) {
      return context.l10n.schoolSetupCodeIncorrect;
    }

    if (message.contains('school-registration-already-exists')) {
      return context.l10n.schoolRegistrationAlreadyExists;
    }

    if (message.contains('invalid-argument')) {
      return context.l10n.checkLoginFields;
    }

    if (message.contains('user-not-found') ||
        message.contains('wrong-password') ||
        message.contains('invalid-credential')) {
      return context.l10n.adminLoginIncorrect;
    }

    return message.replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    schoolNameController.dispose();
    schoolCodeController.dispose();
    setupCodeController.dispose();
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
        onTap:
            isLoading
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
              color:
                  selected ? colourScheme.primary : colourScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color:
                    selected
                        ? colourScheme.onPrimaryContainer
                        : colourScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      selected
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
            decoration: InputDecoration(
              labelText: context.l10n.schoolName,
              hintText: context.l10n.schoolNameHint,
              prefixIcon: const Icon(Icons.school_outlined),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: schoolCodeController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: context.l10n.schoolCode,
              hintText: context.l10n.schoolCodeHint,
              prefixIcon: const Icon(Icons.badge_outlined),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: setupCodeController,
            obscureText: !_showSetupCode,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: context.l10n.schoolSetupCode,
              hintText: context.l10n.schoolSetupCodeHint,
              prefixIcon: const Icon(Icons.verified_user_outlined),
              suffixIcon: IconButton(
                tooltip:
                    _showSetupCode
                        ? context.l10n.hidePassword
                        : context.l10n.showPassword,
                icon: Icon(
                  _showSetupCode
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed:
                    isLoading
                        ? null
                        : () {
                          setState(() {
                            _showSetupCode = !_showSetupCode;
                          });
                        },
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
        ],
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: context.l10n.adminEmail,
            prefixIcon: const Icon(Icons.email_outlined),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: passwordController,
          obscureText: !_showAdminPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!isLoading) _handleAdminAuth();
          },
          decoration: InputDecoration(
            labelText: context.l10n.password,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              tooltip:
                  _showAdminPassword
                      ? context.l10n.hidePassword
                      : context.l10n.showPassword,
              icon: Icon(
                _showAdminPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed:
                  isLoading
                      ? null
                      : () {
                        setState(() {
                          _showAdminPassword = !_showAdminPassword;
                        });
                      },
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _handleAdminAuth,
            icon:
                isLoading
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Icon(isRegistering ? Icons.person_add : Icons.login),
            label: Text(
              isLoading
                  ? context.l10n.pleaseWait
                  : isRegistering
                  ? context.l10n.createSchoolAdminAccount
                  : context.l10n.adminLogin,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed:
              isLoading
                  ? null
                  : () {
                    setState(() {
                      isRegistering = !isRegistering;
                    });
                  },
          child: Text(
            isRegistering
                ? context.l10n.existingAdminLogin
                : context.l10n.registerSchoolPrompt,
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
          decoration: InputDecoration(
            labelText: context.l10n.schoolCode,
            hintText: context.l10n.schoolCodeHint,
            prefixIcon: const Icon(Icons.school_outlined),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: classroomCodeController,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: context.l10n.classroomCode,
            hintText: context.l10n.classroomCodeHint,
            prefixIcon: const Icon(Icons.meeting_room_outlined),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: classroomPinController,
          obscureText: !_showClassroomPin,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!isLoading) _handleClassroomLogin();
          },
          decoration: InputDecoration(
            labelText: context.l10n.classroomPin,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              tooltip:
                  _showClassroomPin
                      ? context.l10n.hidePassword
                      : context.l10n.showPassword,
              icon: Icon(
                _showClassroomPin
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed:
                  isLoading
                      ? null
                      : () {
                        setState(() {
                          _showClassroomPin = !_showClassroomPin;
                        });
                      },
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _handleClassroomLogin,
            icon:
                isLoading
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.login),
            label: Text(
              isLoading ? context.l10n.checking : context.l10n.enterClassroom,
            ),
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
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAdminTab
                            ? isRegistering
                                ? context.l10n.createSchoolAdminIntro
                                : context.l10n.adminLoginIntro
                            : context.l10n.classroomLoginIntro,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildTabButton(
                            label: context.l10n.admin,
                            icon: Icons.admin_panel_settings,
                            index: 0,
                          ),
                          const SizedBox(width: 12),
                          _buildTabButton(
                            label: context.l10n.classroom,
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
