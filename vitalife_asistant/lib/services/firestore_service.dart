import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // =========================
  // SAVE SINGLE HEART RATE LOG
  // =========================
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

  // =========================
  // SAVE DAILY HEART RATE BREAKDOWN (OPTION 1)
  // =========================
  Future<void> saveDailyBreakdown({
    required String uid,
    required List<int?> hourlyData,
  }) async {
    final now = DateTime.now();

    // Normalize date (remove time)
    final today = DateTime(now.year, now.month, now.day);

    final collectionRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('heart_rate_breakdown');

    try {
      // ✅ Check if today's data already exists (prevent duplicate)
      final existing = await collectionRef
          .where('date', isEqualTo: today)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        print("⚠️ Breakdown already saved today. Skipping...");
        return;
      }

      final batch = _firestore.batch();

      for (int hour = 0; hour < hourlyData.length; hour++) {
        final value = hourlyData[hour];

        if (value == null) continue;

        final docRef = collectionRef.doc();

        batch.set(docRef, {
          'hour': hour,
          'heartRate': value,
          'date': today,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      print("✅ Daily heart rate breakdown saved!");
    } catch (e) {
      print("❌ Error saving breakdown: $e");
    }
  }

  // =========================
  // GET TODAY BREAKDOWN
  // =========================
  Future<List<Map<String, dynamic>>> getTodayBreakdown(String uid) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('heart_rate_breakdown')
        .where('date', isEqualTo: today)
        .orderBy('hour')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // =========================
  // SAVE USER PROFILE
  // =========================
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

  Future<void> saveAIInsight({
    required String uid,
    required int heartRate,
    required String risk,
    required String summary,
    required String advice,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final collectionRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('ai_insights');

    try {
      // =========================
      // 🚫 AVOID DUPLICATE (same HR + same day + same risk)
      // =========================
      final existing = await collectionRef
          .where('heartRate', isEqualTo: heartRate)
          .where('risk', isEqualTo: risk)
          .where(
            'date',
            isGreaterThanOrEqualTo: today,
            isLessThan: today.add(const Duration(days: 1)),
          )
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        print("⚠️ Duplicate AI insight skipped");
        return;
      }

      // =========================
      // 💾 SAVE ALL RISK LEVELS
      // =========================
      await collectionRef.add({
        'heartRate': heartRate,
        'risk': risk, // low / medium / high
        'summary': summary,
        'advice': advice,
        'date': today,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("✅ AI insight saved ($risk)");
    } catch (e) {
      print("❌ Error saving AI insight: $e");
    }
  }
}
