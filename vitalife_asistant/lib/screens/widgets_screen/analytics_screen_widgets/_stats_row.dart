import 'package:flutter/material.dart';
import 'package:vitalife_asistant/screens/widgets_screen/analytics_screen_widgets/_statcard.dart';


class StatsRow extends StatelessWidget {
  final String avgHr;
  final String peakHr;
  final String minHr;

  const StatsRow({
    super.key,
    required this.avgHr,
    required this.peakHr,
    required this.minHr,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Avg HR',
            value: avgHr,
            unit: 'bpm',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: 'Peak HR',
            value: peakHr,
            unit: 'bpm',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: 'Min HR',
            value: minHr,
            unit: 'bpm',
          ),
        ),
      ],
    );
  }
}