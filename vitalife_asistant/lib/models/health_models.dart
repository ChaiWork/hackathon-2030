class HealthReading {
  final String date;
  final String day;
  final int systolic;
  final int diastolic;
  final int heartRate;
  final double glucose;
  final int spo2;

  HealthReading({
    required this.date,
    required this.day,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.glucose,
    required this.spo2,
  });

  String get bloodPressure => "$systolic/$diastolic";
  String get heartRateFormatted => "$heartRate bpm";
  String get glucoseFormatted => "$glucose mmol";
  String get spo2Formatted => "$spo2 %";

  Map<String, dynamic> toMap() => {
    'date': date,
    'day': day,
    'systolic': systolic,
    'diastolic': diastolic,
    'heartRate': heartRate,
    'glucose': glucose,
    'spo2': spo2,
  };
}

class HealthMetrics {
  final String bloodPressure;
  final int heartRate;
  final String bloodGlucose;
  final int spo2;

  HealthMetrics({
    required this.bloodPressure,
    required this.heartRate,
    required this.bloodGlucose,
    required this.spo2,
  });
}
