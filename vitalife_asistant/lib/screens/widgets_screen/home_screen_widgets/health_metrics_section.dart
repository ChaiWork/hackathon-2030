import 'package:flutter/material.dart';
import 'package:vitalife_asistant/screens/widgets_screen/home_screen_widgets/_buildHealthCard.dart';
import 'package:vitalife_asistant/ui/responsive.dart';

class HealthMetricsSection extends StatelessWidget {
  final int? currentHeartRate;
  final int? averageHeartRate;
  final String riskLevel;

  const HealthMetricsSection({
    required this.currentHeartRate,
    required this.averageHeartRate,
    required this.riskLevel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final cardGap = r.gapH(0.025, min: 8, max: 12);

    return LayoutBuilder(
      builder: (context, constraints) {
        final minCardW = r.clamp(constraints.maxWidth * 0.30, 120, 200);
        final minNeeded = 3 * minCardW + 2 * cardGap;
        final shouldScroll = constraints.maxWidth < minNeeded;

        final cards = [
          HealthCard(
            title: 'Current',
            value: '${currentHeartRate ?? "--"}',
            unit: 'bpm',
            icon: Icons.favorite,
            color: Colors.red,
          ),
          HealthCard(
            title: 'Average',
            value: '${averageHeartRate ?? "--"}',
            unit: 'bpm',
            icon: Icons.trending_up,
            color: Colors.blue,
          ),
          HealthCard(
            title: 'Risk',
            value: riskLevel,
            unit: '',
            icon: Icons.security,
            color: Colors.orange,
          ),
        ];

        if (!shouldScroll) {
          return Row(
            children: [
              Expanded(child: cards[0]),
              SizedBox(width: cardGap),
              Expanded(child: cards[1]),
              SizedBox(width: cardGap),
              Expanded(child: cards[2]),
            ],
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minNeeded),
            child: Row(
              children: [
                SizedBox(width: minCardW, child: cards[0]),
                SizedBox(width: cardGap),
                SizedBox(width: minCardW, child: cards[1]),
                SizedBox(width: cardGap),
                SizedBox(width: minCardW, child: cards[2]),
              ],
            ),
          ),
        );
      },
    );
  }
}
