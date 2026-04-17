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

  // =========================
  // WEEKLY HEART RATE TREND
  // =========================
  Future<List<int?>> fetchWeeklyHeartRateTrend({int days = 7}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <int?>[];

    for (var i = days - 1; i >= 0; i--) {
      final dayStart = today.subtract(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));

      final data = await _health.getHealthDataFromTypes(
        startTime: dayStart,
        endTime: dayEnd,
        types: [HealthDataType.HEART_RATE],
      );

      final values = data
          .where((p) => p.value is NumericHealthValue)
          .map((p) => (p.value as NumericHealthValue).numericValue.toDouble())
          .toList();

      if (values.isEmpty) {
        result.add(null);
      } else {
        final avg = values.reduce((a, b) => a + b) / values.length;
        result.add(avg.round());
      }
    }

    return result;
  }

  // =========================
  // MONTHLY HEART RATE TREND
  // =========================
  Future<List<int?>> fetchMonthlyHeartRateTrend({int days = 30}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <int?>[];

    for (var i = days - 1; i >= 0; i--) {
      final dayStart = today.subtract(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));

      final data = await _health.getHealthDataFromTypes(
        startTime: dayStart,
        endTime: dayEnd,
        types: [HealthDataType.HEART_RATE],
      );

      final values = data
          .where((p) => p.value is NumericHealthValue)
          .map((p) => (p.value as NumericHealthValue).numericValue.toDouble())
          .toList();

      if (values.isEmpty) {
        result.add(null);
      } else {
        final avg = values.reduce((a, b) => a + b) / values.length;
        result.add(avg.round());
      }
    }

    return result;
  }

  // =========================
  // DAILY HEART RATE BREAKDOWN
  // =========================
  Future<List<int?>> fetchDailyHeartRateBreakdown() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final data = await _health.getHealthDataFromTypes(
      startTime: startOfDay,
      endTime: endOfDay,
      types: [HealthDataType.HEART_RATE],
    );

    final buckets = <int, List<double>>{};

    for (final point in data) {
      if (point.value is! NumericHealthValue) continue;

      final hour = point.dateFrom.hour;
      final value = (point.value as NumericHealthValue).numericValue.toDouble();
      buckets.putIfAbsent(hour, () => <double>[]).add(value);
    }

    return List<int?>.generate(24, (hour) {
      final values = buckets[hour];
      if (values == null || values.isEmpty) return null;
      final avg = values.reduce((a, b) => a + b) / values.length;
      return avg.round();
    });
  }
}
