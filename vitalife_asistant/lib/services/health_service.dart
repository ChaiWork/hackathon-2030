import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();

  bool _permissionGranted = false;
  bool _isRequestingPermission = false;

  // =========================
  // INIT
  // =========================
  Future<void> _initialize() async {
    await _health.configure();
  }

  // =========================
  // 🔥 REQUEST PERMISSION ONLY ONCE
  // =========================
  Future<bool> initPermissionOnce() async {
    await _initialize();

    if (_permissionGranted) return true;

    if (_isRequestingPermission) {
      return _permissionGranted;
    }

    _isRequestingPermission = true;

    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.STEPS,
    ];

    _permissionGranted = await _health.requestAuthorization(types);

    _isRequestingPermission = false;

    return _permissionGranted;
  }

  // =========================
  // FETCH DASHBOARD DATA
  // =========================
  Future<Map<String, dynamic>> fetchData() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final data = await _health.getHealthDataFromTypes(
      startTime: startOfDay,
      endTime: now,
      types: [
        HealthDataType.HEART_RATE,
        HealthDataType.BLOOD_OXYGEN,
        HealthDataType.STEPS,
      ],
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
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - days);

    final data = await _health.getHealthDataFromTypes(
      startTime: startDate,
      endTime: now,
      types: [HealthDataType.HEART_RATE],
    );

    final hr = data
        .where((p) => p.value is NumericHealthValue)
        .map((p) => (p.value as NumericHealthValue).numericValue.toDouble())
        .toList();

    if (hr.isEmpty) return null;

    final sum = hr.reduce((a, b) => a + b);
    return (sum / hr.length).round();
  }

  // =========================
  // PEAK HEART RATE
  // =========================
  Future<int?> fetchPeakHeartRate({int days = 7}) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - days);

    final data = await _health.getHealthDataFromTypes(
      startTime: startDate,
      endTime: now,
      types: [HealthDataType.HEART_RATE],
    );

    final hr = data
        .where((p) => p.value is NumericHealthValue)
        .map((p) => (p.value as NumericHealthValue).numericValue.toDouble())
        .toList();

    if (hr.isEmpty) return null;

    return hr.reduce((a, b) => a > b ? a : b).toInt();
  }

  // =========================
  // MIN HEART RATE
  // =========================
  Future<int?> fetchMinHeartRate({int days = 7}) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - days);

    final data = await _health.getHealthDataFromTypes(
      startTime: startDate,
      endTime: now,
      types: [HealthDataType.HEART_RATE],
    );

    final hr = data
        .where((p) => p.value is NumericHealthValue)
        .map((p) => (p.value as NumericHealthValue).numericValue.toDouble())
        .toList();

    if (hr.isEmpty) return null;

    return hr.reduce((a, b) => a < b ? a : b).toInt();
  }

  // =========================
  // HEART RATE HISTORY
  // =========================
  Future<List<int>> fetchHeartRateHistory({int days = 7}) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - days);

    final data = await _health.getHealthDataFromTypes(
      startTime: startDate,
      endTime: now,
      types: [HealthDataType.HEART_RATE],
    );

    return data
        .where((p) => p.value is NumericHealthValue)
        .map((p) => (p.value as NumericHealthValue).numericValue.toInt())
        .toList();
  }
}
