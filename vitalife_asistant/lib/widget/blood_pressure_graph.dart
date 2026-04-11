import 'package:flutter/material.dart';
import 'package:vitalife_asistant/logic/health_utils.dart';

class BloodPressureGraph extends StatelessWidget {
  final Map<String, double> systolicReadings;
  final List<String> days;
  final VoidCallback onViewAll;

  const BloodPressureGraph({
    super.key,
    required this.systolicReadings,
    required this.days,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "7-DAY BLOOD PRESSURE TREND",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  "View All",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: isSmallScreen ? 200 : 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((day) {
                double systolicValue = systolicReadings[day] ?? 0;
                double barHeight = HealthUtils.calculateBarHeight(
                  systolicValue,
                );
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (systolicValue > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${systolicValue.toInt()}',
                          style: TextStyle(
                            color: HealthUtils.getBarColor(systolicValue),
                            fontSize: isSmallScreen ? 10 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Container(
                      width: isSmallScreen ? 12 : 20,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: HealthUtils.getBarColor(systolicValue),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          _buildDayLabels(isSmallScreen),
          const SizedBox(height: 5),
          _buildLegend(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildDayLabels(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) {
        final isToday = HealthUtils.isToday(day);
        return Column(
          children: [
            Text(
              day,
              style: TextStyle(
                color: isToday ? Colors.blue : Colors.white54,
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isToday)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLegend(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 10, height: 2, color: Colors.red),
            const SizedBox(width: 4),
            Text(
              "High",
              style: TextStyle(
                color: Colors.red,
                fontSize: isSmallScreen ? 8 : 10,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(width: 10, height: 2, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              "Normal",
              style: TextStyle(
                color: Colors.green,
                fontSize: isSmallScreen ? 8 : 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
