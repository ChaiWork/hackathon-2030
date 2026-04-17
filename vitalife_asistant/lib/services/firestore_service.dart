import 'package:cloud_functions/cloud_functions.dart';

class FirestoreService {
  static const String _region = 'us-central1';
  final FirebaseFunctions _functions;

  FirestoreService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instanceFor(region: _region);

  Future<void> saveHeartRate({
    required String uid,
    required int heartRate,
    int? spo2,
    int? steps,
  }) async {
    // uid is ignored server-side (request.auth.uid is used).
    final callable = _functions.httpsCallable(
      'saveHeartRateLog',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 20)),
    );
    await callable.call(<String, dynamic>{
      'heartRate': heartRate,
      if (spo2 != null) 'spo2': spo2,
      if (steps != null) 'steps': steps,
    });
  }
}
