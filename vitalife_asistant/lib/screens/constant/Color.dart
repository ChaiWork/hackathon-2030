// constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryLight = Color(0xFFE7ECFF);
  static const Color primaryMedium = Color(0xFFD8E1FF);
  static const Color primaryDark = Color(0xFFA8BCFB);
  static const Color primaryDeep = Color(0xFF7EA0EA);

  // Secondary Colors
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Gradients
  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFC62828)], // Red 600, Red 800
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // With Opacity Helpers
  static Color getPrimaryWithOpacity(double opacity) {
    return primaryDeep.withOpacity(opacity);
  }

  static Color getErrorWithOpacity(double opacity) {
    return error.withOpacity(opacity);
  }

  static Color getSuccessWithOpacity(double opacity) {
    return success.withOpacity(opacity);
  }
}

// Alternative: If you prefer individual constants
const Color colorPrimaryLight = Color(0xFFE7ECFF);
const Color colorPrimaryMedium = Color(0xFFD8E1FF);
const Color colorPrimaryDark = Color(0xFFA8BCFB);
const Color colorPrimaryDeep = Color(0xFF7EA0EA);
