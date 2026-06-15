import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassroomAuthService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, String>> login({
    required String schoolCode,
    required String classroomCode,
    required String pin,
  }) async {
    final callable = _functions.httpsCallable('loginClassroomWithCode');

    final result = await callable.call({
      'schoolCode': schoolCode,
      'classroomCode': classroomCode,
      'pin': pin,
    });

    final rawData = result.data;

    if (rawData is! Map) {
      throw Exception('Invalid classroom login response.');
    }

    final token = rawData['token']?.toString();
    final schoolId = rawData['schoolId']?.toString();
    final classroomId = rawData['classroomId']?.toString();
    final classroomName = rawData['classroomName']?.toString();

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