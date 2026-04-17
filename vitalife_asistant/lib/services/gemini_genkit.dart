import 'package:cloud_functions/cloud_functions.dart';

class GenkitService {
  static const String _functionName = 'healthAnalysis';
  static const String _region = 'us-central1';

  static Future<Map<String, dynamic>> analyzeHealth({
    required int heartRate,
  }) async {
    try {
      final functions = FirebaseFunctions.instanceFor(region: _region);

      final callable = functions.httpsCallable(
        _functionName,
        options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
      );

      final result = await callable.call({
        "heartRate": heartRate,
      });

      final normalized = _normalizeResponse(result.data);
      if (normalized == null) {
        throw Exception("Empty response from server");
      }

      return normalized;
    } on FirebaseFunctionsException catch (e) {
      return {
        "risk": "unknown",
        "error": true,
        "errorCode": e.code,
        "summary": "Cloud Function error (${e.code})",
        "advice": e.message ?? "Function failed. Check backend logs.",
        "details": e.details?.toString(),
      };
    } catch (e) {
      return {
        "risk": "unknown",
        "error": true,
        "errorCode": "client_exception",
        "summary": "Unexpected error while calling AI analysis",
        "details": e.toString(),
        "advice": "Check internet connection and Cloud Function deployment.",
      };
    }
  }

  static Map<String, dynamic>? _normalizeResponse(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      // Support wrapped payloads from callable handlers.
      final nested = map['data'] ?? map['result'] ?? map['output'];
      if (nested is Map) {
        final nestedMap = Map<String, dynamic>.from(nested);
        return _ensureRequiredFields(nestedMap);
      }

      return _ensureRequiredFields(map);
    }

    if (data is String && data.isNotEmpty) {
      return _ensureRequiredFields({"summary": data});
    }

    return null;
  }

  static Map<String, dynamic> _ensureRequiredFields(Map<String, dynamic> map) {
    return {
      "risk": (map['risk'] ?? map['level'] ?? 'unknown').toString(),
      "summary": (map['summary'] ?? map['analysis'] ?? '').toString(),
      "advice": (map['advice'] ?? map['recommendation'] ?? '').toString(),
      ...map,
    };
  }
}
