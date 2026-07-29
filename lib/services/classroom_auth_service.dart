import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class ClassroomAuthService {
  Future<Map<String, String>> registerSchoolAdmin({
    required String email,
    required String password,
    required String schoolName,
    required String schoolCode,
    required String setupCode,
  }) async {
    final projectId = Firebase.app().options.projectId;

    if (projectId.isEmpty) {
      throw Exception('Missing Firebase project ID.');
    }

    final uri = Uri.parse(
      'https://us-central1-$projectId.cloudfunctions.net/registerSchoolAdminWithSetupCode',
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'data': {
          'email': email,
          'password': password,
          'schoolName': schoolName,
          'schoolCode': schoolCode,
          'setupCode': setupCode,
        },
      }),
    );

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid registration response.');
    }

    final error = decoded['error'];

    if (error is Map<String, dynamic>) {
      final status = error['status']?.toString();

      if (status == 'ALREADY_EXISTS') {
        throw Exception('school-registration-already-exists');
      }

      if (status == 'PERMISSION_DENIED') {
        throw Exception('school-registration-not-allowed');
      }

      throw Exception('Could not create admin account.');
    }

    if (response.statusCode != 200) {
      throw Exception('Could not create admin account.');
    }

    final result = decoded['result'];

    if (result is! Map<String, dynamic>) {
      throw Exception('Invalid registration result.');
    }

    final token = result['token']?.toString();
    final schoolId = result['schoolId']?.toString();
    final schoolNameResult = result['schoolName']?.toString();

    if (token == null ||
        schoolId == null ||
        schoolNameResult == null ||
        token.isEmpty ||
        schoolId.isEmpty ||
        schoolNameResult.isEmpty) {
      throw Exception('Incomplete registration response.');
    }

    await FirebaseAuth.instance.signInWithCustomToken(token);

    return {'schoolId': schoolId, 'schoolName': schoolNameResult};
  }

  Future<Map<String, String>> login({
    required String schoolCode,
    required String classroomCode,
    required String pin,
  }) async {
    final projectId = Firebase.app().options.projectId;

    if (projectId.isEmpty) {
      throw Exception('Missing Firebase project ID.');
    }

    final uri = Uri.parse(
      'https://us-central1-$projectId.cloudfunctions.net/loginClassroomWithCode',
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'data': {
          'schoolCode': schoolCode,
          'classroomCode': classroomCode,
          'pin': pin,
        },
      }),
    );

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid classroom login response.');
    }

    final error = decoded['error'];

    if (error is Map<String, dynamic>) {
      final status = error['status']?.toString();

      if (status == 'RESOURCE_EXHAUSTED') {
        throw Exception('classroom-login-rate-limited');
      }

      throw Exception('Classroom login details are incorrect.');
    }

    if (response.statusCode != 200) {
      throw Exception('Classroom login failed.');
    }

    final result = decoded['result'];

    if (result is! Map<String, dynamic>) {
      throw Exception('Invalid classroom login result.');
    }

    final token = result['token']?.toString();
    final schoolId = result['schoolId']?.toString();
    final classroomId = result['classroomId']?.toString();
    final classroomName = result['classroomName']?.toString();

    if (token == null ||
        schoolId == null ||
        classroomId == null ||
        classroomName == null ||
        token.isEmpty ||
        schoolId.isEmpty ||
        classroomId.isEmpty ||
        classroomName.isEmpty) {
      throw Exception('Incomplete classroom login response.');
    }

    await FirebaseAuth.instance.signInWithCustomToken(token);

    return {
      'schoolId': schoolId,
      'classroomId': classroomId,
      'classroomName': classroomName,
    };
  }
}
