import 'package:cloud_functions/cloud_functions.dart';

class ProfileService {
  static const String _region = 'us-central1';

  FirebaseFunctions get _functions => FirebaseFunctions.instanceFor(region: _region);

  Future<Map<String, dynamic>> getProfile() async {
    final callable = _functions.httpsCallable(
      'getUserProfile',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );
    final result = await callable.call();
    final data = result.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final profile = map['profile'];
      if (profile is Map) return Map<String, dynamic>.from(profile);
    }
    throw Exception('Invalid response from getUserProfile');
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> patch) async {
    final callable = _functions.httpsCallable(
      'updateUserProfile',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );
    final result = await callable.call(patch);
    final data = result.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final profile = map['profile'];
      if (profile is Map) return Map<String, dynamic>.from(profile);
    }
    throw Exception('Invalid response from updateUserProfile');
  }
}

