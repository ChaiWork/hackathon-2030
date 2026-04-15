import 'package:cloud_functions/cloud_functions.dart';

class GenkitService {
  static Future<Map<String, dynamic>> analyzeHealth({
    required int systolic,
    required int diastolic,
    required int heartRate,
    required double glucose,
    required int spo2,
  }) async {
    try {
      final functions = FirebaseFunctions.instance;

      final callable = functions.httpsCallable(
        'healthAnalysis',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
      );

      final result = await callable.call({
        "systolic": systolic,
        "diastolic": diastolic,
        "heartRate": heartRate,
        "glucose": glucose,
        "spo2": spo2,
      });

      if (result.data == null) {
        throw Exception("Empty response from server");
      }

      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      print("FUNCTION CODE: ${e.code}");
      print("FUNCTION MESSAGE: ${e.message}");
      print("FUNCTION DETAILS: ${e.details}");

      return {
        "risk": "unknown",
        "explanation": "Firebase error: ${e.code}",
        "advice": e.message ?? "No message",
        "summary": e.details?.toString() ?? "No details",
      };
    } catch (e) {
      return {
        "risk": "unknown",
        "explanation": "Unexpected error",
        "advice": "Check internet or backend",
        "summary": e.toString(),
      };
    }
  }
}
