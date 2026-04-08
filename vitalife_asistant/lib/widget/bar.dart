import 'package:flutter/widgets.dart';

/// Graph bar with proper height scaling based on blood pressure value
/// Lower bar = Good blood pressure (below 120)
/// Higher bar = High blood pressure (above 140)
Widget bar(double systolicValue, Color color, bool isSmallScreen) {
  // Calculate height based on systolic value (scale: 80-180 mmHg)
  double barHeight = _calculateBarHeight(systolicValue);

  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      // Value label above bar
      if (systolicValue > 0)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '${systolicValue.toInt()}',
            style: TextStyle(
              color: color,
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      // The bar
      Container(
        width: isSmallScreen ? 12 : 20,
        height: barHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ],
  );
}

/// Calculate bar height based on systolic value
/// Scale: 80 mmHg = 20px (very low bar - good)
///        120 mmHg = 60px (medium-low bar - normal)
///        140 mmHg = 100px (medium-high bar - elevated)
///        180 mmHg = 140px (very high bar - dangerous)
double _calculateBarHeight(double systolicValue) {
  if (systolicValue <= 0) return 0;

  // Min height for very low BP (80 mmHg)
  const minHeight = 20.0;
  // Max height for very high BP (180+ mmHg)
  const maxHeight = 140.0;
  // Min reference value (80 mmHg)
  const minValue = 80.0;
  // Max reference value (180 mmHg)
  const maxValue = 180.0;

  // Clamp value between min and max
  double clampedValue = systolicValue.clamp(minValue, maxValue);

  // Linear interpolation: height = minHeight + (value - minValue) * (maxHeight - minHeight) / (maxValue - minValue)
  double height =
      minHeight +
      (clampedValue - minValue) *
          (maxHeight - minHeight) /
          (maxValue - minValue);

  return height;
}
