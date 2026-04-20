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
    final size = MediaQuery.sizeOf(context);
    final gap = (size.width * 0.03).clamp(8.0, 16.0);

    final row = Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Avg HR',
            value: avgHr,
            unit: 'bpm',
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: StatCard(
            label: 'Peak HR',
            value: peakHr,
            unit: 'bpm',
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: StatCard(
            label: 'Min HR',
            value: minHr,
            unit: 'bpm',
          ),
        ),
      ],
    );

    // Preserves the row layout; on very narrow screens we allow horizontal scroll
    // instead of letting cards overflow.
    return LayoutBuilder(
      builder: (context, constraints) {
        final minCardWidth =
            (constraints.maxWidth * 0.32).clamp(120.0, 180.0);
        final minNeeded = 3 * minCardWidth + 2 * gap;
        final shouldScroll = constraints.maxWidth < minNeeded;

        if (!shouldScroll) return row;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minNeeded),
            child: Row(
              children: [
                SizedBox(
                  width: minCardWidth,
                  child: StatCard(label: 'Avg HR', value: avgHr, unit: 'bpm'),
                ),
                SizedBox(width: gap),
                SizedBox(
                  width: minCardWidth,
                  child: StatCard(label: 'Peak HR', value: peakHr, unit: 'bpm'),
                ),
                SizedBox(width: gap),
                SizedBox(
                  width: minCardWidth,
                  child: StatCard(label: 'Min HR', value: minHr, unit: 'bpm'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}