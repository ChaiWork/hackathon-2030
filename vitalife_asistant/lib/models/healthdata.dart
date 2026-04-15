class HealthData {
  final int? heartRate;
  final int? spo2;
  final int steps;

  // 🔥 NEW AI fields
  final int? systolic;
  final int? diastolic;
  final double? glucose;

  HealthData({
    required this.heartRate,
    required this.spo2,
    required this.steps,
    this.systolic,
    this.diastolic,
    this.glucose,
  });

  factory HealthData.fromMap(Map<String, dynamic> map) {
    return HealthData(
      heartRate: map['heartRate'] as int?,
      spo2: map['spo2'] as int?,
      steps: map['steps'] ?? 0,

      // AI fields
      systolic: map['systolic'] as int?,
      diastolic: map['diastolic'] as int?,
      glucose: (map['glucose'] as num?)?.toDouble(),
    );
  }

  // 🔥 CLEAN METHOD FOR GENKIT
  Map<String, dynamic> toGenkitInput() {
    return {
      "systolic": systolic ?? 120,
      "diastolic": diastolic ?? 80,
      "heartRate": heartRate ?? 0,
      "glucose": glucose ?? 5.5,
      "spo2": spo2 ?? 95,
    };
  }
}