import 'package:google_generative_ai/google_generative_ai.dart';

import '../env.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  GenerativeModel? _model;
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      // Get API key from Envied (compile-time safe)
      final apiKey = Env.geminiApiKey;

      if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
        print("❌ ERROR: GEMINI_API_KEY not found in .env file");
        print("📝 Make sure you:");
        print("   1. Created .env file in project root");
        print("   2. Added GEMINI_API_KEY=your_key_here");
        print("   3. Ran build_runner");
        return;
      }

      print("✅ API Key loaded successfully via Envied");
      print("🔑 API Key length: ${apiKey.length} characters");

      _model = GenerativeModel(
        model: 'gemini-2.5-flash-lite', // Using stable model
        apiKey: apiKey,
      );

      _isInitialized = true;
      print("✅ Gemini service initialized successfully");
    } catch (e) {
      print("❌ Error initializing Gemini: $e");
      _isInitialized = false;
    }
  }

  Future<String> analyzeBloodPressureTrend(
    Map<String, double> systolicReadings,
    List<Map<String, dynamic>> history,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized || _model == null) {
      return _getFallbackInsight(systolicReadings);
    }

    try {
      final validReadings = systolicReadings.entries
          .where((e) => e.value > 0 && e.value < 250)
          .toList();

      if (validReadings.isEmpty) {
        return "📊 Add your first blood pressure reading to get AI insights!";
      }

      final prompt =
          '''
You are a helpful health assistant. Analyze this blood pressure data:

Weekly Systolic Readings (mmHg):
${validReadings.map((e) => "${e.key}: ${e.value}").join('\n')}

Total readings in history: ${history.length}

Provide a VERY BRIEF analysis (under 60 words):
1. Overall trend (improving, stable, or concerning)
2. One specific observation
3. One actionable health tip

Keep it encouraging and simple. Use emojis to make it friendly.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? _getFallbackInsight(systolicReadings);
    } catch (e) {
      print("❌ Gemini API Error: $e");
      return _getFallbackInsight(systolicReadings);
    }
  }

  Future<String> getPersonalizedAdvice(
    String bloodPressure,
    String heartRate,
    String bloodGlucose,
    String spo2,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized || _model == null) {
      return "💪 Keep monitoring your health regularly! Stay hydrated and exercise daily.";
    }

    try {
      final prompt =
          '''
Give ONE short health tip (max 25 words) based on these readings:
- Blood Pressure: $bloodPressure
- Heart Rate: $heartRate
- Blood Glucose: $bloodGlucose
- SpO2: $spo2

Make it specific and actionable. Use an emoji.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? "💙 Keep up with your healthy habits!";
    } catch (e) {
      print("❌ Gemini API Error: $e");
      return "💪 Stay consistent with your health monitoring!";
    }
  }

  String _getFallbackInsight(Map<String, double> systolicReadings) {
    final values = systolicReadings.values.where((v) => v > 0).toList();
    if (values.isEmpty) {
      return "📊 Welcome! Add your first blood pressure reading to get personalized health insights and track your progress!";
    }

    final avg = values.reduce((a, b) => a + b) / values.length;

    if (avg < 120) {
      return "✅ Excellent! Your average blood pressure (${avg.toInt()}) is in the optimal range. Keep maintaining your healthy lifestyle! 🌟";
    } else if (avg < 130) {
      return "📊 Good! Your average blood pressure (${avg.toInt()}) is normal. Continue regular monitoring and healthy habits. 💪";
    } else if (avg < 140) {
      return "⚠️ Your average blood pressure (${avg.toInt()}) is elevated. Consider reducing salt intake and increasing physical activity. 🏃‍♂️";
    } else {
      return "🔴 Your average blood pressure (${avg.toInt()}) is high. Please consult a healthcare provider for personalized advice. 🏥";
    }
  }
}
