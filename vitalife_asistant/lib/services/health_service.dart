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
    final yesterday = now.subtract(const Duration(hours: 24));

    final data = await _health.getHealthDataFromTypes(
      startTime: yesterday,
      endTime: now,
      types: types,
    );

    if (data.isEmpty) {
      print("⚠️ No data returned from Health Connect");
    }

    // ✅ SORT by latest time
    data.sort((a, b) => b.dateTo.compareTo(a.dateTo));

    double? heartRate;
    double? spo2;
    int? steps;

    for (var point in data) {
      if (point.value is! NumericHealthValue) continue;

      final value = (point.value as NumericHealthValue).numericValue.toDouble();

      // ✅ TAKE FIRST (LATEST) VALUE ONLY
      if (point.type == HealthDataType.HEART_RATE && heartRate == null) {
        heartRate = value;
      }

      if (point.type == HealthDataType.BLOOD_OXYGEN && spo2 == null) {
        spo2 = value;
      }

      if (point.type == HealthDataType.STEPS && steps == null) {
        steps = value.toInt();
      }

      // ✅ Stop early if all found
      if (heartRate != null && spo2 != null && steps != null) break;
    }

    print("✅ Final Data → HR: $heartRate, SpO2: $spo2, Steps: $steps");

    return {
      "heartRate": heartRate,
      "spo2": spo2,
      "steps": steps,
      "lastUpdated": DateTime.now().toIso8601String(),
    };
  }
}
