// services/health_service.dart
import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();

  bool _permissionGranted = false;
  bool _isRequestingPermission = false;

  Future<void> _initialize() async {
    await _health.configure();
  }

  // =========================
  // 🔥 SAFE PERMISSION HANDLER (KEY FIX)
  // =========================
  Future<bool> _ensurePermission(List<HealthDataType> types) async {
    await _initialize();

    // already granted → skip
    if (_permissionGranted) return true;

    // prevent multiple simultaneous requests
    if (_isRequestingPermission) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _permissionGranted;
    }

    _isRequestingPermission = true;

    _permissionGranted = await _health.requestAuthorization(types);

    _isRequestingPermission = false;

    return _permissionGranted;
  }

  // =========================
  // FETCH DASHBOARD DATA
  // =========================
  Future<Map<String, dynamic>> fetchData() async {
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.STEPS,
    ];

    bool permission = await _ensurePermission(types);

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

      if (point.type == HealthDataType.HEART_RATE && heartRate == null) {
        heartRate = value;
      }

      if (point.type == HealthDataType.BLOOD_OXYGEN && spo2 == null) {
        spo2 = value;
      }

      if (point.type == HealthDataType.STEPS) {
        totalSteps += value.toInt();
      }
    }

    return {
      "heartRate": heartRate?.toInt(),
      "spo2": spo2?.toInt(),
      "steps": totalSteps,
      "lastUpdated": DateTime.now().toIso8601String(),
    };
  }

  // =========================
  // AVERAGE HEART RATE
  // =========================
  Future<int?> fetchAverageHeartRate({int days = 7}) async {
    final types = [HealthDataType.HEART_RATE];

    bool permission = await _ensurePermission(types);

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

    List<double> heartRates = [];

    for (var point in data) {
      if (point.value is NumericHealthValue) {
        heartRates.add(
          (point.value as NumericHealthValue).numericValue.toDouble(),
        );
      }
    }

    if (heartRates.isEmpty) return null;

    double sum = heartRates.reduce((a, b) => a + b);
    return (sum / heartRates.length).round();
  }

  // =========================
  // PEAK HEART RATE (MAX)
  // =========================
  Future<int?> fetchPeakHeartRate({int days = 7}) async {
    final types = [HealthDataType.HEART_RATE];

    bool permission = await _ensurePermission(types);

    if (!permission) {
      print("❌ Permission denied for peak heart rate");
      return null;
    }

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - days);

    final data = await _health.getHealthDataFromTypes(
      startTime: startDate,
      endTime: now,
      types: types,
    );

    List<double> hr = [];

    for (var point in data) {
      if (point.value is NumericHealthValue) {
        hr.add((point.value as NumericHealthValue).numericValue.toDouble());
      }
    }

    if (hr.isEmpty) return null;

    double peak = hr.reduce((a, b) => a > b ? a : b);

    return peak.toInt();
  }

  // =========================
  // MIN HEART RATE
  // =========================
  Future<int?> fetchMinHeartRate({int days = 7}) async {
    final types = [HealthDataType.HEART_RATE];

    bool permission = await _ensurePermission(types);

    if (!permission) {
      print("❌ Permission denied for min heart rate");
      return null;
    }

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - days);

    final data = await _health.getHealthDataFromTypes(
      startTime: startDate,
      endTime: now,
      types: types,
    );

    List<double> hr = [];

    for (var point in data) {
      if (point.value is NumericHealthValue) {
        hr.add((point.value as NumericHealthValue).numericValue.toDouble());
      }
    }

    if (hr.isEmpty) return null;

    double min = hr.reduce((a, b) => a < b ? a : b);

    return min.toInt();
  }

  // =========================
  // HEART RATE HISTORY
  // =========================
  Future<List<int>> fetchHeartRateHistory({int days = 7}) async {
    final types = [HealthDataType.HEART_RATE];

    bool permission = await _ensurePermission(types);

    if (!permission) return [];

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - days);

    final data = await _health.getHealthDataFromTypes(
      startTime: startDate,
      endTime: now,
      types: types,
    );

    return data
        .where((p) => p.value is NumericHealthValue)
        .map((p) => (p.value as NumericHealthValue).numericValue.toInt())
        .toList();
  }
}
