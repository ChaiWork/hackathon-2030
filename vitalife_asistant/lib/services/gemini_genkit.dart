import 'dart:convert';
import 'package:http/http.dart' as http;

class GenkitService {
  static const String baseUrl = "http://10.0.2.2:3000";

  /// AI health analysis (REPLACES analyzeBloodPressureTrend)
  static Future<Map<String, dynamic>> analyzeHealth({
    required int systolic,
    required int diastolic,
    required int heartRate,
    required double glucose,
    required int spo2,
    String symptoms = "",
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/analyze"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "systolic": systolic,
        "diastolic": diastolic,
        "heartRate": heartRate,
        "glucose": glucose,
        "spo2": spo2,
        "symptoms": symptoms,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Genkit API failed");
    }
  }
}
