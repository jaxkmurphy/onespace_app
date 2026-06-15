import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class ClassroomAuthService {
  Future<Map<String, String>> login({
    required String schoolCode,
    required String classroomCode,
    required String pin,
  }) async {
    final projectId = Firebase.app().options.projectId;

    if (projectId == null || projectId.isEmpty) {
      throw Exception('Missing Firebase project ID.');
    }

    final uri = Uri.parse(
      'https://us-central1-$projectId.cloudfunctions.net/loginClassroomWithCode',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'data': {
          'schoolCode': schoolCode,
          'classroomCode': classroomCode,
          'pin': pin,
        },
      }),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception('Classroom login failed.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid classroom login response.');
    }

    if (decoded['error'] != null) {
      throw Exception('Classroom login details are incorrect.');
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