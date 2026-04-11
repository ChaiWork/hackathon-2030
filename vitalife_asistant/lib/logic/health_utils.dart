import 'package:flutter/material.dart';

class HealthUtils {
  static String getCurrentDay() {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final now = DateTime.now();
    return days[now.weekday - 1];
  }

  static String getCurrentDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }

  static bool isToday(String day) => day == getCurrentDay();

  static bool isBloodPressureHigh(String bp) {
    try {
      final parts = bp.split('/');
      if (parts.length == 2) {
        return int.parse(parts[0]) > 130;
      }
    } catch (e) {}
    return false;
  }

  static double calculateBarHeight(double systolicValue) {
    if (systolicValue <= 0) return 0;
    const minHeight = 20.0;
    const maxHeight = 140.0;
    const minValue = 80.0;
    const maxValue = 180.0;
    double clampedValue = systolicValue.clamp(minValue, maxValue);
    return minHeight +
        (clampedValue - minValue) *
            (maxHeight - minHeight) /
            (maxValue - minValue);
  }

  // Color getters
  static Color getBloodPressureColor(String bp) {
    try {
      final systolic = int.parse(bp.split('/')[0]);
      if (systolic < 120) return Colors.green;
      if (systolic < 130) return Colors.orange;
      return Colors.red;
    } catch (e) {
      return Colors.red;
    }
  }

  static Color getHeartRateColor(String hr) {
    try {
      final value = int.parse(hr.split(' ')[0]);
      return (value >= 60 && value <= 100) ? Colors.green : Colors.orange;
    } catch (e) {
      return Colors.green;
    }
  }

  static Color getGlucoseColor(String glucose) {
    try {
      final value = double.parse(glucose.split(' ')[0]);
      return (value >= 4.0 && value <= 7.0) ? Colors.green : Colors.orange;
    } catch (e) {
      return Colors.orange;
    }
  }

  static Color getSpO2Color(String spo2Value) {
    try {
      final value = int.parse(spo2Value.split(' ')[0]);
      return (value >= 95) ? Colors.green : Colors.orange;
    } catch (e) {
      return Colors.green;
    }
  }

  static Color getBarColor(double value) {
    if (value < 120) return Colors.green;
    if (value < 130) return Colors.lightGreen;
    if (value < 140) return Colors.orange;
    if (value < 160) return Colors.deepOrange;
    return Colors.red;
  }
}
