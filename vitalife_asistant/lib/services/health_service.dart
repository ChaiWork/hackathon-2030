// services/health_service.dart
import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();

  Future<void> _initialize() async {
    await _health.configure();
  }

  Future<Map<String, dynamic>> fetchData() async {
    await _initialize();
    
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.STEPS,
    ];

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

    // SORT BY MOST RECENT
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

      // TAKE LATEST ONLY
      if (point.type == HealthDataType.HEART_RATE && heartRate == null) {
        heartRate = value;
        print("❤️ Latest HR: $heartRate at ${point.dateTo}");
      }

      // TAKE LATEST ONLY
      if (point.type == HealthDataType.BLOOD_OXYGEN && spo2 == null) {
        spo2 = value;
        print("🫁 Latest SpO2: $spo2 at ${point.dateTo}");
      }

      // SUM ALL TODAY
      if (point.type == HealthDataType.STEPS) {
        totalSteps += value.toInt();
      }
    }

    print("✅ FINAL → HR: $heartRate, SpO2: $spo2, Steps: $totalSteps");

    return {
      "heartRate": heartRate?.toInt(),
      "spo2": spo2?.toInt(),
      "steps": totalSteps,
      "lastUpdated": DateTime.now().toIso8601String(),
    };
  }

  Future<int?> fetchAverageHeartRate({int days = 7}) async {
    await _initialize();
    
    final types = [HealthDataType.HEART_RATE];

    bool permission = await _health.requestAuthorization(types);

    if (!permission) {
      print("❌ Permission denied for average heart rate");
      return null;
    }

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - days);

    final data = await _health.getHealthDataFromTypes(
      startTime: startDate,
      endTime: now,
      types: types,
    );

    if (data.isEmpty) {
      print("⚠️ No heart rate data for average calculation");
      return null;
    }

    List<double> heartRates = [];
    
    for (var point in data) {
      if (point.value is NumericHealthValue) {
        final value = (point.value as NumericHealthValue).numericValue.toDouble();
        heartRates.add(value);
      }
    }

    if (heartRates.isEmpty) {
      return null;
    }

    // Calculate average
    double sum = heartRates.reduce((a, b) => a + b);
    int average = (sum / heartRates.length).round();
    
    print("📊 Average heart rate over $days days: $average bpm (from ${heartRates.length} readings)");
    
    return average;
  }

  Future<List<int>> fetchHeartRateHistory({int days = 7}) async {
    await _initialize();
    
    final types = [HealthDataType.HEART_RATE];

    bool permission = await _health.requestAuthorization(types);

    if (!permission) {
      print("❌ Permission denied for heart rate history");
      return [];
    }

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - days);

    final data = await _health.getHealthDataFromTypes(
      startTime: startDate,
      endTime: now,
      types: types,
    );

    List<int> heartRates = [];
    
    for (var point in data) {
      if (point.value is NumericHealthValue) {
        final value = (point.value as NumericHealthValue).numericValue.toInt();
        heartRates.add(value);
      }
    }

    return heartRates;
  }
}