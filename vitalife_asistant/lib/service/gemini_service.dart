import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const apiKey = "AIzaSyA6xv2HtQJhxlf_3IyqWJwys1VntVJJivU";

  static Future<Map<String, dynamic>> analyzeSymptoms(String symptoms) async {
    final url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey";

    final prompt =
        """
You are a medical triage assistant.

Classify symptoms into:
HIGH - go to emergency department
MEDIUM - visit clinic  
LOW - self care

Symptoms: $symptoms

Return ONLY valid JSON in this exact format:
{
  "risk": "HIGH/MEDIUM/LOW",
  "reason": "brief explanation",
  "recommendation": "what to do"
}
""";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    final data = jsonDecode(response.body);

    print("Gemini response:");
    print(data);

    if (data["candidates"] != null) {
      String text = data["candidates"][0]["content"]["parts"][0]["text"];

      return {"result": text};
    }

    return {"result": "Failed to analyze symptoms"};
  }
}
