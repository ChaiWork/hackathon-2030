import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const apiKey = "AIzaSyA6xv2HtQJhxlf_3IyqWJwys1VntVJJivU";

  static Future<Map<String, dynamic>> analyzeSymptoms(String symptoms) async {
    try {
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

Return ONLY valid JSON:
{
 "risk":"HIGH/MEDIUM/LOW",
 "reason":"brief explanation",
 "recommendation":"what to do"
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

      if (data["candidates"] != null) {
        String text = data["candidates"][0]["content"]["parts"][0]["text"];
        return {"result": text};
      }
    } catch (e) {
      print("Gemini failed, switching to rule-based AI");
    }

    // Fallback Rule-Based AI
    return ruleBasedAI(symptoms);
  }

  static Map<String, dynamic> ruleBasedAI(String symptoms) {
    String s = symptoms.toLowerCase();

    if (s.contains("chest pain") || s.contains("difficulty breathing")) {
      return {
        "result": """
{
 "risk": "HIGH",
 "reason": "Possible serious condition affecting heart or lungs",
 "recommendation": "Go to emergency department immediately"
}
""",
      };
    }

    if (s.contains("fever") || s.contains("cough")) {
      return {
        "result": """
{
 "risk": "MEDIUM",
 "reason": "Possible infection",
 "recommendation": "Visit clinic if symptoms persist"
}
""",
      };
    }

    return {
      "result": """
{
 "risk": "LOW",
 "reason": "Minor symptoms",
 "recommendation": "Rest, hydrate, and monitor symptoms"
}
""",
    };
  }
}
