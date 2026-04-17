import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveHeartRate({
    required String uid,
    required int heartRate,
    int? spo2,
    int? steps,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('heart_rate_logs')
        .add({
      'heartRate': heartRate,
      'spo2': spo2,
      'steps': steps,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
