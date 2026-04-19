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
  // REQUEST PERMISSION (ONLY ONCE)
  // =========================
  Future<bool> initPermissionOnce() async {
    await _initialize();

    if (_permissionGranted) return true;
    if (_isRequestingPermission) return _permissionGranted;

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

      final value =
          (point.value as NumericHealthValue).numericValue.toDouble();

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
  // COMMON FUNCTION (REUSE)
  // =========================
  Future<List<double>> _fetchHeartRateRaw({
    required DateTime start,
    required DateTime end,
  }) async {
    final data = await _health.getHealthDataFromTypes(
      startTime: start,
      endTime: end,
      types: [HealthDataType.HEART_RATE],
    );

    final seen = <String>{};

    return data
        .where((p) => p.value is NumericHealthValue)
        .where((p) {
          final key = "${p.type}_${p.dateFrom}_${p.dateTo}";
          if (seen.contains(key)) return false;
          seen.add(key);
          return true;
        })
        .map((p) =>
            (p.value as NumericHealthValue).numericValue.toDouble())
        .toList();
  }

  // =========================
  // AVERAGE HEART RATE
  // =========================
  Future<int?> fetchAverageHeartRate({int days = 7}) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - days);

    final values = await _fetchHeartRateRaw(start: start, end: now);

    if (values.isEmpty) return null;

    return (values.reduce((a, b) => a + b) / values.length).round();
  }

  // =========================
  // PEAK HEART RATE
  // =========================
  Future<int?> fetchPeakHeartRate({int days = 7}) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - days);

    final values = await _fetchHeartRateRaw(start: start, end: now);

    if (values.isEmpty) return null;

    return values.reduce((a, b) => a > b ? a : b).toInt();
  }

  // =========================
  // MIN HEART RATE
  // =========================
  Future<int?> fetchMinHeartRate({int days = 7}) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - days);

    final values = await _fetchHeartRateRaw(start: start, end: now);

    if (values.isEmpty) return null;

    return values.reduce((a, b) => a < b ? a : b).toInt();
  }

  // =========================
  // WEEKLY TREND
  // =========================
  Future<List<int?>> fetchWeeklyHeartRateTrend({int days = 7}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = <int?>[];

    for (var i = days - 1; i >= 0; i--) {
      final start = today.subtract(Duration(days: i));
      final end = start.add(const Duration(days: 1));

      final values = await _fetchHeartRateRaw(start: start, end: end);

      if (values.isEmpty) {
        result.add(null);
      } else {
        result.add(
            (values.reduce((a, b) => a + b) / values.length).round());
      }
    }

    return result;
  }

  // =========================
  // MONTHLY TREND
  // =========================
  Future<List<int?>> fetchMonthlyHeartRateTrend({int days = 30}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = <int?>[];

    for (var i = days - 1; i >= 0; i--) {
      final start = today.subtract(Duration(days: i));
      final end = start.add(const Duration(days: 1));

      final values = await _fetchHeartRateRaw(start: start, end: end);

      if (values.isEmpty) {
        result.add(null);
      } else {
        result.add(
            (values.reduce((a, b) => a + b) / values.length).round());
      }
    }

    return result;
  }

  // =========================
  // DAILY BREAKDOWN (HOURLY)
  // =========================
  Future<List<int?>> fetchDailyHeartRateBreakdown() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final data = await _health.getHealthDataFromTypes(
      startTime: start,
      endTime: end,
      types: [HealthDataType.HEART_RATE],
    );

    final buckets = <int, List<double>>{};
    final seen = <String>{};

    for (final point in data) {
      if (point.value is! NumericHealthValue) continue;

      final key = "${point.type}_${point.dateFrom}_${point.dateTo}";
      if (seen.contains(key)) continue;
      seen.add(key);

      final hour = point.dateFrom.hour;
      final value =
          (point.value as NumericHealthValue).numericValue.toDouble();

      buckets.putIfAbsent(hour, () => <double>[]).add(value);
    }

    return List<int?>.generate(24, (hour) {
      final values = buckets[hour];
      if (values == null || values.isEmpty) return null;

      final avg = values.reduce((a, b) => a + b) / values.length;
      return avg.round();
    });
  }

  // =========================
  // HELPER FOR FIREBASE FLOW
  // =========================
  Future<List<int?>> fetchAndPrepareDailyBreakdown() async {
    await initPermissionOnce();
    return await fetchDailyHeartRateBreakdown();
  }
}