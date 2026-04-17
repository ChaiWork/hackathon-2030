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

  Future<void> saveUserProfile({
    required String uid,
    required String age,
    required String gender,
    required String height,
    required String weight,
    required String email,
    required String fullName,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'email': email,
      'fullName': fullName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // =========================
  // GET USER PROFILE
  // =========================
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists) {
      return doc.data();
    }
    return null;
  }
}
