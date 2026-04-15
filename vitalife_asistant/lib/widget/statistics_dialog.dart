// widgets/statistics_dialog.dart
import 'package:flutter/material.dart';
import 'package:vitalife_asistant/models/health_models_old.dart';


class StatisticsDialog extends StatelessWidget {
  final List<HealthReading> readings;

  const StatisticsDialog({super.key, required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return AlertDialog(
        title: const Text("Health Statistics"),
        content: const Text("No data available yet"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      );
    }

    final avgSystolic =
        readings.map((r) => r.systolic.toDouble()).reduce((a, b) => a + b) /
        readings.length;
    final avgDiastolic =
        readings.map((r) => r.diastolic.toDouble()).reduce((a, b) => a + b) /
        readings.length;
    final avgHeartRate =
        readings.map((r) => r.heartRate.toDouble()).reduce((a, b) => a + b) /
        readings.length;

    return AlertDialog(
      title: const Text("Health Statistics"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Average Systolic: ${avgSystolic.toStringAsFixed(1)}"),
          const SizedBox(height: 5),
          Text("Average Diastolic: ${avgDiastolic.toStringAsFixed(1)}"),
          const SizedBox(height: 5),
          Text("Average Heart Rate: ${avgHeartRate.toStringAsFixed(1)} bpm"),
          const SizedBox(height: 5),
          Text("Total Readings: ${readings.length}"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }

  static void show(BuildContext context, List<HealthReading> readings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatisticsDialog(readings: readings);
      },
    );
  }
}
