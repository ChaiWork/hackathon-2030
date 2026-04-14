import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();

  Future<Map<String, dynamic>> fetchData() async {
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.STEPS,
    ];

    await _health.configure();

    bool permission = await _health.requestAuthorization(types);

    if (!permission) {
      return {
        "heartRate": null,
        "spo2": null,
        "steps": null,
        "error": "Permission denied",
      };
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final data = await _health.getHealthDataFromTypes(
      startTime: startOfDay,
      endTime: now,
      types: types,
    );

    if (data.isEmpty) {
      print("⚠️ No data returned");
    }

    // ✅ SORT BY MOST RECENT
    data.sort((a, b) => b.dateTo.compareTo(a.dateTo));

    double? heartRate;
    double? spo2;
    int totalSteps = 0;

    final seen = <String>{};

    for (var point in data) {
      if (point.value is! NumericHealthValue) continue;

      final key = "${point.type}_${point.dateFrom}_${point.dateTo}";
      if (seen.contains(key)) continue;
      seen.add(key);

      final value = (point.value as NumericHealthValue).numericValue.toDouble();

      // ❤️ TAKE LATEST ONLY
      if (point.type == HealthDataType.HEART_RATE && heartRate == null) {
        heartRate = value;
        print("❤️ Latest HR: $heartRate at ${point.dateTo}");
      }

      // 🫁 TAKE LATEST ONLY
      if (point.type == HealthDataType.BLOOD_OXYGEN && spo2 == null) {
        spo2 = value;
        print("🫁 Latest SpO2: $spo2 at ${point.dateTo}");
      }

      // 👟 SUM ALL TODAY
      if (point.type == HealthDataType.STEPS) {
        totalSteps += value.toInt();
      }

      // ✅ BREAK EARLY when done
      if (heartRate != null && spo2 != null) {
        // still continue steps (optional)
        continue;
      }
    }

    print("✅ FINAL → HR: $heartRate, SpO2: $spo2, Steps: $totalSteps");

    return {
      "heartRate": heartRate?.toInt(), // ✅ convert to int
      "spo2": spo2?.toInt(), // ✅ convert to int
      "steps": totalSteps,
      "lastUpdated": DateTime.now().toIso8601String(),
    };
  }
}
