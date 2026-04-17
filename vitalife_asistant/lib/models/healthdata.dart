class HealthData {
  final int? heartRate;
  final int? spo2;
  final int steps;

  HealthData({
    required this.heartRate,
    required this.spo2,
    required this.steps,
  });

  factory HealthData.fromMap(Map<String, dynamic> map) {
    return HealthData(
      heartRate: map['heartRate'] as int?,
      spo2: map['spo2'] as int?,
      steps: map['steps'] ?? 0,
    );
  }

  // AI analyzes heart rate only.
  Map<String, dynamic> toGenkitInput() {
    return {
      "heartRate": heartRate ?? 0,
    };
  }
}