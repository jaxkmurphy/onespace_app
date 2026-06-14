import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassroomAuthService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> login({
    required String schoolCode,
    required String classroomCode,
    required String pin,
  }) async {
    final callable =
        _functions.httpsCallable('loginClassroomWithCode');

    final result = await callable.call({
      'schoolCode': schoolCode,
      'classroomCode': classroomCode,
      'pin': pin,
    });

    final data = Map<String, dynamic>.from(result.data);

    final token = data['token'] as String;

    await FirebaseAuth.instance.signInWithCustomToken(token);

    return data;
  }
}